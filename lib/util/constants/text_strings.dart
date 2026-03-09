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
  static const String reviewBtn = 'reviewBtn';
  static const String automatic = 'automatic';
  static const String unSelected = '';
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
  static const String markerNoteRequired = 'markerNoteRequired';
  static const String markerNoteRequiredMsg = 'markerNoteRequiredMsg';
  static const String markerTypeRequired = 'markerTypeRequired';
  static const String markerTypeRequiredMsg = 'markerTypeRequiredMsg';
  static const String markerAddPhoto = 'markerAddPhoto';
  static const String markerChangePhoto = 'markerChangePhoto';
  static const String bodyInspectionDetails = 'bodyInspectionDetails';
  static const String bodyTapHint = 'bodyTapHint';
  static const String bodyDragHint = 'bodyDragHint';
  static const String bodyPartTop = 'bodyPartTop';
  static const String bodyPartLeft = 'bodyPartLeft';
  static const String bodyPartRight = 'bodyPartRight';
  static const String bodyPartFront = 'bodyPartFront';
  static const String bodyPartBack = 'bodyPartBack';
  static const String bodyPartInterior = 'bodyPartInterior';
  static const String markerSavedSuccess = 'markerSavedSuccess';
  static const String markerSavedSuccessMsg = 'markerSavedSuccessMsg';
  static const String markerDeletedSuccess = 'markerDeletedSuccess';
  static const String markerDeletedSuccessMsg = 'markerDeletedSuccessMsg';
  static const String markerErrorTitle = 'markerErrorTitle';
  static const String markerErrorMsg = 'markerErrorMsg';
  static const String systemInspector = 'systemInspector';
  static const String profileTitle = 'profileTitle';
  static const String logoutBtn = 'logoutBtn';
  static const String logoutConfirmTitle = 'logoutConfirmTitle';
  static const String logoutConfirmMessage = 'logoutConfirmMessage';
  static const String profileName = 'profileName';
  static const String profileEmail = 'profileEmail';
  static const String profilePhone = 'profilePhone';
  static const String profileCity = 'profileCity';
  static const String profileUpdate = 'profileUpdate';
  static const String profileNameHint = 'profileNameHint';
  static const String profileEmailHint = 'profileEmailHint';
  static const String profilePhoneHint = 'profilePhoneHint';
  
  /// Inspection Stage Labels
  static const String stageAll = 'stageAll';
  static const String stagePending = 'stagePending';
  static const String stageAccepted = 'stageAccepted';
  static const String stageInfo = 'stageInfo';
  static const String stagePoints = 'stagePoints';
  static const String stagePhotos = 'stagePhotos';
  static const String stageBody = 'stageBody';
  static const String stageObd = 'stageObd';
  static const String stageFinished = 'stageFinished';
  static const String stageRejected = 'stageRejected';
  static const String stageReviewed = 'stageReviewed';

  /// Camera
  static const String cameraRetake = 'cameraRetake';
  static const String cameraUsePhoto = 'cameraUsePhoto';
  static const String cameraRetry = 'cameraRetry';
  static const String cameraOk = 'cameraOk';

  /// Force Update
  static const String forceUpdateTitle = 'forceUpdateTitle';
  static const String forceUpdateMessage = 'forceUpdateMessage';
  static const String forceUpdateButton = 'forceUpdateButton';
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
