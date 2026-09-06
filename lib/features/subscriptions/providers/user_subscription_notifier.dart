import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../../../core/config/app_config.dart';
import '../../../core/storage/secure_storage_service.dart';
import 'subscription_providers.dart';

/// Payload model for creating a user subscription
class CreateSubscriptionPayload {
  final String? catalogId;
  final String customPlanName;
  final double price;
  final String currency;
  final String billingCycle;
  final DateTime startDate;
  final DateTime nextBillingDate;
  final DateTime? trialEndDate;
  final String? paymentMethodHint;
  final String? notes;

  const CreateSubscriptionPayload({
    this.catalogId,
    required this.customPlanName,
    required this.price,
    required this.currency,
    required this.billingCycle,
    required this.startDate,
    required this.nextBillingDate,
    this.trialEndDate,
    this.paymentMethodHint,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'catalog_id': catalogId,
      'custom_plan_name': customPlanName,
      'price': price,
      'currency': currency,
      'billing_cycle': billingCycle,
      'start_date': startDate.toIso8601String().split('T').first,
      'next_billing_date': nextBillingDate.toIso8601String().split('T').first,
      'trial_end_date': trialEndDate?.toIso8601String().split('T').first,
      if (paymentMethodHint != null && paymentMethodHint!.isNotEmpty)
        'payment_method_hint': paymentMethodHint,
      if (notes != null && notes!.isNotEmpty) 'notes': notes,
    };
  }
}

/// Riverpod AsyncNotifier to handle creation state, validation, and API submission
class UserSubscriptionNotifier extends AutoDisposeAsyncNotifier<void> {
  final SecureStorageService _storage = SecureStorageService();

  @override
  Future<void> build() async {
    // Initial idle state
    return;
  }

  /// Sends a POST payload to `/api/v1/user-subscriptions` (FastAPI backend)
  Future<bool> createSubscription({
    required CreateSubscriptionPayload payload,
    required String serviceName,
    required String category,
  }) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      try {
        final token = await _storage.getAuthToken();
        final uri = Uri.parse('${AppConfig.apiBaseUrl}/api/v1/user-subscriptions');

        final headers = {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        };

        final response = await http
            .post(
              uri,
              headers: headers,
              body: jsonEncode(payload.toJson()),
            )
            .timeout(const Duration(seconds: 8));

        if (response.statusCode != 200 && response.statusCode != 201) {
          // If offline / dev server fallback, handle gracefully
          if (response.statusCode == 404 || response.statusCode == 502 || response.statusCode == 503) {
            // Development fallback mock persistence
          } else {
            final body = jsonDecode(response.body);
            throw Exception(body['detail'] ?? 'Failed to create subscription (${response.statusCode})');
          }
        }
      } catch (e) {
        // In local mock or network offline mode, still record into local list provider
        if (e is! Exception || e.toString().contains('Failed to create subscription')) {
          rethrow;
        }
      }

      // Add to local state notifier and trigger refresh
      ref.read(subscriptionListProvider.notifier).addSubscription(
            catalogId: payload.catalogId,
            serviceName: serviceName,
            category: category,
            billingCycle: payload.billingCycle,
            price: payload.price,
            currency: payload.currency,
            nextBillingDate: payload.nextBillingDate,
            trialEndDate: payload.trialEndDate,
            isTrial: payload.trialEndDate != null,
            alertTrial24h: payload.trialEndDate != null,
            paymentMethodHint: payload.paymentMethodHint,
            notes: payload.notes,
          );

      // Invalidate providers to re-calculate burn rate and metrics
      ref.invalidate(subscriptionListProvider);
      ref.invalidate(totalMonthlyBurnRateProvider);
      ref.invalidate(totalAnnualBurnRateProvider);
      ref.invalidate(imminentTrialAlertsProvider);
      ref.invalidate(detectedPriceHikesProvider);
    });

    return !state.hasError;
  }
}

/// AsyncNotifierProvider for managing user subscription creation
final userSubscriptionNotifierProvider =
    AutoDisposeAsyncNotifierProvider<UserSubscriptionNotifier, void>(
  UserSubscriptionNotifier.new,
);
