import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:front/config/api_config.dart';

class OCRService {
  static Future<Map<String, dynamic>> scanIdCard(
    html.File file,
    int individuId,
  ) async {
    try {
      // Créer l'URL
      final url = Uri.parse('${APIConfig.baseUrl}/cni/create');

      // Créer le FormData
      final formData = html.FormData();
      formData.appendBlob('file', file);
      formData.append('individu_id', individuId.toString());

      print('=== Début du scan de la carte d\'identité ===');
      print('Détails du fichier:');
      print('- Type: ${file.type}');
      print('- Taille: ${file.size} bytes');
      print('- Nom: ${file.name}');
      print('- ID de l\'individu: $individuId');

      // Envoyer la requête avec XMLHttpRequest
      final completer = Completer<Map<String, dynamic>>();
      final xhr = html.HttpRequest();

      xhr.open('POST', url.toString());
      xhr.withCredentials = false;

      xhr.onLoad.listen((e) {
        print('=== Réponse reçue ===');
        print('Status: ${xhr.status}');
        print('Response Text: ${xhr.responseText}');

        if (xhr.status == 200) {
          final jsonResponse = json.decode(xhr.responseText!);
          print('Données OCR reçues: $jsonResponse');

          if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
            final data = jsonResponse['data'];
            completer.complete({
              'success': true,
              'data': {
                'nom': data['nom'] ?? '',
                'prenom': data['prenom'] ?? '',
                'date_naissance': data['date_naissance'] ?? '',
                'date_validite': data['date_validite'] ?? '',
                'numero': data['numero'] ?? '',
              },
            });
          } else {
            completer.completeError('Réponse invalide du serveur');
          }
        } else {
          completer.completeError('Erreur serveur: ${xhr.status}');
        }
      });

      xhr.onError.listen((e) {
        print('Erreur lors de la requête: ${xhr.statusText}');
        completer.completeError('Erreur lors de la requête');
      });

      xhr.send(formData);
      return await completer.future;
    } catch (e) {
      print('Erreur dans scanIdCard: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  static Future<Uint8List> _readFileAsBytes(html.File file) async {
    final completer = Completer<Uint8List>();
    final reader = html.FileReader();

    reader.onLoad.listen((e) {
      try {
        final result = reader.result;
        if (result is Uint8List) {
          completer.complete(result);
        } else if (result is String) {
          final bytes = Uint8List.fromList(result.codeUnits);
          completer.complete(bytes);
        } else {
          throw Exception('Format de fichier non supporté');
        }
      } catch (e) {
        completer.completeError(e);
      }
    });

    reader.onError.listen((e) {
      completer.completeError('Erreur lors de la lecture du fichier');
    });

    reader.readAsArrayBuffer(file);
    return completer.future;
  }
}
