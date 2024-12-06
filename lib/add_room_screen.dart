import 'package:flutter/material.dart';
import 'package:smart_house/server/server.dart';
import 'package:smart_house/models/models.dart';

class AddRoomScreen extends StatefulWidget {
  final String userId;

  AddRoomScreen({required this.userId});

  @override
  _AddRoomScreenState createState() => _AddRoomScreenState();
}

class _AddRoomScreenState extends State<AddRoomScreen> {
  final _formKey = GlobalKey<FormState>();
  final _roomNameController = TextEditingController();
  String _selectedRoomType = '';
  final SupabaseService _supabaseService = SupabaseService();
  List<RoomType> _roomTypes = [];

  @override
  void initState() {
    super.initState();
    _loadRoomTypes();
  }

  Future<void> _loadRoomTypes() async {
    final roomTypes = await _supabaseService.getRoomTypes();
    setState(() {
      _roomTypes = roomTypes;
      if (_roomTypes.isNotEmpty) {
        _selectedRoomType = _roomTypes.first.id;
      }
    });
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final roomName = _roomNameController.text;
      await _supabaseService.addRoom(widget.userId, roomName, _selectedRoomType);
      Navigator.of(context).pop(roomName);
    }
  }

  @override
  void dispose() {
    _roomNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Добавить комнату'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _roomNameController,
                decoration: InputDecoration(labelText: 'Название комнаты'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Пожалуйста, введите название комнаты';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _selectedRoomType,
                items: _roomTypes.map((roomType) {
                  return DropdownMenuItem<String>(
                    value: roomType.id,
                    child: Row(
                      children: [
                        Image.network(roomType.imageUrl, height: 50, width: 50),
                        SizedBox(width: 10),
                        Text(roomType.name),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedRoomType = value!;
                  });
                },
                decoration: InputDecoration(labelText: 'Выбрать тип'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('Сохранить'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}