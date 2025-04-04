import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:front/screens/infos_idcard.dart';
import 'package:front/services/ocr_service.dart';
import 'package:http/http.dart' as http;
import 'dart:html' as html;

class ScanIdCardScreen extends StatefulWidget {
  final int individuId;

  const ScanIdCardScreen({Key? key, required this.individuId})
    : super(key: key);

  @override
  _ScanIdCardScreenState createState() => _ScanIdCardScreenState();
}

class _ScanIdCardScreenState extends State<ScanIdCardScreen> {
  String? _imageUrl;
  String? _errorMessage;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Créer un input de type file
      final input =
          html.FileUploadInputElement()
            ..accept = 'image/*'
            ..click();

      // Attendre la sélection du fichier
      await input.onChange.first;

      if (input.files?.isEmpty ?? true) {
        setState(() {
          _errorMessage = 'Aucun fichier sélectionné';
          _isLoading = false;
        });
        return;
      }

      final file = input.files!.first;

      // Vérifier le type de fichier
      if (!file.type!.startsWith('image/')) {
        setState(() {
          _errorMessage = 'Veuillez sélectionner une image';
          _isLoading = false;
        });
        return;
      }

      // Créer l'URL de l'image
      _imageUrl = html.Url.createObjectUrlFromBlob(file);
      setState(() {});

      // Appeler le service OCR
      final ocrData = await OCRService.scanIdCard(file);

      // Navigation vers l'écran suivant
      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => InfosIdCardScreen(
                individuId: widget.individuId,
                imageUrl: _imageUrl!,
                ocrData: ocrData,
              ),
        ),
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors de la sélection de la photo: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scanner une carte d\'identité')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_imageUrl != null)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Image.network(
                  _imageUrl!,
                  height: 300,
                  fit: BoxFit.contain,
                ),
              ),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            if (_isLoading)
              const CircularProgressIndicator()
            else
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Sélectionner une photo'),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    if (_imageUrl != null) {
      html.Url.revokeObjectUrl(_imageUrl!);
    }
    super.dispose();
  }
}
