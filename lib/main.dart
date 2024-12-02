import 'package:flutter/material.dart';
import 'splash_screen.dart'; // Импортируем SplashScreen

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SplashScreen(), // Используем SplashScreen как домашний экран
    );
  }
}