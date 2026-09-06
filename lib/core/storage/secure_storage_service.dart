import 'dart:convert';
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

  static const String _keySubscriptions = 'user_subscriptions_v1';
  static const String _keyThemeMode = 'app_theme_mode';
  static const String _keyLocale = 'app_locale';
  static const String _keyNotifications = 'notification_settings_v1';

  Future<void> saveThemeMode(String mode) async {
    await _storage.write(key: _keyThemeMode, value: mode);
  }

  Future<String?> getThemeMode() async {
    return await _storage.read(key: _keyThemeMode);
  }

  Future<void> saveLocale(String locale) async {
    await _storage.write(key: _keyLocale, value: locale);
  }

  Future<String?> getLocale() async {
    return await _storage.read(key: _keyLocale);
  }

  Future<void> saveNotificationSettings(Map<String, dynamic> data) async {
    await _storage.write(key: _keyNotifications, value: jsonEncode(data));
  }

  Future<Map<String, dynamic>?> getNotificationSettings() async {
    final raw = await _storage.read(key: _keyNotifications);
    if (raw == null || raw.isEmpty) return null;
    try {
      return Map<String, dynamic>.from(jsonDecode(raw) as Map);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveSubscriptions(List<Map<String, dynamic>> items) async {
    await _storage.write(key: _keySubscriptions, value: jsonEncode(items));
  }

  Future<List<Map<String, dynamic>>?> getSubscriptions() async {
    final raw = await _storage.read(key: _keySubscriptions);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw) as List;
      return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (_) {
      return null;
    }
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
