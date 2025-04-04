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
      final url = Uri.parse('${APIConfig.baseUrl}/cni/create');

      // Créer un form data
      var request = http.MultipartRequest('POST', url);

      // Lire le fichier
      final reader = html.FileReader();
      final completer = Completer<List<int>>();

      reader.onLoadEnd.listen((e) {
        final result = reader.result;
        if (result is List<int>) {
          completer.complete(result);
        } else {
          completer.completeError('Format de fichier non supporté');
        }
      });

      reader.readAsArrayBuffer(file);
      final bytes = await completer.future;

      // Ajouter le fichier
      request.files.add(
        http.MultipartFile.fromBytes('file', bytes, filename: file.name),
      );

      // Ajouter l'ID
      request.fields['individu_id'] = individuId.toString();

      print('=== Début du scan de la carte d\'identité ===');
      print('Détails du fichier:');
      print('- Type: ${file.type}');
      print('- Taille: ${file.size} bytes');
      print('- Nom: ${file.name}');
      print('- ID de l\'individu: $individuId');

      // Envoyer la requête
      final response = await http.Response.fromStream(await request.send());

      print('=== Réponse reçue ===');
      print('Status: ${response.statusCode}');
      print('Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        print('Données OCR reçues: $jsonResponse');

        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          final data = jsonResponse['data'];
          return {
            'success': true,
            'data': {
              'nom': data['nom'] ?? '',
              'prenom': data['prenom'] ?? '',
              'date_naissance': data['date_naissance'] ?? '',
              'date_validite': data['date_validite'] ?? '',
              'numero': data['numero'] ?? '',
            },
          };
        }
      }

      throw 'Erreur serveur: ${response.statusCode}';
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
