import 'package:fahis_inspector/features/authentication/screens/onboarding/onboarding.dart';
import 'package:fahis_inspector/features/inspection/screens/inspection_screen.dart';
import 'package:fahis_inspector/features/inspections/screens/search_page.dart';
import 'package:fahis_inspector/features/notifications/screen.dart';
import 'package:fahis_inspector/services/app_binding.dart';
import 'package:fahis_inspector/features/authentication/screens/forget_password.dart';
import 'package:fahis_inspector/features/inspections/models/inspection.dart';
import 'package:fahis_inspector/services/authentication/middleware/auth.dart';
import 'package:fahis_inspector/services/authentication/middleware/boarder.dart';
import 'package:fahis_inspector/services/authentication/middleware/unauth.dart';
import 'package:fahis_inspector/util/constants/text_strings.dart';
import 'package:fahis_inspector/util/localization/localization.dart';
import 'package:get/get.dart';
import 'features/authentication/screens/login.dart';
import 'features/inspections/screens/home_screen.dart';

class AppRoute {

  AppRoute._();

  static final _routes = [

    GetPage(
      name: RoutingUrl.onBoarding,
      page: () => const OnBoardingScreen(),
      middlewares: [BoarderMiddleware()],
    ),

    GetPage(
      name: RoutingUrl.login,
      binding: LoginBinding(),
      page: () => const Login(),
      middlewares: [BoarderMiddleware(), UnauthMiddleware()],
    ),

    GetPage(
      name: RoutingUrl.forgetPassword,
      binding: RestorePasswordBinding(),
      page: () => const RestorePassword(),
      middlewares: [BoarderMiddleware(), UnauthMiddleware()],
    ),

    GetPage(
      name: RoutingUrl.home,
      page: () => const HomeScreen(),
      middlewares: [BoarderMiddleware(), AuthMiddleware()],
      binding: HomeBinding(),
    ),

    GetPage(
      name: RoutingUrl.notifications,
      page: () => const NotificationScreen(),
      middlewares: [BoarderMiddleware(), AuthMiddleware()],
      transition: FLocalization.isArabic ? Transition.leftToRightWithFade : Transition.rightToLeftWithFade,
      transitionDuration: Duration(milliseconds: 400), // optional
    ),

    GetPage(
      name: RoutingUrl.search,
      page: () => const SearchPage(),
      transition: FLocalization.isArabic ? Transition.leftToRightWithFade : Transition.rightToLeftWithFade,
      transitionDuration: Duration(milliseconds: 400), // optional
    ),

    GetPage(
      name: '${RoutingUrl.inspection}/:slug',
      arguments: Inspection,
      binding: InspectionBinding(),
      middlewares: [AuthMiddleware()],
      page: () => InspectionScreen(),
    ),

  ];

  static const INITIAL = RoutingUrl.home;

  static get route => _routes;
}
