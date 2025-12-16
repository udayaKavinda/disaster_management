// lib/models/report_data.dart
import 'dart:io';

class ReportData {
  String ownerName = '';
  String contact = '';
  String address = '';
  String district = '';
  String gnDivision = '';
  String additionalNotes='';
  String reviewStatus='';

  Map<String, bool> riskAnswers = {};
  Map<String, List<File>> riskImages = {};

  double? latitude;
  double? longitude;
}
