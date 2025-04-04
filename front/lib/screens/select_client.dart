import 'package:flutter/material.dart';
import 'package:front/screens/select_person.dart';
import 'package:front/services/api_service.dart';
import 'dart:convert';

class SelectClientScreen extends StatefulWidget {
  const SelectClientScreen({Key? key}) : super(key: key);

  @override
  _SelectClientScreenState createState() => _SelectClientScreenState();
}

class _SelectClientScreenState extends State<SelectClientScreen> {
  List<dynamic> _clients = [];
  List<dynamic> _filteredClients = [];
  bool _isLoading = true;
  String? _errorMessage;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchClients();
    _searchController.addListener(_filterClients);
  }

  Future<void> _fetchClients() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final clients = await ApiService.getClients();
      print('Clients reçus dans SelectClientScreen:');
      print(jsonEncode(clients));

      setState(() {
        _clients = List<dynamic>.from(clients);
        _filteredClients = List<dynamic>.from(clients);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors de la récupération des clients: $e';
        _isLoading = false;
      });
    }
  }

  void _filterClients() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredClients =
          _clients
              .where(
                (client) =>
                    client['name'].toString().toLowerCase().contains(query),
              )
              .toList();
      print('Clients filtrés:');
      print(jsonEncode(_filteredClients));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sélectionner un client')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Rechercher un client',
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
                    : _filteredClients.isEmpty
                    ? const Center(child: Text('Aucun client trouvé'))
                    : ListView.builder(
                      itemCount: _filteredClients.length,
                      itemBuilder: (context, index) {
                        final client = _filteredClients[index];
                        return ListTile(
                          title: Text(client['name']),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => SelectPersonScreen(
                                      clientId: client['id'],
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
