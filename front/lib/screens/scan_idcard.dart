import 'package:flutter/material.dart';

class ScanIdCardScreen extends StatelessWidget {
  final int individuId;

  ScanIdCardScreen({required this.individuId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Préparez-vous à scanner la CNI')),
      body: Center(
        child: Text("A vous de jouez les gars"),
      ),
    );
  }
}
