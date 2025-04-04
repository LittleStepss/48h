import 'package:flutter/material.dart';
import 'package:front/services/api_service.dart';

class InfosIdCardScreen extends StatefulWidget {
  final String imageUrl;
  final Map<String, dynamic> ocrData;
  final int individuId;

  const InfosIdCardScreen({
    Key? key,
    required this.imageUrl,
    required this.ocrData,
    required this.individuId,
  }) : super(key: key);

  @override
  _InfosIdCardScreenState createState() => _InfosIdCardScreenState();
}

class _InfosIdCardScreenState extends State<InfosIdCardScreen> {
  final Map<String, TextEditingController> _controllers = {
    'nom': TextEditingController(),
    'prenom': TextEditingController(),
    'date_naissance': TextEditingController(),
    'date_validite': TextEditingController(),
    'numero': TextEditingController(),
  };
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Initialiser les contrôleurs avec les données OCR
    _controllers['nom']!.text = widget.ocrData['nom'] ?? '';
    _controllers['prenom']!.text = widget.ocrData['prenom'] ?? '';
    _controllers['date_naissance']!.text =
        widget.ocrData['date_naissance'] ?? '';
    _controllers['date_validite']!.text = widget.ocrData['date_validite'] ?? '';
    _controllers['numero']!.text = widget.ocrData['numero'] ?? '';
  }

  Future<void> _submitData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final idCardData = {
        'nom': _controllers['nom']!.text,
        'prenom': _controllers['prenom']!.text,
        'date_naissance': _controllers['date_naissance']!.text,
        'date_validite': _controllers['date_validite']!.text,
        'numero': _controllers['numero']!.text,
      };

      final success = await ApiService.uploadIdCard(
        widget.individuId,
        widget.imageUrl,
        idCardData,
      );

      if (!mounted) return;

      if (success) {
        Navigator.pop(context, true);
      } else {
        setState(() {
          _errorMessage = 'Erreur lors de l\'envoi des données';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Une erreur est survenue: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Informations de la carte d\'identité')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Image.network(
              widget.imageUrl,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 24),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            TextField(
              controller: _controllers['nom'],
              decoration: const InputDecoration(
                labelText: 'Nom',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controllers['prenom'],
              decoration: const InputDecoration(
                labelText: 'Prénom',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controllers['date_naissance'],
              decoration: const InputDecoration(
                labelText: 'Date de naissance',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controllers['date_validite'],
              decoration: const InputDecoration(
                labelText: 'Date de validité',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controllers['numero'],
              decoration: const InputDecoration(
                labelText: 'Numéro de carte',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _submitData,
              child:
                  _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Valider'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
}
