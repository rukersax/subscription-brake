/// Subscription and Catalog Models for Flutter Frontend
class SubscriptionCatalogItem {
  final String id;
  final String name;
  final String slug;
  final String category;
  final String tierName;
  final String defaultBillingCycle;
  final double priceTry;
  final double? priceUsd;
  final double? priceEur;
  final String iconName;
  final String? websiteUrl;
  final String? description;
  final bool isPopular;

  const SubscriptionCatalogItem({
    required this.id,
    required this.name,
    required this.slug,
    required this.category,
    required this.tierName,
    required this.defaultBillingCycle,
    required this.priceTry,
    this.priceUsd,
    this.priceEur,
    required this.iconName,
    this.websiteUrl,
    this.description,
    this.isPopular = false,
  });

  factory SubscriptionCatalogItem.fromJson(Map<String, dynamic> json) {
    return SubscriptionCatalogItem(
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      category: json['category'] as String,
      tierName: json['tier_name'] as String? ?? 'Standard',
      defaultBillingCycle: json['default_billing_cycle'] as String? ?? 'monthly',
      priceTry: (json['price_try'] as num).toDouble(),
      priceUsd: (json['price_usd'] as num?)?.toDouble(),
      priceEur: (json['price_eur'] as num?)?.toDouble(),
      iconName: json['icon_name'] as String? ?? 'subscriptions',
      websiteUrl: json['website_url'] as String?,
      description: json['description'] as String?,
      isPopular: json['is_popular'] as bool? ?? false,
    );
  }
}

class UserSubscriptionItem {
  final String id;
  final String? catalogId;
  final String serviceName;
  final String category;
  final String billingCycle;
  final double price;
  final String currency;
  final DateTime nextBillingDate;
  final DateTime? trialEndDate;
  final bool isTrial;
  final bool alertTrial24h;
  final double? baselineCatalogPrice;
  final bool isPriceHikeDetected;
  final double? priceHikePercentage;
  final String status;
  final String? paymentMethodHint;
  final String? notes;

  const UserSubscriptionItem({
    required this.id,
    this.catalogId,
    required this.serviceName,
    required this.category,
    required this.billingCycle,
    required this.price,
    required this.currency,
    required this.nextBillingDate,
    this.trialEndDate,
    this.isTrial = false,
    this.alertTrial24h = true,
    this.baselineCatalogPrice,
    this.isPriceHikeDetected = false,
    this.priceHikePercentage,
    this.status = 'active',
    this.paymentMethodHint,
    this.notes,
  });

  /// Monthly normalized cost calculation in TRY or base currency
  double get monthlyNormalizedPrice {
    if (billingCycle.toLowerCase() == 'annual') {
      return price / 12.0;
    }
    return price;
  }

  factory UserSubscriptionItem.fromJson(Map<String, dynamic> json) {
    return UserSubscriptionItem(
      id: json['id'] as String,
      catalogId: json['catalog_id'] as String?,
      serviceName: json['service_name'] as String,
      category: json['category'] as String? ?? 'Other',
      billingCycle: json['billing_cycle'] as String? ?? 'monthly',
      price: (json['price'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'TRY',
      nextBillingDate: DateTime.parse(json['next_billing_date'] as String),
      trialEndDate: json['trial_end_date'] != null
          ? DateTime.parse(json['trial_end_date'] as String)
          : null,
      isTrial: json['is_trial'] as bool? ?? false,
      alertTrial24h: json['alert_trial_24h'] as bool? ?? true,
      baselineCatalogPrice: (json['baseline_catalog_price'] as num?)?.toDouble(),
      isPriceHikeDetected: json['is_price_hike_detected'] as bool? ?? false,
      priceHikePercentage: (json['price_hike_percentage'] as num?)?.toDouble(),
      status: json['status'] as String? ?? 'active',
      paymentMethodHint: json['payment_method_hint'] as String?,
      notes: json['notes'] as String?,
    );
  }
}
