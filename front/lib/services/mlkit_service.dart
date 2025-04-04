import 'dart:html' as html;
import 'dart:typed_data';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/material.dart' show Size;

class MLKitService {
  static final _textRecognizer = TextRecognizer();

  static Future<Map<String, String>> extractIdCardInfo(html.File file) async {
    try {
      // Lire le fichier comme un tableau de bytes
      final bytes = await _readFileAsBytes(file);

      // Convertir les bytes en InputImage pour ML Kit
      final inputImage = InputImage.fromBytes(
        bytes: bytes,
        metadata: InputImageMetadata(
          size: const Size(800, 600), // Taille approximative
          rotation: InputImageRotation.rotation0deg,
          format: InputImageFormat.bgra8888,
          bytesPerRow: 800 * 4, // 4 bytes par pixel pour BGRA
        ),
      );

      // Reconnaître le texte
      final recognizedText = await _textRecognizer.processImage(inputImage);

      // Extraire les informations de la carte d'identité
      return _parseIdCardText(recognizedText.text);
    } catch (e) {
      print('Erreur lors de l\'extraction du texte: $e');
      rethrow;
    }
  }

  static Future<Uint8List> _readFileAsBytes(html.File file) async {
    final reader = html.FileReader();
    reader.readAsArrayBuffer(file);
    await reader.onLoad.first;
    return reader.result as Uint8List;
  }

  static Map<String, String> _parseIdCardText(String text) {
    final result = <String, String>{};
    final lines = text.split('\n');

    for (var line in lines) {
      line = line.trim().toUpperCase();

      // Nom
      if (line.contains('NOM') || line.contains('NAME')) {
        final parts = line.split(':');
        if (parts.length > 1) {
          result['nom'] = parts[1].trim();
        }
      }
      // Prénom
      else if (line.contains('PRENOM') || line.contains('GIVEN NAME')) {
        final parts = line.split(':');
        if (parts.length > 1) {
          result['prenom'] = parts[1].trim();
        }
      }
      // Date de naissance
      else if (line.contains('NEE LE') || line.contains('DATE OF BIRTH')) {
        final parts = line.split(':');
        if (parts.length > 1) {
          result['date_naissance'] = parts[1].trim();
        }
      }
      // Numéro de carte
      else if (line.contains('CARTE NATIONALE D\'IDENTITE N°') ||
          line.contains('ID CARD NO')) {
        final parts = line.split('N°');
        if (parts.length > 1) {
          result['numero'] = parts[1].trim();
        }
      }
      // Date de validité
      else if (line.contains('VALABLE JUSQU\'AU') ||
          line.contains('DATE OF EXPIRY')) {
        final parts = line.split(':');
        if (parts.length > 1) {
          result['date_validite'] = parts[1].trim();
        }
      }
    }

    return result;
  }

  static void dispose() {
    _textRecognizer.close();
  }
}
