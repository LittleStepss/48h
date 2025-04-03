import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:front/screens/select_person.dart';
import 'package:http/http.dart' as http;

class SelectClientScreen extends StatefulWidget {
  @override
  _SelectClientScreenState createState() => _SelectClientScreenState();
}

class _SelectClientScreenState extends State<SelectClientScreen> {
  TextEditingController searchController = TextEditingController();
  List<dynamic> clients = [];
  List<dynamic> filteredClients = [];

  final String token = "6UXrKe@zSKdnn7rUz#4A@NQ6CU#PYEgw4eRuK^*f";

  @override
  void initState() {
    super.initState();
    fetchClients();
  }

  Future<void> fetchClients() async {
    final String apiUrl = "http://foureight.gurvan-nicolas.fr:8080/clients";
    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          "Authorization": "Bearer $token", 
          "Content-Type": "application/json",
        },
      );
      if (response.statusCode == 200) {
        setState(() {
          final Map<String, dynamic> responseData = jsonDecode(response.body);
          clients = responseData["data"];
          filteredClients = clients;
        });
      } else {
        print("Erreur de chargement: \${response.statusCode}");
      }
    } catch (e) {
      print("Erreur: \$e");
    }
  }

  //filtrer les clients (barre de recherche)
  void filterClients(String query) {
    setState(() {
      filteredClients =
          clients.where((client) {
            String clientName = client["name"] ?? "";
            return clientName.toLowerCase().contains(query.toLowerCase());
          }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sélectionner un client')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Rechercher un client',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: filterClients,
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: filteredClients.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      filteredClients[index]["name"] ?? "Nom inconnu",
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => SelectPersonScreen(
                                clientId: filteredClients[index]["id"],
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
      ),
    );
  }
}
