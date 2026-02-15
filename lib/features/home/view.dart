import 'package:fahis_inspector/common/widgets/app/logo.dart';
import 'package:fahis_inspector/features/home/components/appbar_search.dart';
import 'package:fahis_inspector/features/home/components/menu_side.dart';
import 'package:fahis_inspector/features/inspections/view.dart';
import 'package:fahis_inspector/services/notifications/components/notification_icon.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const double tabletBreakpoint = 600;

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  bool isSearchActive = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final isPhone = screenWidth < tabletBreakpoint;

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Logo(height: 30),
        centerTitle: true,
        actions: [
          if (!isSearchActive) NotificationIcon(),
          AppBarSearch(
            onSearchStateChanged: (expanded) {
              setState(() => isSearchActive = expanded);
            },
          ),
        ],
        leading: IconButton(
          onPressed: () => scaffoldKey.currentState?.openDrawer(),
          icon: Icon(
            (scaffoldKey.currentState?.isDrawerOpen ?? false)
                ? Icons.menu_open
                : Iconsax.menu_1,
            color: FColors.primaryColor,
          ),
        ),
      ),
      drawer: isPhone
          ? Drawer(
              width: Get.width * .8,
              child: SafeArea(
                child: SizedBox.expand(child: SideMenuWrapper(isTablet: false)),
              ),
            )
          : null,
      body: isPhone
          ? InspectionList()
          : Row(
              children: [
                SideMenuWrapper(isTablet: true),
                Expanded(child: InspectionList()),
              ],
            ),
    );
  }
}

// class NotificationIcon extends StatelessWidget {
//   final NotificationsController controller;
//   const NotificationIcon({super.key, required this.controller});

//   @override
//   Widget build(BuildContext context) {
//     return Obx(() {
//       // final count = controller.notifications.length;
//       return Badge(
//         label: Text(controller.notifications.length.toString()),
//         backgroundColor: FColors.error,
//         largeSize: 18,
//         isLabelVisible: controller.notifications.length > 0,
//         offset: Offset(-5, 5),
//         alignment: Alignment.topRight,
//         child: IconButton(
//           onPressed: () => Get.toNamed(RoutingUrl.notifications),
//           icon: Icon(Iconsax.notification, color: FColors.primaryColor),
//         ),
//       );
//     });
//   }
// }
