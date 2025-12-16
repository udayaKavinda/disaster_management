import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static const _baseUrl = "http://72.60.193.97:3000/api/auth";
  // use localhost for web, 10.0.2.2 for Android emulator

  static final _storage = FlutterSecureStorage();

  static Future<void> login({
    required String nic,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse("$_baseUrl/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": nic,
        "password": password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await _storage.write(key: "jwt", value: data["token"]);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error["message"] ?? "Login failed");
    }
  }

  static Future<String?> getToken() async {
    return _storage.read(key: "jwt");
  }

  static Future<void> logout() async {
    await _storage.delete(key: "jwt");
  }
}
