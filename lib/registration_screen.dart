import 'package:flutter/material.dart';
import 'sign_in_screen.dart'; // Импортируем SignInScreen

class RegistrationScreen extends StatefulWidget {
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  bool _isButtonEnabled = false;

  String _username = '';
  String _email = '';
  String _password = '';

  void _checkFormValidity() {
    setState(() {
      _isButtonEnabled = _formKey.currentState?.validate() ?? false;
    });
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$');
    return emailRegex.hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/auth_logo.png',
                  width: 200,
                  height: 200,
                ),
                SizedBox(height: 20),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Имя пользователя'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Пожалуйста, введите имя пользователя';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    _username = value;
                    _checkFormValidity();
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Почта'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Пожалуйста, введите почту';
                    } else if (!_isValidEmail(value)) {
                      return 'Пожалуйста, введите корректную почту';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    _email = value;
                    _checkFormValidity();
                  },
                ),
                TextFormField(
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'Пароль',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Пожалуйста, введите пароль';
                    } else if (value.length < 6) {
                      return 'Пароль должен быть не менее 6 символов';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    _password = value;
                    _checkFormValidity();
                  },
                ),
                SizedBox(height: 20),
                SizedBox(
                  width: 333,
                  height: 35,
                  child: ElevatedButton(
                    onPressed: _isButtonEnabled ? () {
                      // Действие при нажатии на кнопку регистрации
                      if (_formKey.currentState!.validate()) {
                        // Здесь можно добавить логику регистрации
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Регистрация прошла успешно')),
                        );
                      }
                    } : null,
                    style: ElevatedButton.styleFrom(
                      primary: _isButtonEnabled ? Colors.black : Colors.white,
                      onPrimary: Colors.white,
                    ),
                    child: Text('Зарегистрироваться'),
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Уже есть аккаунт? ',
                      style: TextStyle(color: Color(0xFFD9D9D9)),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => SignInScreen()),
                        );
                      },
                      child: Text(
                        'Войти',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}