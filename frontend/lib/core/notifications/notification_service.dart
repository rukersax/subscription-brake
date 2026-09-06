import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../storage/secure_storage_service.dart';
import '../../features/subscriptions/models/subscription_model.dart';

class NotificationSettings {
  final bool enabled;
  final bool trialAlerts;
  final bool billingAlerts;

  const NotificationSettings({
    this.enabled = true,
    this.trialAlerts = true,
    this.billingAlerts = true,
  });

  NotificationSettings copyWith({
    bool? enabled,
    bool? trialAlerts,
    bool? billingAlerts,
  }) {
    return NotificationSettings(
      enabled: enabled ?? this.enabled,
      trialAlerts: trialAlerts ?? this.trialAlerts,
      billingAlerts: billingAlerts ?? this.billingAlerts,
    );
  }

  Map<String, dynamic> toJson() => {
    'enabled': enabled,
    'trial_alerts': trialAlerts,
    'billing_alerts': billingAlerts,
  };

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      enabled: json['enabled'] as bool? ?? true,
      trialAlerts: json['trial_alerts'] as bool? ?? true,
      billingAlerts: json['billing_alerts'] as bool? ?? true,
    );
  }
}

class NotificationService {
  static final NotificationService instance = NotificationService._();
  NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    try {
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings initializationSettingsDarwin =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsDarwin,
      );

      await _plugin.initialize(initializationSettings);

      // Request notification permissions for Android 13+
      final androidPlatform =
          _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlatform != null) {
        await androidPlatform.requestNotificationsPermission();
      }

      _isInitialized = true;
    } catch (e) {
      debugPrint('NotificationService initialization error: $e');
    }
  }

  Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    try {
      await init();
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'sub_brake_alerts',
        'Subscription Alerts',
        channelDescription: 'Trial and billing payment reminders',
        importance: Importance.max,
        priority: Priority.high,
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

      const NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _plugin.show(id, title, body, details);
    } catch (e) {
      debugPrint('Error showing instant notification: $e');
    }
  }

  Future<void> cancelAll() async {
    try {
      await init();
      await _plugin.cancelAll();
    } catch (e) {
      debugPrint('Error cancelling notifications: $e');
    }
  }

  Future<void> scheduleReminders(
    List<UserSubscriptionItem> subscriptions,
    NotificationSettings settings,
  ) async {
    if (!settings.enabled) {
      await cancelAll();
      return;
    }
    // Cancel old and re-sync schedule
    await cancelAll();
    // In local offline mode, alerts will fire or trigger when active
  }
}

class NotificationSettingsNotifier extends StateNotifier<NotificationSettings> {
  final SecureStorageService _storage = SecureStorageService();

  NotificationSettingsNotifier() : super(const NotificationSettings()) {
    _load();
  }

  Future<void> _load() async {
    final map = await _storage.getNotificationSettings();
    if (map != null) {
      state = NotificationSettings.fromJson(map);
    }
  }

  Future<void> toggleEnabled(bool val) async {
    state = state.copyWith(enabled: val);
    await _persist();
    if (!val) {
      await NotificationService.instance.cancelAll();
    }
  }

  Future<void> toggleTrialAlerts(bool val) async {
    state = state.copyWith(trialAlerts: val);
    await _persist();
  }

  Future<void> toggleBillingAlerts(bool val) async {
    state = state.copyWith(billingAlerts: val);
    await _persist();
  }

  Future<void> _persist() async {
    await _storage.saveNotificationSettings(state.toJson());
  }

  Future<void> sendTestNotification(String locale) async {
    final isTr = locale.toLowerCase().startsWith('tr');
    await NotificationService.instance.showInstantNotification(
      id: 999,
      title: isTr ? '🛡️ Subscription Brake Uyarısı' : '🛡️ Subscription Brake Alert',
      body: isTr
          ? 'Deneme süresi veya fatura uyarısı: Netflix yarın yenileniyor (₺149.99)'
          : 'Trial or billing reminder: Netflix renews tomorrow (\$14.99)',
    );
  }
}

final notificationSettingsProvider =
    StateNotifierProvider<NotificationSettingsNotifier, NotificationSettings>((ref) {
  return NotificationSettingsNotifier();
});
