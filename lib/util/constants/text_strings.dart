import 'package:fahis_inspector/util/constants/api_endpoints.dart';

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
  static OfflinePage offlinePage = OfflinePage();
  static UpdatePage updatePage = UpdatePage();

  /// --------------------///
  /// --- End Pages Texts

  /// --- Routing
  static RoutingUrl routes = RoutingUrl();

  /// --- Api End Points
  static EndPoints authEndPoints = EndPoints();

  static const String markerInputTitle = 'markerInputTitle';
  static const String markerInputHint = 'markerInputHint';
  static const String markerSelectTitle = 'markerSelectTitle';
  static const String markerTitle = 'markerTitle';
}

class RoutingUrl {
  static const String forgetPassword = '/forgetPassword';
  static const String login = '/login';
  static const String home = '/home';
  static const String notifications = '/notifications';
  static const String search = '/search';
  static const String inspection = '/inspection';
  static const String inspectionDetails = '/inspection/details';
  static const String requestInspection = '/request/inspection';
  static const String versionUpdate = '/version/update';
  static const String settings = '/settings';
  static const String offline = '/offline';
  static const String onBoarding = '/onBoarding';
  static const String testScreen = '/test/screen';
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

class OnBoardingTexts {
  // --- OnBoarding Texts
  static const String onBoardingTitle1 = 'Choose your product';
  static const String onBoardingTitle2 = 'Select Payment Method';
  static const String onBoardingTitle3 = 'Deliver at your door step';

  static const String onBoardingSubTitle1 =
      'Welcome to a World of Limitless Choices - Your Prefect Product Awaits!';
  static const String onBoardingSubTitle2 =
      'For Seamless Transaction, Choose Your Payment Path - Your Convenience, Our Priority!';
  static const String onBoardingSubTitle3 =
      'From Our Doorsteps to Yours - Swift, Secure, and Contactless Delivery!';
}

class LoginPage {
  /// Login Screen
  static const String loginTitle = 'loginTitle';
  static const String loginSubTitle = 'loginSubTitle';
  static const String phoneNumber = 'phoneNumber';
  static const String phoneNumberValidation = 'phoneNumberValidation';
  static const String username = 'email';
  static const String emailValidation = 'emailValidation';
  static const String password = 'password';
  static const String passwordValidation = 'passwordValidation';
  static const String rememberMe = 'rememberMe';
  static const String signIn = 'login';
  static const String resetPassword = 'resetPassword';
  static const String forgetBTN = 'forgetBTN';
  static const String verifyOTP = 'verifyOTP';
  static const String loginWithEmail = 'loginWithEmail';
  static const String otpTitle = 'otpTitle';
  static const String sentOtp = 'sentOtp';
  static const String resendBtnWithTime = 'resendBtnWithTime';
  static const String resendBtn = 'resendBtn';
  static const String editPhoneNumber = 'editPhoneNumber';
  static const String processingTitle = 'processingTitle';
}

class ForgetPage {
  /// Login Screen
  static const String loginTitle = 'loginTitle';
  static const String forgetSubTitle = 'forgetSubTitle';
  static const String phoneNumber = 'phoneNumber';
  static const String phoneNumberValidation = 'phoneNumberValidation';
  static const String forgetBTN = 'forgetBTN';
  static const String otpTitle = 'otpTitle';
  static const String resendBtnWithTime = 'resendBtnWithTime';
  static const String resendBtn = 'resendBtn';
  static const String editPhoneNumber = 'editPhoneNumber';
  static const String processingTitle = 'processingTitle';
}

class HomePage {
  // --- OnBoarding Texts
  static const String searchHint = 'searchHint';
  static const String request = 'request';
  static const String history = 'history';
  static const String onEmpty = 'HomePageOnEmpty';
  static const String onError = 'HomePageOnError';
  static const String noMore = 'HomePageNoMore';
}

class DetailsPage {
  // --- OnBoarding Texts

  static const String pageTitle = 'pageTitle @inspection';
  static const String requestInfoTitle = 'requestInfoTitle';
  static const String centerInfoTitle = 'centerInfoTitle';
  static const String reviewNoteTitle = 'reviewNoteTitle';
  static const String vehiclePhotosTitle = 'vehiclePhotosTitle';
  static const String vehicleInfoTile = 'vehicleInfoTile';
  static const String inspectionPointResults = 'inspectionPointResults';
  static const String defaultValidationIfNull = 'defaultValidationIfNull';
  static const String defaultValidation = 'defaultValidation';
  static const String pointCategories = 'pointCategories';

  static const String vin = 'vin';
  static const String vinHint = 'vinHint';
  static const String vinValidation = 'vinValidation';
  static const String vinValidationIfNull = 'vinValidationIfNull';

