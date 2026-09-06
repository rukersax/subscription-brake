import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../models/subscription_model.dart';
import '../../providers/user_subscription_notifier.dart';

/// Predefined plan option with price multiplier or explicit pricing
class CatalogPlanOption {
  final String id;
  final String title;
  final String description;
  final double price;
  final String currency;

  const CatalogPlanOption({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    this.currency = 'TRY',
  });
}

/// Helper function to display the 2-step simplified subscription creation modal
Future<bool?> showAddCatalogSubscriptionDialog(
  BuildContext context, {
  required SubscriptionCatalogItem catalogItem,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (ctx) => AddCatalogSubscriptionDialog(catalogItem: catalogItem),
  );
}

class AddCatalogSubscriptionDialog extends ConsumerStatefulWidget {
  final SubscriptionCatalogItem catalogItem;

  const AddCatalogSubscriptionDialog({
    super.key,
    required this.catalogItem,
  });

  @override
  ConsumerState<AddCatalogSubscriptionDialog> createState() =>
      _AddCatalogSubscriptionDialogState();
}

class _AddCatalogSubscriptionDialogState
    extends ConsumerState<AddCatalogSubscriptionDialog> {
  CatalogPlanOption? _selectedPlan;
  DateTime? _selectedBillingDate;
  late List<CatalogPlanOption> _availablePlans;

  @override
  void initState() {
    super.initState();
    _availablePlans = _generatePlansForCatalogItem(widget.catalogItem);
    // Pre-select the default standard plan
    if (_availablePlans.isNotEmpty) {
      _selectedPlan = _availablePlans.firstWhere(
        (p) => p.id == 'standard',
        orElse: () => _availablePlans.first,
      );
    }
    // Default next billing date to 1 month from today
    _selectedBillingDate = DateTime.now().add(const Duration(days: 30));
  }

  /// Generates catalog-specific plans with fixed predefined prices (SELECT ONLY)
  List<CatalogPlanOption> _generatePlansForCatalogItem(SubscriptionCatalogItem item) {
    final basePrice = item.priceTry;
    final nameLower = item.name.toLowerCase();

    if (nameLower.contains('netflix')) {
      return [
        CatalogPlanOption(
          id: 'basic',
          title: 'Temel (Basic)',
          description: '720p • 1 Cihaz',
          price: 149.99,
        ),
        CatalogPlanOption(
          id: 'standard',
          title: 'Standart',
          description: '1080p Full HD • 2 Cihaz',
          price: 229.99,
        ),
        CatalogPlanOption(
          id: 'premium',
          title: 'Özel (Premium)',
          description: '4K Ultra HD + HDR • 4 Cihaz',
          price: 299.99,
        ),
      ];
    } else if (nameLower.contains('spotify')) {
      return [
        CatalogPlanOption(
          id: 'student',
          title: 'Öğrenci',
          description: '1 Hesap • İndirimli',
          price: 32.99,
        ),
        CatalogPlanOption(
          id: 'standard',
          title: 'Bireysel',
          description: '1 Premium Hesap',
          price: 59.99,
        ),
        CatalogPlanOption(
          id: 'duo',
          title: 'Duo',
          description: 'Aynı evde 2 Hesap',
          price: 79.99,
        ),
        CatalogPlanOption(
          id: 'family',
          title: 'Aile',
          description: '6 Kişiye kadar Premium',
          price: 99.99,
        ),
      ];
    } else if (nameLower.contains('youtube')) {
      return [
        CatalogPlanOption(
          id: 'student',
          title: 'Öğrenci',
          description: 'Tek Kullanıcı',
          price: 37.99,
        ),
        CatalogPlanOption(
          id: 'standard',
          title: 'Bireysel',
          description: 'Reklamsız + Music',
          price: 57.99,
        ),
        CatalogPlanOption(
          id: 'family',
          title: 'Aile',
          description: '5 Aile Üyesi',
          price: 115.99,
        ),
      ];
    } else if (nameLower.contains('chatgpt') || nameLower.contains('openai')) {
      return [
        CatalogPlanOption(
          id: 'standard',
          title: 'Plus (Bireysel)',
          description: 'GPT-4o, DALL-E & Erken Erişim',
          price: 649.99,
        ),
        CatalogPlanOption(
          id: 'team',
          title: 'Team',
          description: 'Ekip Çalışma Alanı',
          price: 999.00,
        ),
      ];
    }

    // Default dynamic tiers based on base item price
    return [
      CatalogPlanOption(
        id: 'basic',
        title: 'Temel Plan',
        description: 'Standart Erişim',
        price: double.parse((basePrice * 0.75).toStringAsFixed(2)),
      ),
      CatalogPlanOption(
        id: 'standard',
        title: item.tierName.isNotEmpty ? item.tierName : 'Standart Plan',
        description: 'Önerilen Paket',
        price: basePrice,
      ),
      CatalogPlanOption(
        id: 'premium',
        title: 'Premium Plan',
        description: 'Tüm Özellikler Dahil',
        price: double.parse((basePrice * 1.4).toStringAsFixed(2)),
      ),
    ];
  }

  Future<void> _pickBillingDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedBillingDate ?? now.add(const Duration(days: 30)),
      firstDate: now.subtract(const Duration(days: 30)),
      lastDate: now.add(const Duration(days: 365 * 3)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppTheme.primaryNavy,
                  onPrimary: Colors.white,
                ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedBillingDate = picked;
      });
    }
  }

  Future<void> _handleCreateSubscription() async {
    if (_selectedPlan == null || _selectedBillingDate == null) return;

    final item = widget.catalogItem;
    final payload = CreateSubscriptionPayload(
      catalogId: item.id,
      customPlanName: _selectedPlan!.title,
      price: _selectedPlan!.price,
      currency: _selectedPlan!.currency,
      billingCycle: item.defaultBillingCycle,
      startDate: DateTime.now(),
      nextBillingDate: _selectedBillingDate!,
      trialEndDate: null,
      notes: 'Katalogdan 2-Adımda eklendi: ${_selectedPlan!.title}',
    );

    final success = await ref
        .read(userSubscriptionNotifierProvider.notifier)
        .createSubscription(
          payload: payload,
          serviceName: item.name,
          category: item.category,
        );

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '${item.name} (${_selectedPlan!.title}) aboneliği başarıyla oluşturuldu!',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: AppTheme.accentEmerald,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.catalogItem;
    final notifierState = ref.watch(userSubscriptionNotifierProvider);
    final isLoading = notifierState.isLoading;

    // Form validity check (requires both plan and billing date)
    final bool isFormValid = _selectedPlan != null && _selectedBillingDate != null;

    return Dialog(
      backgroundColor: Colors.white,
      elevation: 6,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(22),
        constraints: const BoxConstraints(maxWidth: 440),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header: Service Icon, Title, and Close Button
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _getBrandColor(item.name).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getCategoryIcon(item.category),
                    color: _getBrandColor(item.name),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primaryNavy,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.category,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded, color: Colors.grey),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  splashRadius: 20,
                ),
              ],
            ),
            const SizedBox(height: 18),
            const Divider(height: 1),
            const SizedBox(height: 18),

            // FIELD 1: Package / Plan Type (SELECT ONLY - NO TYPING)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '1. Paket Seçimi',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryNavy,
                  ),
                ),
                Text(
                  '(Seçim yapınız)',
                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Clickable Plan Selection Cards / Chips
            Column(
              children: _availablePlans.map((plan) {
                final isSelected = _selectedPlan?.id == plan.id;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      setState(() {
                        _selectedPlan = plan;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.primaryNavy.withOpacity(0.06)
                            : Colors.grey.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.primaryNavy
                              : Colors.grey.withOpacity(0.2),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isSelected
                                ? Icons.radio_button_checked_rounded
                                : Icons.radio_button_off_rounded,
                            color: isSelected ? AppTheme.primaryNavy : Colors.grey[400],
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  plan.title,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                    color: isSelected ? AppTheme.primaryNavy : Colors.black87,
                                  ),
                                ),
                                Text(
                                  plan.description,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '₺${plan.price.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: isSelected ? AppTheme.primaryNavy : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // FIELD 2: Next Billing Date (Date Picker)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '2. Sonraki Fatura Tarihi',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryNavy,
                  ),
                ),
                Text(
                  '(Yenilenme Günü)',
                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                ),
              ],
            ),
            const SizedBox(height: 10),
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: _pickBillingDate,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _selectedBillingDate != null
                        ? AppTheme.primaryNavy.withOpacity(0.4)
                        : Colors.grey.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_rounded,
                      size: 20,
                      color: AppTheme.primaryNavy,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _selectedBillingDate != null
                            ? DateFormat('dd MMMM yyyy').format(_selectedBillingDate!)
                            : 'Tarih seçin...',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _selectedBillingDate != null ? Colors.black87 : Colors.grey[500],
                        ),
                      ),
                    ),
                    Icon(
                      Icons.edit_calendar_rounded,
                      size: 18,
                      color: Colors.grey[600],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 22),

            // SUBMIT BUTTON ("Oluştur" / Create)
            SizedBox(
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryNavy,
                  disabledBackgroundColor: Colors.grey[300],
                  foregroundColor: Colors.white,
                  disabledForegroundColor: Colors.grey[500],
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: (isFormValid && !isLoading) ? _handleCreateSubscription : null,
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Oluştur',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getBrandColor(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('netflix')) return const Color(0xFFE50914);
    if (lower.contains('spotify')) return const Color(0xFF1DB954);
    if (lower.contains('youtube')) return const Color(0xFFFF0000);
    if (lower.contains('exxen')) return const Color(0xFFFFCC00);
    if (lower.contains('blutv')) return const Color(0xFF00A2E8);
    if (lower.contains('chatgpt')) return const Color(0xFF10A37F);
    if (lower.contains('prime')) return const Color(0xFF00A8E1);
    if (lower.contains('disney')) return const Color(0xFF113CCF);
    return AppTheme.primaryNavy;
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'streaming video':
      case 'shopping & video':
        return Icons.movie_outlined;
      case 'music & audio':
      case 'music & video':
        return Icons.music_note_outlined;
      case 'ai & productivity':
        return Icons.psychology_outlined;
      case 'cloud storage':
        return Icons.cloud_outlined;
      case 'gaming':
        return Icons.sports_esports_outlined;
      case 'sports & tv':
        return Icons.sports_soccer_outlined;
      case 'education':
        return Icons.school_outlined;
      default:
        return Icons.subscriptions_outlined;
    }
  }
}
