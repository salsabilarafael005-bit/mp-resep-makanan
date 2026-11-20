import 'package:flutter/material.dart';

import 'halaman/halaman_login.dart';

void main() {
  runApp(const AdminResepApp());
}

class AdminResepApp extends StatelessWidget {
  const AdminResepApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Admin Resep Tradisional',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFD35400)),
      ),
      home: const HalamanLogin(),
    );
  }
}
