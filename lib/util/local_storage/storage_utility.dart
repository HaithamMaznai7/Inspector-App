/*
import 'package:get_storage/get_storage.dart';

class FLocalStorage {
  static final FLocalStorage _instance = FLocalStorage._internal();

  factory FLocalStorage(){
    return _instance;
  }

  FLocalStorage._internal();

  final _storage = GetStorage();

  // Generic method to save data
  Future<void> saveData(String key, dynamic value) async {
    await _storage.write(key, value);
  }

  // Generic method to read data
  T? readData<T>(String key) {
    return _storage.read<T>(key);
  }

  // Generic method to save data
  Future<void> removeData(String key) async {
    await _storage.remove(key);
  }

  // Generic method to save data
  Future<void> clearAll() async {
    await _storage.erase();
  }
}
*/
