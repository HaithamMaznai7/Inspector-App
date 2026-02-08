part of 'main.dart';

void dd(dynamic error) {
  if (kDebugMode) {
    print(error);
    // try{
    //   if(error is Exception){
    //     FLoader.errorSnackBar(
    //       title: 'Error'.tr,
    //       message: error.toString(),
    //       duration: 10,
    //     );
    //   }else{
    //     FLoader.infoSnackBar(
    //       title: 'Information'.tr,
    //       message: error.toString(),
    //       duration: 10,
    //     );
    //   }
    // }catch(_){
    //   // FLoader.warningSnackBar(
    //   //   title: 'Warning '.tr,
    //   //   message: 'There is an issue but, Can not show the message',
    //   //   duration: 10,
    //   // );
    // }
  }
}

AppServiceProvider app() {
  return AppBinding().instance;
}

AuthService auth() {
  return AuthBinding().instance;
}

NotificationsService notifications({bool fresh = false}) {
  if (fresh) {
    NotificationsBinding().dependencies();
  }
  return NotificationsBinding().instance;
}

StorageService storage() {
  return StorageBinding().instance;
}
