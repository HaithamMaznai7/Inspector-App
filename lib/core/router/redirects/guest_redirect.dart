import 'package:fahis_inspector/core/router/route_names.dart';
import 'package:go_router/go_router.dart';

// Redirects authenticated users away from guest-only routes.
// isLoggedIn is supplied by AuthCubit (wired in Task 16).
String? guestRedirect(GoRouterState state, {required bool isLoggedIn}) {
  if (isLoggedIn) return RouteNames.home;
  return null;
}
