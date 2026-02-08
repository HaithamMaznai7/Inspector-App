part of '../../routes.dart';

class AuthBinding extends BindingsService<AuthService> {
  
  @override
  final String? tag = BindingTags.authService;
  
  AuthService get instance {
    if (!Get.isRegistered<AuthService>(tag: tag)) {
      dependencies();
    }
    
    return Get.find<AuthService>(tag: tag);
  }

  @override
  void dependencies() {
    if (!Get.isRegistered(tag: tag)) {
      Get.put<AuthService>(AuthService(), tag: tag);
    }
  }
}
