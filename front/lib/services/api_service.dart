import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api.dart';
import 'auth_service.dart';

class ApiService {
  static Future<Map<String, String>> _getHeaders() async {
    final token = await AuthService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<List<dynamic>> getClients() async {
    try {
      final response = await http.get(
        Uri.parse('${APIConfig.baseUrl}/clients'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final allClients = data['data'] ?? [];

        print('Données brutes reçues des clients:');
        print(jsonEncode(allClients));

        // Utiliser un Map avec le nom comme clé pour éliminer les doublons
        final Map<String, dynamic> uniqueClientsMap = {};
        for (var client in allClients) {
          final name = client['name'].toString();
          // Ne garder que la première occurrence de chaque nom
          if (!uniqueClientsMap.containsKey(name)) {
            uniqueClientsMap[name] = client;
          }
        }

        final uniqueClients = uniqueClientsMap.values.toList();
        print('Clients après déduplication:');
        print(jsonEncode(uniqueClients));

        return uniqueClients;
      }
      throw Exception('Erreur lors de la récupération des clients');
    } catch (e) {
      print('Erreur API: $e');
      rethrow;
    }
  }

  static Future<List<dynamic>> getIndividus(int clientId) async {
    try {
      final response = await http.get(
        Uri.parse('${APIConfig.baseUrl}/individus'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final allIndividus = data['data'] ?? [];

        print('Données brutes reçues des individus pour le client $clientId:');
        print(jsonEncode(allIndividus));

        // Utiliser un Map avec la combinaison nom+prénom comme clé pour éliminer les doublons
        final Map<String, dynamic> uniqueIndividusMap = {};
        for (var individu in allIndividus) {
          if (individu['client_id'] == clientId) {
            final fullName =
                '${individu['name']} ${individu['surname']}'.toLowerCase();
            // Ne garder que la première occurrence de chaque nom complet
            if (!uniqueIndividusMap.containsKey(fullName)) {
              uniqueIndividusMap[fullName] = individu;
            }
          }
        }

        final uniqueIndividus = uniqueIndividusMap.values.toList();
        print('Individus après déduplication:');
        print(jsonEncode(uniqueIndividus));

        return uniqueIndividus;
      }
      throw Exception('Erreur lors de la récupération des individus');
    } catch (e) {
      print('Erreur API: $e');
      rethrow;
    }
  }

  static Future<bool> uploadIdCard(
    int individuId,
    String imageUrl,
    Map<String, dynamic> idCardData,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('${APIConfig.baseUrl}/cni/create'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'individu_id': individuId,
          'image_url': imageUrl,
          'data': idCardData,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Erreur lors de l\'upload de la carte: $e');
      return false;
    }
  }
}
