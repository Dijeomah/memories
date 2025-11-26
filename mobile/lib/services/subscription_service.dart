import '../config/api_config.dart';
import '../models/subscription_plan.dart';
import '../models/user_subscription.dart';
import '../models/subscription_transaction.dart';
import 'api_service.dart';

class SubscriptionService {
  final ApiService _api = ApiService();

  // Get all subscription plans
  Future<List<SubscriptionPlan>> getPlans() async {
    final response = await _api.get(ApiConfig.subscriptionPlans);
    final data = response['plans'] as List;
    return data.map((json) => SubscriptionPlan.fromJson(json)).toList();
  }

  // Get current subscription
  Future<UserSubscription?> getCurrentSubscription() async {
    try {
      final response = await _api.get(ApiConfig.subscription);
      if (response['subscription'] != null) {
        return UserSubscription.fromJson(response['subscription']);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Subscribe to a plan
  Future<Map<String, dynamic>> subscribe({
    required int planId,
  }) async {
    final response = await _api.post(
      ApiConfig.subscribe,
      {'plan_id': planId},
    );

    return response;
  }

  // Upgrade/downgrade subscription
  Future<Map<String, dynamic>> upgradeSubscription({
    required int planId,
  }) async {
    final response = await _api.post(
      ApiConfig.upgradeSubscription,
      {'plan_id': planId},
    );

    return response;
  }

  // Cancel subscription
  Future<void> cancelSubscription() async {
    await _api.post(ApiConfig.cancelSubscription, {});
  }

  // Get transaction history
  Future<List<SubscriptionTransaction>> getTransactions() async {
    final response = await _api.get(ApiConfig.transactions);
    final data = response['transactions'] as List;
    return data.map((json) => SubscriptionTransaction.fromJson(json)).toList();
  }

  // Verify payment
  Future<Map<String, dynamic>> verifyPayment(String reference) async {
    final response = await _api.get(ApiConfig.verifyPayment(reference));
    return response;
  }
}
