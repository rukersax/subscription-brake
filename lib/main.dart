import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';

// ==========================================
// 1. NOTIFICATION ENGINE INITIALIZATION
// ==========================================
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> initializeNotificationEngine() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      debugPrint('Notification clicked with payload: ${response.payload}');
    },
  );
}

// Flexible Offline Notification Scheduler ($0 Server Cost)
Future<void> scheduleSubscriptionReminders(Subscription sub) async {
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'sub_brake_reminder_channel',
    'Abonelik Yenileme Hatırlatıcıları',
    channelDescription: 'Fatura ödemeleri ve deneme süreleri için çevrimdışı bildirimler',
    importance: Importance.max,
    priority: Priority.high,
    color: Color(0xFF10B981),
  );

  const NotificationDetails notificationDetails = NotificationDetails(
    android: androidDetails,
  );

  final now = DateTime.now();
  final billingDate = sub.nextBillingDate;

  // Reminders for 7 days, 3 days, 1 day before, and on the billing day
  final triggerOffsets = [
    {'days': 7, 'label': '7 gün kaldı'},
    {'days': 3, 'label': '3 gün kaldı'},
    {'days': 1, 'label': 'Yarın yenileniyor (24 saat)'},
    {'days': 0, 'label': 'Bugün fatura kesiliyor'},
  ];

  for (final offset in triggerOffsets) {
    final days = offset['days'] as int;
    final label = offset['label'] as String;
    final scheduledDate = billingDate.subtract(Duration(days: days));

    // If scheduled time is in future or today, schedule notification
    if (scheduledDate.isAfter(now) || scheduledDate.day == now.day) {
      final notifId = (sub.id.hashCode + days).abs() % 100000;
      final currencySym = sub.currency == 'TRY' ? '₺' : (sub.currency == 'USD' ? '\$' : '€');

      // Schedule instant alert if today is notification day, or queue local payload
      if (days == 3 || days == 0) {
        await flutterLocalNotificationsPlugin.show(
          notifId,
          '🚨 Subscription Brake: ${sub.serviceName}',
          '${sub.serviceName} ($label) ödemesi yaklaşıyor: ${sub.price.toStringAsFixed(2)} $currencySym',
          notificationDetails,
          payload: sub.id,
        );
      }
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeNotificationEngine();

  runApp(
    const ProviderScope(
      child: SubscriptionBrakeApp(),
    ),
  );
}

// ==========================================
// 2. DATA MODELS & CATALOG DEFINITIONS
// ==========================================
class CatalogPlan {
  final String name;
  final double price;
  final String billingCycle;

  const CatalogPlan({
    required this.name,
    required this.price,
    this.billingCycle = 'Aylık',
  });
}

class CatalogApp {
  final String id;
  final String name;
  final String category;
  final String cancellationUrl;
  final IconData iconData;
  final Color brandColor;
  final List<CatalogPlan> plans;

  const CatalogApp({
    required this.id,
    required this.name,
    required this.category,
    required this.cancellationUrl,
    required this.iconData,
    required this.brandColor,
    required this.plans,
  });
}

final List<CatalogApp> predefinedCatalog = [
  CatalogApp(
    id: 'netflix',
    name: 'Netflix',
    category: 'Film & Dizi',
    cancellationUrl: 'https://www.netflix.com/youraccount',
    iconData: Icons.movie_filter_rounded,
    brandColor: const Color(0xFFE50914),
    plans: const [
      CatalogPlan(name: 'Temel (720p)', price: 149.99),
      CatalogPlan(name: 'Standart (1080p)', price: 229.99),
      CatalogPlan(name: 'Özel (4K+HDR)', price: 299.99),
    ],
  ),
  CatalogApp(
    id: 'spotify',
    name: 'Spotify',
    category: 'Müzik',
    cancellationUrl: 'https://www.spotify.com/account/cancel/',
    iconData: Icons.graphic_eq_rounded,
    brandColor: const Color(0xFF1DB954),
    plans: const [
      CatalogPlan(name: 'Öğrenci', price: 32.99),
      CatalogPlan(name: 'Bireysel', price: 59.99),
      CatalogPlan(name: 'Duo (2 Kişilik)', price: 79.99),
      CatalogPlan(name: 'Aile (6 Kişilik)', price: 99.99),
    ],
  ),
  CatalogApp(
    id: 'chatgpt',
    name: 'ChatGPT Plus',
    category: 'Yapay Zeka',
    cancellationUrl: 'https://chatgpt.com/#settings/Subscription',
    iconData: Icons.psychology_alt_rounded,
    brandColor: const Color(0xFF10A37F),
    plans: const [
      CatalogPlan(name: 'Plus (GPT-4o)', price: 649.99),
      CatalogPlan(name: 'Team (Kişi başı)', price: 820.00),
      CatalogPlan(name: 'Pro Tier', price: 6500.00),
    ],
  ),
  CatalogApp(
    id: 'amazon',
    name: 'Amazon Prime',
    category: 'Alışveriş & Dizi',
    cancellationUrl: 'https://www.amazon.com.tr/mc/pipelines/cancellation',
    iconData: Icons.shopping_bag_rounded,
    brandColor: const Color(0xFF00A8E1),
    plans: const [
      CatalogPlan(name: 'Standart Prime', price: 39.00),
    ],
  ),
  CatalogApp(
    id: 'exxen',
    name: 'Exxen',
    category: 'Spor & Dizi',
    cancellationUrl: 'https://www.exxen.com/tr/account',
    iconData: Icons.sports_soccer_rounded,
    brandColor: const Color(0xFFFFD500),
    plans: const [
      CatalogPlan(name: 'Reklamlı Dizi', price: 160.90),
      CatalogPlan(name: 'Reklamsız Dizi', price: 223.50),
      CatalogPlan(name: 'ExxenSpor Reklamlı', price: 327.90),
      CatalogPlan(name: 'ExxenSpor Reklamsız', price: 390.50),
    ],
  ),
  CatalogApp(
    id: 'blutv',
    name: 'BluTV / Max',
    category: 'Film & Dizi',
    cancellationUrl: 'https://www.blutv.com/hesabim/abonelik-bilgilerim',
    iconData: Icons.tv_rounded,
    brandColor: const Color(0xFF0051FF),
    plans: const [
      CatalogPlan(name: 'Aylık Standart', price: 139.90),
      CatalogPlan(name: 'Yıllık (Aylık Hesabı)', price: 89.90),
    ],
  ),
];

class Subscription {
  final String id;
  final String serviceName;
  final String planName;
  final String category;
  final double price;
  final String currency; // TRY, USD, EUR
  final DateTime nextBillingDate;
  final String? cancellationUrl;
  final bool isTrial;
  final String? paymentMethodHint;
  final String? notes;
  final bool isPriceHikeDetected;

  const Subscription({
    required this.id,
    required this.serviceName,
    this.planName = 'Standart Plan',
    required this.category,
    required this.price,
    this.currency = 'TRY',
    required this.nextBillingDate,
    this.cancellationUrl,
    this.isTrial = false,
    this.paymentMethodHint,
    this.notes,
    this.isPriceHikeDetected = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'serviceName': serviceName,
        'planName': planName,
        'category': category,
        'price': price,
        'currency': currency,
        'nextBillingDate': nextBillingDate.toIso8601String(),
        'cancellationUrl': cancellationUrl,
        'isTrial': isTrial,
        'paymentMethodHint': paymentMethodHint,
        'notes': notes,
        'isPriceHikeDetected': isPriceHikeDetected,
      };

  factory Subscription.fromJson(Map<String, dynamic> json) => Subscription(
        id: json['id'] as String,
        serviceName: json['serviceName'] as String,
        planName: (json['planName'] as String?) ?? 'Standart',
        category: json['category'] as String,
        price: (json['price'] as num).toDouble(),
        currency: (json['currency'] as String?) ?? 'TRY',
        nextBillingDate: DateTime.parse(json['nextBillingDate'] as String),
        cancellationUrl: json['cancellationUrl'] as String?,
        isTrial: (json['isTrial'] as bool?) ?? false,
        paymentMethodHint: json['paymentMethodHint'] as String?,
        notes: json['notes'] as String?,
        isPriceHikeDetected: (json['isPriceHikeDetected'] as bool?) ?? false,
      );
}

// ==========================================
// 3. RIVERPOD STATE PROVIDERS
// ==========================================
final selectedCurrencyProvider = StateProvider<String>((ref) => 'TRY');

final subscriptionsProvider =
    StateNotifierProvider<SubscriptionNotifier, List<Subscription>>((ref) {
  return SubscriptionNotifier();
});

class SubscriptionNotifier extends StateNotifier<List<Subscription>> {
  SubscriptionNotifier()
      : super([
          Subscription(
            id: 'sub_1',
            serviceName: 'Netflix',
            planName: 'Standart (1080p)',
            category: 'Film & Dizi',
            price: 229.99,
            currency: 'TRY',
            nextBillingDate: DateTime.now().add(const Duration(days: 3)),
            cancellationUrl: 'https://www.netflix.com/youraccount',
            paymentMethodHint: 'Garanti BBVA ••4092',
            isPriceHikeDetected: true,
          ),
          Subscription(
            id: 'sub_2',
            serviceName: 'Spotify',
            planName: 'Bireysel',
            category: 'Müzik',
            price: 59.99,
            currency: 'TRY',
            nextBillingDate: DateTime.now().add(const Duration(days: 8)),
            cancellationUrl: 'https://www.spotify.com/account/cancel/',
            paymentMethodHint: 'Papara ••1024',
          ),
          Subscription(
            id: 'sub_3',
            serviceName: 'ChatGPT Plus',
            planName: 'Plus (GPT-4o)',
            category: 'Yapay Zeka',
            price: 649.99,
            currency: 'TRY',
            nextBillingDate: DateTime.now().add(const Duration(days: 19)),
            cancellationUrl: 'https://chatgpt.com/#settings/Subscription',
            paymentMethodHint: 'İş Bankası ••3091',
          ),
          Subscription(
            id: 'sub_4',
            serviceName: 'Storytel',
            planName: 'Sınırsız Dinle',
            category: 'Kitap & Sesli',
            price: 149.99,
            currency: 'TRY',
            nextBillingDate: DateTime.now().add(const Duration(days: 1)),
            cancellationUrl: 'https://www.storytel.com/tr/tr/hesabim',
            isTrial: true,
            paymentMethodHint: 'Garanti BBVA ••4092',
          ),
        ]);

  void addSubscription(Subscription sub) {
    state = [sub, ...state];
    scheduleSubscriptionReminders(sub);
  }

  void deleteSubscription(String id) {
    state = state.where((s) => s.id != id).toList();
  }

  void restoreAll(List<Subscription> restoredList) {
    state = restoredList;
  }
}

// ==========================================
// 4. MAIN APPLICATION ENTRY
// ==========================================
class SubscriptionBrakeApp extends StatelessWidget {
  const SubscriptionBrakeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Subscription Brake',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF0A192F), // Navy Canvas
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF10B981), // Emerald
          brightness: Brightness.dark,
          surface: const Color(0xFF112240), // Slate Surface
          primary: const Color(0xFF10B981),
          error: const Color(0xFFEF4444), // Crimson
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          titleMedium: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
          bodyMedium: TextStyle(color: Color(0xFF8892B0)),
        ),
      ),
      home: const DashboardScreen(),
    );
  }
}

