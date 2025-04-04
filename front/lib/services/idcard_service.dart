import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;

class IdCardService {
  static final _textRecognizer = TextRecognizer();
  static final _imagePicker = ImagePicker();

  static Future<String?> takePicture() async {
    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        imageQuality: 100,
      );

      if (photo == null) return null;

      // Traitement de l'image pour améliorer la détection
      final processedImage = await _processImage(photo.path);
      return processedImage;
    } catch (e) {
      print('Erreur lors de la prise de photo: $e');
      return null;
    }
  }

  static Future<String> _processImage(String imagePath) async {
    final originalImage = img.decodeImage(File(imagePath).readAsBytesSync())!;

    // Amélioration du contraste
    final enhancedImage = img.adjustColor(originalImage, contrast: 1.5);

    // Conversion en niveaux de gris
    final grayImage = img.grayscale(enhancedImage);

    // Sauvegarde de l'image traitée
    final directory = await getTemporaryDirectory();
    final processedPath = '${directory.path}/processed_idcard.jpg';
    File(processedPath).writeAsBytesSync(img.encodeJpg(grayImage));

    return processedPath;
  }

  static Future<Map<String, String?>?> extractText(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final recognizedText = await _textRecognizer.processImage(inputImage);

      final text = recognizedText.text;

      // Extraction des informations
      return {
        'nom': _extractPattern(text, r'Nom\s*:\s*([A-Z\s]+)'),
        'prenom': _extractPattern(text, r'Prénom\s*:\s*([A-Z\s]+)'),
        'date_naissance': _extractPattern(
          text,
          r'Date de naissance\s*:\s*(\d{2}/\d{2}/\d{4})',
        ),
        'date_validite': _extractPattern(
          text,
          r'Date de validité\s*:\s*(\d{2}/\d{2}/\d{4})',
        ),
        'numero': _extractPattern(text, r'Numéro\s*:\s*([A-Z0-9]+)'),
      };
    } catch (e) {
      print('Erreur lors de l\'extraction du texte: $e');
      return null;
    }
  }

  static String? _extractPattern(String text, String pattern) {
    final regex = RegExp(pattern, caseSensitive: false);
    final match = regex.firstMatch(text);
    return match?.group(1)?.trim();
  }

  static void dispose() {
    _textRecognizer.close();
  }
}
