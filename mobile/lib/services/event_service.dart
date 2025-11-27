import 'dart:io';
import '../config/api_config.dart';
import '../models/event.dart';
import '../models/media.dart';
import '../models/user.dart';
import '../models/qr_scan.dart';
import 'api_service.dart';

class EventService {
  final ApiService _api = ApiService();

  // Get all user's events
  Future<List<Event>> getEvents() async {
    final response = await _api.get(ApiConfig.events);
    final data = response['data'] as List;
    return data.map((json) => Event.fromJson(json)).toList();
  }

  // Get single event
  Future<Event> getEvent(int id) async {
    final response = await _api.get(ApiConfig.eventDetail(id));
    return Event.fromJson(response['event']);
  }

  // Create event
  Future<Event> createEvent({
    required String title,
    String? description,
    DateTime? eventDate,
    String? location,
    String? status,
    Map<String, dynamic>? settings,
    File? eventImage,
  }) async {
    final Map<String, dynamic> response;

    if (eventImage != null) {
      // Use multipart upload when image is provided
      final additionalFields = <String, String>{
        'title': title,
        if (description != null) 'description': description,
        if (eventDate != null) 'event_date': eventDate.toIso8601String(),
        if (location != null) 'location': location,
        if (status != null) 'status': status,
      };

      response = await _api.uploadFile(
        ApiConfig.events,
        eventImage,
        'event_image',
        additionalFields: additionalFields,
      );
    } else {
      // Use regular POST when no image
      response = await _api.post(
        ApiConfig.events,
        {
          'title': title,
          if (description != null) 'description': description,
          if (eventDate != null) 'event_date': eventDate.toIso8601String(),
          if (location != null) 'location': location,
          if (status != null) 'status': status,
          if (settings != null) 'settings': settings,
        },
      );
    }

    return Event.fromJson(response['event']);
  }

  // Update event
  Future<Event> updateEvent({
    required int id,
    String? title,
    String? description,
    DateTime? eventDate,
    String? location,
    String? status,
    Map<String, dynamic>? settings,
    File? eventImage,
  }) async {
    final Map<String, dynamic> response;

    if (eventImage != null) {
      // Use multipart upload when image is provided
      final additionalFields = <String, String>{
        if (title != null) 'title': title,
        if (description != null) 'description': description,
        if (eventDate != null) 'event_date': eventDate.toIso8601String(),
        if (location != null) 'location': location,
        if (status != null) 'status': status,
        '_method': 'PUT', // Laravel needs this for multipart PUT requests
      };

      response = await _api.uploadFile(
        ApiConfig.eventDetail(id),
        eventImage,
        'event_image',
        additionalFields: additionalFields,
      );
    } else {
      // Use regular PUT when no image
      response = await _api.put(
        ApiConfig.eventDetail(id),
        {
          if (title != null) 'title': title,
          if (description != null) 'description': description,
          if (eventDate != null) 'event_date': eventDate.toIso8601String(),
          if (location != null) 'location': location,
          if (status != null) 'status': status,
          if (settings != null) 'settings': settings,
        },
      );
    }

    return Event.fromJson(response['event']);
  }

  // Delete event
  Future<void> deleteEvent(int id) async {
    await _api.delete(ApiConfig.eventDetail(id));
  }

  // Get event QR code
  Future<Map<String, dynamic>> getEventQRCode(int id) async {
    return await _api.get(ApiConfig.eventQr(id));
  }

  // Get event media
  Future<List<Media>> getEventMedia(int id) async {
    final response = await _api.get(ApiConfig.eventMedia(id));
    final data = response['data'] as List;
    return data.map((json) => Media.fromJson(json)).toList();
  }

  // Get event guests
  Future<List<User>> getEventGuests(int id) async {
    final response = await _api.get(ApiConfig.eventGuests(id));
    final data = response['data'] as List;
    return data.map((json) => User.fromJson(json)).toList();
  }

  // Get event QR scans
  Future<List<QrScan>> getEventQRScans(int id) async {
    final response = await _api.get(ApiConfig.eventScans(id));
    final data = response['data'] as List;
    return data.map((json) => QrScan.fromJson(json)).toList();
  }

  // Get event QR scan statistics
  Future<QrScanStats> getEventQRScanStats(int id) async {
    final response = await _api.get(ApiConfig.eventScanStats(id));
    return QrScanStats.fromJson(response);
  }

  // Download event media (returns URLs)
  Future<List<Map<String, dynamic>>> downloadEventMedia(int id) async {
    final response = await _api.post(ApiConfig.eventDownload(id), {});
    return List<Map<String, dynamic>>.from(response['media']);
  }

  // Scan QR code
  Future<Event> scanQRCode({
    required String qrCodeData,
    double? latitude,
    double? longitude,
  }) async {
    final response = await _api.post(
      ApiConfig.scan,
      {
        'qr_code_data': qrCodeData,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
      },
    );

    return Event.fromJson(response['event']);
  }

  // Join event as guest
  Future<Map<String, dynamic>> joinEvent({
    required int eventId,
    required String name,
    required String email,
    String? phone,
  }) async {
    final response = await _api.post(
      ApiConfig.joinEvent(eventId),
      {
        'name': name,
        'email': email,
        if (phone != null) 'phone': phone,
      },
    );

    // Save guest token
    if (response['token'] != null) {
      await _api.saveToken(response['token']);
    }

    return response;
  }
}
