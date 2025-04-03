import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'select_client.dart';
import 'scan_idcard.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isPasswordVisible = false;
  String? errorMessage;

  final String token = "6UXrKe@zSKdnn7rUz#4A@NQ6CU#PYEgw4eRuK^*f";

  Future<void> login() async {
    final String apiUrl = "http://foureight.gurvan-nicolas.fr:8080/login";
    
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token", 
      },
      body: jsonEncode({
        "email": emailController.text,
        "password": passwordController.text,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (responseData["code"] == 200) {
        int userId = responseData["id"];
        String userEmail = responseData["email"];
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Connexion réussie ! Bienvenue, $userEmail")),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SelectClientScreen()),
        );
      } else {
        setState(() {
          errorMessage = responseData["message"];
        });
      }
    } else {
      setState(() {
        errorMessage = "Erreur serveur (${response.statusCode})";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'assets/images/cerfrance.jpg',
          height: 60,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (errorMessage != null)
              Text(
                errorMessage!,
                style: TextStyle(color: Colors.red),
              ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: 'Mot de passe',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      isPasswordVisible = !isPasswordVisible;
                    });
                  },
                ),
              ),
              obscureText: !isPasswordVisible,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: login,
              child: const Text('Se connecter'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ScanIdCardScreen(individuId: 1)),
                );
              },
              child: const Text('Aller directement à SelectClient'),
            ),
          ],
        ),
      ),
    );
  }
}
