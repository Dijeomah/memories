import 'package:flutter/foundation.dart';

class SubscriptionProvider with ChangeNotifier {
  Map<String, dynamic>? _currentSubscription;
  List<Map<String, dynamic>> _plans = [];
  bool _isLoading = false;

  Map<String, dynamic>? get currentSubscription => _currentSubscription;
  List<Map<String, dynamic>> get plans => _plans;
  bool get isLoading => _isLoading;

  Future<void> fetchPlans() async {
    _isLoading = true;
    notifyListeners();

    try {
      // TODO: Implement API call
      await Future.delayed(const Duration(seconds: 1));
      _plans = [];
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> subscribe(int planId) async {
    // TODO: Implement API call and payment flow
    notifyListeners();
  }
}
