import 'package:fahis_inspector/Common/widget/skeleton.dart';
import 'package:fahis_inspector/util/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:fahis_inspector/util/constants/colors.dart';

class OnLoadingHomePage extends StatelessWidget {
  const OnLoadingHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 10,
      itemBuilder: (BuildContext context, int index) {
        return const PlaceHolderRequestCard();
      },
    );
  }
}

class PlaceHolderRequestCard extends StatelessWidget{
  const PlaceHolderRequestCard({super.key});

  @override
  Widget build(BuildContext context){
    // TODO: implement build
    final isDark = FHelper.isDarkMode(context);
    return InkWell(
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: 140.0,
        child: Card(
          color: isDark ? FColors.black : Colors.white,
          child: const Padding(
            padding: EdgeInsets.fromLTRB(25, 15, 25, 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Skeleton(width: 30,color: FColors.primaryColor),
                    Flexible(
                      child: Skeleton(width: 180,color: FColors.grey),
                    ),
                    Skeleton(width: 80,color: FColors.grey),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Skeleton(width: 30,color: FColors.primaryColor),
                    Flexible(
                      child: Skeleton(width: 180,color: FColors.grey),
                    ),
                    Skeleton(width: 100,color: FColors.grey),
                  ],
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Skeleton(width: 120,color: FColors.grey),
                    ]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}