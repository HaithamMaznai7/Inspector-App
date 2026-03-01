part of '../../routes.dart';

class AuthBinding extends BindingsService<AuthService> {
  AuthBinding() : super(tag: BindingTags.authService);
  
  @override
  AuthService get instance {
    if (!Get.isRegistered<AuthService>(tag: tag)) {
      dependencies();
    }
    
    return Get.find<AuthService>(tag: tag);
  }

  @override
  void dependencies() {
    if (!Get.isRegistered<AuthService>(tag: tag)) {
      Get.put<AuthService>(AuthService(), tag: tag, permanent: true);
    }
  }
}
