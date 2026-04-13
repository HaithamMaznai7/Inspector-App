import 'package:fahis_inspector/common/widgets/skeletons/skeleton.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:fahis_inspector/util/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:fahis_inspector/util/constants/colors.dart';

class OnLoadingInspections extends StatelessWidget {
  const OnLoadingInspections({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 3,
      itemBuilder: (BuildContext context, int index) {
        return const PlaceHolderRequestCard();
      },
    );
  }
}

class PlaceHolderRequestCard extends StatelessWidget {
  const PlaceHolderRequestCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = FHelper.isDarkMode(context);
    return InkWell(
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: FSizes.imagePreviewSm + FSizes.iconInlineSm,
        child: Card(
          color: isDark ? FColors.black : Colors.white,
          child: const Padding(
            padding: EdgeInsets.fromLTRB(FSizes.defaultSpace, FSizes.borderRadiusLg, FSizes.defaultSpace, FSizes.borderRadiusLg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Skeleton(width: 30, color: FColors.primaryColor),
                    Flexible(child: Skeleton(width: 180, color: FColors.grey)),
                    Skeleton(width: 80, color: FColors.grey),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Skeleton(width: 30, color: FColors.primaryColor),
                    Flexible(child: Skeleton(width: 180, color: FColors.grey)),
                    Skeleton(width: 100, color: FColors.grey),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[Skeleton(width: 120, color: FColors.grey)],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
