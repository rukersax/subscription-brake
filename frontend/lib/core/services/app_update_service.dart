import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../localization/app_localizations.dart';
import '../storage/secure_storage_service.dart';
import '../theme/app_theme.dart';

class AppReleaseInfo {
  final String currentVersion;
  final String latestVersion;
  final bool hasUpdate;
  final String? releaseNotes;
  final String downloadUrl;
  final String htmlUrl;

  const AppReleaseInfo({
    required this.currentVersion,
    required this.latestVersion,
    required this.hasUpdate,
    this.releaseNotes,
    required this.downloadUrl,
    required this.htmlUrl,
  });
}

class AppUpdateService {
  static const String currentVersion = '1.2.0';
  static const String defaultRepo = 'rukersax/subscription-brake';
  static const String fallbackRepo = 'berkayturangs/subscription-brake';
  static const String _keyCustomRepo = 'update_github_repo';

  final SecureStorageService _storage = SecureStorageService();

  Future<String> getTargetRepo() async {
    return defaultRepo;
  }

  /// Compares semantic versions (e.g. "1.1.0" > "1.0.0", "v1.0.1" > "1.0.0")
  bool isNewerVersion(String remote, String current) {
    try {
      final cleanRemote = remote.replaceAll(RegExp(r'[^0-9.]'), '').trim();
      final cleanCurrent = current.replaceAll(RegExp(r'[^0-9.]'), '').trim();

      final remoteParts = cleanRemote.split('.').map((e) => int.tryParse(e) ?? 0).toList();
      final currentParts = cleanCurrent.split('.').map((e) => int.tryParse(e) ?? 0).toList();

      while (remoteParts.length < 3) {
        remoteParts.add(0);
      }
      while (currentParts.length < 3) {
        currentParts.add(0);
      }

      for (int i = 0; i < 3; i++) {
        if (remoteParts[i] > currentParts[i]) return true;
        if (remoteParts[i] < currentParts[i]) return false;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Checks GitHub Releases API for the latest release
  Future<AppReleaseInfo?> checkLatestRelease({String? repository}) async {
    final reposToTry = [
      if (repository != null) repository,
      defaultRepo,
      fallbackRepo,
    ];

    for (final repo in reposToTry) {
      final url = Uri.parse('https://api.github.com/repos/$repo/releases/latest');
      try {
        final response = await http.get(url, headers: {
          'Accept': 'application/vnd.github.v3+json',
          'User-Agent': 'Subscription-Brake-App',
        }).timeout(const Duration(seconds: 8));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          final tagName = data['tag_name'] as String? ?? '';
          final bodyNotes = data['body'] as String?;
          final htmlUrl = data['html_url'] as String? ?? 'https://github.com/$repo/releases';

          // Look for direct APK asset download URL
          String downloadUrl = htmlUrl;
          final assets = data['assets'] as List<dynamic>?;
          if (assets != null && assets.isNotEmpty) {
            final apkAsset = assets.firstWhere(
              (a) => (a['name'] as String? ?? '').toLowerCase().endsWith('.apk'),
              orElse: () => null,
            );
            if (apkAsset != null && apkAsset['browser_download_url'] != null) {
              downloadUrl = apkAsset['browser_download_url'] as String;
            }
          }

          final hasUpdate = isNewerVersion(tagName, currentVersion);

          return AppReleaseInfo(
            currentVersion: currentVersion,
            latestVersion: tagName.replaceAll('v', ''),
            hasUpdate: hasUpdate,
            releaseNotes: bodyNotes,
            downloadUrl: downloadUrl,
            htmlUrl: htmlUrl,
          );
        }
      } catch (e) {
        debugPrint('AppUpdateService error checking release on $repo: $e');
      }
    }
    return null;
  }

  /// Show the Update Dialog to user
  static void showUpdateDialog(
    BuildContext context, {
    required AppReleaseInfo info,
    required AppStrings tr,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.accentEmerald.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.system_update_alt_rounded,
                  color: AppTheme.accentEmerald,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  tr.updateAvailable,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${tr.currentVersion}: v${info.currentVersion}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      '${tr.latestVersion}: v${info.latestVersion}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.accentEmerald,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Text(
                tr.updateAvailableDesc,
                style: const TextStyle(fontSize: 13, height: 1.4),
              ),
              if (info.releaseNotes != null && info.releaseNotes!.trim().isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  '${tr.releaseNotes}:',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 4),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 120),
                  child: SingleChildScrollView(
                    child: Text(
                      info.releaseNotes!,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                    ),
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(tr.later, style: const TextStyle(color: Colors.grey)),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentEmerald,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.download_rounded, size: 18),
              label: Text(tr.updateNow),
              onPressed: () async {
                Navigator.of(context).pop();
                final uri = Uri.parse(info.downloadUrl);
                try {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                } catch (_) {}
              },
            ),
          ],
        );
      },
    );
  }
}

class AppUpdateState {
  final bool isChecking;
  final AppReleaseInfo? releaseInfo;
  final String? errorMessage;
  final DateTime? lastChecked;

  const AppUpdateState({
    this.isChecking = false,
    this.releaseInfo,
    this.errorMessage,
    this.lastChecked,
  });

  AppUpdateState copyWith({
    bool? isChecking,
    AppReleaseInfo? releaseInfo,
    String? errorMessage,
    DateTime? lastChecked,
  }) {
    return AppUpdateState(
      isChecking: isChecking ?? this.isChecking,
      releaseInfo: releaseInfo ?? this.releaseInfo,
      errorMessage: errorMessage ?? this.errorMessage,
      lastChecked: lastChecked ?? this.lastChecked,
    );
  }
}

class AppUpdateNotifier extends StateNotifier<AppUpdateState> {
  final AppUpdateService _service = AppUpdateService();
  bool _hasAutoChecked = false;

  AppUpdateNotifier() : super(const AppUpdateState());

  Future<void> checkForUpdates({
    BuildContext? context,
    required AppStrings tr,
    bool isManual = false,
  }) async {
    if (state.isChecking) return;

    state = state.copyWith(isChecking: true, errorMessage: null);

    final info = await _service.checkLatestRelease();

    state = state.copyWith(
      isChecking: false,
      releaseInfo: info,
      lastChecked: DateTime.now(),
      errorMessage: info == null ? 'Güncelleme sunucusuna ulaşılamadı.' : null,
    );

    if (context != null && context.mounted) {
      if (info != null && info.hasUpdate) {
        AppUpdateService.showUpdateDialog(context, info: info, tr: tr);
      } else if (isManual) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    info != null
                        ? '${tr.alreadyLatestVersion} (v${AppUpdateService.currentVersion})'
                        : 'Henüz yeni bir sürüm yayınlanmadı (v${AppUpdateService.currentVersion})',
                  ),
                ),
              ],
            ),
            backgroundColor: AppTheme.primaryNavy,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void checkAutoOnStartup(BuildContext context, AppStrings tr) {
    if (_hasAutoChecked) return;
    _hasAutoChecked = true;
    Future.delayed(const Duration(seconds: 2), () {
      if (context.mounted) {
        checkForUpdates(context: context, tr: tr, isManual: false);
      }
    });
  }
}

final appUpdateProvider =
    StateNotifierProvider<AppUpdateNotifier, AppUpdateState>((ref) {
  return AppUpdateNotifier();
});
