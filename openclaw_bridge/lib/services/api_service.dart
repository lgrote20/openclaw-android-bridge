import 'dart:convert';
import 'package:http/http.dart' as http;
import 'storage_service.dart';

class ApiService {
  static Future<bool> sendNotification(Map<String, dynamic> payload) async {
    final baseUrl = await StorageService.getBaseUrl();
    final token = await StorageService.getAuthToken();

    if (baseUrl == null || baseUrl.isEmpty) {
      return false;
    }

    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(payload),
      );

      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      return false;
    }
  }
}