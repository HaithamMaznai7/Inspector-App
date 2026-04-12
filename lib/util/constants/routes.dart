part of '../../routes.dart';

class RoutingUrl {
  static const String init = '/initialization';
  static const String forgetPassword = '/forgetPassword';
  static const String resetPassword = '/resetPassword';
  static const String login = '/login';
  static const String home = '/home';
  static const String notifications = '/notifications';
  static const String search = '/search';
  static const String inspections = '/inspections';
  static const String inspectionSteps = '/inspection-steps';
  static const String inspectionDetails = '/inspection/details';
  static const String requestInspection = '/request/inspection';
  static const String versionUpdate = '/version/update';
  static const String settings = '/settings';
  static const String offline = '/offline';
  static const String onBoarding = '/onBoarding';
  static const String join = '/join';
  static const String requestAccess = '/request-access';
  static const String requestSuccess = '/request-success';
  static const String selectTeam = '/select-team';
  static const String testScreen = '/test/screen';

  static const List<String> authPages = [home, selectTeam, notifications, search, inspections, inspectionDetails, requestInspection, settings];
  static const List<String> guestPages = [forgetPassword, resetPassword, login, versionUpdate, offline, onBoarding, join, requestAccess, requestSuccess];
}

class BindingTags {
  static const String app = 'App';
  static const String storageService = 'StorageService';
  static const String authService = 'AuthService';
  static const String notificationsService = 'NotificationsService';
  static const String onBoarding = 'OnBoarding';
  static const String login = 'Login';
  static const String forgetPassword = 'ForgetPassword';
  static const String resetPassword = 'ResetPassword';
  static const String home = 'Home';
  static const String inspections = 'Inspections';
  static const String inspectionDetails = 'InspectionDetails';
  static const String vehicleDetails = 'VehicleDetails';
  static const String inspectionPoints = 'InspectionPoints';
  static const String inspectionPhotos = 'InspectionPhotos';
  static const String inspectionBody = 'InspectionBody';
  static const String inspectionOBD = 'InspectionOBD';
  static const String notifications = 'Notifications';
  static const String accessRequest = 'AccessRequest';
  static const String paintGauge = 'PaintGauge';
}
