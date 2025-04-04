import 'package:flutter/material.dart';
import 'package:front/screens/scan_idcard.dart';
import 'package:front/services/api_service.dart';

class SelectPersonScreen extends StatefulWidget {
  final int clientId;

  const SelectPersonScreen({Key? key, required this.clientId})
    : super(key: key);

  @override
  _SelectPersonScreenState createState() => _SelectPersonScreenState();
}

class _SelectPersonScreenState extends State<SelectPersonScreen> {
  List<dynamic> _individus = [];
  List<dynamic> _filteredIndividus = [];
  bool _isLoading = true;
  String? _errorMessage;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchIndividus();
    _searchController.addListener(_filterIndividus);
  }

  Future<void> _fetchIndividus() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final individus = await ApiService.getIndividus(widget.clientId);

      // Supprimer les doublons en utilisant un Set
      final uniqueIndividus = individus.toSet().toList();

      setState(() {
        _individus = uniqueIndividus;
        _filteredIndividus = uniqueIndividus;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors de la récupération des employés: $e';
        _isLoading = false;
      });
    }
  }

  void _filterIndividus() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredIndividus =
          _individus.where((individu) {
            final name =
                '${individu['name']} ${individu['surname']}'.toLowerCase();
            return name.contains(query);
          }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sélectionner un employé')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Rechercher un employé',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
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
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _filteredIndividus.isEmpty
                    ? const Center(child: Text('Aucun employé trouvé'))
                    : ListView.builder(
                      itemCount: _filteredIndividus.length,
                      itemBuilder: (context, index) {
                        final individu = _filteredIndividus[index];
                        return ListTile(
                          title: Text(
                            '${individu['name']} ${individu['surname']}',
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => ScanIdCardScreen(
                                      individuId: individu['id'],
                                    ),
                              ),
                            );
                          },
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
