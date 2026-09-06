import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure local token and credential storage service.
/// Wraps FlutterSecureStorage for encrypted on-device session management.
class SecureStorageService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  static const String _keyAuthToken = 'auth_token';
  static const String _keyUserId = 'user_id';
  static const String _keyPreferredCurrency = 'preferred_currency';

  Future<void> saveAuthToken(String token) async {
    await _storage.write(key: _keyAuthToken, value: token);
  }

  Future<String?> getAuthToken() async {
    return await _storage.read(key: _keyAuthToken);
  }

  Future<void> saveUserId(String userId) async {
    await _storage.write(key: _keyUserId, value: userId);
  }

  Future<String?> getUserId() async {
    return await _storage.read(key: _keyUserId);
  }

  Future<void> savePreferredCurrency(String currency) async {
    await _storage.write(key: _keyPreferredCurrency, value: currency);
  }

  Future<String> getPreferredCurrency() async {
    return (await _storage.read(key: _keyPreferredCurrency)) ?? 'TRY';
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
