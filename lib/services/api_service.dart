import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000';

  static Future<Map<String, dynamic>> register(
    String email,
    String password,
    String username,
  ) async {
    final client = http.Client();
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/api/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
          'username': username,
        }),
      ).timeout(const Duration(seconds: 10));

      final data = json.decode(response.body);
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'user_id': data['user_id'],
          'username': data['username'],
          'email': data['email'],
        };
      } else {
        return {
          'success': false,
          'error': data['detail'] ?? 'Ошибка регистрации',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Ошибка подключения: $e',
      };
    } finally {
      client.close();
    }
  }

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final client = http.Client();
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/api/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 10));

      final data = json.decode(response.body);
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'user_id': data['user_id'],
          'username': data['username'],
          'email': data['email'],
        };
      } else {
        return {
          'success': false,
          'error': data['detail'] ?? 'Ошибка входа',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Ошибка подключения: $e',
      };
    } finally {
      client.close();
    }
  }

  // Проверка доступности сервера
  static Future<bool> checkServer() async {
    final client = http.Client();
    try {
      final response = await client
          .get(Uri.parse('$baseUrl/health'))
          .timeout(const Duration(seconds: 3));
      return response.statusCode == 200;
    } catch (e) {
      print('Сервер недоступен: $e');
      return false;
    } finally {
      client.close();
    }
  }
}