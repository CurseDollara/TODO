import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8000';

  // Получение токена из SharedPreferences
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('session_token');
  }

  // Сохранение токена в SharedPreferences
  static Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('session_token', token);
  }

  // Общие заголовки с авторизацией
  static Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ----- Пользователи -----
  static Future<Map<String, dynamic>> register(
    String email,
    String password,
    String username,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
          'username': username,
        }),
      );

      final data = json.decode(response.body);
      
      if (response.statusCode == 200) {
        // Сохраняем токен сессии
        await _saveToken(data['session_token']);
        
        // Сохраняем данные пользователя
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_id', data['user_id']);
        await prefs.setString('username', data['username']);
        await prefs.setString('email', data['email']);
        await prefs.setBool('is_logged_in', true);
        
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
    }
  }

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      final data = json.decode(response.body);
      
      if (response.statusCode == 200) {
        // Сохраняем токен сессии
        await _saveToken(data['session_token']);
        
        // Сохраняем данные пользователя
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_id', data['user_id']);
        await prefs.setString('username', data['username']);
        await prefs.setString('email', data['email']);
        await prefs.setBool('is_logged_in', true);
        
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
    }
  }

  // ----- Задачи -----
  static Future<Map<String, dynamic>> createTask(Map<String, dynamic> task) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/api/tasks'),
        headers: headers,
        body: json.encode(task),
      );

      final data = json.decode(response.body);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'task_id': data['task_id'],
          'task': data['task'],
        };
      } else {
        return {
          'success': false,
          'error': data['detail'] ?? 'Ошибка создания задачи',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Ошибка создания задачи: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> getTasks() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/tasks'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'tasks': List<Map<String, dynamic>>.from(data['tasks']),
          'count': data['count'],
        };
      } else {
        final data = json.decode(response.body);
        return {
          'success': false,
          'error': data['detail'] ?? 'Ошибка получения задач',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Ошибка получения задач: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> updateTask(
    String taskId,
    Map<String, dynamic> updates,
  ) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/api/tasks/$taskId'),
        headers: headers,
        body: json.encode(updates),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'task': data['task'],
        };
      } else {
        final data = json.decode(response.body);
        return {
          'success': false,
          'error': data['detail'] ?? 'Ошибка обновления задачи',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Ошибка обновления задачи: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> deleteTask(String taskId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/api/tasks/$taskId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return {'success': true};
      } else {
        final data = json.decode(response.body);
        return {
          'success': false,
          'error': data['detail'] ?? 'Ошибка удаления задачи',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Ошибка удаления задачи: $e',
      };
    }
  }

  // Проверка доступности сервера
  static Future<bool> checkServer() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/health'));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
  // Выход из системы
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}