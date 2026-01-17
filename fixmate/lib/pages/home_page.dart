import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("FixMate Dashboard"),
        centerTitle: true,
        backgroundColor: const Color(0xFF00A8C6),
      ),
      body: const Center(
        child: Text(
          "Welcome to Apartment FixMate!",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
