import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:fahis_inspector/util/constants/vehicle_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

/// A labeled selector that opens a bottom-sheet color picker.
///
/// Stores the selected **English** color name in [controller] so the value
/// is locale-independent for the backend. The button and sheet display the
/// localized name based on the current app locale.
///
/// Listens to [controller] so the button updates immediately after the
/// bottom sheet selection, including when VIN auto-fill populates the field.
class ColorPickerField extends StatefulWidget {
  final String label;
  final List<VehicleColor> colors;
  final TextEditingController controller;
  final String? errorText;
  final VoidCallback? onChanged;

  const ColorPickerField({
    super.key,
    required this.label,
    required this.colors,
    required this.controller,
    this.errorText,
    this.onChanged,
  });

  @override
  State<ColorPickerField> createState() => _ColorPickerFieldState();
}

class _ColorPickerFieldState extends State<ColorPickerField> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_rebuild);
  }

  @override
  void didUpdateWidget(ColorPickerField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_rebuild);
      widget.controller.addListener(_rebuild);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final matched = VehicleColors.find(widget.colors, widget.controller.text);
    final displayValue =
        matched?.localizedName ??
        (widget.controller.text.trim().isNotEmpty
            ? widget.controller.text.trim()
            : null);
    final swatch = matched != null
        ? VehicleColors.swatches[matched.english]
        : null;
    final hasError = widget.errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Label ─────────────────────────────────────────────────────────
        Text(
          widget.label,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: FSizes.xs),

        // ── Selector button ───────────────────────────────────────────────
        GestureDetector(
          onTap: () => _openSheet(context, widget.label, widget.colors),
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: FSizes.borderRadiusLg,
              vertical: FSizes.borderRadiusLg,
            ),
            decoration: BoxDecoration(
              color: isDark ? FColors.darkerGrey : FColors.white,
              borderRadius: BorderRadius.circular(FSizes.inputFieldRadius),
              border: Border.all(
                color: hasError
                    ? FColors.error
                    : isDark
                    ? FColors.grey.withValues(alpha: 0.3)
                    : FColors.grey,
              ),
            ),
            child: Row(
              children: [
                // Color swatch circle
                if (swatch != null) ...[
                  _Swatch(color: swatch, size: FSizes.iconMd),
                  const SizedBox(width: FSizes.sm),
                ],

                // Display value or hint
                Expanded(
                  child: Text(
                    displayValue ?? 'colorSelectHint'.tr,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: displayValue != null
                          ? (isDark ? FColors.light : FColors.dark)
                          : FColors.darkGrey,
                    ),
                  ),
                ),

                Icon(
                  Iconsax.arrow_down_1,
                  size: FSizes.iconSm,
                  color: FColors.primaryColor,
                ),
              ],
            ),
          ),
        ),

        // ── Error text ────────────────────────────────────────────────────
        if (hasError) ...[
          const SizedBox(height: FSizes.xs),
          Padding(
            padding: const EdgeInsets.only(left: FSizes.xs),
            child: Text(
              widget.errorText!,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: FColors.error),
            ),
          ),
        ],
      ],
    );
  }

  void _openSheet(
    BuildContext context,
    String label,
    List<VehicleColor> colors,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (_) => _ColorSheet(
        title: label,
        colors: colors,
        selectedValue: widget.controller.text.trim(),
        onSelected: (color) {
          widget.controller.text = color.english;
          widget.onChanged?.call();
        },
      ),
    );
  }
}

// ── Bottom sheet ──────────────────────────────────────────────────────────────

class _ColorSheet extends StatefulWidget {
  final String title;
  final List<VehicleColor> colors;
  final String selectedValue;
  final ValueChanged<VehicleColor> onSelected;

  const _ColorSheet({
    required this.title,
    required this.colors,
    required this.selectedValue,
    required this.onSelected,
  });

  @override
  State<_ColorSheet> createState() => _ColorSheetState();
}

class _ColorSheetState extends State<_ColorSheet> {
  final _searchController = TextEditingController();
  List<VehicleColor> _filtered = [];

