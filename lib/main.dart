import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

// --- Global Local Notification Plugin ---
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Notification Initialization
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  runApp(
    const ProviderScope(
      child: SubscriptionBrakeApp(),
    ),
  );
}

// --- Data Model ---
class Subscription {
  final String id;
  final String serviceName;
  final String category;
  final double price;
  final String currency;
  final DateTime nextBillingDate;
  final String? cancellationUrl;
  final bool isTrial;
  final String? paymentMethodHint;
  final bool isPriceHikeDetected;

  const Subscription({
    required this.id,
    required this.serviceName,
    required this.category,
    required this.price,
    this.currency = 'TRY',
    required this.nextBillingDate,
    this.cancellationUrl,
    this.isTrial = false,
    this.paymentMethodHint,
    this.isPriceHikeDetected = false,
  });
}

// --- Sample Initial Data ---
final initialSubscriptions = [
  Subscription(
    id: '1',
    serviceName: 'Netflix',
    category: 'Film & Dizi',
    price: 229.99,
    nextBillingDate: DateTime.now().add(const Duration(days: 3)),
    cancellationUrl: 'https://www.netflix.com/youraccount',
    paymentMethodHint: 'Garanti BBVA ••4092',
    isPriceHikeDetected: true,
  ),
  Subscription(
    id: '2',
    serviceName: 'Spotify',
    category: 'Müzik',
    price: 59.99,
    nextBillingDate: DateTime.now().add(const Duration(days: 5)),
    cancellationUrl: 'https://www.spotify.com/account/cancel/',
    paymentMethodHint: 'Papara ••1024',
  ),
  Subscription(
    id: '3',
    serviceName: 'Storytel',
    category: 'Kitap & Sesli',
    price: 149.99,
    nextBillingDate: DateTime.now().add(const Duration(days: 1)),
    cancellationUrl: 'https://www.storytel.com/tr/tr/hesabim',
    isTrial: true,
    paymentMethodHint: 'Garanti BBVA ••4092',
  ),
  Subscription(
    id: '4',
    serviceName: 'ChatGPT Plus',
    category: 'Yapay Zeka',
    price: 649.99,
    nextBillingDate: DateTime.now().add(const Duration(days: 22)),
    cancellationUrl: 'https://chatgpt.com/#settings/Subscription',
    paymentMethodHint: 'İş Bankası ••3091',
  ),
];

// --- State Provider ---
final subscriptionsProvider =
    StateNotifierProvider<SubscriptionNotifier, List<Subscription>>((ref) {
  return SubscriptionNotifier();
});

class SubscriptionNotifier extends StateNotifier<List<Subscription>> {
  SubscriptionNotifier() : super(initialSubscriptions);

  void addSubscription(Subscription sub) {
    state = [...state, sub];
  }

  void removeSubscription(String id) {
    state = state.where((s) => s.id != id).toList();
  }
}

// --- Main App Widget ---
class SubscriptionBrakeApp extends StatelessWidget {
  const SubscriptionBrakeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Subscription Brake',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF0F172A), // Dark slate
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF10B981), // Emerald
          brightness: Brightness.dark,
          surface: const Color(0xFF1E293B),
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          bodyMedium: TextStyle(color: Color(0xFF94A3B8)),
        ),
      ),
      home: const DashboardScreen(),
    );
  }
}

// --- Dashboard Screen ---
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  Future<void> _launchCancellationUrl(BuildContext context, String? urlString) async {
    if (urlString == null || urlString.isEmpty) return;
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bağlantı açılamadı: $urlString')),
        );
      }
    }
  }

  Future<void> _sendTestNotification() async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'sub_brake_channel',
      'Abonelik Uyarıları',
      channelDescription: 'Fatura günü ve deneme süresi bildirimleri',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      '🚨 Subscription Brake Hatırlatması',
      'Netflix aboneliğiniz 3 gün sonra yenilenecek (₺229.99).',
      notificationDetails,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subs = ref.watch(subscriptionsProvider);
    final totalMonthly = subs.fold<double>(0, (sum, item) => sum + item.price);
    final currencyFormatter = NumberFormat.currency(locale: 'tr_TR', symbol: '₺');
    final dateFormatter = DateFormat('dd MMM yyyy', 'tr_TR');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.shield_outlined, color: Color(0xFF10B981), size: 20),
            ),
            const SizedBox(width: 10),
            const Text(
              'Subscription Brake',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_active_outlined, color: Color(0xFF10B981)),
            tooltip: 'Bildirim Testi',
            onPressed: () async {
              await _sendTestNotification();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Çevrimdışı test bildirimi gönderildi!')),
                );
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Monthly Summary Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF334155)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'AYLIK TOPLAM YÜK',
                    style: TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currencyFormatter.format(totalMonthly),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Aktif ${subs.length} abonelik izleniyor (%100 Çevrimdışı & AES-256)',
                    style: const TextStyle(color: Color(0xFF10B981), fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'Abonelikler ve Doğrudan İptal',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 12),

            // Subscription List
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: subs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final sub = subs[index];
                final daysLeft = sub.nextBillingDate.difference(DateTime.now()).inDays;

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: sub.isPriceHikeDetected
                          ? const Color(0xFFEF4444).withOpacity(0.5)
                          : const Color(0xFF334155),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    sub.serviceName,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  if (sub.isTrial) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.amber.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text(
                                        'DENEME',
                                        style: TextStyle(color: Colors.amber, fontSize: 10, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                  if (sub.isPriceHikeDetected) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEF4444).withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text(
                                        'ZAM UYARISI',
                                        style: TextStyle(color: Color(0xFFEF4444), fontSize: 10, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${sub.category} • ${sub.paymentMethodHint ?? "Kart bilgisi yok"}',
                                style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                              ),
                            ],
                          ),
                          Text(
                            currencyFormatter.format(sub.price),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(color: Color(0xFF334155), height: 1),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today_outlined,
                                size: 14,
                                color: daysLeft <= 3 ? const Color(0xFFEF4444) : const Color(0xFF94A3B8),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '$daysLeft gün kaldı (${dateFormatter.format(sub.nextBillingDate)})',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: daysLeft <= 3 ? const Color(0xFFEF4444) : const Color(0xFF94A3B8),
                                  fontWeight: daysLeft <= 3 ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                          if (sub.cancellationUrl != null)
                            InkWell(
                              onTap: () => _launchCancellationUrl(context, sub.cancellationUrl),
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEF4444).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.3)),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.open_in_new, size: 14, color: Color(0xFFEF4444)),
                                    SizedBox(width: 4),
                                    Text(
                                      'Tek Tıkla İptal',
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
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
