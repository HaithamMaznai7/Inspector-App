abstract class RouteNames {
  // ── Guest ─────────────────────────────────────────────────────────────────
  static const String initialization = '/initialization';
  static const String onboarding = '/onboarding';
  static const String join = '/join';
  static const String requestAccess = '/request-access';
  static const String requestSuccess = '/request-success';
  static const String login = '/login';
  static const String forgetPassword = '/forget-password';
  static const String resetPassword = '/reset-password';

  // ── Authenticated ─────────────────────────────────────────────────────────
  static const String selectTeam = '/select-team';
  static const String home = '/home';
  static const String inspectionDetails = '/inspections/:slug';
  static const String inspectionSteps = '/inspection-steps';
}
