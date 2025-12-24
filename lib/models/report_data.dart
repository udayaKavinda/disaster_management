// lib/models/report_data.dart
import 'dart:io';

/// Local submission payload (used when creating a report)
class SubmitReport {
  String ownerName = '';
  String contact = '';
  String address = '';
  String district = '';
  String gnDivision = '';
  String additionalNotes = '';
  String reviewStatus = '';

  Map<String, bool> riskAnswers = {};
  Map<String, List<File>> riskImages = {};

  double? latitude;
  double? longitude;
}

/// Response model from backend (read-only data returned by APIs)
class ReportResponse {
  String id = '';
  String ownerName = '';
  String contact = '';
  String address = '';
  String district = '';
  String gnDivision = '';
  String additionalNotes = '';
  String reviewStatus = 'Under review';
  String createdAt = '';
  String? feedback;

  Map<String, bool> riskAnswers = {};
  Map<String, List<String>> riskImagesUrls = {};
  Map<String, dynamic>? submittedBy;

  double? latitude;
  double? longitude;

  ReportResponse();

  factory ReportResponse.fromJson(Map<String, dynamic> json) {
    final r = ReportResponse();
    r.id = json['_id']?.toString() ?? '';
    r.ownerName = json['ownerName']?.toString() ?? '';
    r.contact = json['contact']?.toString() ?? '';
    r.address = json['address']?.toString() ?? '';
    r.district = json['district']?.toString() ?? '';
    r.gnDivision = json['gnDivision']?.toString() ?? '';
    r.additionalNotes = json['additionalNotes']?.toString() ?? '';
    r.reviewStatus = json['reviewStatus']?.toString() ?? 'Under review';
    r.createdAt = json['createdAt']?.toString() ?? '';
    r.feedback = json['feedback']?.toString();
    r.latitude = (json['latitude'] as num?)?.toDouble();
    r.longitude = (json['longitude'] as num?)?.toDouble();

    final ra = json['riskAnswers'];
    if (ra is Map) {
      r.riskAnswers = ra.map((key, value) {
        return MapEntry(key.toString(), value == true);
      });
    }

    final ri = json['riskImages'];
    if (ri is Map) {
      final Map<String, List<String>> urls = {};
      ri.forEach((key, value) {
        final list =
            (value as List?)
                ?.map((e) => e.toString())
                .where((e) => e.isNotEmpty)
                .toList() ??
            [];
        urls[key.toString()] = list;
      });
      r.riskImagesUrls = urls;
    }

    if (json['submittedBy'] is Map<String, dynamic>) {
      r.submittedBy = Map<String, dynamic>.from(json['submittedBy']);
    }

    return r;
  }
}
