import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  static const String baseUrl = "http://192.168.1.55:5000";
  static const _storage = FlutterSecureStorage();

  // LOGIN
  static Future<bool> login(String email, String password) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/users/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        await _storage.write(key: "token", value: data["access_token"]);
        return true;
      } else {
        final data = jsonDecode(res.body);
        print("Login failed: ${data['error']}");
        return false;
      }
    } catch (e) {
      print("Error connecting to API: $e");
      return false;
    }
  }

  // Get token
  static Future<String?> getToken() async {
    return await _storage.read(key: "token");
  }

  // REGISTER
  static Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
    String currencyCode,
  ) async {
    final res = await http.post(
      Uri.parse("$baseUrl/users/register"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name": name,
        "email": email,
        "password": password,
        "currency_code": currencyCode,
      }),
    );

    return {"status": res.statusCode, "body": jsonDecode(res.body)};
  }
}
