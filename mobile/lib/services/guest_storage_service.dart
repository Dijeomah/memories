import 'dart:convert';
import 'dart:math';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GuestStorageService {
  static final GuestStorageService _instance = GuestStorageService._internal();
  factory GuestStorageService() => _instance;
  GuestStorageService._internal();

  final _secureStorage = const FlutterSecureStorage();
  static const String _deviceIdKey = 'device_id';
  static const String _guestInfoKey = 'guest_info';

  // Generate or retrieve device ID
  Future<String> getDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    String? deviceId = prefs.getString(_deviceIdKey);

    if (deviceId == null || deviceId.isEmpty) {
      // Generate a new device ID
      deviceId = _generateDeviceId();
      await prefs.setString(_deviceIdKey, deviceId);
    }

    return deviceId;
  }

  // Generate a unique device ID
  String _generateDeviceId() {
    final random = Random.secure();
    final values = List<int>.generate(16, (i) => random.nextInt(256));
    return base64UrlEncode(values);
  }

  // Save guest information
  Future<void> saveGuestInfo({
    required String name,
    required String email,
    String? phone,
  }) async {
    final guestInfo = {
      'name': name,
      'email': email,
      'phone': phone,
      'saved_at': DateTime.now().toIso8601String(),
    };

    await _secureStorage.write(
      key: _guestInfoKey,
      value: jsonEncode(guestInfo),
    );
  }

  // Get saved guest information
  Future<Map<String, dynamic>?> getGuestInfo() async {
    final guestInfoJson = await _secureStorage.read(key: _guestInfoKey);

    if (guestInfoJson == null || guestInfoJson.isEmpty) {
      return null;
    }

    try {
      return jsonDecode(guestInfoJson) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  // Check if guest info exists
  Future<bool> hasGuestInfo() async {
    final guestInfo = await getGuestInfo();
    return guestInfo != null;
  }

  // Clear guest information
  Future<void> clearGuestInfo() async {
    await _secureStorage.delete(key: _guestInfoKey);
  }

  // Clear all guest data including device ID
  Future<void> clearAll() async {
    await clearGuestInfo();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_deviceIdKey);
  }
}
