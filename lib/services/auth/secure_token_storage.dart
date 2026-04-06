import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureTokenStorage {
  static const _key = 'backend_token';
  final _storage = const FlutterSecureStorage(
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  Future<void> save(String token) =>
      _storage.write(key: _key, value: token);

  Future<String?> read() =>
      _storage.read(key: _key);

  Future<void> clear() =>
      _storage.delete(key: _key);
}
