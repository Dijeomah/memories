import 'package:flutter/foundation.dart';
import '../models/event.dart';
import '../models/media.dart';
import '../models/user.dart';
import '../models/qr_scan.dart';
import '../services/event_service.dart';
import '../services/media_service.dart';
import 'dart:io';

class EventProvider with ChangeNotifier {
  final EventService _eventService = EventService();
  final MediaService _mediaService = MediaService();

  List<Event> _events = [];
  Event? _currentEvent;
  List<Media> _eventMedia = [];
  List<Media> _recentMedia = [];
  List<User> _eventGuests = [];
  List<QrScan> _eventScans = [];
  QrScanStats? _scanStats;

  bool _isLoading = false;
  String? _error;

  List<Event> get events => _events;
  Event? get currentEvent => _currentEvent;
  List<Media> get eventMedia => _eventMedia;
  List<Media> get recentMedia => _recentMedia;
  List<User> get eventGuests => _eventGuests;
  List<QrScan> get eventScans => _eventScans;
  QrScanStats? get scanStats => _scanStats;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Fetch all events
  Future<void> fetchEvents() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _events = await _eventService.getEvents();
      _error = null;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch single event
  Future<void> fetchEvent(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentEvent = await _eventService.getEvent(id);
      _error = null;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create event
  Future<Event> createEvent({
    required String title,
    String? description,
    DateTime? eventDate,
    String? location,
    String? status,
    File? eventImage,
    bool? enableGeofence,
    double? geofenceLatitude,
    double? geofenceLongitude,
    double? geofenceRadius,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      Map<String, dynamic>? settings;
      if (enableGeofence == true) {
        settings = {
          'geofence_enabled': true,
          if (geofenceLatitude != null) 'geofence_latitude': geofenceLatitude,
          if (geofenceLongitude != null) 'geofence_longitude': geofenceLongitude,
          if (geofenceRadius != null) 'geofence_radius': geofenceRadius,
        };
      }

      final event = await _eventService.createEvent(
        title: title,
        description: description,
        eventDate: eventDate,
        location: location,
        status: status,
        settings: settings,
        eventImage: eventImage,
      );

      _events.insert(0, event);
      _error = null;
      return event;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update event
  Future<Event> updateEvent({
    required int id,
    String? title,
    String? description,
    DateTime? eventDate,
    String? location,
    String? status,
    File? eventImage,
    Map<String, dynamic>? settings,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final event = await _eventService.updateEvent(
        id: id,
        title: title,
        description: description,
        eventDate: eventDate,
        location: location,
        status: status,
        settings: settings,
        eventImage: eventImage,
      );

      // Update in list
      final index = _events.indexWhere((e) => e.id == id);
      if (index != -1) {
        _events[index] = event;
      }

      if (_currentEvent?.id == id) {
        _currentEvent = event;
      }

      _error = null;
      return event;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete event
  Future<void> deleteEvent(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _eventService.deleteEvent(id);
      _events.removeWhere((e) => e.id == id);
      if (_currentEvent?.id == id) {
        _currentEvent = null;
      }
      _error = null;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch event QR code
  Future<Map<String, dynamic>> fetchEventQRCode(int id) async {
    try {
      return await _eventService.getEventQRCode(id);
    } catch (e) {
      _error = e.toString();
      rethrow;
    }
  }

  // Fetch event media
  Future<void> fetchEventMedia(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _eventMedia = await _eventService.getEventMedia(id);
      _error = null;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch recent media across all events
  Future<void> fetchRecentMedia() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // First fetch all events
      if (_events.isEmpty) {
        await fetchEvents();
      }

      // Collect media from all events
      final List<Media> allMedia = [];
      for (final event in _events) {
        try {
          // Use getEventMedia instead of getMyMedia to get ALL media (creator + guests)
          final media = await _eventService.getEventMedia(event.id);
          allMedia.addAll(media);
        } catch (e) {
          // Skip events with errors
          continue;
        }
      }

      // Sort by most recent
      allMedia.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _recentMedia = allMedia;
      _error = null;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch event guests
  Future<void> fetchEventGuests(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _eventGuests = await _eventService.getEventGuests(id);
      _error = null;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch event QR scans
  Future<void> fetchEventScans(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _eventScans = await _eventService.getEventQRScans(id);
      _error = null;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch event scan stats
  Future<void> fetchEventScanStats(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _scanStats = await _eventService.getEventQRScanStats(id);
      _error = null;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Scan QR code
  Future<Event> scanQRCode({
    required String qrCodeData,
    double? latitude,
    double? longitude,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final event = await _eventService.scanQRCode(
        qrCodeData: qrCodeData,
        latitude: latitude,
        longitude: longitude,
      );
      _error = null;
      return event;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Join event
  Future<Map<String, dynamic>> joinEvent({
    required int eventId,
    required String name,
    required String email,
    String? phone,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _eventService.joinEvent(
        eventId: eventId,
        name: name,
        email: email,
        phone: phone,
      );
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

  // Upload media
  Future<Media> uploadMedia({
    required int eventId,
    required File file,
    String? caption,
    double? latitude,
    double? longitude,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final media = await _mediaService.uploadMedia(
        eventId: eventId,
        file: file,
        caption: caption,
        latitude: latitude,
        longitude: longitude,
      );
      _eventMedia.insert(0, media);
      _error = null;
      return media;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete media
  Future<void> deleteMedia(int id) async {
    try {
      await _mediaService.deleteMedia(id);
      _eventMedia.removeWhere((m) => m.id == id);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      rethrow;
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
