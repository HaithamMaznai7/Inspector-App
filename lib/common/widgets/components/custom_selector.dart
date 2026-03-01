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

    if (oldWidget.value != widget.value ||
        oldWidget.items != widget.items) {
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          widget.title ?? 'Select Field',
          style: Theme.of(context).textTheme.titleLarge,
          textAlign: TextAlign.right,
        ),
        GestureDetector(
          onTap: _openMenuToggle,
          child: Container(
            decoration: BoxDecoration(
              color: isDark
                  ? FColors.darkGrey.withValues(alpha: .2)
                  : FColors.grey.withValues(alpha: .8),
              borderRadius: widget.borderRadius,
            ),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(width: 1, color: FColors.grey),
                borderRadius: widget.borderRadius ?? BorderRadius.circular(10),
                color: isDark ? FColors.darkerGrey : FColors.white,
              ),
              child: ListTile(
                title: Text(_value?.label ?? (widget.title ?? '')),
                trailing: Icon(
                  Iconsax.arrow_down_1,
                  color: FColors.primaryColor,
                ),
              ),
            ),
          ),
        ),
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
          constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.4),
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
