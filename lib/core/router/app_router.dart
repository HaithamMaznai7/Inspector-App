import 'package:fahis_inspector/core/router/redirects/auth_redirect.dart';
import 'package:fahis_inspector/core/router/redirects/guest_redirect.dart';
import 'package:fahis_inspector/core/router/route_names.dart';
import 'package:fahis_inspector/core/services/storage/prefs.dart';
import 'package:fahis_inspector/features/access_request/decision_view.dart';
import 'package:fahis_inspector/features/access_request/request_view.dart';
import 'package:fahis_inspector/features/access_request/success_view.dart';
import 'package:fahis_inspector/features/authentication/views/forget_password_view.dart';
import 'package:fahis_inspector/features/authentication/views/login_view.dart';
import 'package:fahis_inspector/features/authentication/views/reset_password_view.dart';
import 'package:fahis_inspector/features/authentication/views/select_team_screen.dart';
import 'package:fahis_inspector/features/configuration/view.dart';
import 'package:fahis_inspector/features/home/view.dart';
import 'package:fahis_inspector/features/inspection_details/view.dart';
import 'package:fahis_inspector/features/inspection_steps/view.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

// rootNavigatorKey exposed so SnackbarService and dialogs can reach the root.
final rootNavigatorKey = GlobalKey<NavigatorState>();

// appRouter is the single GoRouter instance for the app.
// redirect uses Prefs as a temporary auth proxy until AuthCubit is wired
// in Task 16 (refreshListenable will be replaced with AuthCubit.stream).
final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: RouteNames.initialization,
  redirect: _globalRedirect,
  routes: [
    // ── Init / splash ──────────────────────────────────────────────────────
    GoRoute(
      path: RouteNames.initialization,
      builder: (_, _) => const OnBoardingScreen(),
    ),

    // ── Onboarding ─────────────────────────────────────────────────────────
    GoRoute(
      path: RouteNames.onboarding,
      redirect: (_, state) => guestRedirect(state, isLoggedIn: _isLoggedIn()),
      builder: (_, _) => const OnBoardingScreen(),
    ),

    // ── Access request ─────────────────────────────────────────────────────
    GoRoute(
      path: RouteNames.join,
      redirect: (_, state) => guestRedirect(state, isLoggedIn: _isLoggedIn()),
      builder: (_, _) => const DecisionScreen(),
    ),
    GoRoute(
      path: RouteNames.requestAccess,
      redirect: (_, state) => guestRedirect(state, isLoggedIn: _isLoggedIn()),
      builder: (_, _) => const RequestAccessScreen(),
    ),
    GoRoute(
      path: RouteNames.requestSuccess,
      redirect: (_, state) => guestRedirect(state, isLoggedIn: _isLoggedIn()),
      builder: (_, _) => const RequestSuccessScreen(),
    ),

    // ── Auth ───────────────────────────────────────────────────────────────
    GoRoute(
      path: RouteNames.login,
      redirect: (_, state) => guestRedirect(state, isLoggedIn: _isLoggedIn()),
      builder: (_, _) => const Login(),
    ),
    GoRoute(
      path: RouteNames.forgetPassword,
      redirect: (_, state) => guestRedirect(state, isLoggedIn: _isLoggedIn()),
      builder: (_, _) => const ForgetPassword(),
    ),
    GoRoute(
      path: RouteNames.resetPassword,
      redirect: (_, state) => guestRedirect(state, isLoggedIn: _isLoggedIn()),
      builder: (_, _) => const ResetPasswordView(),
    ),

    // ── Protected ──────────────────────────────────────────────────────────
    GoRoute(
      path: RouteNames.selectTeam,
      redirect: (_, state) => authRedirect(state, isLoggedIn: _isLoggedIn()),
      builder: (_, _) => const SelectTeamToContinueScreen(),
    ),
    GoRoute(
      path: RouteNames.home,
      redirect: (_, state) => authRedirect(state, isLoggedIn: _isLoggedIn()),
      builder: (_, _) => const HomeScreen(),
    ),
    // slug passed via pathParameters; the existing GetX view reads it via
    // Get.parameters — replaced with state.pathParameters in Task 22.
    GoRoute(
      path: RouteNames.inspectionDetails,
      redirect: (_, state) => authRedirect(state, isLoggedIn: _isLoggedIn()),
      builder: (_, _) => const InspectionDetailsScreen(),
    ),
    // extra (Inspection object) passed via state.extra; read via Get.arguments
    // in the existing view — replaced with state.extra in Task 28.
    GoRoute(
      path: RouteNames.inspectionSteps,
      redirect: (_, state) => authRedirect(state, isLoggedIn: _isLoggedIn()),
      builder: (_, _) => const InspectionStepsScreen(),
    ),
  ],
);

// Temporary auth proxy — replaced with AuthCubit.state in Task 16.
bool _isLoggedIn() => Prefs.lastUserId != null;

String? _globalRedirect(BuildContext context, GoRouterState state) {
  final onInit = state.matchedLocation == RouteNames.initialization;
  if (!onInit) return null;
  // On cold-start: skip onboarding if already seen, route by auth state.
  if (!Prefs.onboardingSeen) return RouteNames.onboarding;
  return _isLoggedIn() ? RouteNames.home : RouteNames.login;
}
