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
        backgroundColor: Color(0xFF2A2A37),
        toolbarHeight: 100,
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Color(0xFF0B50A0),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(Icons.chevron_left, color: Colors.white, size: 30),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        title: Text(
          'Добавить комнату',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              TextFormField(
                controller: _roomNameController,
                decoration: InputDecoration(
                  hintText: 'Название комнаты',
                  hintStyle: TextStyle(color: Color(0xFF94949B)),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF94949B)),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                style: TextStyle(color: Color(0xFF94949B)),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Пожалуйста, введите название комнаты';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              Text(
                'Выбрать тип',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF94949B)
                ),
              ),
              SizedBox(height: 8),
              Expanded(
                child: GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1.0,
                    mainAxisSpacing: 8.0,
                    crossAxisSpacing: 8.0,
                  ),
                  itemCount: _roomTypes.length,
                  itemBuilder: (context, index) {
                    final roomType = _roomTypes[index];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedRoomType = roomType.id;
                        });
                      },
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              border: _selectedRoomType == roomType.id
                                  ? Border.all(color: Color(0xFF0B50A0), width: 2)
                                  : null,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: EdgeInsets.all(8),
                            child: Image.network(
                              roomType.imageUrl,
                              height: 50,
                              width: 50,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(roomType.name),
                        ],
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 20),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    child: Text(
                      'Сохранить',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    style: ElevatedButton.styleFrom(
                      primary: Color(0xFF0B50A0),
                      minimumSize: Size(150, 60),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}