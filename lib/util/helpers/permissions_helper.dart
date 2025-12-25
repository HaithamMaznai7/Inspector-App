/* import 'package:fahis_inspector/services/authentication/auth.dart';
import 'package:fahis_inspector/util/constants/enums.dart';

class PermissionsHelper{

  static bool can(String ability){
    if (Auth.check()){
      return Auth.can(ability);
    }

    return false;
  }

  static UserType role(){
    return Auth.role();
  }
} */