import 'user.dart';

class Event {
  final int id;
  final int creatorId;
  final String title;
  final String? description;
  final DateTime? eventDate;
  final String? location;
  final String qrCodeData;
  final String status; // draft, active, expired
  final Map<String, dynamic>? settings;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Relationships
  final User? creator;
  final int? mediaCount;
  final int? guestsCount;

  Event({
    required this.id,
    required this.creatorId,
    required this.title,
    this.description,
    this.eventDate,
    this.location,
    required this.qrCodeData,
    required this.status,
    this.settings,
    required this.createdAt,
    required this.updatedAt,
    this.creator,
    this.mediaCount,
    this.guestsCount,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] as int? ?? 0,
      creatorId: json['creator_id'] as int? ?? 0,
      title: json['title'] ?? '',
      description: json['description'],
      eventDate: json['event_date'] != null
          ? DateTime.parse(json['event_date'])
          : null,
      location: json['location'],
      qrCodeData: json['qr_code_data'] ?? '',
      status: json['status'] ?? 'draft',
      settings: json['settings'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
      creator: json['creator'] != null ? User.fromJson(json['creator']) : null,
      mediaCount: json['media_count'] as int?,
      guestsCount: json['guests_count'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'creator_id': creatorId,
      'title': title,
      'description': description,
      'event_date': eventDate?.toIso8601String(),
      'location': location,
      'qr_code_data': qrCodeData,
      'status': status,
      'settings': settings,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  bool get isActive => status == 'active';
  bool get isDraft => status == 'draft';
  bool get isExpired => status == 'expired';

  // Geofencing helpers
  bool get hasGeofence =>
      settings?['geofence_enabled'] == true;

  double? get geofenceLatitude =>
      settings?['geofence_latitude']?.toDouble();

  double? get geofenceLongitude =>
      settings?['geofence_longitude']?.toDouble();

  double? get geofenceRadius =>
      settings?['geofence_radius']?.toDouble();
}
