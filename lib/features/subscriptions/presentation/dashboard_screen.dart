import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../models/subscription_model.dart';
import '../providers/subscription_providers.dart';
import 'add_subscription_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCurrency = ref.watch(selectedCurrencyProvider);
    final currencyFormat = NumberFormat.currency(
      locale: selectedCurrency == 'TRY' ? 'tr_TR' : 'en_US',
      symbol: selectedCurrency == 'TRY' ? '₺' : (selectedCurrency == 'USD' ? '\$' : '€'),
    );

    final burnRate = ref.watch(totalMonthlyBurnRateProvider);
    final annualBurnRate = ref.watch(totalAnnualBurnRateProvider);
    final trialAlerts = ref.watch(imminentTrialAlertsProvider);
    final priceHikes = ref.watch(detectedPriceHikesProvider);
    final subscriptionsState = ref.watch(subscriptionListProvider);
    final filteredSubscriptions = ref.watch(filteredSubscriptionsProvider);
    final selectedCategory = ref.watch(selectedCategoryFilterProvider);
    final categoryBreakdown = ref.watch(categoryBreakdownProvider);

    final categories = [
      'All',
      'Streaming Video',
      'Music & Audio',
      'AI & Productivity',
      'Cloud Storage',
      'Gaming',
      'Audiobooks',
      'Sports & TV',
      'Education'
    ];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.primaryNavy,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.shield, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Subscription Brake', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text('Financial Guard Dog', style: TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ],
        ),
        actions: [
          // Currency Selector Menu
          PopupMenuButton<String>(
            icon: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Text(
                    selectedCurrency,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  const Icon(Icons.arrow_drop_down, size: 18),
                ],
              ),
            ),
            onSelected: (curr) {
              ref.read(selectedCurrencyProvider.notifier).state = curr;
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'TRY', child: Text('TRY (₺) - Turkish Lira')),
              PopupMenuItem(value: 'USD', child: Text('USD (\$) - US Dollar')),
              PopupMenuItem(value: 'EUR', child: Text('EUR (€) - Euro')),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reload subscriptions',
            onPressed: () => ref.read(subscriptionListProvider.notifier).loadSubscriptions(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primaryNavy,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Subscription'),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AddSubscriptionScreen(),
            ),
          );
        },
      ),
      body: subscriptionsState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppTheme.alertCrimson),
              const SizedBox(height: 12),
              Text('Error loading subscriptions: $err'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.read(subscriptionListProvider.notifier).loadSubscriptions(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (allSubscriptions) {
          return RefreshIndicator(
            onRefresh: () => ref.read(subscriptionListProvider.notifier).loadSubscriptions(),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
              children: [
                // 1. Total Monthly & Annual Burn Rate Card
                Card(
                  color: AppTheme.primaryNavy,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.account_balance_wallet_outlined, color: Colors.white70, size: 16),
                                SizedBox(width: 6),
                                Text(
                                  'MONTHLY BURN RATE',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.1,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Normalized in $selectedCurrency',
                                style: const TextStyle(color: Colors.white, fontSize: 10),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          currencyFormat.format(burnRate),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Divider(color: Colors.white24),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Est. Annual: ${currencyFormat.format(annualBurnRate)}',
                              style: const TextStyle(color: Colors.white70, fontSize: 13),
                            ),
                            Text(
                              '${allSubscriptions.length} items total',
                              style: const TextStyle(color: Colors.white60, fontSize: 13),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 2. Feature Seeding: Trial Expiry Guardian (24h Alert)
                if (trialAlerts.isNotEmpty) ...[
                  Card(
                    color: const Color(0xFFFEF2F2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: const BorderSide(color: Color(0xFFF87171), width: 1.2),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.alarm, color: AppTheme.alertCrimson, size: 22),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Trial Expiry Guardian (Active)',
                                  style: TextStyle(
                                    color: AppTheme.alertCrimson,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              Icon(Icons.shield_outlined, color: AppTheme.alertCrimson, size: 18),
                            ],
                          ),
                          const SizedBox(height: 10),
                          for (final alert in trialAlerts)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('🚨 ', style: TextStyle(fontSize: 14)),
                                  Expanded(
                                    child: Text(
                                      '${alert.serviceName} trial ends on ${DateFormat('dd MMM').format(alert.trialEndDate!)}! Regular fee of ₺${alert.price.toStringAsFixed(2)} starts soon. Cancel now if not needed.',
                                      style: const TextStyle(
                                        color: Color(0xFF7F1D1D),
                                        fontSize: 13,
                                        height: 1.3,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // 3. Feature Seeding: Silent Price Hike Tracker
                if (priceHikes.isNotEmpty) ...[
                  Card(
                    color: const Color(0xFFFFFBEB),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: const BorderSide(color: Color(0xFFFBBF24), width: 1.2),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.trending_up, color: Color(0xFFB45309), size: 22),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Silent Price Hike Alert',
                                  style: TextStyle(
                                    color: Color(0xFF92400E),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          for (final hike in priceHikes)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Text(
                                '📈 ${hike.serviceName} is ${hike.priceHikePercentage?.toStringAsFixed(1)}% higher than reference baseline (₺${hike.baselineCatalogPrice?.toStringAsFixed(2)} ➔ ₺${hike.price.toStringAsFixed(2)}).',
                                style: const TextStyle(color: Color(0xFF78350F), fontSize: 13),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // 4. Category Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (final cat in categories)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(cat),
                            selected: selectedCategory == cat,
                            onSelected: (selected) {
                              if (selected) {
                                ref.read(selectedCategoryFilterProvider.notifier).state = cat;
                              }
                            },
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 5. Subscriptions List Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      selectedCategory == 'All' ? 'All Subscriptions' : selectedCategory,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${filteredSubscriptions.length} items',
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Empty state or list
                if (filteredSubscriptions.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(32),
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        Icon(Icons.inbox_outlined, size: 48, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        Text(
                          'No subscriptions in this category.',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  )
                else
                  for (final sub in filteredSubscriptions)
                    Dismissible(
                      key: Key(sub.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: AppTheme.alertCrimson,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              'Delete',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.delete_outline, color: Colors.white),
                          ],
                        ),
                      ),
                      confirmDismiss: (direction) async {
                        return await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete Subscription?'),
                            content: Text('Are you sure you want to stop tracking ${sub.serviceName}?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.alertCrimson),
                                onPressed: () => Navigator.of(context).pop(true),
                                child: const Text('Delete', style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                        );
                      },
                      onDismissed: (direction) {
                        ref.read(subscriptionListProvider.notifier).removeSubscription(sub.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${sub.serviceName} removed.'),
                            action: SnackBarAction(
                              label: 'UNDO',
                              onPressed: () {
                                ref.read(subscriptionListProvider.notifier).addSubscription(
                                      catalogId: sub.catalogId,
                                      serviceName: sub.serviceName,
                                      category: sub.category,
                                      billingCycle: sub.billingCycle,
                                      price: sub.price,
                                      currency: sub.currency,
                                      nextBillingDate: sub.nextBillingDate,
                                      trialEndDate: sub.trialEndDate,
                                      isTrial: sub.isTrial,
                                      alertTrial24h: sub.alertTrial24h,
                                      paymentMethodHint: sub.paymentMethodHint,
                                      notes: sub.notes,
                                    );
                              },
                            ),
                          ),
                        );
                      },
                      child: Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => _showSubscriptionDetailsModal(context, ref, sub),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundColor: AppTheme.primaryNavy.withOpacity(0.08),
                                  child: Icon(
                                    sub.isTrial ? Icons.hourglass_top : _getIconForCategory(sub.category),
                                    color: sub.isTrial ? AppTheme.alertCrimson : AppTheme.primaryNavy,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Flexible(
                                            child: Text(
                                              sub.serviceName,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          if (sub.isTrial) ...[
                                            const SizedBox(width: 6),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: AppTheme.alertCrimson.withOpacity(0.15),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: const Text(
                                                'TRIAL',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppTheme.alertCrimson,
                                                ),
                                              ),
                                            ),
                                          ],
                                          if (sub.isPriceHikeDetected) ...[
                                            const SizedBox(width: 6),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: AppTheme.warningAmber.withOpacity(0.2),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                '+${sub.priceHikePercentage?.toStringAsFixed(0)}% HIKE',
                                                style: const TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFFB45309),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        sub.isTrial && sub.trialEndDate != null
                                            ? 'Trial ends: ${DateFormat('dd MMM yyyy').format(sub.trialEndDate!)}'
                                            : 'Renews: ${DateFormat('dd MMM yyyy').format(sub.nextBillingDate)}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: sub.isTrial ? AppTheme.alertCrimson : Colors.grey.shade600,
                                          fontWeight: sub.isTrial ? FontWeight.w600 : FontWeight.normal,
                                        ),
                                      ),
                                      if (sub.paymentMethodHint != null)
                                        Text(
                                          sub.paymentMethodHint!,
                                          style: const TextStyle(fontSize: 11, color: Colors.grey),
                                        ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '${sub.currency == 'TRY' ? '₺' : (sub.currency == 'USD' ? '\$' : '€')}${sub.price.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      '/${sub.billingCycle == 'annual' ? 'yr' : 'mo'}',
                                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showSubscriptionDetailsModal(
    BuildContext context,
    WidgetRef ref,
    UserSubscriptionItem sub,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      sub.serviceName,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildDetailRow('Category', sub.category),
              _buildDetailRow('Billing Cycle', sub.billingCycle.toUpperCase()),
              _buildDetailRow(
                'Price Paid',
                '${sub.currency == 'TRY' ? '₺' : (sub.currency == 'USD' ? '\$' : '€')}${sub.price.toStringAsFixed(2)}',
              ),
              _buildDetailRow('Next Billing Date', DateFormat('dd MMMM yyyy').format(sub.nextBillingDate)),
              if (sub.isTrial && sub.trialEndDate != null)
                _buildDetailRow('Trial Expiration', DateFormat('dd MMMM yyyy').format(sub.trialEndDate!)),
              if (sub.paymentMethodHint != null)
                _buildDetailRow('Payment Method', sub.paymentMethodHint!),
              if (sub.baselineCatalogPrice != null)
                _buildDetailRow(
                  'Catalog Baseline',
                  '₺${sub.baselineCatalogPrice!.toStringAsFixed(2)} ${sub.isPriceHikeDetected ? '(Silent Hike: +${sub.priceHikePercentage?.toStringAsFixed(1)}%)' : '(Normal)'}',
                ),
              if (sub.notes != null) ...[
                const SizedBox(height: 8),
                const Text('Notes:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text(sub.notes!, style: const TextStyle(color: Colors.grey)),
              ],
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Edit'),
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => AddSubscriptionScreen(
                              existingSubscription: sub,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.alertCrimson,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Delete'),
                      onPressed: () {
                        ref.read(subscriptionListProvider.notifier).removeSubscription(sub.id);
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        ],
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
