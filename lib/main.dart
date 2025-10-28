import 'package:flutter/material.dart';
import 'package:tokonovel/dashboard.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NovelKu',
      theme: ThemeData(
        primarySwatch: Colors.brown,
        fontFamily: 'Poppins',
      ),
      debugShowCheckedModeBanner: false,
      home: const LoginPage(),
    );
  }
}
