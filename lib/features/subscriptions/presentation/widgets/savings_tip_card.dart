import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';

final savingsTipIndexProvider = StateProvider<int>((ref) => 0);

class SavingsTipCard extends ConsumerWidget {
  const SavingsTipCard({super.key});

  static const List<Map<String, String>> _tipsTr = [
    {
      'title': 'Ücretsiz Denemeleri Anında İptal Edin',
      'desc': 'Birçok servis deneme süresini başlattığınız an iptal etseniz bile süresi bitene kadar kullanmanıza izin verir. Böylece unutup para ödemezsiniz!',
      'icon': 'timer',
    },
    {
      'title': 'Yıllık Plan Yerine Aylık Deneyin',
      'desc': 'Gerçekten tüm yıl kullanacağınızdan emin olmadığınız servislere yıllık taahhüt vermek yerine 1-2 ay deneyip karar verin.',
      'icon': 'calendar',
    },
    {
      'title': 'Aile & Ortak Planları Değerlendirin',
      'desc': 'Spotify, YouTube Premium veya iCloud gibi servislerde aile planı kullanarak kişi başı maliyeti %60\'a varan oranda düşürebilirsiniz.',
      'icon': 'group',
    },
    {
      'title': 'Öğrenci İndirimlerini Kaçırmayın',
      'desc': 'Eğer öğrenciyseniz veya bir öğrenci yakınınız varsa Spotify, Apple Music, YouTube ve GitHub gibi platformlar %50 indirim sunar.',
      'icon': 'school',
    },
    {
      'title': 'Aynı Amaca Hizmet Edenleri Birleştirin',
      'desc': 'Hem Netflix, hem Disney+, hem de BluTV aynı anda mı ödüyorsunuz? Birini izleyip bitirip diğerine geçerek harcamanızı üçe bölebilirsiniz.',
      'icon': 'movie',
    },
    {
      'title': 'Kullanılmayan Bulut Depolamaları Temizleyin',
      'desc': 'iCloud veya Google One planınızı yükseltmeden önce eski videoları ve yedekleri temizleyerek alt pakete düşmeyi deneyin.',
      'icon': 'cloud',
    },
  ];

  static const List<Map<String, String>> _tipsEn = [
    {
      'title': 'Cancel Free Trials Immediately',
      'desc': 'Most services keep your trial active until the end date even if you cancel on day one. You won\'t get billed by accident!',
      'icon': 'timer',
    },
    {
      'title': 'Test Monthly Before Annual Commitment',
      'desc': 'Don\'t lock into a yearly subscription unless you\'ve actively used the service for at least two consecutive months.',
      'icon': 'calendar',
    },
    {
      'title': 'Leverage Family & Group Plans',
      'desc': 'Sharing an official family plan for services like Spotify, YouTube, or Apple One can cut your personal cost by up to 60%.',
      'icon': 'group',
    },
    {
      'title': 'Check for Student Discounts',
      'desc': 'Services like Spotify, Apple Music, and Amazon Prime offer up to 50% discount for verified students.',
      'icon': 'school',
    },
    {
      'title': 'Rotate Streaming Subscriptions',
      'desc': 'Instead of paying for Netflix, Disney+, and HBO all at once, subscribe to one at a time, binge watch, and swap.',
      'icon': 'movie',
    },
    {
      'title': 'Audit Cloud Storage Hoarding',
      'desc': 'Before upgrading your iCloud or Google Drive storage tier, clean up duplicate photos and large video files.',
      'icon': 'cloud',
    },
  ];

  IconData _getTipIcon(String? iconType) {
    switch (iconType) {
      case 'timer':
        return Icons.timer_outlined;
      case 'calendar':
        return Icons.calendar_month_outlined;
      case 'group':
        return Icons.group_outlined;
      case 'school':
        return Icons.school_outlined;
      case 'movie':
        return Icons.movie_outlined;
      case 'cloud':
        return Icons.cloud_outlined;
      default:
        return Icons.lightbulb_outline;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = ref.watch(stringsProvider);
    final locale = ref.watch(appLocaleProvider);
    final isEn = locale.toLowerCase().startsWith('en');
    final tips = isEn ? _tipsEn : _tipsTr;

    final currentIndex = ref.watch(savingsTipIndexProvider);
    final currentTip = tips[currentIndex % tips.length];

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: const Color(0xFF10B981).withOpacity(0.3),
          width: 1.5,
        ),
      ),
      color: const Color(0xFFF0FDF4), // Warm light emerald background
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getTipIcon(currentTip['icon']),
                    color: const Color(0xFF047857),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            tr.financialTipTitle.toUpperCase(),
                            style: const TextStyle(
                              color: Color(0xFF047857),
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF047857),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${(currentIndex % tips.length) + 1}/${tips.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        currentTip['title'] ?? '',
                        style: const TextStyle(
                          color: Color(0xFF064E3B),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: tr.nextTip,
                  icon: const Icon(Icons.refresh, color: Color(0xFF047857), size: 20),
                  onPressed: () {
                    ref.read(savingsTipIndexProvider.notifier).state =
                        (currentIndex + 1) % tips.length;
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              currentTip['desc'] ?? '',
              style: const TextStyle(
                color: Color(0xFF065F46),
                fontSize: 12.5,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
