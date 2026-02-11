import 'package:fahis_inspector/services/app/support/bindings_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import '../../main.dart';

abstract class AppService extends GetxService with WidgetsBindingObserver {
  AppService();

  RxMap<String, GetxController> controllers = RxMap({});

  RxString status = 'initilizing'.obs;

  Future<void> boot() async {
    final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
    FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  }

  List<BindingsService> register();

  Future<AppService> init() async {

    await boot();
    
    await _bindingRegistered();
    
    FlutterNativeSplash.remove();

    return this;
  }

  Future<void> addControlle(BindingsService provider) async {
    try {
      status.value = "${provider.tag ?? provider.runtimeType} Initializing.";
      dd("${provider.tag ?? provider.runtimeType} Initializing.");
      provider.dependencies();
      if (provider.tag != null) {
        controllers[provider.tag!] = provider.instance;
      }
      status.value = "${provider.tag ?? provider.runtimeType} Initialized.";
      dd("${provider.tag ?? provider.runtimeType} Initialized.");
    } catch (e, s) {
      dd(
        'App Service Error: Error on ${provider.tag ?? provider.runtimeType} Initializing. ${e.toString()}',
      );
      dd('App Service Error: $e');
      debugPrintStack(stackTrace: s);
    }
  }

  Future<void> _bindingRegistered() async {
    for (final provider in register()) {
      await addControlle(provider);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.inactive:
        onInactive();
        break;
      case AppLifecycleState.detached:
        onDetached();
        break;
      case AppLifecycleState.hidden:
        onHidden();
        break;
      case AppLifecycleState.resumed:
        onResumed();
        break;
      case AppLifecycleState.paused:
        onPaused();
        break;
    }
  }

  void onInactive() {
    dd('onInactive');
  }

  void onDetached() {
    dd('onDetached');
  }

  void onHidden() {
    dd('onHidden');
  }

  void onResumed() {
    dd('onResumed');
  }

  void onPaused() {
    dd('onPaused');
  }
}
