import 'dart:io' show File; // mobile
import 'dart:typed_data'; // Web
import 'package:flutter/foundation.dart'; // détecter Web
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_tesseract_ocr/flutter_tesseract_ocr.dart';

class ScanIdCardScreen extends StatefulWidget {
  final int individuId;

  ScanIdCardScreen({required this.individuId});

  @override
  _ScanIdCardScreenState createState() => _ScanIdCardScreenState();
}

class _ScanIdCardScreenState extends State<ScanIdCardScreen> {
  File? _imageFile; //  mobile
  Uint8List? _webImage; // Web
  String _ocrText = '';

  Future<void> _takePicture() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      if (kIsWeb) {
        // Web
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _webImage = bytes;
        });
      } else {
        // Mobile
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
      _performOCR(File(pickedFile.path));
    }
  }

  Future<void> _performOCR(File imageFile) async {
    String text = await FlutterTesseractOcr.extractText(imageFile.path);
    print("Texte OCR extrait : $text");
    setState(() {
      _ocrText = text;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Scanner la CNI')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (_webImage != null)
              Image.memory(_webImage!)
            else if (_imageFile != null)
              Image.file(_imageFile!)
            else
              Text('Veuillez sélectionner une image.'),

            SizedBox(height: 20),

            ElevatedButton(
              onPressed: _takePicture,
              child: Text('Sélectionner une image'),
            ),

            SizedBox(height: 20),

            Text(
              'Texte extrait :\n$_ocrText',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
