import 'package:flutter/material.dart';
import 'package:smart_house/registration_screen.dart';
import 'home_screen.dart'; // Импортируем HomeScreen

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _opacity = 0.0; // Начальная прозрачность

  @override
  void initState() {
    super.initState();
    // Задержка перед переходом на основной экран
    Future.delayed(Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => RegistrationScreen()),
      );
    });

    // Анимация появления
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        _opacity = 1.0; // Полная непрозрачность
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AnimatedOpacity(
          opacity: _opacity,
          duration: Duration(seconds: 1), // Длительность анимации
          child: FittedBox(
            fit: BoxFit.contain,
            child: SizedBox(
              width: 250,
              height: 250,
              child: Image.asset('assets/splash_screen_logo.png'),
            ),
          ),
        ),
      ),
    );
  }
}