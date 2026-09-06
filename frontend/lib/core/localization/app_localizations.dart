import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../storage/secure_storage_service.dart';

class AppStrings {
  final String appTitle;
  final String appSubtitle;
  final String settings;
  final String theme;
  final String lightMode;
  final String darkMode;
  final String language;
  final String turkish;
  final String english;
  final String notifications;
  final String enableNotifications;
  final String enableNotificationsDesc;
  final String trialAlerts;
  final String trialAlertsDesc;
  final String billingAlerts;
  final String billingAlertsDesc;
  final String testNotification;
  final String testNotificationDesc;
  final String testNotificationSent;
  final String about;
  final String privacyNotice;
  final String addSubscription;
  final String editSubscription;
  final String delete;
  final String cancel;
  final String save;
  final String monthlyBurnRate;
  final String activeSubscriptions;
  final String activeTrials;
  final String all;
  final String emptyTitle;
  final String emptyDesc;
  final String addFirst;
  final String undo;
  final String deleteConfirm;
  final String deletePrompt;
  final String notes;
  final String category;
  final String billingCycle;
  final String price;
  final String nextBillingDate;
  final String trialExpiration;
  final String paymentMethod;
  final String cancellationUrl;
  final String cancellationUrlHint;
  final String cancellationUrlDesc;
  final String cancelOrManage;
  final String openCancellationPage;
  final String selectFromCatalog;
  final String customSubscription;
  final String reload;
  final String trialBadge;
  final String hikeBadge;
  final String quickFillPlayStore;
  final String quickFillAppStore;
  final String appUpdates;
  final String checkForUpdates;
  final String checkingForUpdates;
  final String alreadyLatestVersion;
  final String updateAvailable;
  final String updateAvailableDesc;
  final String updateNow;
  final String later;
  final String currentVersion;
  final String latestVersion;
  final String releaseNotes;

  const AppStrings({
    required this.appTitle,
    required this.appSubtitle,
    required this.settings,
    required this.theme,
    required this.lightMode,
    required this.darkMode,
    required this.language,
    required this.turkish,
    required this.english,
    required this.notifications,
    required this.enableNotifications,
    required this.enableNotificationsDesc,
    required this.trialAlerts,
    required this.trialAlertsDesc,
    required this.billingAlerts,
    required this.billingAlertsDesc,
    required this.testNotification,
    required this.testNotificationDesc,
    required this.testNotificationSent,
    required this.about,
    required this.privacyNotice,
    required this.addSubscription,
    required this.editSubscription,
    required this.delete,
    required this.cancel,
    required this.save,
    required this.monthlyBurnRate,
    required this.activeSubscriptions,
    required this.activeTrials,
    required this.all,
    required this.emptyTitle,
    required this.emptyDesc,
    required this.addFirst,
    required this.undo,
    required this.deleteConfirm,
    required this.deletePrompt,
    required this.notes,
    required this.category,
    required this.billingCycle,
    required this.price,
    required this.nextBillingDate,
    required this.trialExpiration,
    required this.paymentMethod,
    required this.cancellationUrl,
    required this.cancellationUrlHint,
    required this.cancellationUrlDesc,
    required this.cancelOrManage,
    required this.openCancellationPage,
    required this.selectFromCatalog,
    required this.customSubscription,
    required this.reload,
    required this.trialBadge,
    required this.hikeBadge,
    required this.quickFillPlayStore,
    required this.quickFillAppStore,
    required this.appUpdates,
    required this.checkForUpdates,
    required this.checkingForUpdates,
    required this.alreadyLatestVersion,
    required this.updateAvailable,
    required this.updateAvailableDesc,
    required this.updateNow,
    required this.later,
    required this.currentVersion,
    required this.latestVersion,
    required this.releaseNotes,
  });
}

