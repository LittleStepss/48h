import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../config/api.dart';

class AuthService {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'auth_token';

  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  static Future<void> setToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  static Future<void> clearToken() async {
    await _storage.delete(key: _tokenKey);
  }

  static Future<bool> login(String email, String password) async {
    try {
      print('Tentative de connexion avec email: $email');
      final url = '${APIConfig.baseUrl}/login';
      print('URL de connexion: $url');

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      print('Réponse du serveur: ${response.statusCode}');
      print('Corps de la réponse: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['code'] == 200) {
          print('Connexion réussie');
          await setToken('6UXrKe@zSKdnn7rUz#4A@NQ6CU#PYEgw4eRuK^*f');
          return true;
        }
      }
      print('Échec de la connexion');
      return false;
    } catch (e) {
      print('Erreur de connexion: $e');
      return false;
    }
  }

  static Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null;
  }
}
