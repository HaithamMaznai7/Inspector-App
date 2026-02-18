import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class InfoCard extends StatelessWidget {
  const InfoCard({
    super.key,
    required this.title,
    this.subtitle,
    this.tilePadding = 0,
    this.icon,
    this.iconColor,
    this.cardColor,
    this.leading,
    this.trailing,
    this.children = const [],
    this.initiallyExpanded = false,
    this.showCard = true,
    this.onEdit,
  });

  final IconData? icon;
  final Color? iconColor;
  final Color? cardColor;
  final Widget title;
  final double tilePadding;
  final Widget? leading;
  final Widget? subtitle;
  final Widget? trailing;
  final List<Widget> children;
  final bool initiallyExpanded;
  final bool showCard;
  /// When provided, shows a compact edit icon in the card header.
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    // Wrap title with edit icon when onEdit is provided
    final titleWidget = onEdit != null
        ? Row(
            children: [
              Expanded(child: title),
              GestureDetector(
                onTap: onEdit,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: FColors.primaryColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Iconsax.edit_2,
                    size: 16,
                    color: FColors.primaryColor,
                  ),
                ),
              ),
            ],
          )
        : title;

    final expansionTile = ExpansionTile(
      title: titleWidget,
      subtitle: subtitle,
      initiallyExpanded: initiallyExpanded,
      trailing: trailing,
      childrenPadding: EdgeInsets.symmetric(
        horizontal: FSizes.md,
        vertical: FSizes.md,
      ),
      leading: icon != null ? Icon(icon, color: iconColor) : leading,
      dense: true,
      iconColor: iconColor ?? FColors.primaryColor,
      clipBehavior: Clip.antiAlias,
      splashColor: FColors.grey.withOpacity(0.3),
      enabled: true,
      shape: Border(
        bottom: BorderSide.none,
        top: BorderSide.none,
        left: BorderSide.none,
        right: BorderSide.none
      ),
      collapsedShape: Border(
        bottom: BorderSide.none,
        top: BorderSide.none,
        left: BorderSide.none,
        right: BorderSide.none
      ),
      tilePadding: EdgeInsets.symmetric(
        horizontal: FSizes.md,
        vertical: FSizes.sm
      ),
      children: children,
    );

    if (!showCard) {
      return expansionTile;
    }

    return Card(
      margin: EdgeInsets.symmetric(
        horizontal: FSizes.md,
        vertical: FSizes.sm,
      ),
      elevation: 2,
      shadowColor: FColors.grey.withOpacity(0.5),
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
      ),
      child: expansionTile,
    );
  }

  static List<Widget> initializeInfo(Map<String, dynamic> data) {
    final List<Widget> rows = [];

    data.forEach((key, value) {
      rows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: FSizes.sm),
          child: Row(
            children: [
              Expanded(
                child: RichText(
                  textAlign: TextAlign.start,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  text: TextSpan(
                    style: Theme.of(Get.context!).textTheme.bodyLarge,
                    children: [
                      TextSpan(text: '$key: '),
                      TextSpan(
                        text: value?.toString() ?? '-',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });

    return rows;
  }

  static InfoCard fromMap({
    required Widget title,
    Widget? subtitle,
    double tilePadding = 0,
    IconData? icon,
    Widget? trailing,
    bool initiallyExpanded = false,
    Map<String, dynamic> items = const {},
    VoidCallback? onEdit,
  }) {
    return InfoCard(
      title: title,
      subtitle: subtitle,
      tilePadding: tilePadding,
      icon: icon,
      trailing: trailing,
      initiallyExpanded: initiallyExpanded,
      onEdit: onEdit,
      children: initializeInfo(items).toList(),
    );
  }

}
