part of '../../routes.dart';

class AppBinding extends BindingsService<AppServiceProvider> {
  
  @override
  final String? tag = BindingTags.app;

  @override
  void dependencies() async {
    if (!isRegistered) {
      await Get.putAsync<AppServiceProvider>(
        () async => AppServiceProvider()..init(),
        permanent: true,
        tag: tag,
      );
    }
  }
}
