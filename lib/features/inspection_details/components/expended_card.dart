import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:fahis_inspector/util/helpers/helper_functions.dart';
import 'package:flutter/material.dart';

class ExpandedCard extends StatefulWidget {
  const ExpandedCard({super.key, this.title = '', this.content = const SizedBox()});
  final String title;
  final Widget content;

  @override
  State<ExpandedCard> createState() => _ExpandedCardState();
}

class _ExpandedCardState extends State<ExpandedCard> {

  bool _cardSizeStatus = true;
  void cardSizeToggle() => setState(() {
    _cardSizeStatus = !_cardSizeStatus ;
  });

  @override
  Widget build(BuildContext context) {
    final isDark = FHelper.isDarkMode(context);

    return InkWell(
      onTap: cardSizeToggle,
      child: Card(
        shadowColor: Colors.white,
        color: isDark ? FColors.darkGrey.withValues(alpha: .2) : FColors.grey,
        elevation: 0,
        child: AnimatedContainer(
            padding: const EdgeInsets.symmetric(vertical: FSizes.lg, horizontal: FSizes.md),
            duration: const Duration(milliseconds: 500),
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(widget.title, style:Theme.of(context).textTheme.titleLarge),
                    Icon(_cardSizeStatus ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down)
                  ],
                ),
                AnimatedSize(
                  clipBehavior: Clip.none,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOut ,
                  child: SizedBox(
                      height: _cardSizeStatus ? 0 : null,
                      child: widget.content
                  ),
                )
              ],
            )
        ),
      ),
    );
  }
}