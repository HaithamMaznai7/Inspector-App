import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  SecureStorage._();

  static const _key = 'backend_token';

  static const _storage = FlutterSecureStorage(
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  static Future<void> saveToken(String token) =>
      _storage.write(key: _key, value: token);

  static Future<String?> readToken() => _storage.read(key: _key);

  static Future<void> clearToken() => _storage.delete(key: _key);
}
