import 'package:flutter/material.dart';
import 'package:smart_house/home_screen.dart'; // Импортируем HomeScreen
import 'package:smart_house/server/server.dart'; // Импортируем SupabaseService

class PinCodeScreen extends StatefulWidget {
  final String userId; // Добавляем userId для проверки PIN-кода

  PinCodeScreen({required this.userId});

  @override
  _PinCodeScreenState createState() => _PinCodeScreenState();
}

class _PinCodeScreenState extends State<PinCodeScreen> {
  final _pinController = TextEditingController();
  List<bool> _pinFilled = [false, false, false, false];
  final SupabaseService _supabaseService = SupabaseService();

  void _onNumberPressed(String number) {
    if (_pinController.text.length < 4) {
      setState(() {
        _pinController.text += number;
        _pinFilled[_pinController.text.length - 1] = true;
      });

      // Проверка PIN-кода после ввода 4 цифр
      if (_pinController.text.length == 4) {
        final pinCode = int.parse(_pinController.text);
        _verifyPinCode(pinCode);
      }
    }
  }

  void _verifyPinCode(int pinCode) async {
    final isValid = await _supabaseService.verifyPinCode(widget.userId, pinCode);

    if (isValid) {
      final address = await _supabaseService.getAddress(widget.userId);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => HomeScreen(userId: widget.userId, address: address),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Неверный PIN-код. Пожалуйста, попробуйте снова.'),
          backgroundColor: Colors.red,
        ),
      );
      _clearPin();
    }
  }

  void _clearPin() {
    setState(() {
      _pinController.clear();
      _pinFilled = [false, false, false, false];
    });
  }

  void _onExitPressed() {
    _clearPin();
    Navigator.of(context).pop();
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
                SizedBox(height: 24.0),
                Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: ElevatedButton(
                    onPressed: _onExitPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF010101),
                      foregroundColor: Colors.white,
                      textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    child: Text('Выйти'),
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