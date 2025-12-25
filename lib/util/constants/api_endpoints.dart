class EndPoints {

  // For Production : 
  // static const String domain = 'backend.fahis.sa';
  // static const String schema = 'https';

  // For Staging : 
  static const String domain = 'backend.fahis.sa';
  static const String schema = 'https';
  
  // For Local : 
  // static const String domain = '192.168.1.168';
  // static const String schema = 'http';

  static const String websiteUrl = 'https://fahis.test';
  static const String reverbApp = 'q0ppjj2j99aqpjbe0wra';
  static const int wssPort = 443;
  static const int wsPort = 8090;
  static const int port = 8000;
  static const String baseUrl = '$schema://$domain/api/';

  // auth
  static const String login = 'login';
  static const String services = 'services';
  static const String reverbAuthenticate = 'broadcasting/auth';
  static const String verifyMobile = 'sent-otp';
  static const String forgetPassword = 'forget-password';
  static const String verifyOTP = 'verify-otp';
  static const String logout = 'logout';
  static const String profile = 'user';
  static const String setTeam = 'user/current-team';
  static const String notifications = 'notifications';

  // request
  static const String inspections = 'inspector/inspections';
  // inspectio

  //config
  static const String config = 'inspector/configs';
  static const String cities = 'assets/cities';
  //static const String makeById = 'obj/vehicle_make/';
  //static const String modelById = 'obj/vehicle_model/';
  //static const String String listVehicleDrivetrain = 'obj/vehicle_drivetrain';
  //static const String listVehicleFueltype = 'obj/vehicle_fueltype';
  static const String listVehicleMake = 'obj/vehicle_make';
  //static const String listVehicleCategory = 'obj/vehicle_category';
  static const String listInspectionPoints =
      'wf/mobapp_list_inspection_point_details';
//  static const String listBodyNotes = 'wf/mobapp_list_body_note_details';
  static const String listInspectionTypeCategory =
      'wf/mobapp_list_inspection_type_category';
//  static const String listOBDs = 'wf/mobapp_list_obd_details';
  static const String getMakeById = 'obj/vehicle_make/';
  static const String getModelById = 'obj/vehicle_model/';
  static const String obdCodeSearch = 'wf/mobapp_get_obd_description';

  // test
  static const testConnection = 'google.com';
}
