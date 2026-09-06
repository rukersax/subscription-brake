import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../models/subscription_model.dart';
import '../../providers/catalog_provider.dart';
import '../../providers/user_subscription_notifier.dart';
import 'add_catalog_subscription_dialog.dart';

/// Opens the unified Add Subscription Modal with Fast Catalog & Custom entry tabs
Future<bool?> showAddSubscriptionModal(
  BuildContext context, {
  SubscriptionCatalogItem? initialCatalogItem,
  int initialTabIndex = 0,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withOpacity(0.55),
    builder: (ctx) => AddSubscriptionModal(
      initialCatalogItem: initialCatalogItem,
      initialTabIndex: initialTabIndex,
    ),
  );
}

/// Dual-Mode Subscription Modal: Fast Catalog Selection & Custom Form
class AddSubscriptionModal extends ConsumerStatefulWidget {
  final SubscriptionCatalogItem? initialCatalogItem;
  final int initialTabIndex;

  const AddSubscriptionModal({
    super.key,
    this.initialCatalogItem,
    this.initialTabIndex = 0,
  });

  @override
  ConsumerState<AddSubscriptionModal> createState() => _AddSubscriptionModalState();
}

class _AddSubscriptionModalState extends ConsumerState<AddSubscriptionModal>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedModeIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedModeIndex = widget.initialTabIndex;
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _selectedModeIndex = _tabController.index;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      constraints: BoxConstraints(
        maxHeight: screenHeight * 0.90,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header with Title & Close Action
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryNavy.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.add_card_rounded,
                    color: AppTheme.primaryNavy,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Abonelik Ekle',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primaryNavy,
                          letterSpacing: -0.2,
                        ),
                      ),
                      Text(
                        'Hızlı katalogdan seçin veya özel servis tanımlayın',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded, color: Colors.grey),
                  splashRadius: 20,
                ),
              ],
            ),
          ),

          // Dual-Mode Segmented Selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(3),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        _tabController.animateTo(0);
                        setState(() => _selectedModeIndex = 0);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        decoration: BoxDecoration(
                          color: _selectedModeIndex == 0
                              ? Colors.white
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: _selectedModeIndex == 0
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.06),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  )
                                ]
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.bolt_rounded,
                              size: 18,
                              color: _selectedModeIndex == 0
                                  ? AppTheme.primaryNavy
                                  : Colors.grey[600],
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Hızlı Seçim',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: _selectedModeIndex == 0
                                    ? FontWeight.w700
                                    : FontWeight.w600,
                                color: _selectedModeIndex == 0
                                    ? AppTheme.primaryNavy
                                    : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        _tabController.animateTo(1);
                        setState(() => _selectedModeIndex = 1);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        decoration: BoxDecoration(
                          color: _selectedModeIndex == 1
                              ? Colors.white
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: _selectedModeIndex == 1
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.06),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  )
                                ]
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.edit_note_rounded,
                              size: 18,
                              color: _selectedModeIndex == 1
                                  ? AppTheme.primaryNavy
                                  : Colors.grey[600],
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Özel Abonelik',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: _selectedModeIndex == 1
                                    ? FontWeight.w700
                                    : FontWeight.w600,
                                color: _selectedModeIndex == 1
                                    ? AppTheme.primaryNavy
                                    : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Divider(height: 1),

          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Mode 1: Fast Catalog Selection
                FastCatalogSelectionView(
                  onItemSelected: (item) async {
                    final created = await showAddCatalogSubscriptionDialog(
                      context,
                      catalogItem: item,
                    );
                    if (created == true && context.mounted) {
                      Navigator.of(context).pop(true);
                    }
                  },
                ),

                // Mode 2: Custom Subscription Form
                CustomSubscriptionFormView(
                  bottomInset: bottomInset,
                  onSuccess: () {
                    if (context.mounted) {
                      Navigator.of(context).pop(true);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Mode 1: Fast Catalog Selection View (Hızlı Seçim)
class FastCatalogSelectionView extends ConsumerStatefulWidget {
  final void Function(SubscriptionCatalogItem item) onItemSelected;

  const FastCatalogSelectionView({
    super.key,
    required this.onItemSelected,
  });

  @override
  ConsumerState<FastCatalogSelectionView> createState() =>
      _FastCatalogSelectionViewState();
}

class _FastCatalogSelectionViewState
    extends ConsumerState<FastCatalogSelectionView> {
  String _searchQuery = '';
  String _selectedCategoryFilter = 'Tümü';

  @override
  Widget build(BuildContext context) {
    final catalogList = ref.watch(catalogListProvider);

    final categories = [
      'Tümü',
      'Streaming Video',
      'Music & Audio',
      'AI & Productivity',
      'Cloud Storage',
      'Gaming',
      'Shopping & Video',
    ];

    final filteredList = catalogList.where((item) {
      final matchesSearch = _searchQuery.isEmpty ||
          item.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.category.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategoryFilter == 'Tümü' ||
          item.category.toLowerCase() == _selectedCategoryFilter.toLowerCase();
      return matchesSearch && matchesCategory;
    }).toList();

    return Column(
      children: [
        // Search Bar & Filter Chips
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            onChanged: (v) => setState(() => _searchQuery = v),
            decoration: InputDecoration(
              hintText: 'Katalogda servis ara (Netflix, Spotify, ChatGPT)...',
              prefixIcon: const Icon(Icons.search_rounded, size: 20),
              isDense: true,
              filled: true,
              fillColor: Colors.grey.withOpacity(0.06),
              contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
              ),
            ),
          ),
        ),

        // Horizontal Category Filter
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: categories.map((cat) {
              final isSelected = _selectedCategoryFilter == cat;
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: FilterChip(
                  label: Text(cat, style: const TextStyle(fontSize: 12)),
                  selected: isSelected,
                  selectedColor: AppTheme.primaryNavy.withOpacity(0.12),
                  checkmarkColor: AppTheme.primaryNavy,
                  labelStyle: TextStyle(
                    color: isSelected ? AppTheme.primaryNavy : Colors.black87,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
                  ),
                  onSelected: (val) {
                    setState(() => _selectedCategoryFilter = cat);
                  },
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 4),

        // Catalog List
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: filteredList.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (ctx, index) {
              final item = filteredList[index];
              return _CatalogQuickTile(
                item: item,
                onTap: () => widget.onItemSelected(item),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CatalogQuickTile extends StatelessWidget {
  final SubscriptionCatalogItem item;
  final VoidCallback onTap;

  const _CatalogQuickTile({
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final brandColor = _getBrandColor(item.name);

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: brandColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getCategoryIcon(item.category),
                color: brandColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),

            // Name & Category
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          item.name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (item.isPopular) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.accentEmerald.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'POPÜLER',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.accentEmerald,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${item.category} • ${item.tierName}',
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),

            // Price & Quick Action
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₺${item.priceTry.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primaryNavy,
                  ),
                ),
                Text(
                  '/${item.defaultBillingCycle == "annual" ? "yıl" : "ay"}',
                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                ),
              ],
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.add_circle_outline_rounded,
              color: AppTheme.primaryNavy,
              size: 22,
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
      default:
        return Icons.subscriptions_outlined;
    }
  }
}

/// Mode 2: Custom Subscription Form View (Özel Abonelik)
class CustomSubscriptionFormView extends ConsumerStatefulWidget {
  final double bottomInset;
  final VoidCallback onSuccess;

  const CustomSubscriptionFormView({
    super.key,
    required this.bottomInset,
    required this.onSuccess,
  });

  @override
  ConsumerState<CustomSubscriptionFormView> createState() =>
      _CustomSubscriptionFormViewState();
}

class _CustomSubscriptionFormViewState
    extends ConsumerState<CustomSubscriptionFormView> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _paymentMethodController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedCategory = 'Streaming Video';
  String _selectedCurrency = 'TRY';
  String _billingCycle = 'monthly';
  DateTime _nextBillingDate = DateTime.now().add(const Duration(days: 30));
  DateTime? _trialEndDate;
  bool _isFreeTrial = false;

  final List<String> _categories = [
    'Streaming Video',
    'Music & Audio',
    'AI & Productivity',
    'Cloud Storage',
    'Gaming',
    'Education',
    'Sports & TV',
    'Other'
  ];

  final List<String> _currencies = ['TRY', 'USD', 'EUR', 'GBP'];

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _paymentMethodController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickNextBillingDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _nextBillingDate,
      firstDate: now.subtract(const Duration(days: 30)),
      lastDate: now.add(const Duration(days: 365 * 3)),
    );
    if (picked != null) {
      setState(() => _nextBillingDate = picked);
    }
  }

  Future<void> _pickTrialEndDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _trialEndDate ?? now.add(const Duration(days: 7)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _trialEndDate = picked);
    }
  }

  Future<void> _submitCustomForm() async {
    if (!_formKey.currentState!.validate()) return;

    final parsedPrice = double.tryParse(_priceController.text.trim().replaceAll(',', '.'));
    if (parsedPrice == null || parsedPrice <= 0) return;

    final payload = CreateSubscriptionPayload(
      catalogId: null,
      customPlanName: 'Custom',
      price: parsedPrice,
      currency: _selectedCurrency,
      billingCycle: _billingCycle,
      startDate: DateTime.now(),
      nextBillingDate: _nextBillingDate,
      trialEndDate: _isFreeTrial ? _trialEndDate : null,
      paymentMethodHint: _paymentMethodController.text.trim().isNotEmpty
          ? _paymentMethodController.text.trim()
          : null,
      notes: _notesController.text.trim().isNotEmpty
          ? _notesController.text.trim()
          : null,
    );

    final success = await ref
        .read(userSubscriptionNotifierProvider.notifier)
        .createSubscription(
          payload: payload,
          serviceName: _nameController.text.trim(),
          category: _selectedCategory,
        );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_nameController.text.trim()} aboneliği başarıyla eklendi!'),
          backgroundColor: AppTheme.accentEmerald,
          behavior: SnackBarBehavior.floating,
        ),
      );
      widget.onSuccess();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(userSubscriptionNotifierProvider).isLoading;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20, 16, 20, widget.bottomInset + 24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // a. Service Name
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Servis / Abonelik Adı *',
                hintText: 'Örn: Notion Plus, Midjourney, Digiturk',
                prefixIcon: const Icon(Icons.business_rounded),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Lütfen bir servis adı girin' : null,
            ),
            const SizedBox(height: 14),

            // b. Category Selector
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: InputDecoration(
                labelText: 'Kategori',
                prefixIcon: const Icon(Icons.category_rounded),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: _categories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedCategory = val);
              },
            ),
            const SizedBox(height: 14),

            // c. Price & Currency Input
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    controller: _priceController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Abonelik Ücreti *',
                      prefixIcon: const Icon(Icons.payments_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Ücret girin' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    value: _selectedCurrency,
                    decoration: InputDecoration(
                      labelText: 'Para Birimi',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    items: _currencies
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedCurrency = val);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // d. Billing Cycle Segmented Control
            const Text(
              'Fatura Döngüsü',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'monthly',
                  label: Text('Aylık'),
                  icon: Icon(Icons.calendar_month_rounded),
                ),
                ButtonSegment(
                  value: 'annual',
                  label: Text('Yıllık'),
                  icon: Icon(Icons.event_repeat_rounded),
                ),
              ],
              selected: {_billingCycle},
              onSelectionChanged: (set) => setState(() => _billingCycle = set.first),
            ),
            const SizedBox(height: 14),

            // e. Next Billing Date Picker
            const Text(
              'Sonraki Fatura Tarihi',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: _pickNextBillingDate,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.withOpacity(0.35)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded,
                        size: 20, color: AppTheme.primaryNavy),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        DateFormat('dd MMMM yyyy').format(_nextBillingDate),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Icon(Icons.edit_calendar_rounded, size: 18, color: Colors.grey[600]),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            // f. Payment Method Hint
            TextFormField(
              controller: _paymentMethodController,
              decoration: InputDecoration(
                labelText: 'Ödeme Yöntemi İpucu (İsteğe bağlı)',
                hintText: 'Örn: Garanti BBVA ••4092, Papara Kart',
                prefixIcon: const Icon(Icons.credit_card_rounded),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 14),

            // g. Free Trial Toggle
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _isFreeTrial ? const Color(0xFFFEF2F2) : Colors.grey.withOpacity(0.06),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Ücretsiz Deneme Sürümü mü?',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Switch.adaptive(
                        value: _isFreeTrial,
                        activeColor: AppTheme.alertCrimson,
                        onChanged: (val) => setState(() => _isFreeTrial = val),
                      ),
                    ],
                  ),
                  if (_isFreeTrial) ...[
                    const SizedBox(height: 8),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Deneme Bitiş Tarihi'),
                      subtitle: Text(
                        _trialEndDate != null
                            ? DateFormat('dd MMMM yyyy').format(_trialEndDate!)
                            : 'Tarih seçin...',
                      ),
                      trailing: const Icon(Icons.edit_calendar_rounded),
                      onTap: _pickTrialEndDate,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryNavy,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: isLoading ? null : _submitCustomForm,
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
                        'Aboneliği Kaydet',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
