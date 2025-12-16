
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/report_data.dart';
import 'auth_service.dart';

class ReportService {
  static const String baseUrl = "http://72.60.193.97:3000/api/reports"; // Android emulator

  static Future<bool> submitReport(ReportData report) async {
    final Map<String, dynamic> body = {
      "ownerName": report.ownerName,
      "contact": report.contact,
      "address": report.address,
      "district": report.district,
      "gnDivision": report.gnDivision,
      "additionalNotes": report.additionalNotes,
      "reviewStatus":"Under review",

      "latitude": report.latitude,
      "longitude": report.longitude,

      "riskAnswers": report.riskAnswers,

      // Convert File → path string
      "riskImages": report.riskImages.map(
            (key, value) => MapEntry(
          key,
          value.map((file) => file.path).toList(),
        ),
      ),
    };
    final token = await AuthService.getToken();
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json",
                "Authorization": "Bearer $token",
      },
      body: jsonEncode(body),
    );

    return response.statusCode == 201;
  }

  static Future<List<dynamic>> fetchReports() async {
    final token = await AuthService.getToken();
    final res = await http.get(Uri.parse("$baseUrl/my"),
      headers: {"Content-Type": "application/json",
      "Authorization": "Bearer $token",
      },);
    if (res.statusCode == 200) {
      return json.decode(res.body);
    }
    throw Exception("Failed to load reports");
  }
  static Future<List<dynamic>> fetchAllReports() async {
    final token = await AuthService.getToken();
    final res = await http.get(Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },);
    if (res.statusCode == 200) {
      return json.decode(res.body);
    }
    throw Exception("Failed to load reports");
  }
  static Future<Map<String, dynamic>> fetchReportById(String id) async {
    final token = await AuthService.getToken();
    final res = await http.get(Uri.parse("$baseUrl/$id"),
      headers: {"Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },);
    if (res.statusCode == 200) {
      return json.decode(res.body);
    }
    throw Exception("Failed to load report");
  }

  static Future<void> deleteReport(String id) async {
    final token = await AuthService.getToken();
    final res = await http.delete(Uri.parse("$baseUrl/$id"),
      headers: {"Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },);
    if (res.statusCode != 200) {
      throw Exception("Delete failed");
    }
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
        headers: {"Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "name": name,
          "contact": contact,
          "title": title,
        }),
      );

      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

}