  static const String plateNumber = 'plateNumber';
  static const String plateNumberHint = 'plateNumberHint';
  static const String plateNumberValidation = 'plateNumberValidation';
  static const String plateNumberValidationIfNull =
      'plateNumberValidationIfNull';

  static const String bodyType = 'bodyType';
  static const String bodyTypeValidation = 'bodyTypeValidation';

  static const String drivetrain = 'drivetrain';
  static const String drivetrainValidation = 'drivetrainValidation';

  static const String fuelType = 'fuelType';
  static const String fuelTypeValidation = 'fuelTypeValidation';

  static const String gasolineType = 'gasolineType';
  static const String gasolineTypeValidation = 'gasolineTypeValidation';

  static const String milage = 'milage';
  static const String milageHint = 'milageHint';
  static const String milageValidation = 'milageValidation';
  static const String milageValidationIfNull = 'milageValidationIfNull';

  static const String yearModel = 'yearModel';
  static const String yearModelValidation = 'yearModelValidation';

  static const String exteriorColor = 'exteriorColor';
  static const String exteriorColorHint = 'exteriorColorHint';
  static const String exteriorColorValidation = 'exteriorColorValidation';

  static const String interiorColor = 'interiorColor';
  static const String interiorColorHint = 'interiorColorHint';
  static const String interiorColorValidation = 'interiorColorValidation';

  static const String gearboxType = 'gearboxType';
  static const String gearboxTypeValidation = 'gearboxTypeValidation';

  static const String cylindersNo = 'cylindersNo';
  static const String cylindersNoValidation = 'cylindersNoValidation';

  static const String engineSize = 'engineSize';
  static const String engineSizeHint = 'engineSizeHint';
  static const String engineSizeValidation = 'engineSizeValidation';
  static const String engineSizeValidationIfNull = 'engineSizeValidationIfNull';

  static const String seatType = 'seatType';
  static const String seatTypeValidation = 'seatTypeValidation';

  static const String seatNo = 'seatNo';
  static const String seatNoValidation = 'seatNoValidation';
}

class InspectionPage {
  // --- OnBoarding Texts
  static const String onBoardingTitle1 = 'Choose your product';
  static const String onBoardingTitle2 = 'Select Payment Method';
  static const String onBoardingTitle3 = 'Deliver at your door step';

  static const String onBoardingSubTitle1 =
      'Welcome to a World of Limitless Choices - Your Prefect Product Awaits!';
  static const String onBoardingSubTitle2 =
      'For Seamless Transaction, Choose Your Payment Path - Your Convenience, Our Priority!';
  static const String onBoardingSubTitle3 =
      'From Our Doorsteps to Yours - Swift, Secure, and Contactless Delivery!';
}

class OfflinePage {
  // --- OnBoarding Texts
  static const String onBoardingTitle1 = 'Choose your product';
  static const String onBoardingTitle2 = 'Select Payment Method';
  static const String onBoardingTitle3 = 'Deliver at your door step';

  static const String onBoardingSubTitle1 =
      'Welcome to a World of Limitless Choices - Your Prefect Product Awaits!';
  static const String onBoardingSubTitle2 =
      'For Seamless Transaction, Choose Your Payment Path - Your Convenience, Our Priority!';
  static const String onBoardingSubTitle3 =
      'From Our Doorsteps to Yours - Swift, Secure, and Contactless Delivery!';
}

class UpdatePage {
  // --- OnBoarding Texts
  static const String onBoardingTitle1 = 'Choose your product';
  static const String onBoardingTitle2 = 'Select Payment Method';
  static const String onBoardingTitle3 = 'Deliver at your door step';