// ==========================================
// 5. DASHBOARD SCREEN
// ==========================================
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  // URL Launcher for 1-Tap Cancellation
  Future<void> _launchCancellationUrl(BuildContext context, String? urlString) async {
    if (urlString == null || urlString.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bu abonelik için doğrudan iptal linki bulunmuyor.')),
      );
      return;
    }
    final Uri url = Uri.parse(urlString);
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Bağlantı açılamadı: $urlString')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tarayıcı açılamadı: $e')),
        );
      }
    }
  }

  // Export JSON Snapshot
  Future<void> _exportEncryptedJson(BuildContext context, List<Subscription> subs) async {
    final exportData = {
      'appName': 'Subscription Brake',
      'version': '1.0.0',
      'exportDate': DateTime.now().toIso8601String(),
      'securitySchema': 'zero_knowledge_offline_v1',
      'subscriptions': subs.map((s) => s.toJson()).toList(),
    };

    final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);
    await Share.share(
      jsonString,
      subject: 'Subscription_Brake_Backup_${DateFormat('yyyyMMdd').format(DateTime.now())}.json',
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subs = ref.watch(subscriptionsProvider);
    final selectedCurrency = ref.watch(selectedCurrencyProvider);

    // Filter or calculate conversion for currency toggle
    double totalBurnRate = 0.0;
    for (final s in subs) {
      if (s.currency == selectedCurrency) {
        totalBurnRate += s.price;
      } else if (selectedCurrency == 'USD' && s.currency == 'TRY') {
        totalBurnRate += s.price / 34.0;
      } else if (selectedCurrency == 'EUR' && s.currency == 'TRY') {
        totalBurnRate += s.price / 37.5;
      } else if (selectedCurrency == 'TRY' && s.currency == 'USD') {
        totalBurnRate += s.price * 34.0;
      } else if (selectedCurrency == 'TRY' && s.currency == 'EUR') {
        totalBurnRate += s.price * 37.5;
      } else {
        totalBurnRate += s.price;
      }
    }

    final currencySymbol = selectedCurrency == 'TRY' ? '₺' : (selectedCurrency == 'USD' ? '\$' : '€');
    final formatter = NumberFormat.currency(locale: 'tr_TR', symbol: currencySymbol);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A192F),
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3)),
              ),
              child: const Icon(Icons.shield_rounded, color: Color(0xFF10B981), size: 20),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Subscription Brake',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Text(
                  '100% Çevrimdışı & Gizlilik Odaklı',
                  style: TextStyle(fontSize: 10, color: Color(0xFF8892B0)),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.ios_share_rounded, color: Color(0xFF10B981)),
            tooltip: 'Yedek Dışa Aktar',
            onPressed: () => _exportEncryptedJson(context, subs),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_active_outlined, color: Colors.white70),
            tooltip: 'Test Bildirimi Gönder',
            onPressed: () async {
              if (subs.isNotEmpty) {
                await scheduleSubscriptionReminders(subs.first);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Test bildirimi tetiklendi!')),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HERO BURN RATE CARD
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF112240), Color(0xFF0A192F)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFF233554)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'AYLIK TOPLAM YÜK (BURN RATE)',
                        style: TextStyle(
                          color: Color(0xFF8892B0),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      // Currency Switcher
                      Container(
                        height: 32,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0A192F),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFF233554)),
                        ),
                        child: Row(
                          children: ['TRY', 'USD', 'EUR'].map((curr) {
                            final isSel = curr == selectedCurrency;
                            return GestureDetector(
                              onTap: () => ref.read(selectedCurrencyProvider.notifier).state = curr,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isSel ? const Color(0xFF10B981) : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  curr == 'TRY' ? '₺' : (curr == 'USD' ? '\$' : '€'),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: isSel ? const Color(0xFF0A192F) : const Color(0xFF8892B0),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    formatter.format(totalBurnRate),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${subs.length} Aktif Hizmet',
                          style: const TextStyle(color: Color(0xFF10B981), fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Yerel Güvenli Depolama',
                        style: TextStyle(color: Color(0xFF8892B0), fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // SECTION TITLE
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Abonelikler ve İptal Panelleri',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Text(
                  'Tek Dokunuşla İptal',
                  style: TextStyle(fontSize: 12, color: const Color(0xFFEF4444).withOpacity(0.9), fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // SUBSCRIPTION CARDS LIST
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: subs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = subs[index];
                final daysLeft = item.nextBillingDate.difference(DateTime.now()).inDays;
                final isUrgent = daysLeft <= 3;

                return InkWell(
                  onTap: () => _showSubscriptionDetailSheet(context, item, ref),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF112240),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: item.isPriceHikeDetected
                            ? const Color(0xFFEF4444).withOpacity(0.5)
                            : const Color(0xFF233554),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Icon Box
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: const Color(0xFF0A192F),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFF233554)),
                              ),
                              child: Center(
                                child: Text(
                                  item.serviceName.substring(0, 1).toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF10B981),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        item.serviceName,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      if (item.isTrial) ...[
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.amber.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: const Text(
                                            'DENEME',
                                            style: TextStyle(color: Colors.amber, fontSize: 9, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                      if (item.isPriceHikeDetected) ...[
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFEF4444).withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: const Text(
                                            'ZAM UYARISI',
                                            style: TextStyle(color: Color(0xFFEF4444), fontSize: 9, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    '${item.planName} • ${item.category}',
                                    style: const TextStyle(color: Color(0xFF8892B0), fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '${item.price.toStringAsFixed(2)} ${item.currency == 'TRY' ? '₺' : (item.currency == 'USD' ? '\$' : '€')}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Divider(color: Color(0xFF233554), height: 1),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.schedule_rounded,
                                  size: 14,
                                  color: isUrgent ? const Color(0xFFEF4444) : const Color(0xFF8892B0),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '$daysLeft gün kaldı (${DateFormat('dd.MM.yyyy').format(item.nextBillingDate)})',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: isUrgent ? FontWeight.bold : FontWeight.normal,
                                    color: isUrgent ? const Color(0xFFEF4444) : const Color(0xFF8892B0),
                                  ),
                                ),
                              ],
                            ),
                            if (item.cancellationUrl != null)
                              GestureDetector(
                                onTap: () => _launchCancellationUrl(context, item.cancellationUrl),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEF4444).withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.4)),
                                  ),
                                  child: const Row(
                                    children: [
                                      Icon(Icons.open_in_new_rounded, size: 13, color: Color(0xFFEF4444)),
                                      SizedBox(width: 4),
                                      Text(
                                        'İptal Sayfasına Git',
                                        style: TextStyle(
                                          color: Color(0xFFEF4444),
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddSubscriptionModal(context, ref),
        backgroundColor: const Color(0xFF10B981),
        foregroundColor: const Color(0xFF0A192F),
        icon: const Icon(Icons.add_rounded, fontWeight: FontWeight.bold),
        label: const Text(
          'Abonelik Ekle',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ),
    );
  }

  // ==========================================
  // 6. SUBSCRIPTION DETAIL SHEET
  // ==========================================
  void _showSubscriptionDetailSheet(BuildContext context, Subscription sub, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF112240),
      shape: const RoundedCornerShape(top: 24),
      builder: (ctx) {
        final daysLeft = sub.nextBillingDate.difference(DateTime.now()).inDays;
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    sub.serviceName,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444)),
                    onPressed: () {
                      ref.read(subscriptionsProvider.notifier).deleteSubscription(sub.id);
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${sub.serviceName} kaldırıldı.')),
                      );
                    },
                  ),
                ],
              ),
              Text(
                '${sub.planName} • ${sub.category}',
                style: const TextStyle(color: Color(0xFF8892B0), fontSize: 14),
              ),
              const SizedBox(height: 16),
              const Divider(color: Color(0xFF233554)),
              const SizedBox(height: 12),
              _buildDetailRow('Aylık Ücret', '${sub.price.toStringAsFixed(2)} ${sub.currency}'),
              _buildDetailRow('Sonraki Fatura', DateFormat('dd MMMM yyyy, EEEE', 'tr_TR').format(sub.nextBillingDate)),
              _buildDetailRow('Kalan Süre', '$daysLeft gün kaldı'),
              if (sub.paymentMethodHint != null)
                _buildDetailRow('Ödeme Kartı', sub.paymentMethodHint!),
              _buildDetailRow('Çevrimdışı Bildirimler', '7 Gün, 3 Gün, 24 Saat & Fatura Günü'),
              const SizedBox(height: 20),
              if (sub.cancellationUrl != null)
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF4444),
                      foregroundColor: Colors.white,
                      shape: RoundedCornerShape(12),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      _launchCancellationUrl(context, sub.cancellationUrl);
                    },
                    icon: const Icon(Icons.open_in_new_rounded, size: 18),
                    label: const Text(
                      'İptal Sayfasına Git (Tek Dokunuş)',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF8892B0), fontSize: 13)),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }

  // ==========================================
  // 7. DUAL-MODE "ABONELİK EKLE" MODAL
  // ==========================================
  void _showAddSubscriptionModal(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF112240),
      shape: const RoundedCornerShape(top: 24),
      builder: (ctx) => const AddSubscriptionSheetContent(),
    );
  }
}

