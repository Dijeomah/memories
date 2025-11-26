import 'package:flutter/foundation.dart';

class EventProvider with ChangeNotifier {
  List<Map<String, dynamic>> _events = [];
  bool _isLoading = false;

  List<Map<String, dynamic>> get events => _events;
  bool get isLoading => _isLoading;

  Future<void> fetchEvents() async {
    _isLoading = true;
    notifyListeners();

    try {
      // TODO: Implement API call
      await Future.delayed(const Duration(seconds: 1));
      _events = [];
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createEvent(Map<String, dynamic> data) async {
    // TODO: Implement API call
    _events.add(data);
    notifyListeners();
  }
}
