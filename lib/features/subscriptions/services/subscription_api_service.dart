import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/config/app_config.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../models/subscription_model.dart';

/// API Client for FastAPI backend
class SubscriptionApiService {
  final SecureStorageService _storage = SecureStorageService();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _storage.getAuthToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Fetches Centralized Subscription Catalog
  Future<List<SubscriptionCatalogItem>> fetchCatalog({String? category, String? search}) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/api/v1/catalog/').replace(
      queryParameters: {
        if (category != null) 'category': category,
        if (search != null) 'search': search,
      },
    );
    final response = await http.get(uri, headers: await _getHeaders());
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final items = data['items'] as List<dynamic>;
      return items.map((e) => SubscriptionCatalogItem.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw Exception('Failed to fetch subscription catalog: ${response.statusCode}');
  }

  /// Fetches User Subscriptions
  Future<List<UserSubscriptionItem>> fetchUserSubscriptions() async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/api/v1/subscriptions/');
    final response = await http.get(uri, headers: await _getHeaders());
    if (response.statusCode == 200) {
      final list = jsonDecode(response.body) as List<dynamic>;
      return list.map((e) => UserSubscriptionItem.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw Exception('Failed to fetch user subscriptions: ${response.statusCode}');
  }

  /// Adds a new User Subscription
  Future<UserSubscriptionItem> addSubscription(Map<String, dynamic> payload) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/api/v1/subscriptions/');
    final response = await http.post(
      uri,
      headers: await _getHeaders(),
      body: jsonEncode(payload),
    );
    if (response.statusCode == 201) {
      return UserSubscriptionItem.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw Exception('Failed to add subscription: ${response.body}');
  }
}
