import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/config/app_config.dart';
import '../models/subscription_model.dart';
import 'catalog_provider.dart';

const _uuid = Uuid();

/// Mock Seed Data for Development Mode
final List<UserSubscriptionItem> _mockInitialSubscriptions = [
  UserSubscriptionItem(
    id: 'sub-1',
    catalogId: 'cat-1',
    serviceName: 'Netflix',
    category: 'Streaming Video',
    billingCycle: 'monthly',
    price: 269.99, // Intentional price hike above 229.99 baseline
    currency: 'TRY',
    nextBillingDate: DateTime.now().add(const Duration(days: 12)),
    baselineCatalogPrice: 229.99,
    isPriceHikeDetected: true,
    priceHikePercentage: 17.39,
    paymentMethodHint: 'Garanti BBVA ••4092',
    notes: 'Family HD 2 Screens',
  ),
  UserSubscriptionItem(
    id: 'sub-2',
    catalogId: 'cat-2',
    serviceName: 'Spotify Premium',
    category: 'Music & Audio',
    billingCycle: 'monthly',
    price: 59.99,
    currency: 'TRY',
    nextBillingDate: DateTime.now().add(const Duration(days: 5)),
    baselineCatalogPrice: 59.99,
    isPriceHikeDetected: false,
    paymentMethodHint: 'Papara Card ••1024',
  ),
  UserSubscriptionItem(
    id: 'sub-3',
    catalogId: 'cat-4',
    serviceName: 'Exxen Reklamsız',
    category: 'Streaming Video',
    billingCycle: 'monthly',
    price: 222.50,
    currency: 'TRY',
    nextBillingDate: DateTime.now().add(const Duration(days: 18)),
    baselineCatalogPrice: 222.50,
    isPriceHikeDetected: false,
    paymentMethodHint: 'Enpara ••8831',
  ),
  UserSubscriptionItem(
    id: 'sub-4',
    catalogId: 'cat-6',
    serviceName: 'ChatGPT Plus',
    category: 'AI & Productivity',
    billingCycle: 'monthly',
    price: 649.99,
    currency: 'TRY',
    nextBillingDate: DateTime.now().add(const Duration(days: 22)),
    baselineCatalogPrice: 649.99,
    isPriceHikeDetected: false,
    paymentMethodHint: 'İş Bankası ••3091',
  ),
  UserSubscriptionItem(
    id: 'sub-5',
    catalogId: 'cat-15',
    serviceName: 'Storytel Free Trial',
    category: 'Audiobooks',
    billingCycle: 'monthly',
    price: 149.99,
    currency: 'TRY',
    nextBillingDate: DateTime.now().add(const Duration(hours: 18)),
    trialEndDate: DateTime.now().add(const Duration(hours: 18)),
    isTrial: true,
    alertTrial24h: true,
    paymentMethodHint: 'Garanti BBVA ••4092',
    notes: 'Cancel before trial renews at 149.99 TL',
  ),
];

/// Selected Currency State
final selectedCurrencyProvider = StateProvider<String>((ref) => AppConfig.defaultCurrency);

/// Selected Category Filter State ('All' or specific category)
final selectedCategoryFilterProvider = StateProvider<String>((ref) => 'All');

/// StateNotifier to manage user subscriptions list with full CRUD
class SubscriptionListNotifier extends StateNotifier<AsyncValue<List<UserSubscriptionItem>>> {
  final Ref ref;

  SubscriptionListNotifier(this.ref) : super(const AsyncValue.loading()) {
    loadSubscriptions();
  }

