import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api.dart';

class ClientSelectionScreen extends StatefulWidget {
  @override
  _ClientSelectionScreenState createState() => _ClientSelectionScreenState();
}

class _ClientSelectionScreenState extends State<ClientSelectionScreen> {
  List<dynamic> clients = [];
  List<dynamic> filteredClients = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchClients();
    searchController.addListener(_filterClients);
  }

  Future<void> fetchClients() async {
    try {
      final response = await http.get(Uri.parse(APIConfig.clients));

      if (response.statusCode == 200) {
        setState(() {
          clients = json.decode(response.body);
          filteredClients = clients; 
        });
      } else {
        print("Erreur: ${response.statusCode}");
      }
    } catch (e) {
      print("Erreur réseau: $e");
    }
  }

  void _filterClients() {
    String query = searchController.text.toLowerCase();
    setState(() {
      filteredClients = clients.where((client) {
        String name = client['name'].toLowerCase();
        return name.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sélectionner un client')),
      body: Column(
        children: [
          // Barre de recherche
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: "Rechercher un client...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),

          // Liste des clients
          Expanded(
            child: filteredClients.isEmpty
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: filteredClients.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(filteredClients[index]['name']),
                        onTap: () {
                          Navigator.pushNamed(context, '/scan');
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
