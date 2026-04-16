part of '../../routes.dart';

class ConnectionBinding extends BindingsService<ConnectionService> {
  ConnectionBinding() : super(tag: BindingTags.connectionService);

  @override
  void dependencies() {
    if (!Get.isRegistered<ConnectionService>(tag: tag)) {
      Get.put<ConnectionService>(ConnectionService(), tag: tag, permanent: true);
    }
  }
}
