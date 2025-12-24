import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/report_data.dart';
import 'auth_service.dart';
import '../config/api_config.dart';
import 'package:path/path.dart' as p;

class ReportService {
  static const String baseUrl = ApiConfig.reports; // Android emulator

  static Future<bool> submitReport(SubmitReport report) async {
    final token = await AuthService.getToken();
    final request = http.MultipartRequest('POST', Uri.parse(baseUrl));

    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    request.fields.addAll({
      'ownerName': report.ownerName,
      'contact': report.contact,
      'address': report.address,
      'district': report.district,
      'gnDivision': report.gnDivision,
      'additionalNotes': report.additionalNotes,
      'reviewStatus': 'Under review',
      'riskAnswers': jsonEncode(report.riskAnswers),
    });

    if (report.latitude != null) {
      request.fields['latitude'] = report.latitude.toString();
    }
    if (report.longitude != null) {
      request.fields['longitude'] = report.longitude.toString();
    }

    report.riskImages.forEach((category, files) async {
      for (var i = 0; i < files.length; i++) {
        final File file = files[i];
        if (file.path.isEmpty) continue;

        final fieldName = 'riskImages[$category][$i]';
        request.files.add(
          await http.MultipartFile.fromPath(
            fieldName,
            file.path,
            filename: '$fieldName${p.extension(file.path)}', // preserve ext
          ),
        );
      }
    });

    final streamedResponse = await request.send();
    final responseBody = await streamedResponse.stream.bytesToString();

    if (streamedResponse.statusCode == 201) {
      return true;
    }

    try {
      final Map<String, dynamic> error = jsonDecode(responseBody);
      throw Exception(error['message'] ?? 'Report submission failed');
    } catch (_) {
      throw Exception('Report submission failed');
    }
  }

  static Future<List<ReportResponse>> fetchReports() async {
    final token = await AuthService.getToken();
    final res = await http.get(
      Uri.parse("$baseUrl/my"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );
    if (res.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(res.body);
      return jsonList.map((e) => ReportResponse.fromJson(e)).toList();
    }
    throw Exception("Failed to load reports");
  }

  static Future<List<ReportResponse>> fetchAllReports() async {
    final token = await AuthService.getToken();
    final res = await http.get(
      Uri.parse(baseUrl),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );
    if (res.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(res.body);
      return jsonList.map((e) => ReportResponse.fromJson(e)).toList();
    }
    throw Exception("Failed to load reports");
  }

  static Future<List<ReportResponse>> searchReports(String query) async {
    final token = await AuthService.getToken();
    final res = await http.get(
      Uri.parse('$baseUrl/search?q=$query'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (res.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(res.body);
      return jsonList.map((e) => ReportResponse.fromJson(e)).toList();
    }
    return [];
  }

  static Future<bool> saveOfficialDetails({
    required String name,
    required String contact,
    required String title,
  }) async {
    try {
      final token = await AuthService.getToken();
      final res = await http.post(
        Uri.parse("$baseUrl/officials"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({"name": name, "contact": contact, "title": title}),
      );

      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> updateReportReview({
    required String id,
    required String reviewStatus,
    required String feedback,
  }) async {
    final token = await AuthService.getToken();
    final res = await http.patch(
      Uri.parse("$baseUrl/$id"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({"reviewStatus": reviewStatus, "feedback": feedback}),
    );

    return res.statusCode == 200;
  }

  static Future<ReportResponse> fetchReportById(String id) async {
    final token = await AuthService.getToken();
    final res = await http.get(
      Uri.parse("$baseUrl/$id"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );
    if (res.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(res.body);
      return ReportResponse.fromJson(data);
    }
    throw Exception("Failed to load report");
  }

  static Future<void> deleteReport(String id) async {
    final token = await AuthService.getToken();
    final res = await http.delete(
      Uri.parse("$baseUrl/$id"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );
    if (res.statusCode != 200) {
      throw Exception("Delete failed");
    }
  }
}
