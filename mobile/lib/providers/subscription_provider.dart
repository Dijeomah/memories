import 'package:flutter/foundation.dart';
import '../models/subscription_plan.dart';
import '../models/user_subscription.dart';
import '../models/subscription_transaction.dart';
import '../services/subscription_service.dart';

class SubscriptionProvider with ChangeNotifier {
  final SubscriptionService _subscriptionService = SubscriptionService();

  List<SubscriptionPlan> _plans = [];
  UserSubscription? _currentSubscription;
  List<SubscriptionTransaction> _transactions = [];

  bool _isLoading = false;
  String? _error;

  List<SubscriptionPlan> get plans => _plans;
  UserSubscription? get currentSubscription => _currentSubscription;
  List<SubscriptionTransaction> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get current plan from subscription
  SubscriptionPlan? get currentPlan => _currentSubscription?.plan;

  // Check if user has active subscription
  bool get hasActiveSubscription =>
      _currentSubscription != null && _currentSubscription!.isActive;

  // Fetch all subscription plans
  Future<void> fetchPlans() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _plans = await _subscriptionService.getPlans();
      _error = null;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch current subscription
  Future<void> fetchCurrentSubscription() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentSubscription = await _subscriptionService.getCurrentSubscription();
      _error = null;
    } catch (e) {
      _error = e.toString();
      // Don't rethrow - having no subscription is not an error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Subscribe to a plan
  Future<Map<String, dynamic>> subscribe(int planId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _subscriptionService.subscribe(planId: planId);

      // If free plan, subscription is created immediately
      if (response['subscription'] != null) {
        _currentSubscription = UserSubscription.fromJson(response['subscription']);
      }

      _error = null;
      return response;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Upgrade/downgrade subscription
  Future<Map<String, dynamic>> upgradeSubscription(int planId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _subscriptionService.upgradeSubscription(planId: planId);
      _error = null;
      return response;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Cancel subscription
  Future<void> cancelSubscription() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _subscriptionService.cancelSubscription();
      // Refresh subscription to get updated status from backend
      await fetchCurrentSubscription();
      _error = null;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch transaction history
  Future<void> fetchTransactions() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _transactions = await _subscriptionService.getTransactions();
      _error = null;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Verify payment
  Future<Map<String, dynamic>> verifyPayment(String reference) async {
    try {
      final response = await _subscriptionService.verifyPayment(reference);

      // Refresh current subscription after successful payment
      if (response['status'] == 'success') {
        await fetchCurrentSubscription();
      }

      return response;
    } catch (e) {
      _error = e.toString();
      rethrow;
    }
  }

  // Get plan by id
  SubscriptionPlan? getPlanById(int id) {
    try {
      return _plans.firstWhere((plan) => plan.id == id);
    } catch (e) {
      return null;
    }
  }

  // Check if can perform action based on plan limits
  bool canCreateEvent(int currentEventCount) {
    if (currentPlan == null) return false;
    if (currentPlan!.hasUnlimitedEvents) return true;
    return currentEventCount < currentPlan!.maxEvents;
  }

  bool canUploadMedia(int currentMediaCount) {
    if (currentPlan == null) return false;
    if (currentPlan!.hasUnlimitedMedia) return true;
    return currentMediaCount < currentPlan!.maxMediaPerEvent;
  }

  bool canAddGuest(int currentGuestCount) {
    if (currentPlan == null) return false;
    if (currentPlan!.hasUnlimitedGuests) return true;
    return currentGuestCount < currentPlan!.maxGuestsPerEvent;
  }

  bool canUploadFile(int currentStorageBytes) {
    if (currentPlan == null) return false;
    final limitBytes = currentPlan!.storageLimitMb * 1024 * 1024;
    return currentStorageBytes < limitBytes;
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
