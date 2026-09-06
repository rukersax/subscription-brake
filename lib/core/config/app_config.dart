/// Global application configuration and environment flags.
class AppConfig {
  /// When true, frontend uses static mocked data without requiring live network APIs
  static const bool developmentMode = true;

  static const String appName = 'Subscription Brake';
  static const String apiBaseUrl = 'http://10.0.2.2:8000'; // Standard Android emulator localhost

  static const String defaultCurrency = 'TRY';
  static const List<String> supportedCurrencies = ['TRY', 'USD', 'EUR'];
}