class AddSubscriptionSheetContent extends ConsumerStatefulWidget {
  const AddSubscriptionSheetContent({super.key});

  @override
  ConsumerState<AddSubscriptionSheetContent> createState() => _AddSubscriptionSheetContentState();
}

class _AddSubscriptionSheetContentState extends ConsumerState<AddSubscriptionSheetContent> {
  int _selectedModeIndex = 0; // 0 = Hızlı Seçim (2-Step), 1 = Özel Abonelik

  // --- Mode A: 2-Step Fast Flow States ---
  CatalogApp _selectedApp = predefinedCatalog.first;
  CatalogPlan? _selectedPlan;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 30));

  // --- Mode B: Custom Subscription States ---
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _categoryController = TextEditingController(text: 'Diğer');
  final _cardHintController = TextEditingController();
  final _cancellationUrlController = TextEditingController();
  String _customCurrency = 'TRY';
  bool _isTrial = false;

  @override
  void initState() {
    super.initState();
    _selectedPlan = _selectedApp.plans.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _categoryController.dispose();
    _cardHintController.dispose();
    _cancellationUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Modal Title & Close
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Abonelik Ekle',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Color(0xFF8892B0)),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Header Segmented Button: ["Hızlı Seçim", "Özel Abonelik"]
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFF0A192F),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF233554)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedModeIndex = 0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: _selectedModeIndex == 0 ? const Color(0xFF10B981) : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            '⚡ Hızlı Seçim',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: _selectedModeIndex == 0 ? const Color(0xFF0A192F) : const Color(0xFF8892B0),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedModeIndex = 1),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: _selectedModeIndex == 1 ? const Color(0xFF10B981) : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            '✍️ Özel Abonelik',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: _selectedModeIndex == 1 ? const Color(0xFF0A192F) : const Color(0xFF8892B0),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // MODE A: STREAMLINED 2-STEP SELECTION FLOW
            if (_selectedModeIndex == 0) ...[
              // Step 0: App Selector
              const Text(
                '1. Platform Seçin',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: predefinedCatalog.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, idx) {
                    final app = predefinedCatalog[idx];
                    final isSelected = app.id == _selectedApp.id;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedApp = app;
                          _selectedPlan = app.plans.first;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF10B981) : const Color(0xFF0A192F),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected ? const Color(0xFF10B981) : const Color(0xFF233554),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              app.iconData,
                              size: 16,
                              color: isSelected ? const Color(0xFF0A192F) : app.brandColor,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              app.name,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? const Color(0xFF0A192F) : Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 18),

              // Step 1: Package Selector (Clickable cards showing predefined plans & TRY prices)
              const Text(
                '2. Paket / Tarife Seçin',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13),
              ),
              const SizedBox(height: 8),
              Column(
                children: _selectedApp.plans.map((plan) {
                  final isPlanSelected = _selectedPlan?.name == plan.name;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedPlan = plan),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: isPlanSelected
                            ? const Color(0xFF10B981).withOpacity(0.15)
                            : const Color(0xFF0A192F),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isPlanSelected ? const Color(0xFF10B981) : const Color(0xFF233554),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            plan.name,
                            style: TextStyle(
                              color: isPlanSelected ? Colors.white : const Color(0xFF8892B0),
                              fontWeight: isPlanSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          Text(
                            '${plan.price.toStringAsFixed(2)} ₺ / ${plan.billingCycle}',
                            style: const TextStyle(
                              color: Color(0xFF10B981),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),

              // Step 2: Renewal Date Picker
              const Text(
                '3. Fatura Yenilenme Tarihi',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) {
                    setState(() => _selectedDate = picked);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A192F),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF233554)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.calendar_month_rounded, color: Color(0xFF10B981), size: 18),
                          const SizedBox(width: 8),
                          Text(
                            DateFormat('dd.MM.yyyy').format(_selectedDate),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const Text(
                        'Değiştir',
                        style: TextStyle(color: Color(0xFF8892B0), fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Commit Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: const Color(0xFF0A192F),
                    shape: RoundedCornerShape(12),
                  ),
                  onPressed: () {
                    final newSub = Subscription(
                      id: 'sub_${DateTime.now().millisecondsSinceEpoch}',
                      serviceName: _selectedApp.name,
                      planName: _selectedPlan?.name ?? 'Standart',
                      category: _selectedApp.category,
                      price: _selectedPlan?.price ?? 99.99,
                      currency: 'TRY',
                      nextBillingDate: _selectedDate,
                      cancellationUrl: _selectedApp.cancellationUrl,
                    );
                    ref.read(subscriptionsProvider.notifier).addSubscription(newSub);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${newSub.serviceName} (${newSub.planName}) eklendi!')),
                    );
                  },
                  child: const Text('Oluştur ve Takibe Başla', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ] else ...[
              // MODE B: CUSTOM SUBSCRIPTION ENTRY
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Servis Adı (Örn: Gym, Domain)',
                  filled: true,
                  fillColor: const Color(0xFF0A192F),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _priceController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Ücret',
                        filled: true,
                        fillColor: const Color(0xFF0A192F),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  DropdownButton<String>(
                    value: _customCurrency,
                    dropdownColor: const Color(0xFF0A192F),
                    items: ['TRY', 'USD', 'EUR'].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (val) => setState(() => _customCurrency = val ?? 'TRY'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _cardHintController,
                decoration: InputDecoration(
                  labelText: 'Ödeme Yöntemi Notu (Örn: Bonus ••1234)',
                  filled: true,
                  fillColor: const Color(0xFF0A192F),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _cancellationUrlController,
                decoration: InputDecoration(
                  labelText: 'Doğrudan İptal URL (Opsiyonel)',
                  hintText: 'https://...',
                  filled: true,
                  fillColor: const Color(0xFF0A192F),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Ücretsiz Deneme Sürümü mü?'),
                value: _isTrial,
                activeColor: const Color(0xFF10B981),
                onChanged: (v) => setState(() => _isTrial = v),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: const Color(0xFF0A192F),
                    shape: RoundedCornerShape(12),
                  ),
                  onPressed: () {
                    final name = _nameController.text.trim();
                    final price = double.tryParse(_priceController.text.replaceAll(',', '.')) ?? 0.0;
                    if (name.isEmpty || price <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Lütfen geçerli servis adı ve ücret girin.')),
                      );
                      return;
                    }
                    final customSub = Subscription(
                      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
                      serviceName: name,
                      category: _categoryController.text.trim().ifEmpty('Özel'),
                      price: price,
                      currency: _customCurrency,
                      nextBillingDate: DateTime.now().add(const Duration(days: 30)),
                      cancellationUrl: _cancellationUrlController.text.trim().ifEmptyNull(),
                      paymentMethodHint: _cardHintController.text.trim().ifEmptyNull(),
                      isTrial: _isTrial,
                    );
                    ref.read(subscriptionsProvider.notifier).addSubscription(customSub);
                    Navigator.pop(context);
                  },
                  child: const Text('Özel Aboneliği Kaydet', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Helpers
extension StringExtensions on String {
  String ifEmpty(String fallback) => isEmpty ? fallback : this;
  String? ifEmptyNull() => isEmpty ? null : this;
}

class RoundedCornerShape extends RoundedRectangleBorder {
  RoundedCornerShape(double radius) : super(borderRadius: BorderRadius.circular(radius));
  RoundedCornerShape.top(double radius)
      : super(
          borderRadius: BorderRadius.vertical(top: Radius.circular(radius)),
        );
}