  Future<void> loadSubscriptions() async {
    state = const AsyncValue.loading();
    try {
      if (AppConfig.developmentMode) {
        await Future.delayed(const Duration(milliseconds: 250));
        state = AsyncValue.data(List.from(_mockInitialSubscriptions));
      } else {
        state = AsyncValue.data(List.from(_mockInitialSubscriptions));
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void addSubscription({
    required String serviceName,
    required String category,
    required String billingCycle,
    required double price,
    required String currency,
    required DateTime nextBillingDate,
    DateTime? trialEndDate,
    bool isTrial = false,
    bool alertTrial24h = true,
    String? catalogId,
    String? paymentMethodHint,
    String? notes,
  }) {
    // Check against catalog baseline if available
    double? baselinePrice;
    bool isPriceHike = false;
    double? hikePct;

    if (catalogId != null) {
      final catalog = ref.read(catalogListProvider);
      final match = catalog.where((c) => c.id == catalogId).firstOrNull;
      if (match != null) {
        baselinePrice = match.priceTry;
        if (currency == 'USD' && match.priceUsd != null) baselinePrice = match.priceUsd!;
        if (currency == 'EUR' && match.priceEur != null) baselinePrice = match.priceEur!;

        if (baselinePrice != null && price > baselinePrice) {
          isPriceHike = true;
          hikePct = ((price - baselinePrice) / baselinePrice) * 100.0;
        }
      }
    }

    final newItem = UserSubscriptionItem(
      id: 'sub-${_uuid.v4().substring(0, 8)}',
      catalogId: catalogId,
      serviceName: serviceName,
      category: category,
      billingCycle: billingCycle,
      price: price,
      currency: currency,
      nextBillingDate: nextBillingDate,
      trialEndDate: trialEndDate,
      isTrial: isTrial,
      alertTrial24h: alertTrial24h,
      baselineCatalogPrice: baselinePrice,
      isPriceHikeDetected: isPriceHike,
      priceHikePercentage: hikePct,
      paymentMethodHint: paymentMethodHint,
      notes: notes,
    );

    state.whenData((list) {
      state = AsyncValue.data([newItem, ...list]);
    });
  }

  void updateSubscription(UserSubscriptionItem updated) {
    state.whenData((list) {
      state = AsyncValue.data(
        list.map((item) => item.id == updated.id ? updated : item).toList(),
      );
    });
  }

  void removeSubscription(String id) {
    state.whenData((list) {
      state = AsyncValue.data(list.where((element) => element.id != id).toList());
    });
  }
}

/// Provider for user subscriptions list
final subscriptionListProvider =
    StateNotifierProvider<SubscriptionListNotifier, AsyncValue<List<UserSubscriptionItem>>>(
  (ref) => SubscriptionListNotifier(ref),
);

/// Exchange rates for local normalization
const Map<String, double> mockRatesToTry = {
  'TRY': 1.0,
  'USD': 34.50,
  'EUR': 37.80,
};

double convertCurrency(double amount, String from, String to) {
  if (from == to) return amount;
  final inTry = amount * (mockRatesToTry[from.toUpperCase()] ?? 1.0);
  final inTarget = inTry / (mockRatesToTry[to.toUpperCase()] ?? 1.0);
  return inTarget;
}

/// Filtered Subscriptions based on selected category
final filteredSubscriptionsProvider = Provider<List<UserSubscriptionItem>>((ref) {
  final subscriptionsAsync = ref.watch(subscriptionListProvider);
  final selectedCategory = ref.watch(selectedCategoryFilterProvider);

  return subscriptionsAsync.maybeWhen(
    data: (items) {
      if (selectedCategory == 'All') return items;
      return items.where((i) => i.category == selectedCategory).toList();
    },
    orElse: () => [],
  );
});

/// Provider aggregating total monthly burn rate normalized to selected display currency
final totalMonthlyBurnRateProvider = Provider<double>((ref) {
  final subscriptionsAsync = ref.watch(subscriptionListProvider);
  final targetCurrency = ref.watch(selectedCurrencyProvider);

  return subscriptionsAsync.maybeWhen(
    data: (items) => items
        .where((item) => !item.isTrial && item.status == 'active')
        .fold(0.0, (sum, item) {
      final monthlyInOriginal = item.monthlyNormalizedPrice;
      final normalized = convertCurrency(monthlyInOriginal, item.currency, targetCurrency);
      return sum + normalized;
    }),
    orElse: () => 0.0,
  );
});

/// Provider aggregating total annual burn rate normalized to selected display currency
final totalAnnualBurnRateProvider = Provider<double>((ref) {
  final monthly = ref.watch(totalMonthlyBurnRateProvider);
  return monthly * 12.0;
});

/// Provider filtering imminent trial expirations (within 48 hours)
final imminentTrialAlertsProvider = Provider<List<UserSubscriptionItem>>((ref) {
  final subscriptionsAsync = ref.watch(subscriptionListProvider);
  final now = DateTime.now();

  return subscriptionsAsync.maybeWhen(
    data: (items) => items
        .where((item) =>
            item.isTrial &&
            item.trialEndDate != null &&
            item.trialEndDate!.difference(now).inHours <= 48 &&
            item.trialEndDate!.isAfter(now.subtract(const Duration(hours: 1))))
        .toList(),
    orElse: () => [],
  );
});

/// Provider filtering detected price hikes
final detectedPriceHikesProvider = Provider<List<UserSubscriptionItem>>((ref) {
  final subscriptionsAsync = ref.watch(subscriptionListProvider);
  return subscriptionsAsync.maybeWhen(
    data: (items) => items.where((item) => item.isPriceHikeDetected).toList(),
    orElse: () => [],
  );
});

/// Category breakdown map
final categoryBreakdownProvider = Provider<Map<String, double>>((ref) {
  final subscriptionsAsync = ref.watch(subscriptionListProvider);
  final targetCurrency = ref.watch(selectedCurrencyProvider);

  return subscriptionsAsync.maybeWhen(
    data: (items) {
      final map = <String, double>{};
      for (final item in items.where((i) => !i.isTrial && i.status == 'active')) {
        final val = convertCurrency(item.monthlyNormalizedPrice, item.currency, targetCurrency);
        map[item.category] = (map[item.category] ?? 0.0) + val;
      }
      return map;
    },
    orElse: () => {},
  );
});