const trStrings = AppStrings(
  appTitle: 'Subscription Brake',
  appSubtitle: 'Financial Guard Dog',
  settings: 'Ayarlar',
  theme: 'Tema Ayarları',
  lightMode: 'Aydınlık Mod',
  darkMode: 'Karanlık Mod',
  language: 'Dil Ayarları',
  turkish: 'Türkçe',
  english: 'English',
  notifications: 'Bildirim Ayarları',
  enableNotifications: 'Bildirimleri Etkinleştir',
  enableNotificationsDesc: 'Fatura ve deneme süresi hatırlatıcıları',
  trialAlerts: 'Deneme Süresi Uyarıları',
  trialAlertsDesc: 'Deneme süresi dolmadan 24 saat önce haber ver',
  billingAlerts: 'Fatura Hatırlatıcıları',
  billingAlertsDesc: 'Yenileme tarihinden 2 gün önce haber ver',
  testNotification: 'Test Bildirimi Gönder',
  testNotificationDesc: 'Cihazınızda bildirimlerin çalıştığını doğrulayın',
  testNotificationSent: 'Test bildirimi başarıyla gönderildi!',
  about: 'Hakkında',
  privacyNotice: 'Subscription Brake %100 çevrimdışı ve gizlilik odaklı çalışır. Hiçbir finansal bilginiz sunucuya gönderilmez.',
  addSubscription: 'Abonelik Ekle',
  editSubscription: 'Aboneliği Düzenle',
  delete: 'Sil',
  cancel: 'Vazgeç',
  save: 'Kaydet',
  monthlyBurnRate: 'Aylık Toplam Harcama',
  activeSubscriptions: 'Aktif Abonelik',
  activeTrials: 'Aktif Deneme',
  all: 'Tümü',
  emptyTitle: 'Henüz abonelik eklenmedi',
  emptyDesc: 'Takip etmek istediğiniz dijital aboneliklerinizi ekleyin.',
  addFirst: 'İlk Aboneliğini Ekle',
  undo: 'GERİ AL',
  deleteConfirm: 'Aboneliği Sil?',
  deletePrompt: 'Bu aboneliği takipten çıkarmak istediğinize emin misiniz?',
  notes: 'Notlar',
  category: 'Kategori',
  billingCycle: 'Faturalandırma Döngüsü',
  price: 'Ücret',
  nextBillingDate: 'Sonraki Fatura Tarihi',
  trialExpiration: 'Deneme Süresi Sonu',
  paymentMethod: 'Ödeme Yöntemi',
  cancellationUrl: 'İptal / Yönetim Linki',
  cancellationUrlHint: 'https://play.google.com/store/account/subscriptions',
  cancellationUrlDesc: 'Aboneliği kolayca iptal edebileceğiniz doğrudan web veya mağaza linki',
  cancelOrManage: 'Aboneliği İptal Et / Yönet',
  openCancellationPage: 'İptal Sayfasına Git',
  selectFromCatalog: 'Katalogdan Seç',
  customSubscription: 'Özel Abonelik',
  reload: 'Yenile',
  trialBadge: 'DENEME',
  hikeBadge: 'ZAM',
  quickFillPlayStore: 'Google Play',
  quickFillAppStore: 'App Store',
  appUpdates: 'Uygulama Güncellemeleri',
  checkForUpdates: 'Güncellemeleri Denetle',
  checkingForUpdates: 'Güncellemeler kontrol ediliyor...',
  alreadyLatestVersion: 'Harika! En güncel sürümü kullanıyorsunuz.',
  updateAvailable: 'Yeni Güncelleme Mevcut!',
  updateAvailableDesc: 'Yeni bir sürüm yayınlandı. Yenilikleri ve düzeltmeleri almak için güncelleyin.',
  updateNow: 'Şimdi Güncelle',
  later: 'Daha Sonra',
  currentVersion: 'Mevcut Sürüm',
  latestVersion: 'En Son Sürüm',
  releaseNotes: 'Yenilikler',
);

