import 'package:flutter/material.dart';
import 'package:smart_house/splash_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:smart_house/registration_screen.dart'; // Импортируем ваш экран регистрации

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Инициализация Supabase с вашими ключами
  await Supabase.initialize(
    url: 'https://yhkkygrudzttgkccxohy.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inloa2t5Z3J1ZHp0dGdrY2N4b2h5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzMxMjM5OTAsImV4cCI6MjA0ODY5OTk5MH0.k5_P-3wPIL9MIUlymNDtJttglYrP2bkcLgs0K2DlHog',
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Supabase Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SplashScreen(), // Ваш стартовый экран
    );
  }
}