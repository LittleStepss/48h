import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'package:http/http.dart' as http;
import 'package:front/config/api_config.dart';

class OCRService {
  static Future<Map<String, dynamic>> scanIdCard(html.File file) async {
    try {
      print('Début du scan de la carte...');
      print('Type de fichier: ${file.type}');
      print('Taille du fichier: ${file.size} bytes');

      // Créer un FormData pour l'envoi multipart
      final formData = html.FormData();
      formData.appendBlob('image', file, file.name);

      // Créer un objet XMLHttpRequest pour gérer manuellement la requête
      final xhr = html.HttpRequest();
      final completerXhr = Completer<Map<String, dynamic>>();

      final url = Uri.parse('${APIConfig.baseUrl}/cni/create');
      print('Envoi de la requête à $url');

      xhr.open('POST', url.toString());

      // Ajouter les headers nécessaires
      xhr.setRequestHeader('Accept', '*/*');

      // Récupérer le token depuis le localStorage
      final token = html.window.localStorage['token'];
      if (token != null) {
        xhr.setRequestHeader('Authorization', 'Bearer $token');
      }

      xhr.onLoad.listen((event) {
        print('Status de la réponse: ${xhr.status}');
        print('Headers de la réponse: ${xhr.getAllResponseHeaders()}');

        if (xhr.status == 200) {
          print('Réponse reçue avec succès');
          final responseText = xhr.responseText;
          if (responseText != null && responseText.isNotEmpty) {
            try {
              final data = jsonDecode(responseText);
              completerXhr.complete(data);
            } catch (e) {
              print('Erreur lors du décodage de la réponse: $e');
              print('Réponse reçue: $responseText');
              completerXhr.completeError('Format de réponse invalide');
            }
          } else {
            print('Réponse vide reçue du serveur');
            completerXhr.completeError('Réponse vide du serveur');
          }
        } else {
          print('Erreur HTTP: ${xhr.status} - ${xhr.statusText}');
          final errorText = xhr.responseText ?? 'Pas de message d\'erreur';
          print('Réponse: $errorText');
          completerXhr.completeError('Erreur HTTP: ${xhr.status}');
        }
      });

      xhr.onError.listen((event) {
        print('Erreur XHR: ${xhr.statusText}');
        print('Status de l\'erreur: ${xhr.status}');
        final errorText = xhr.responseText ?? 'Pas de message d\'erreur';
        print('Réponse d\'erreur: $errorText');
        if (xhr.status == 0) {
          completerXhr.completeError(
            'Erreur de connexion au serveur. Vérifiez que le serveur est en cours d\'exécution et accessible.',
          );
        } else {
          completerXhr.completeError('Erreur lors de la requête');
        }
      });

      // Envoyer la requête
      xhr.send(formData);

      try {
        final result = await completerXhr.future.timeout(
          const Duration(seconds: 30),
          onTimeout: () {
            xhr.abort();
            throw TimeoutException('Le serveur met trop de temps à répondre');
          },
        );
        print('Données OCR extraites avec succès');
        return result;
      } catch (e) {
        print('Erreur lors de l\'attente de la réponse: $e');
        rethrow;
      }
    } catch (e) {
      print('Erreur détaillée lors du scan: $e');
      throw Exception('Erreur lors du scan de la carte: $e');
    }
  }
}
