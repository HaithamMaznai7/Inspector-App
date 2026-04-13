import 'package:fahis_inspector/models/selection.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

// abstract class Selectable {
//   bool isEquel();
//   bool getLabel();
// }

class CustomSelector extends StatefulWidget {
  const CustomSelector({
    super.key,
    this.title,
    required this.items,
    this.borderRadius = const BorderRadius.all(Radius.circular(10)),
    required this.value,
    required this.onChanged,
    this.enable = true,
    this.error,
  });

  final String? title;
  final Function(Selection?) onChanged;
  final List<Selection> items;
  final BorderRadius? borderRadius;
  final String? value;
  final String? error;
  final bool enable;

  @override
  State<CustomSelector> createState() => _CustomSelector();
}

class _CustomSelector extends State<CustomSelector> {
  bool openMenu = false;
  Selection? _value;

  @override
  void initState() {
    super.initState();
    _value =
        widget.items.where((item) => item.value == widget.value).firstOrNull ??
        Selection.empty();
  }

  @override
  void didUpdateWidget(covariant CustomSelector oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.value != widget.value || oldWidget.items != widget.items) {
      setState(() {
        _value =
            widget.items
                .where((item) => item.value == widget.value)
                .firstOrNull ??
            Selection.empty();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = FHelper.isDarkMode(context);
    final hasError = widget.error != null && widget.error!.isNotEmpty;
    final hasValue =
        _value != null && _value!.value != null && _value!.value!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          widget.title ?? 'Select Field',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: _openMenuToggle,
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? FColors.darkerGrey : FColors.white,
              borderRadius: widget.borderRadius ?? BorderRadius.circular(10),
              border: Border.all(
                width: hasError ? 1.5 : 1,
                color: hasError
                    ? FColors.error
                    : isDark
                    ? FColors.grey.withValues(alpha: 0.3)
                    : FColors.grey,
              ),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 0,
              ),
              title: Text(
                _value?.label ?? (widget.title ?? ''),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: hasValue ? FontWeight.w500 : FontWeight.normal,
                  color: hasValue
                      ? null
                      : (isDark ? FColors.darkGrey : FColors.darkGrey),
                ),
              ),
              trailing: Icon(
                Iconsax.arrow_down_1,
                size: 18,
                color: FColors.primaryColor,
              ),
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(right: 12, left: 12),
            child: Text(
              widget.error!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: FColors.error,
                fontStyle: FontStyle.normal,
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _openMenuToggle() {
    final isDark = FHelper.isDarkMode(context);

    if (!widget.enable) return;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: isDark
          ? FColors.darkerGrey.withValues(alpha: .95)
          : FColors.white.withValues(alpha: .95),
      builder: (context) {
        return ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.4,
          ),
          child: ListView.separated(
            shrinkWrap: true,
            separatorBuilder: (context, index) {
              return Divider();
            },
            itemCount: widget.items.length,
            itemBuilder: (context, index) {
              final item = widget.items[index];
              return ListTile(
                title: Center(child: Text(item.label)),
                onTap: () {
                  Navigator.of(context).pop(); // Close the sheet
                  widget.onChanged(item);
                  setState(() {
                    _value = item;
                    openMenu = false;
                  });
                },
              );
            },
          ),
        );
      },
    );
  }
}
