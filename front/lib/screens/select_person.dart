import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'scan_idcard.dart'; // Importation de la page scan_idcard.dart

class SelectPersonScreen extends StatefulWidget {
  final int clientId;

  SelectPersonScreen({required this.clientId});

  @override
  _SelectPersonScreenState createState() => _SelectPersonScreenState();
}

class _SelectPersonScreenState extends State<SelectPersonScreen> {
  List<dynamic> individus = [];
  List<dynamic> filteredIndividus = [];
  TextEditingController searchController = TextEditingController();

  final String token = "6UXrKe@zSKdnn7rUz#4A@NQ6CU#PYEgw4eRuK^*f";

  @override
  void initState() {
    super.initState();
    fetchIndividus();
  }

  Future<void> fetchIndividus() async {
    final String apiUrl = "http://foureight.gurvan-nicolas.fr:8080/individus";
    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          "Authorization": "Bearer $token",  
          "Content-Type": "application/json",
        },
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        List<dynamic> allIndividus = responseData["data"];

        // Filtrer les individus par id du client
        setState(() {
          individus = allIndividus.where((individu) => individu["client_id"] == widget.clientId).toList();
          filteredIndividus = individus;  
        });
      } else {
        print("Erreur de chargement: \${response.statusCode}");
      }
    } catch (e) {
      print("Erreur: \$e");
    }
  }

  // flitrer les individus (barre de recherche)
  void filterIndividus(String query) {
    setState(() {
      filteredIndividus = individus.where((individu) {
        String fullName = "${individu['name']} ${individu['surname']}".toLowerCase();
        return fullName.contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sélectionner un employe(é)'),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher un employe(é)',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onChanged: filterIndividus,
            ),
          ),
        ),
      ),
      body: filteredIndividus.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: filteredIndividus.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    "${filteredIndividus[index]["name"]} ${filteredIndividus[index]["surname"]}",
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ScanIdCardScreen(
                          individuId: filteredIndividus[index]["id"], 
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
