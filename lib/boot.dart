import 'routes.dart';
import 'util/localization/localization.dart';
import 'util/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Boot extends StatelessWidget {
  const Boot({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Fahis for inspectors',
      translations: FLocalization(),
      locale: Get.deviceLocale,
      fallbackLocale: Locale('en'),
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: FAppTheme.lightTheme,
      darkTheme: FAppTheme.darkTheme,
      initialRoute: AppRoute.INITIAL,
      getPages: AppRoute.route,
      // WHAT: Wrap the app content with a GestureDetector for dismissing keyboard
      //       and ensure an Overlay is always available for snackbars/dialogs.
      // WHY: The original builder wrapped the Navigator's Overlay inside a
      //       GestureDetector, which meant Overlay.of() could fail when called
      //       from a context above the Navigator (e.g., GetX's snackbar system).
      //       By adding an explicit Overlay widget here, we guarantee one is
      //       always available regardless of the widget tree structure.
      // HOW: We wrap child in Overlay → GestureDetector → child.
      //       The Overlay sits at the top of the tree, above the GestureDetector.
      // EDGE CASES:
      //   - child is null (shouldn't happen with GetMaterialApp) → shows empty SizedBox
      //   - Multiple Overlays in tree → Flutter uses the nearest ancestor, which is fine
      builder: (context, child) {
        return Overlay(
          initialEntries: [
            OverlayEntry(
              builder: (context) => GestureDetector(
                onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
                behavior: HitTestBehavior.opaque,
                child: child ?? const SizedBox(),
              ),
            ),
          ],
        );
      },
    );
  }
}
