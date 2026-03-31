import 'package:fahis_inspector/boot/app_service_provider.dart';
import 'package:fahis_inspector/features/authentication/controllers/forget_password_controller.dart';
import 'package:fahis_inspector/features/authentication/controllers/reset_password_controller.dart';
import 'package:fahis_inspector/features/authentication/views/forget_password_view.dart';
import 'package:fahis_inspector/features/authentication/views/login_view.dart';
import 'package:fahis_inspector/features/authentication/views/reset_password_view.dart';
import 'package:fahis_inspector/features/authentication/views/select_team_screen.dart';
import 'package:fahis_inspector/features/configuration/view.dart';
import 'package:fahis_inspector/features/home/view.dart';
import 'package:fahis_inspector/features/inspection_details/view.dart';
import 'package:fahis_inspector/features/inspection_steps/view.dart';
import 'package:fahis_inspector/models/inspection.dart';
import 'package:fahis_inspector/services/app/support/bindings_service.dart';
import 'package:fahis_inspector/services/auth/midlwares/auth_midlware.dart';
import 'package:fahis_inspector/services/auth/midlwares/guest_midlware.dart';
import 'common/widgets/app/app.dart';
import 'package:get/get.dart';

//features
import 'features/authentication/controllers/login_controller.dart';
import 'features/home/controller.dart';
import 'features/inspections/controller.dart';
import 'features/inspection_steps/controller.dart';
import 'features/inspection_details/controller.dart';
import 'features/vehicle_details/controller.dart';
import 'features/inspection_points/controller.dart';
import 'features/inspection_photos/controller.dart';
import 'features/inspection_body_notes/controller.dart';
import 'features/inspection_obd/controller.dart';
import 'features/configuration/controller.dart';
import 'features/access_request/controller.dart';
import 'features/access_request/decision_view.dart';
import 'features/access_request/request_view.dart';
import 'features/access_request/success_view.dart';

//services
import 'services/storage/storage_service.dart';
import 'services/auth/auth_service.dart';
import 'services/notifications/notifications_service.dart';

// services bindings
part 'util/constants/routes.dart';
part 'services/storage/binding.dart';
part 'services/app/binding.dart';
part 'services/auth/binding.dart';
part 'services/notifications/binding.dart';

// features bindings
part 'features/configuration/binding.dart';
part 'features/authentication/binding.dart';
part 'features/home/binding.dart';
part 'features/inspections/binding.dart';
part 'features/inspection_details/binding.dart';
part 'features/inspection_steps/binding.dart';
part 'features/vehicle_details/binding.dart';
part 'features/inspection_points/binding.dart';
part 'features/inspection_photos/binding.dart';
part 'features/inspection_body_notes/binding.dart';
part 'features/inspection_obd/binding.dart';
part 'features/access_request/binding.dart';

class AppRoute {
  AppRoute._();

  static final _routes = [
    GetPage(
      name: RoutingUrl.init,
      binding: AppBinding(),
      page: () => const App(),
    ),

    GetPage(
      name: RoutingUrl.onBoarding,
      binding: OnBoardingBinding(),
      page: () => const OnBoardingScreen(),
      // middlewares: [BoarderMiddleware()],
    ),

    GetPage(
      name: RoutingUrl.join,
      page: () => const DecisionScreen(),
      middlewares: [GuestMiddleware()],
    ),

    GetPage(
      name: RoutingUrl.requestAccess,
      binding: AccessRequestBinding(),
      page: () => const RequestAccessScreen(),
      middlewares: [GuestMiddleware()],
    ),

    GetPage(
      name: RoutingUrl.requestSuccess,
      page: () => const RequestSuccessScreen(),
      middlewares: [GuestMiddleware()],
    ),

    GetPage(
      name: RoutingUrl.login,
      binding: LoginBinding(),
      page: () => const Login(),
      middlewares: [GuestMiddleware()],
    ),

    GetPage(
      name: RoutingUrl.forgetPassword,
      binding: ForgetBinding(),
      page: () => const ForgetPassword(),
      middlewares: [GuestMiddleware()],
    ),

    GetPage(
      name: RoutingUrl.resetPassword,
      binding: ResetPasswordBinding(),
      page: () => const ResetPasswordView(),
      middlewares: [GuestMiddleware()],
    ),

    GetPage(
      name: RoutingUrl.selectTeam,
      page: () => const SelectTeamToContinueScreen(),
      middlewares: [AuthMiddleware()],
    ),

    GetPage(
      name: RoutingUrl.home,
      page: () => const HomeScreen(),
      middlewares: [AuthMiddleware()],
      binding: HomeBinding(),
    ),

    // GetPage(
    //   name: RoutingUrl.notifications,
    //   page: () => const NotificationScreen(),
    //   middlewares: [BoarderMiddleware(), AuthMiddleware()],
    //   transition: FLocalization.isArabic ? Transition.leftToRightWithFade : Transition.rightToLeftWithFade,
    //   transitionDuration: Duration(milliseconds: 400), // optional
    // ),

    // GetPage(
    //   name: RoutingUrl.search,
    //   page: () => const SearchPage(),
    //   transition: FLocalization.isArabic ? Transition.leftToRightWithFade : Transition.rightToLeftWithFade,
    //   transitionDuration: Duration(milliseconds: 400), // optional
    // ),
    GetPage(
      name: '${RoutingUrl.inspections}/:slug',
      binding: InspectionDetailsBinding(),
      middlewares: [AuthMiddleware()],
      page: () => InspectionDetailsScreen(),
    ),

    GetPage(
      name: RoutingUrl.inspectionSteps,
      binding: InspectionStepsBinding(),
      middlewares: [AuthMiddleware()],
      page: () => InspectionStepsScreen(),
    ),
  ];

  static const initial = RoutingUrl.init;

  static get route => _routes;
}