  @override
  void initState() {
    super.initState();
    _filtered = widget.colors;
    _searchController.addListener(_onSearch);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filtered = widget.colors;
      } else {
        _filtered = widget.colors
            .where(
              (c) =>
                  c.english.toLowerCase().contains(query) ||
                  c.arabic.contains(query),
            )
            .toList();
      }
    });
  }

  bool _isSelected(VehicleColor c) =>
      c.english.toLowerCase() == widget.selectedValue.toLowerCase() ||
      c.arabic == widget.selectedValue;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    // DraggableScrollableSheet lets the user pull the sheet up/down and
    // hands its own ScrollController to the ListView, preventing overflow
    // on any screen height — phones, small phones, tablets, landscape mode.
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.35,
      maxChildSize: 0.92,
      expand: false,
      builder: (_, scrollController) => Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(FSizes.cardRadiusLg),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Handle ──────────────────────────────────────────────────
            Center(
              child: Padding(
                padding: const EdgeInsets.only(
                  top: FSizes.borderRadiusLg,
                  bottom: FSizes.md,
                ),
                child: SizedBox(width: FSizes.xl, height: FSizes.xs),
              ),
            ),

            // ── Title ────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                FSizes.spaceBtwItems,
                0,
                FSizes.spaceBtwItems,
                FSizes.borderRadiusLg,
              ),
              child: Text(
                widget.title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),

            // ── Search bar ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                FSizes.spaceBtwItems,
                0,
                FSizes.spaceBtwItems,
                FSizes.sm,
              ),
              child: TextField(
                controller: _searchController,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  isDense: true,
                  filled: true,
                  fillColor: isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : FColors.grey.withValues(alpha: 0.12),
                  hintText: 'colorSearchHint'.tr,
                  hintStyle: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: FColors.darkGrey),
                  prefixIcon: Icon(
                    Iconsax.search_normal_1,
                    size: FSizes.iconSm,
                    color: FColors.darkGrey,
                  ),
                  suffixIcon: ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _searchController,
                    builder: (_, value, _) {
                      if (value.text.isEmpty) return const SizedBox.shrink();
                      return GestureDetector(
                        onTap: () => _searchController.clear(),
                        child: Icon(
                          Icons.close_rounded,
                          size: FSizes.iconSm,
                          color: FColors.darkGrey,
                        ),
                      );
                    },
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: FSizes.md,
                    vertical: FSizes.sm,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
                    borderSide: const BorderSide(
                      color: FColors.primaryColor,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),

            Divider(height: 1, color: FColors.grey.withValues(alpha: 0.3)),

            // ── Scrollable color list ────────────────────────────────────
            Expanded(
              child: _filtered.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(FSizes.spaceBtwSections),
                        child: Text(
                          'colorSearchEmpty'.tr,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: FColors.darkGrey),
                        ),
                      ),
                    )
                  : ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.only(
                        top: FSizes.xs,
                        bottom: FSizes.md,
                      ),
                      itemCount: _filtered.length,
                      separatorBuilder: (_, _) => Divider(
                        height: 1,
                        indent: 20,
                        endIndent: 20,
                        color: FColors.grey.withValues(alpha: 0.15),
                      ),
                      itemBuilder: (_, i) {
                        final c = _filtered[i];
                        final selected = _isSelected(c);
                        final swatch = VehicleColors.swatches[c.english];

                        return InkWell(
                          onTap: () {
                            widget.onSelected(c);
                            Navigator.pop(context);
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: FSizes.spaceBtwItems,
                              vertical: FSizes.borderRadiusLg,
                            ),
                            child: Row(
                              children: [
                                _Swatch(
                                  color: swatch ?? Colors.transparent,
                                  size: FSizes.iconInlineMd,
                                  showBorder: true,
                                ),
                                const SizedBox(width: FSizes.borderRadiusLg),
                                Expanded(
                                  child: Text(
                                    c.localizedName,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          fontWeight: selected
                                              ? FontWeight.w700
                                              : FontWeight.w400,
                                          color: selected
                                              ? FColors.primaryColor
                                              : null,
                                        ),
                                  ),
                                ),
                                if (selected)
                                  const Icon(
                                    Icons.check_rounded,
                                    color: FColors.primaryColor,
                                    size: FSizes.iconInlineSm,
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Color swatch circle ───────────────────────────────────────────────────────

class _Swatch extends StatelessWidget {
  final Color color;
  final double size;
  final bool showBorder;

  const _Swatch({
    required this.color,
    required this.size,
    this.showBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.black.withValues(alpha: showBorder ? 0.12 : 0.08),
          width: 1,
        ),
      ),
    );
  }
}
