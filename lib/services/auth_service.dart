import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/api_config.dart';
import 'package:jwt_decode/jwt_decode.dart';
import '../models/user.dart';

class AuthService {
  static const _baseUrl = ApiConfig.auth;
  // use localhost for web, 10.0.2.2 for Android emulator

  static final _storage = FlutterSecureStorage();

  static Future<void> login({
    required String nic,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse("$_baseUrl/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"nic": nic, "password": password}),
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

  /// Decode the stored JWT token and return User data
  static Future<User?> getCurrentUser() async {
    final token = await getToken();
    if (token == null) return null;

    try {
      final decodedToken = Jwt.parseJwt(token);
      return User.fromToken(decodedToken);
    } catch (e) {
      return null;
    }
  }

  /// Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    if (token == null) return false;

    try {
      // Check if token is expired
      return !Jwt.isExpired(token);
    } catch (e) {
      return false;
    }
  }
}
