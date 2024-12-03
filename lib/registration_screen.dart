import 'package:flutter/material.dart';
import 'package:smart_house/sign_in_screen.dart';
import 'address_screen.dart';
import 'create_pin_code_screen.dart'; // Импортируем PinCodeScreen
import 'package:smart_house/models/models.dart'; // Импортируем модель пользователя
import 'package:smart_house/server/server.dart'; // Импортируем сервис для работы с Supabase

class RegistrationScreen extends StatefulWidget {
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;

  String _username = '';
  String _email = '';
  String _password = '';

  final SupabaseService _supabaseService = SupabaseService();

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[a-z0-9]+(\.[a-z0-9]+)*@[a-z0-9]+(\.[a-z0-9]+)+$');
    return emailRegex.hasMatch(email);
  }

  bool _isValidPassword(String password) {
    final passwordRegex = RegExp(r'^\d{6}$'); // Пароль должен состоять из 6 цифр
    return passwordRegex.hasMatch(password);
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final user = User(
        username: _username,
        email: _email,
        password: _password,
      );

      bool registrationSuccess = await _supabaseService.registerUser(user);

      if (registrationSuccess) {
        // Переход на экран ввода пин-кода
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => AddressScreen()),
        );
      } else {
        // Показ всплывающего сообщения об ошибке
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка регистрации. Пожалуйста, попробуйте снова.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Фон
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Форма регистрации
          Center(
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
                    Container(
                      decoration: BoxDecoration(
                        color: Color(0xFF63D1E4).withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.all(12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Имя пользователя',
                                labelStyle: TextStyle(color: Colors.black),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black),
                                ),
                              ),
                              style: TextStyle(color: Colors.black),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Пожалуйста, введите имя пользователя';
                                }
                                return null;
                              },
                              onChanged: (value) {
                                _username = value;
                              },
                            ),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: TextFormField(
                              decoration: const InputDecoration( // Исправлено здесь
                                labelText: 'Почта',
                                labelStyle: TextStyle(color: Colors.black),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black),
                                ),
                              ),
                              style: TextStyle(color: Colors.black),
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
                              },
                            ),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: TextFormField(
                              obscureText: !_isPasswordVisible,
                              keyboardType: TextInputType.number, // Устанавливаем тип клавиатуры для ввода цифр
                              decoration: InputDecoration(
                                labelText: 'Пароль',
                                labelStyle: TextStyle(color: Colors.black),
                                enabledBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black),
                                ),
                                focusedBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black),
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                    color: Colors.black,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isPasswordVisible = !_isPasswordVisible;
                                    });
                                  },
                                ),
                              ),
                              style: TextStyle(color: Colors.black),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Пожалуйста, введите пароль';
                                } else if (!_isValidPassword(value)) {
                                  return 'Пароль должен состоять из 6 цифр';
                                }
                                return null;
                              },
                              onChanged: (value) {
                                _password = value;
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: SizedBox(
                        width: 333,
                        height: 35,
                        child: ElevatedButton(
                          onPressed: _submitForm,
                          style: ElevatedButton.styleFrom(
                            primary: Colors.black,
                            onPrimary: Colors.white,
                          ),
                          child: const Text('Зарегистрироваться'),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Уже есть аккаунт? ',
                          style: TextStyle(color: Colors.white),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) => SignInScreen()),
                            );
                          },
                          child: const Text(
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
        ],
      ),
    );
  }
}