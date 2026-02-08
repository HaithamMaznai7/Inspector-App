import 'api_endpoints.dart';

part 'pages/forget_page.dart';
part 'pages/details_page.dart';
part 'pages/home_page.dart';
part 'pages/inspection_page.dart';
part 'pages/offline_page.dart';
part 'pages/on_boarder_page.dart';
part 'pages/update_page.dart';
part 'pages/login_page.dart';
part 'pages/inspection_point_page.dart';

class FTexts {
  /// --- GLOBAL VARIABLES
  static const String appName = 'fahis';
  static const String cancelBtn = 'cancelBtn';
  static const String refresh = 'refresh';
  static const String submitBtn = 'submitBtn';
  static const String nextBtn = 'nextBtn';
  static const String backBtn = 'backBtn';
  static const String requestId = 'requestId';
  static const String skip = 'skip';
  static const String deleteBtn = 'deleteBtn';
  static const String offlineMode = 'offlineMode';
  static const String signOut = 'signOut';
  static const String updateAssets = 'updateAssets';
  static const String downloadRequests = 'downloadRequests';

  /// --- GLOBAL VARIABLES
  ///
  /// --- ENUM VARIABLES
  static const String saveBtn = 'saveBtn';
  static const String editBtn = 'editBtn';
  static const String automatic = 'automatic';
  static const String unSelected = 'Nothing';
  static const String more = 'more';
  static const String manual = 'manual';
  static const String fabric = 'Fabric';
  static const String leather = 'Leather';
  static const String inProgress = 'inProgress';
  static const String pended = 'pended';
  static const String finished = 'finished';
  static const String approved = 'approved';
  static const String good = 'good';
  static const String notes = 'notes';
  static const String na = 'na';

  /// --- ENUM VARIABLES
  static StorageKey storageKeys = StorageKey();

  /// --- Pages Texts
  /// --------------------///

  static OnBoardingTexts onBoardingPage = OnBoardingTexts();
  static LoginPage loginPage = LoginPage();
  static HomePage homePage = HomePage();
  static DetailsPage requestDetailsPage = DetailsPage();
  static InspectionPage inspectionPage = InspectionPage();
  static InspectionPointPage inspectionPointPage = InspectionPointPage();
  static OfflinePage offlinePage = OfflinePage();
  static UpdatePage updatePage = UpdatePage();

  /// --------------------///
  /// --- End Pages Texts

  /// --- Api End Points
  static EndPoints authEndPoints = EndPoints();

  static const String markerInputTitle = 'markerInputTitle';
  static const String markerInputHint = 'markerInputHint';
  static const String markerSelectTitle = 'markerSelectTitle';
  static const String markerTitle = 'markerTitle';
}



class StorageKey {
  static const String appData = 'APP_DATA';
  static const String userData = 'USER_DATA';
  static const String configData = 'CONFIG_DATA';
  static const String requests = 'REQUESTS';
  static const String history = 'HISTORY';
  static const String isFirstOpen = 'IS_FIRST_OPEN';
  static const String enableOfflineMode = 'ENABLE_OFFLINE_MODE';
  static const String offlineMode = 'OFFLINE_MODE';
  static String packageVersion = 'PACKAGE_VERSION';

  static const String models = 'ALL_SAVED_MODELS';

  static const String requestDetails = 'REQUEST_';

  static const String photosDetails = 'PHOTOS_DETAILS';
  static const String pointsDetails = 'POINTS_DETAILS';
  static const String inspectionTypeCategoriesDetails =
      'INSPECTION_TYPE_CATEGORIES_DETAILS';
  static const String makesDetails = 'MAKES_DETAILS';
}

class SnackBarMessages {
  /// network Status
  static const String noInternet = 'noInternet';
  static const String hasInternet = 'hasInternet';
}
