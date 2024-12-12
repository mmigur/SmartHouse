import 'package:flutter/material.dart';
import 'package:smart_house/server/server.dart';
import 'package:smart_house/models/models.dart';

class AddDeviceScreen extends StatefulWidget {
  final String userId;

  AddDeviceScreen({required this.userId});

  @override
  _AddDeviceScreenState createState() => _AddDeviceScreenState();
}

class _AddDeviceScreenState extends State<AddDeviceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _deviceNameController = TextEditingController();
  final _customIdController = TextEditingController();
  String _selectedDeviceType = '';
  final SupabaseService _supabaseService = SupabaseService();
  List<RoomType> _deviceTypes = [];

  @override
  void initState() {
    super.initState();
    _loadDeviceTypes();
  }

  Future<void> _loadDeviceTypes() async {
    final deviceTypes = await _supabaseService.getDeviceTypes();
    setState(() {
      _deviceTypes = deviceTypes;
      if (_deviceTypes.isNotEmpty) {
        _selectedDeviceType = _deviceTypes.first.id;
      }
    });
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final deviceName = _deviceNameController.text;
      final customId = _customIdController.text;
      await _supabaseService.addDevice(widget.userId, deviceName, customId, _selectedDeviceType);

      // Возвращаем true, если устройство добавлено успешно
      Navigator.of(context).pop(true);
    }
  }

  @override
  void dispose() {
    _deviceNameController.dispose();
    _customIdController.dispose();
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
          'Добавить устройство',
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
                controller: _deviceNameController,
                decoration: InputDecoration(
                  hintText: 'Название устройства',
                  hintStyle: TextStyle(color: Color(0xFF94949B)),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF94949B)),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                style: TextStyle(color: Color(0xFF94949B)),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Пожалуйста, введите название устройства';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _customIdController,
                decoration: InputDecoration(
                  hintText: 'Идентификатор устройства',
                  hintStyle: TextStyle(color: Color(0xFF94949B)),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF94949B)),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                style: TextStyle(color: Color(0xFF94949B)),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Пожалуйста, введите идентификатор устройства';
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
                  itemCount: _deviceTypes.length,
                  itemBuilder: (context, index) {
                    final deviceType = _deviceTypes[index];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedDeviceType = deviceType.id;
                        });
                      },
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              border: _selectedDeviceType == deviceType.id
                                  ? Border.all(color: Color(0xFF0B50A0), width: 2)
                                  : null,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: EdgeInsets.all(8),
                            child: Image.network(
                              deviceType.image,
                              height: 50,
                              width: 50,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(deviceType.name),
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