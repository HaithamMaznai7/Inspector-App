import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InfoCard extends StatelessWidget {
  const InfoCard({
    super.key,
    required this.title,
    this.subtitle,
    this.tilePadding = 0,
    this.icon,
    this.leading,
    this.trailing,
    this.children = const [],
    this.initiallyExpanded = true,
    this.showCard = true,
  });

  final IconData? icon;
  final Widget title;
  final double tilePadding;
  final Widget? leading;
  final Widget? subtitle;
  final Widget? trailing;
  final List<Widget> children;
  final bool initiallyExpanded;
  final bool showCard;

  @override
  Widget build(BuildContext context) {
    final expansionTile = ExpansionTile(
      title: title,
      subtitle: subtitle,
      initiallyExpanded: initiallyExpanded,
      trailing: trailing,
      childrenPadding: EdgeInsets.symmetric(
        horizontal: FSizes.md,
        vertical: FSizes.md,
      ),
      leading: icon != null ? Icon(icon) : leading,
      dense: true,
      iconColor: FColors.primaryColor,
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
    Map<String, dynamic> items = const {},
  }) {
    return InfoCard(
      title: title,
      subtitle: subtitle,
      tilePadding: tilePadding,
      icon: icon,
      trailing: trailing,
      children: initializeInfo(items).toList(),
    );
  }

}
