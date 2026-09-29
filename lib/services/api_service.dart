import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Physical Android phone → Windows PC
  //static const String baseUrl = 'http://10.232.202.40:8000';
  // Android emulator → Windows PC
  static const String baseUrl = 'http://10.0.2.2:8000';

  static Future<String> checkHealth() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/health'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['status'];
      } else {
        return 'Server error: ${response.statusCode}';
      }
    } catch (e) {
      return 'Connection failed: $e';
    }
  }

  static Future<bool> createUser({
    required String name,
    String? homeLocation,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'home_location': homeLocation,
        }),
      );

      if (response.statusCode == 200) {
        print('User sent to FastAPI successfully');
        print(response.body);
        return true;
      } else {
        print('FastAPI error: ${response.statusCode}');
        print(response.body);
        return false;
      }
    } catch (e) {
      print('API connection error: $e');
      return false;
    }
  }

  // ------------------------------------------------------------
  // GEOREMIND AI CHAT
  // ------------------------------------------------------------

  static Future<Map<String, dynamic>> sendChatMessage(
    String message,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/chat/'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'message': message,
        }),
      );

      print('Chat API status: ${response.statusCode}');
      print('Chat API response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        return {
          'success': true,
          'is_reminder': data['is_reminder'] ?? false,
          'reminder': data['reminder'] ?? '',
          'location': data['location'] ?? '',
        };
      } else {
        return {
          'success': false,
          'error': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('Chat API connection error: $e');

      return {
        'success': false,
        'error': 'Connection failed: $e',
      };
    }
  }
}