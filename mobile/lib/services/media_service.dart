import 'dart:io';
import '../config/api_config.dart';
import '../models/media.dart';
import 'api_service.dart';

class MediaService {
  final ApiService _api = ApiService();

  // Upload media to event
  Future<Media> uploadMedia({
    required int eventId,
    required File file,
    String? caption,
    double? latitude,
    double? longitude,
  }) async {
    final additionalFields = <String, String>{
      if (caption != null) 'caption': caption,
      if (latitude != null) 'latitude': latitude.toString(),
      if (longitude != null) 'longitude': longitude.toString(),
    };

    final response = await _api.uploadFile(
      ApiConfig.uploadMedia(eventId),
      file,
      'file',
      additionalFields: additionalFields,
    );

    return Media.fromJson(response['media']);
  }

  // Get single media
  Future<Media> getMedia(int id) async {
    final response = await _api.get(ApiConfig.mediaDetail(id));
    return Media.fromJson(response);
  }

  // Get my uploaded media for an event
  Future<List<Media>> getMyMedia(int eventId) async {
    final response = await _api.get(ApiConfig.myMedia(eventId));
    final data = response['data'] as List;
    return data.map((json) => Media.fromJson(json)).toList();
  }

  // Moderate media (approve/reject)
  Future<Media> moderateMedia({
    required int id,
    required String status, // approved or rejected
  }) async {
    final response = await _api.put(
      ApiConfig.moderateMedia(id),
      {'status': status},
    );

    return Media.fromJson(response['media']);
  }

  // Delete media
  Future<void> deleteMedia(int id) async {
    await _api.delete(ApiConfig.deleteMedia(id));
  }
}