const enStrings = AppStrings(
  appTitle: 'Subscription Brake',
  appSubtitle: 'Financial Guard Dog',
  settings: 'Settings',
  theme: 'Theme Settings',
  lightMode: 'Light Mode',
  darkMode: 'Dark Mode',
  language: 'Language Settings',
  turkish: 'Türkçe',
  english: 'English',
  notifications: 'Notification Settings',
  enableNotifications: 'Enable Notifications',
  enableNotificationsDesc: 'Reminders for renewals & trial expiries',
  trialAlerts: 'Trial Expiry Alerts',
  trialAlertsDesc: 'Notify 24 hours before free trial ends',
  billingAlerts: 'Renewal Reminders',
  billingAlertsDesc: 'Notify 2 days before payment renewal',
  testNotification: 'Send Test Notification',
  testNotificationDesc: 'Verify push notifications work on this device',
  testNotificationSent: 'Test notification sent successfully!',
  about: 'About',
  privacyNotice: 'Subscription Brake runs 100% offline & privacy-first. No financial details ever leave your device.',
  addSubscription: 'Add Subscription',
  editSubscription: 'Edit Subscription',
  delete: 'Delete',
  cancel: 'Cancel',
  save: 'Save',
  monthlyBurnRate: 'Monthly Burn Rate',
  activeSubscriptions: 'Active Subscriptions',
  activeTrials: 'Active Trials',
  all: 'All',
  emptyTitle: 'No subscriptions added yet',
  emptyDesc: 'Add your recurring digital subscriptions to start tracking.',
  addFirst: 'Add First Subscription',
  undo: 'UNDO',
  deleteConfirm: 'Delete Subscription?',
  deletePrompt: 'Are you sure you want to stop tracking this subscription?',
  notes: 'Notes',
  category: 'Category',
  billingCycle: 'Billing Cycle',
  price: 'Price',
  nextBillingDate: 'Next Billing Date',
  trialExpiration: 'Trial Expiration',
  paymentMethod: 'Payment Method',
  cancellationUrl: 'Cancellation / Manage URL',
  cancellationUrlHint: 'https://play.google.com/store/account/subscriptions',
  cancellationUrlDesc: 'Direct link to cancel or manage this subscription',
  cancelOrManage: 'Cancel / Manage Subscription',
  openCancellationPage: 'Go to Cancellation Page',
  selectFromCatalog: 'Select from Catalog',
  customSubscription: 'Custom Subscription',
  reload: 'Reload',
  trialBadge: 'TRIAL',
  hikeBadge: 'HIKE',
  quickFillPlayStore: 'Google Play',
  quickFillAppStore: 'App Store',
  appUpdates: 'App Updates',
  checkForUpdates: 'Check for Updates',
  checkingForUpdates: 'Checking for updates...',
  alreadyLatestVersion: 'Great! You are using the latest version.',
  updateAvailable: 'New Update Available!',
  updateAvailableDesc: 'A new version has been released. Update now to get the latest features and fixes.',
  updateNow: 'Update Now',
  later: 'Later',
  currentVersion: 'Current Version',
  latestVersion: 'Latest Version',
  releaseNotes: 'Release Notes',
);

class AppLocalizations {
  static AppStrings get(String locale) {
    if (locale.toLowerCase().startsWith('en')) {
      return enStrings;
    }
    return trStrings;
  }
}

class AppLocaleNotifier extends StateNotifier<String> {
  final SecureStorageService _storage = SecureStorageService();

  AppLocaleNotifier() : super('tr') {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final saved = await _storage.getLocale();
    if (saved != null && (saved == 'tr' || saved == 'en')) {
      state = saved;
    }
  }

  Future<void> setLocale(String locale) async {
    state = locale;
    await _storage.saveLocale(locale);
  }
}

final appLocaleProvider = StateNotifierProvider<AppLocaleNotifier, String>((ref) {
  return AppLocaleNotifier();
});

final stringsProvider = Provider<AppStrings>((ref) {
  final locale = ref.watch(appLocaleProvider);
  return AppLocalizations.get(locale);
});
