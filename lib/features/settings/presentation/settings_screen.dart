import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/notifications/notification_service.dart';
import '../../../core/services/app_update_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = ref.watch(stringsProvider);
    final themeMode = ref.watch(themeModeProvider);
    final currentLocale = ref.watch(appLocaleProvider);
    final notifSettings = ref.watch(notificationSettingsProvider);
    final updateState = ref.watch(appUpdateProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          tr.settings,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        children: [
          // 1. Theme Settings
          _buildSectionHeader(
            icon: Icons.palette_outlined,
            title: tr.theme,
            isDark: isDark,
          ),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SegmentedButton<ThemeMode>(
                    segments: [
                      ButtonSegment<ThemeMode>(
                        value: ThemeMode.light,
                        label: Text(tr.lightMode),
                        icon: const Icon(Icons.light_mode_outlined),
                      ),
                      ButtonSegment<ThemeMode>(
                        value: ThemeMode.dark,
                        label: Text(tr.darkMode),
                        icon: const Icon(Icons.dark_mode_outlined),
                      ),
                    ],
                    selected: {themeMode},
                    onSelectionChanged: (Set<ThemeMode> newSelection) {
                      ref
                          .read(themeModeProvider.notifier)
                          .setThemeMode(newSelection.first);
                    },
                    style: SegmentedButton.styleFrom(
                      selectedBackgroundColor:
                          AppTheme.primaryNavy.withOpacity(isDark ? 0.3 : 0.15),
                      selectedForegroundColor:
                          isDark ? AppTheme.accentEmerald : AppTheme.primaryNavy,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 2. Language Settings
          _buildSectionHeader(
            icon: Icons.language_outlined,
            title: tr.language,
            isDark: isDark,
          ),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SegmentedButton<String>(
                    segments: [
                      ButtonSegment<String>(
                        value: 'tr',
                        label: Text(tr.turkish),
                        icon: const Text('🇹🇷 '),
                      ),
                      ButtonSegment<String>(
                        value: 'en',
                        label: Text(tr.english),
                        icon: const Text('🇬🇧 '),
                      ),
                    ],
                    selected: {currentLocale},
                    onSelectionChanged: (Set<String> newSelection) {
                      ref
                          .read(appLocaleProvider.notifier)
                          .setLocale(newSelection.first);
                    },
                    style: SegmentedButton.styleFrom(
                      selectedBackgroundColor:
                          AppTheme.primaryNavy.withOpacity(isDark ? 0.3 : 0.15),
                      selectedForegroundColor:
                          isDark ? AppTheme.accentEmerald : AppTheme.primaryNavy,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 3. Notification Settings
          _buildSectionHeader(
            icon: Icons.notifications_outlined,
            title: tr.notifications,
            isDark: isDark,
          ),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  SwitchListTile(
                    title: Text(
                      tr.enableNotifications,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      tr.enableNotificationsDesc,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                      ),
                    ),
                    value: notifSettings.enabled,
                    activeColor: AppTheme.accentEmerald,
                    onChanged: (val) {
                      ref
                          .read(notificationSettingsProvider.notifier)
                          .toggleEnabled(val);
                    },
                  ),
                  if (notifSettings.enabled) ...[
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    SwitchListTile(
                      title: Text(tr.trialAlerts),
                      subtitle: Text(
                        tr.trialAlertsDesc,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                        ),
                      ),
                      value: notifSettings.trialAlerts,
                      activeColor: AppTheme.accentEmerald,
                      onChanged: (val) {
                        ref
                            .read(notificationSettingsProvider.notifier)
                            .toggleTrialAlerts(val);
                      },
                    ),
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    SwitchListTile(
                      title: Text(tr.billingAlerts),
                      subtitle: Text(
                        tr.billingAlertsDesc,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                        ),
                      ),
                      value: notifSettings.billingAlerts,
                      activeColor: AppTheme.accentEmerald,
                      onChanged: (val) {
                        ref
                            .read(notificationSettingsProvider.notifier)
                            .toggleBillingAlerts(val);
                      },
                    ),
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: isDark ? AppTheme.accentEmerald : AppTheme.primaryNavy,
                          side: BorderSide(
                            color: isDark ? AppTheme.accentEmerald : AppTheme.primaryNavy,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          minimumSize: const Size.fromHeight(44),
                        ),
                        icon: const Icon(Icons.send_outlined, size: 18),
                        label: Text(tr.testNotification),
                        onPressed: () async {
                          await ref
                              .read(notificationSettingsProvider.notifier)
                              .sendTestNotification(currentLocale);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(tr.testNotificationSent),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 4. In-App Updates (OTA via GitHub Releases)
          _buildSectionHeader(
            icon: Icons.system_update_alt_rounded,
            title: tr.appUpdates,
            isDark: isDark,
          ),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${tr.currentVersion}: v${AppUpdateService.currentVersion}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'GitHub Releases (OTA)',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.accentEmerald.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppTheme.accentEmerald,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'OTA Aktif',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.accentEmerald,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? AppTheme.primaryNavy : AppTheme.primaryNavy,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      minimumSize: const Size.fromHeight(46),
                    ),
                    icon: updateState.isChecking
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.sync_rounded, size: 18),
                    label: Text(
                      updateState.isChecking ? tr.checkingForUpdates : tr.checkForUpdates,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onPressed: updateState.isChecking
                        ? null
                        : () => ref.read(appUpdateProvider.notifier).checkForUpdates(
                              context: context,
                              tr: tr,
                              isManual: true,
                            ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 5. About & Privacy
          _buildSectionHeader(
            icon: Icons.shield_outlined,
            title: tr.about,
            isDark: isDark,
          ),
          const SizedBox(height: 10),
          Card(
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
                          color: AppTheme.accentEmerald.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.verified_user_outlined,
                          color: AppTheme.accentEmerald,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Subscription Brake',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              'v${AppUpdateService.currentVersion} • Financial Guard Dog',
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    tr.privacyNotice,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required bool isDark,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: isDark ? AppTheme.accentEmerald : AppTheme.primaryNavy,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isDark ? AppTheme.accentEmerald : AppTheme.primaryNavy,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}
