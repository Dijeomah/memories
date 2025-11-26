import 'user.dart';
import 'event.dart';

class Media {
  final int id;
  final int eventId;
  final int uploaderId;
  final String filePath;
  final String fileType; // photo or video
  final int? fileSize;
  final String? thumbnailPath;
  final String? caption;
  final String status; // pending, approved, rejected
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Relationships
  final User? uploader;
  final Event? event;

  Media({
    required this.id,
    required this.eventId,
    required this.uploaderId,
    required this.filePath,
    required this.fileType,
    this.fileSize,
    this.thumbnailPath,
    this.caption,
    required this.status,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
    this.uploader,
    this.event,
  });

  factory Media.fromJson(Map<String, dynamic> json) {
    return Media(
      id: json['id'],
      eventId: json['event_id'],
      uploaderId: json['uploader_id'],
      filePath: json['file_path'],
      fileType: json['file_type'],
      fileSize: json['file_size'],
      thumbnailPath: json['thumbnail_path'],
      caption: json['caption'],
      status: json['status'],
      metadata: json['metadata'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      uploader: json['uploader'] != null ? User.fromJson(json['uploader']) : null,
      event: json['event'] != null ? Event.fromJson(json['event']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'event_id': eventId,
      'uploader_id': uploaderId,
      'file_path': filePath,
      'file_type': fileType,
      'file_size': fileSize,
      'thumbnail_path': thumbnailPath,
      'caption': caption,
      'status': status,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  bool get isPhoto => fileType == 'photo';
  bool get isVideo => fileType == 'video';
  bool get isApproved => status == 'approved';
  bool get isPending => status == 'pending';
  bool get isRejected => status == 'rejected';

  // Get location from metadata if available
  double? get latitude => metadata?['location']?['latitude']?.toDouble();
  double? get longitude => metadata?['location']?['longitude']?.toDouble();
}
