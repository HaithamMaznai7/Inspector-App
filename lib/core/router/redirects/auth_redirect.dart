import 'package:fahis_inspector/core/router/route_names.dart';
import 'package:go_router/go_router.dart';

// Redirects unauthenticated users away from protected routes.
// isLoggedIn is supplied by AuthCubit (wired in Task 16).
String? authRedirect(GoRouterState state, {required bool isLoggedIn}) {
  if (!isLoggedIn) return RouteNames.login;
  return null;
}
