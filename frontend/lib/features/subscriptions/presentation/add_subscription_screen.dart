import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../models/subscription_model.dart';
import '../providers/catalog_provider.dart';
import '../providers/subscription_providers.dart';
import 'widgets/add_catalog_subscription_dialog.dart';
import 'widgets/add_subscription_modal_bottom_sheet.dart';
import 'widgets/catalog_tile.dart';

class AddSubscriptionScreen extends ConsumerStatefulWidget {
  final UserSubscriptionItem? existingSubscription;

  const AddSubscriptionScreen({super.key, this.existingSubscription});

  @override
  ConsumerState<AddSubscriptionScreen> createState() => _AddSubscriptionScreenState();
}

class _AddSubscriptionScreenState extends ConsumerState<AddSubscriptionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Form Fields
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _paymentMethodController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedCategory = 'Streaming Video';
  String _selectedBillingCycle = 'monthly';
  String _selectedCurrency = 'TRY';
  DateTime _nextBillingDate = DateTime.now().add(const Duration(days: 30));
  DateTime? _trialEndDate;
  bool _isTrial = false;
  bool _alertTrial24h = true;
  String? _catalogId;

  final List<String> _categories = [
    'Streaming Video',
    'Music & Audio',
    'Music & Video',
    'AI & Productivity',
    'Cloud Storage',
    'Gaming',
    'Education',
    'Sports & TV',
    'Shopping & Video',
    'Audiobooks',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: widget.existingSubscription == null ? 2 : 1,
      vsync: this,
    );

    if (widget.existingSubscription != null) {
      final sub = widget.existingSubscription!;
      _nameController.text = sub.serviceName;
      _priceController.text = sub.price.toStringAsFixed(2);
      _paymentMethodController.text = sub.paymentMethodHint ?? '';
      _notesController.text = sub.notes ?? '';
      _selectedCategory = sub.category;
      _selectedBillingCycle = sub.billingCycle;
      _selectedCurrency = sub.currency;
      _nextBillingDate = sub.nextBillingDate;
      _trialEndDate = sub.trialEndDate;
      _isTrial = sub.isTrial;
      _alertTrial24h = sub.alertTrial24h;
      _catalogId = sub.catalogId;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _priceController.dispose();
    _paymentMethodController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _applyCatalogItem(SubscriptionCatalogItem item) {
    setState(() {
      _catalogId = item.id;
      _nameController.text = item.name;
      _selectedCategory = item.category;
      _selectedBillingCycle = item.defaultBillingCycle;
      _selectedCurrency = 'TRY';
      _priceController.text = item.priceTry.toStringAsFixed(2);
      _tabController.animateTo(1); // Switch to manual form with prefilled values
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Selected ${item.name} (${item.tierName})! Review details and save.'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _pickDate({required bool isTrialDate}) async {
    final initial = isTrialDate
        ? (_trialEndDate ?? DateTime.now().add(const Duration(days: 7)))
        : _nextBillingDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (picked != null) {
      setState(() {
        if (isTrialDate) {
          _trialEndDate = picked;
        } else {
          _nextBillingDate = picked;
        }
      });
    }
  }

  void _saveSubscription() {
    if (!_formKey.currentState!.validate()) return;

    final price = double.tryParse(_priceController.text.replaceAll(',', '.')) ?? 0.0;

    if (widget.existingSubscription != null) {
      final updated = UserSubscriptionItem(
        id: widget.existingSubscription!.id,
        catalogId: _catalogId,
        serviceName: _nameController.text.trim(),
        category: _selectedCategory,
        billingCycle: _selectedBillingCycle,
        price: price,
        currency: _selectedCurrency,
        nextBillingDate: _nextBillingDate,
        trialEndDate: _isTrial ? _trialEndDate : null,
        isTrial: _isTrial,
        alertTrial24h: _alertTrial24h,
        paymentMethodHint: _paymentMethodController.text.trim().isNotEmpty
            ? _paymentMethodController.text.trim()
            : null,
        notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
      );
      ref.read(subscriptionListProvider.notifier).updateSubscription(updated);
    } else {
      ref.read(subscriptionListProvider.notifier).addSubscription(
            catalogId: _catalogId,
            serviceName: _nameController.text.trim(),
            category: _selectedCategory,
            billingCycle: _selectedBillingCycle,
            price: price,
            currency: _selectedCurrency,
            nextBillingDate: _nextBillingDate,
            trialEndDate: _isTrial ? _trialEndDate : null,
            isTrial: _isTrial,
            alertTrial24h: _alertTrial24h,
            paymentMethodHint: _paymentMethodController.text.trim().isNotEmpty
                ? _paymentMethodController.text.trim()
                : null,
            notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
          );
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingSubscription != null;
    final catalogList = ref.watch(catalogListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Subscription' : 'Add Subscription'),
        bottom: !isEditing
            ? TabBar(
                controller: _tabController,
                indicatorColor: AppTheme.accentEmerald,
                tabs: const [
                  Tab(icon: Icon(Icons.explore_outlined), text: 'Catalog (1-Click)'),
                  Tab(icon: Icon(Icons.edit_note), text: 'Custom Details'),
                ],
              )
            : null,
      ),
      body: !isEditing
          ? TabBarView(
              controller: _tabController,
              children: [
                _buildCatalogTab(catalogList),
                _buildCustomFormTab(),
              ],
            )
          : _buildCustomFormTab(),
    );
  }

  Widget _buildCatalogTab(List<SubscriptionCatalogItem> catalogList) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 12),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryNavy.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.primaryNavy.withOpacity(0.12)),
            ),
            child: const Row(
              children: [
                Icon(Icons.bolt, color: AppTheme.accentEmerald),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Katalogdan bir servis seçerek tek tıkla modal özelleştirme penceresini açabilirsiniz.',
                    style: TextStyle(fontSize: 13, color: AppTheme.primaryNavy),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Popüler Abonelikler & Katalog',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 8),
        for (final item in catalogList)
          CatalogTile(
            item: item,
            onTap: () {
              showAddCatalogSubscriptionDialog(context, catalogItem: item);
            },
          ),
      ],
    );
  }

  Widget _buildCustomFormTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Service Name
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Service / Subscription Name *',
                hintText: 'e.g. Netflix, Spotify, iCloud',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.subscriptions_outlined),
              ),
              validator: (val) =>
                  val == null || val.trim().isEmpty ? 'Please enter service name' : null,
            ),
            const SizedBox(height: 16),

            // Price and Currency Row
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    controller: _priceController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Price Amount *',
                      hintText: '0.00',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.payments_outlined),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) return 'Enter price';
                      final parsed = double.tryParse(val.replaceAll(',', '.'));
                      if (parsed == null || parsed < 0) return 'Invalid price';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    value: _selectedCurrency,
                    decoration: const InputDecoration(
                      labelText: 'Currency',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'TRY', child: Text('TRY (₺)')),
                      DropdownMenuItem(value: 'USD', child: Text('USD (\$)')),
                      DropdownMenuItem(value: 'EUR', child: Text('EUR (€)')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedCurrency = val);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Category & Billing Cycle Row
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _categories.contains(_selectedCategory) ? _selectedCategory : 'Other',
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                    items: _categories
                        .map((cat) => DropdownMenuItem(value: cat, child: Text(cat, overflow: TextOverflow.ellipsis)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedCategory = val);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedBillingCycle,
                    decoration: const InputDecoration(
                      labelText: 'Billing Cycle',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
                      DropdownMenuItem(value: 'annual', child: Text('Annual')),
                      DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                      DropdownMenuItem(value: 'quarterly', child: Text('Quarterly')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedBillingCycle = val);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Next Billing Date Picker
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(color: Colors.grey),
              ),
              leading: const Icon(Icons.calendar_today_outlined),
              title: const Text('Next Billing Date'),
              subtitle: Text(DateFormat('dd MMMM yyyy').format(_nextBillingDate)),
              trailing: const Icon(Icons.arrow_drop_down),
              onTap: () => _pickDate(isTrialDate: false),
            ),
            const SizedBox(height: 16),

            // Free Trial Guardian Section
            Card(
              color: _isTrial ? const Color(0xFFFEF2F2) : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: _isTrial ? const Color(0xFFFCA5A5) : const BorderSide().color,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'Is this a Free Trial?',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: const Text('Guard Dog will warn you before card charges start'),
                      value: _isTrial,
                      activeColor: AppTheme.alertCrimson,
                      onChanged: (val) {
                        setState(() {
                          _isTrial = val;
                          if (val && _trialEndDate == null) {
                            _trialEndDate = DateTime.now().add(const Duration(days: 7));
                          }
                        });
                      },
                    ),
                    if (_isTrial) ...[
                      const Divider(),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.alarm, color: AppTheme.alertCrimson),
                        title: const Text('Trial Expiry Date'),
                        subtitle: Text(
                          _trialEndDate != null
                              ? DateFormat('dd MMMM yyyy').format(_trialEndDate!)
                              : 'Select date',
                          style: const TextStyle(
                            color: AppTheme.alertCrimson,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        trailing: const Icon(Icons.edit_calendar),
                        onTap: () => _pickDate(isTrialDate: true),
                      ),
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Alert me 24h before trial ends'),
                        value: _alertTrial24h,
                        activeColor: AppTheme.alertCrimson,
                        onChanged: (val) {
                          setState(() => _alertTrial24h = val ?? true);
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Payment Method Hint
            TextFormField(
              controller: _paymentMethodController,
              decoration: const InputDecoration(
                labelText: 'Payment Method Hint (Optional)',
                hintText: 'e.g. Garanti BBVA ••4092, Papara',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.credit_card_outlined),
              ),
            ),
            const SizedBox(height: 16),

            // Notes
            TextFormField(
              controller: _notesController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Notes & Reminder Remarks (Optional)',
                hintText: 'e.g. Shared with roommates, cancel if unused',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.notes_outlined),
              ),
            ),
            const SizedBox(height: 24),

            // Save Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryNavy,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _saveSubscription,
              child: Text(
                isEditing ? 'Save Changes' : 'Track Subscription',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForCategory(String category) {
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
      case 'audiobooks':
        return Icons.auto_stories_outlined;
      default:
        return Icons.subscriptions_outlined;
    }
  }
}
