import 'user.dart';
import 'event.dart';

class QrScan {
  final int id;
  final int eventId;
  final String qrCodeData;
  final String? ipAddress;
  final String? userAgent;
  final Map<String, dynamic>? locationData;
  final int? guestId;
  final DateTime scannedAt;

  // Relationships
  final User? guest;
  final Event? event;

  QrScan({
    required this.id,
    required this.eventId,
    required this.qrCodeData,
    this.ipAddress,
    this.userAgent,
    this.locationData,
    this.guestId,
    required this.scannedAt,
    this.guest,
    this.event,
  });

  factory QrScan.fromJson(Map<String, dynamic> json) {
    return QrScan(
      id: json['id'],
      eventId: json['event_id'],
      qrCodeData: json['qr_code_data'],
      ipAddress: json['ip_address'],
      userAgent: json['user_agent'],
      locationData: json['location_data'],
      guestId: json['guest_id'],
      scannedAt: DateTime.parse(json['scanned_at']),
      guest: json['guest'] != null ? User.fromJson(json['guest']) : null,
      event: json['event'] != null ? Event.fromJson(json['event']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'event_id': eventId,
      'qr_code_data': qrCodeData,
      'ip_address': ipAddress,
      'user_agent': userAgent,
      'location_data': locationData,
      'guest_id': guestId,
      'scanned_at': scannedAt.toIso8601String(),
    };
  }

  double? get latitude => locationData?['latitude']?.toDouble();
  double? get longitude => locationData?['longitude']?.toDouble();
  bool get hasLocation => latitude != null && longitude != null;
}

class QrScanStats {
  final int totalScans;
  final int uniqueScanners;
  final int scansWithLocation;
  final int scansByRegisteredGuests;
  final double conversionRate;
  final List<Map<String, dynamic>> scansOverTime;
  final List<Map<String, dynamic>> scansByHour;
  final List<Map<String, dynamic>> topLocations;

  QrScanStats({
    required this.totalScans,
    required this.uniqueScanners,
    required this.scansWithLocation,
    required this.scansByRegisteredGuests,
    required this.conversionRate,
    required this.scansOverTime,
    required this.scansByHour,
    required this.topLocations,
  });

  factory QrScanStats.fromJson(Map<String, dynamic> json) {
    return QrScanStats(
      totalScans: json['total_scans'] ?? 0,
      uniqueScanners: json['unique_scanners'] ?? 0,
      scansWithLocation: json['scans_with_location'] ?? 0,
      scansByRegisteredGuests: json['scans_by_registered_guests'] ?? 0,
      conversionRate: double.parse(json['conversion_rate'].toString()),
      scansOverTime: json['scans_over_time'] != null
          ? List<Map<String, dynamic>>.from(json['scans_over_time'])
          : [],
      scansByHour: json['scans_by_hour'] != null
          ? List<Map<String, dynamic>>.from(json['scans_by_hour'])
          : [],
      topLocations: json['top_locations'] != null
          ? List<Map<String, dynamic>>.from(json['top_locations'])
          : [],
    );
  }
}
