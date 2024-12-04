import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart'; // Импортируем HomeScreen

class CreatePinScreen extends StatefulWidget {
  @override
  _CreatePinScreenState createState() => _CreatePinScreenState();
}

class _CreatePinScreenState extends State<CreatePinScreen> {
  final _pinController = TextEditingController();
  List<bool> _pinFilled = [false, false, false, false];

  void _onNumberPressed(String number) async {
    if (_pinController.text.length < 4) {
      setState(() {
        _pinController.text += number;
        _pinFilled[_pinController.text.length - 1] = true;
      });

      // Переход на экран HomeScreen после ввода 4 цифр
      if (_pinController.text.length == 4) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('pin_code', _pinController.text);

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => HomeScreen(),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Image.asset(
            'assets/background.png',
            fit: BoxFit.cover,
            height: double.infinity,
            width: double.infinity,
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF30CCE1).withOpacity(0.8),
                  Color(0xFF30CCE1).withOpacity(0.6),
                  Color(0xFF30CCE1).withOpacity(0.4),
                  Color(0xFF30CCE1).withOpacity(0.2),
                ],
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Image.asset(
                  'assets/auth_logo.png',
                  height: 200,
                ),
                const Text(
                  'Создание PinCode',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold
                  ),
                ),
                SizedBox(height: 24.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (index) {
                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: 8.0),
                      width: 20.0,
                      height: 20.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _pinFilled[index] ? Colors.black : Colors.black.withOpacity(0.2),
                      ),
                    );
                  }),
                ),
                SizedBox(height: 24.0),
                Container(
                  margin: const EdgeInsets.all(16.0),
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Color(0xFF30CCE1).withOpacity(0.8),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: GridView.count(
                    shrinkWrap: true,
                    crossAxisCount: 3,
                    childAspectRatio: 1.5, // Уменьшаем размер кнопок
                    mainAxisSpacing: 8.0, // Добавляем отступы между кнопками
                    crossAxisSpacing: 8.0, // Добавляем отступы между кнопками
                    children: List.generate(9, (index) {
                      return _buildNumberButton((index + 1) % 10 == 0 ? '0' : (index + 1).toString());
                    }),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberButton(String number) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 2.0),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: TextButton(
          onPressed: () => _onNumberPressed(number),
          style: TextButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            padding: EdgeInsets.all(8.0),
          ),
          child: Text(number),
        ),
      ),
    );
  }
}