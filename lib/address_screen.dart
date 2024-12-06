import 'package:flutter/material.dart';
import 'package:smart_house/create_pin_code_screen.dart';
import 'package:smart_house/server/server.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddressScreen extends StatefulWidget {
  final String userId;

  AddressScreen({required this.userId});

  @override
  _AddressScreenState createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  final _formKey = GlobalKey<FormState>();
  String _address = '';
  final SupabaseService _supabaseService = SupabaseService();

  bool _isValidAddress(String address) {
    // Паттерн для проверки адреса
    final addressPattern = RegExp(
        r'^г\.\s[А-Яа-я]+\,\sул\.\s[А-Яа-я]+\,\sд\.\s\d+(\,\sкв\.\s\d+)?$');
    return addressPattern.hasMatch(address);
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final houseId = await _supabaseService.addHouse(_address);

      if (houseId != null) {
        await _supabaseService.updateProfileWithHouseId(widget.userId, houseId);
        // Переход на CreatePinScreen
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => CreatePinScreen(userId: widget.userId)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка сохранения адреса. Пожалуйста, попробуйте снова.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Добавить адрес'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  'Добавьте адрес своего дома в формате г. Название города, ул. Название улицы, д. Номер дома',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 20),
              Container(
                width: 333,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey),
                ),
                child: TextFormField(
                  maxLines: null, // Позволяет текстовому полю растягиваться по высоте
                  minLines: 1, // Минимальное количество строк
                  decoration: InputDecoration(
                    labelText: 'Адрес',
                    labelStyle: TextStyle(color: Colors.black),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12), // Добавляем вертикальный отступ
                  ),
                  style: TextStyle(color: Colors.black),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Пожалуйста, введите адрес';
                    } else if (!_isValidAddress(value)) {
                      return 'Адрес должен соответствовать формату: г. Название, ул. Название, д. Номер, кв. Номер';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    _address = value;
                  },
                ),
              ),
              SizedBox(height: 20),
              Spacer(), // Используем Spacer для выравнивания кнопки внизу
              Container(
                margin: EdgeInsets.only(bottom: 12), // Отступ 12 от низа
                width: 200,
                height: 50,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    primary: Color(0xFF0B50A0),
                    onPrimary: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text('Сохранить'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}