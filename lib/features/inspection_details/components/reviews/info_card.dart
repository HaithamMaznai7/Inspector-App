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
  });

  final IconData? icon;
  final Widget title;
  final double tilePadding;
  final Widget? leading;
  final Widget? subtitle;
  final Widget? trailing;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: title,
      subtitle: subtitle,
      initiallyExpanded: true,
      trailing: trailing,
      childrenPadding: EdgeInsets.symmetric(
        horizontal: FSizes.xl,
        vertical: FSizes.md,
      ),
      leading: icon != null ? Icon(icon) : leading,
      dense: true,
      iconColor: FColors.primaryColor,
      clipBehavior: Clip.antiAlias,
      splashColor: FColors.grey,
      enabled: true,
      shape: Border(
        bottom: BorderSide.none,
        top: BorderSide.none,
        left: BorderSide.none,
        right: BorderSide.none
      ), 
      // leading: TextButton(
      //   onPressed: () {},
      //   child: Text(
      //     'Edit',
      //     style: Theme.of(
      //       context,
      //     ).textTheme.labelLarge!.copyWith(color: FColors.warning),
      //   ),
      // ),
      tilePadding: EdgeInsets.symmetric(
        horizontal: FSizes.md,
        vertical: FSizes.sm
      ),
      children: children,
    );
  }

  static List<Widget> initializeInfo(Map<String, dynamic> data) {
    final List<Widget> rows = [];
    List<Widget> rowChildren = [];

    int index = 0;

    data.forEach((key, value) {
      rowChildren.add(
        Expanded(
          child: RichText(
            overflow: TextOverflow.ellipsis,
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
      );

      index++;

      if (rowChildren.length == 3 || index == data.length) {
        rows.add(
          Padding(
            padding: const EdgeInsets.only(bottom: FSizes.sm),
            child: Row(children: rowChildren),
          ),
        );
        rowChildren = [];
      }
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
