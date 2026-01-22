import 'dart:convert';
import 'package:frontend/models/user_details_model.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/transaction_model.dart';
import '../models/timeline_stat_model.dart';
import '../models/category_stat_model.dart';

class ApiService {
  static const String baseUrl = "http://192.168.1.55:5000";
  static const _storage = FlutterSecureStorage();

  // Get token
  static Future<String?> getToken() async {
    return await _storage.read(key: "token");
  }

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
        // await saveToken(data["access_token"]);
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

  // DASHBOARD SUMMARY
  static Future<Map<String, dynamic>> getSummary(int user_id) async {
    // final token = await getToken();
    final uri = Uri.parse(
      "$baseUrl/stats/summary",
    ).replace(queryParameters: {"user_id": user_id.toString()});

    final res = await http.get(
      // Uri.parse("$baseUrl/stats/summary"),
      uri,
      headers: {
        "Content-Type": "application/json",
        // "Authorization": "Bearer $token"
      },
    );

    if (res.statusCode != 200) {
      throw Exception("Failed to load summary");
    }
    // print(res.body);
    return jsonDecode(res.body);
  }

  // TRANSACTIONS
  static Future<List<TransactionModel>> getTransactions(int user_id) async {
    // final token = await getToken();
    final uri = Uri.parse(
      "$baseUrl/transactions",
    ).replace(queryParameters: {"user_id": user_id.toString()});

    final res = await http.get(
      // Uri.parse("$baseUrl/transactions"),
      uri,
      headers: {
        "Content-Type": "application/json",
        // "Authorization": "Bearer $token"
      },
    );

    if (res.statusCode != 200) {
      throw Exception("Error from code: Failed to load transactions");
    }

    final List data = jsonDecode(res.body);
    // print(data);
    return data.map((e) => TransactionModel.fromJson(e)).toList();
  }

  static Future<List<TimelineStat>> getTimelineStats({
    required int userId,
    required String startDate,
    required String endDate,
  }) async {
    final uri = Uri.parse("$baseUrl/stats/timeline").replace(
      queryParameters: {
        "user_id": userId.toString(),
        "start_date": startDate,
        "end_date": endDate,
      },
    );

    final res = await http.get(uri);

    if (res.statusCode != 200) {
      throw Exception("Failed to load timeline stats");
    }

    final List data = jsonDecode(res.body);
    return data.map((e) => TimelineStat.fromJson(e)).toList();
  }

  static Future<List<CategoryStat>> getCategoryStats({
    required int userId,
    required String startDate,
    required String endDate,
  }) async {
    final uri = Uri.parse("$baseUrl/stats/categories").replace(
      queryParameters: {
        "user_id": userId.toString(),
        "start_date": startDate,
        "end_date": endDate,
      },
    );

    final res = await http.get(uri);

    if (res.statusCode != 200) {
      throw Exception("Failed to load category stats");
    }

    final List data = jsonDecode(res.body);
    return data.map((e) => CategoryStat.fromJson(e)).toList();
  }

  static Future<UserDetails> getCurrentUser({required int userId}) async {
    final uri = Uri.parse(
      "$baseUrl/users/me",
    ).replace(queryParameters: {"user_id": userId.toString()});

    final res = await http.get(uri);

    if (res.statusCode != 200) {
      throw Exception("Failed to load category stats");
    }

    return UserDetails.fromJson(jsonDecode(res.body));
  }

  //================Create Transaction===================================================================
  static Future<void> createTransaction({
    required int userId,
    required double amount,
    int? categoryId,
    required String transactionType,
    required DateTime transactionDate,
    required String description,
  }) async {
    final payload = {
      "user_id": userId,
      "amount": amount,
      "transaction_type": transactionType,
      "transaction_date": transactionDate.toIso8601String().split("T")[0],
      "description": description,
      "category_id": categoryId,
    };

    final res = await http.post(
      Uri.parse("$baseUrl/transactions"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(payload),
    );

    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception("Failed to create transaction");
    }
  }

  //==============================Get Categories=======================================================
  static Future<List<Map<String, dynamic>>> getCategories({
    required int userId,
  }) async {
    final uri = Uri.parse(
      "$baseUrl/categories",
    ).replace(queryParameters: {"user_id": userId.toString()});

    final res = await http.get(
      uri,
      headers: {
        "Content-Type": "application/json",
        // "Authorization": "Bearer $token"},
      },
    );

    if (res.statusCode != 200) {
      throw Exception("Failed to load categories");
    }

    final List data = jsonDecode(res.body);
    return data.cast<Map<String, dynamic>>();
  }

  //======================================Create Category===============================================
  static Future<void> createCategory({
    required int userId,
    required String name,
  }) async {
    final res = await http.post(
      Uri.parse("$baseUrl/categories"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"user_id": userId, "name": name}),
    );

    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception("Failed to create category");
    }
  }

  //=======================================Delete Category==============================================
  static Future<void> deleteCategory(int id) async {
    final res = await http.delete(Uri.parse("$baseUrl/categories/$id"));

    if (res.statusCode != 200) {
      throw Exception("Failed to delete category");
    }
  }
}