  static const String onBoardingSubTitle1 =
      'Welcome to a World of Limitless Choices - Your Prefect Product Awaits!';
  static const String onBoardingSubTitle2 =
      'For Seamless Transaction, Choose Your Payment Path - Your Convenience, Our Priority!';
  static const String onBoardingSubTitle3 =
      'From Our Doorsteps to Yours - Swift, Secure, and Contactless Delivery!';
}

class Assets {
  // --- Assets
  static const List<Map> pointCategories = [
    {
      'icon':
          's3.amazonaws.com/appforest_uf/f1669035697685x979162662113499900/test_drive.svg',
      'liveId': '1629229965796x963683547318951800',
      'name': 'TestDrive',
      'vehicleCategory': '1620214162505x553822032984845100',
      'arName': 'اختبار القيادة'
    },
    {
      'liveId': '1629229927692x579992539058576500',
      'name': 'Body',
      'arName': 'هيكل المركبة',
      'vehicleCategory': '1620214162505x553822032984845100',
      'icon':
          's3.amazonaws.com/appforest_uf/f1669035712019x505649745815797570/body.svg'
    },
    {
      'liveId': '1629229897512x442814463963328450',
      'name': 'Brake',
      'arName': 'نظام الفرامل',
      'vehicleCategory': '1620214162505x553822032984845100',
      'icon':
          's3.amazonaws.com/appforest_uf/f1669035722155x611979799501702000/brake.svg'
    },
    {
      'liveId': '1629229870808x934145871714580700',
      'name': 'Ignition and Air Condition',
      'arName': 'نظام التشغيل والتكييف',
      'vehicleCategory': '1620214162505x553822032984845100',
      'icon':
          's3.amazonaws.com/appforest_uf/f1669035731248x432927679035252100/fan.svg'
    },
    {
      'liveId': '1629229838726x153814075892032770',
      'name': 'Suspension and Steering',
      'arName': 'التعليق والتوجية',
      'vehicleCategory': '1620214162505x553822032984845100',
      'icon':
          's3.amazonaws.com/appforest_uf/f1669035742611x181204702591763600/suspension.svg'
    },
    {
      'liveId': '1629229809957x305224420796831550',
      'name': 'Gearbox',
      'arName': 'الجيربوكس',
      'vehicleCategory': '1620214162505x553822032984845100',
      'icon':
          's3.amazonaws.com/appforest_uf/f1669035752574x175554066852321660/gearbox.svg'
    },
    {
      'liveId': '1629229770503x247128422881989900',
      'name': 'Engine and Cooling',
      'arName': 'المحرك والتبريد ',
      'vehicleCategory': '1620214162505x553822032984845100',
      'icon':
          's3.amazonaws.com/appforest_uf/f1669035760632x432380351255576800/engine.svg'
    }
  ];
  static const List<Map> fuelTypes = [
    {
      "ArabicName": "بنزين",
      "Name": "Gasoline",
      "VehicleCategory": "1620214162505x553822032984845100",
      "_id": "1630874407977x140899939849157500"
    },
    {
      "ArabicName": " ديزل",
      "Name": "Diesel",
      "VehicleCategory": "1620214162505x553822032984845100",
      "_id": "1630874430717x139338528671606500"
    },
    {
      "ArabicName": "كهربائية",
      "Name": "Electric",
      "VehicleCategory": "1620214162505x553822032984845100",
      "_id": "1630874498947x504360228122880260"
    },
    {
      "ArabicName": "هجين",
      "Name": "Hybrid",
      "VehicleCategory": "1620214162505x553822032984845100",
      "_id": "1630874516375x510061390507490700"
    },
  ];
  static const List<Map> drivetrainTypes = [
    {
      "Name": "FWD",
      "VehicleCategory": "1620214162505x553822032984845100",
      "_id": "1620222853731x318148069121547000"
    },
    {
      "Name": "RWD",
      "VehicleCategory": "1620214162505x553822032984845100",
      "_id": "1620222853733x108419164515939580"
    },
    {
      "Name": "AWD",
      "VehicleCategory": "1620214162505x553822032984845100",
      "_id": "1620222853733x819995249282322200"
    },
    {
      "Name": "4X4",
      "VehicleCategory": "1620214162505x553822032984845100",
      "_id": "1620222853734x220497425958001250"
    },
    {
      "Name": "Race",
      "VehicleCategory": "1620214172606x641388992810538500",
      "_id": "1620222853782x534843013849439740"
    },
    {
      "Name": "Cruise",
      "VehicleCategory": "1620214172606x641388992810538500",
      "_id": "1620222853783x444845974282497900"
    },
    {
      "Name": "Touring",
      "VehicleCategory": "1620214172606x641388992810538500",
      "_id": "1620222853783x445346156277286000"
    },
    {
      "Name": "Truck",
      "VehicleCategory": "1620214184735x671718483314267300",
      "_id": "1620222853826x892902196201745800"
    },
  ];
  static const List<Map> vehicleCategories = [
    {
      "Modified Date": "2021-05-05T11:29:22.741Z",
      "ID": "1",
      "Name": "Car",
      "Created Date": "2021-05-05T11:29:22.505Z",
      "Created By": "admin_user_fahis_test",
      "_id": "1620214162505x553822032984845100"
    },
    {
      "Modified Date": "2021-05-05T11:29:32.779Z",
      "ID": "2",
      "Name": "Motorcycle",
      "Created Date": "2021-05-05T11:29:32.607Z",
      "Created By": "admin_user_fahis_test",
      "_id": "1620214172606x641388992810538500"
    },
    {
      "Modified Date": "2021-05-05T11:29:44.874Z",
      "ID": "3",
      "Name": "Truck",
      "Created Date": "2021-05-05T11:29:44.736Z",
      "Created By": "admin_user_fahis_test",
      "_id": "1620214184735x671718483314267300"
    }
  ];
}
