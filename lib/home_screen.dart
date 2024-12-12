import 'package:flutter/material.dart';
import 'package:smart_house/server/server.dart';
import 'package:smart_house/models/models.dart';
import 'package:smart_house/add_room_screen.dart';
import 'package:smart_house/add_device_screen.dart'; // Добавляем новый экран для устройств

class HomeScreen extends StatefulWidget {
  final String userId;
  final String address; // Добавляем address

  HomeScreen({
    required this.userId,
    required this.address,
  });

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final SupabaseService _supabaseService = SupabaseService();
  List<Room> _rooms = [];
  List<Device> _devices = [];
  late TabController _tabController;
  bool _isDevicesLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadRooms();
    _tabController = TabController(length: 3, vsync: this);

    _tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.index == 1 && !_isDevicesLoaded) {
      _loadDevices();
    }
  }

  Future<void> _loadRooms() async {
    if (widget.address.isEmpty) {
      print('Address is empty. Cannot load rooms.');
      return;
    }

    final rooms = await _supabaseService.getRoomsByAddress(widget.address); // Используем address для загрузки комнат
    setState(() {
      _rooms = rooms;
    });
  }

  Future<void> _loadDevices() async {
    final devices = await _supabaseService.loadDevicesByHouse(widget.address); // Используем address для загрузки устройств
    setState(() {
      _devices = devices.map((device) {
        return Device(
          id: device['id'],
          name: device['name'] ?? '', // Добавляем проверку на null
          imageUrl: device['imageUrl'] ?? '', // Добавляем проверку на null
          isOn: device['isOn'] ?? false, // Добавляем проверку на null
          roomId: device['room_id'] ?? 0, // Добавляем проверку на null
          customId: device['custom_id'] ?? '', // Добавляем проверку на null
        );
      }).toList();
      _isDevicesLoaded = true;
    });

    print('Devices response: $devices');
  }

  void _addRoom() async {
    if (widget.address.isEmpty) {
      print('Address is empty. Cannot add room.');
      return;
    }

    final roomName = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddRoomScreen(userId: widget.userId, address: widget.address), // Передаем address
      ),
    );

    if (roomName != null) {
      _loadRooms();
    }
  }

  void _addDevice() async {
    if (widget.address.isEmpty) {
      print('Address is empty. Cannot add device.');
      return;
    }

    // Переход на экран добавления устройства
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddDeviceScreen(userId: widget.userId), // Передаем userId
      ),
    );

    // Если устройство было добавлено успешно, обновляем список устройств
    if (result == true) {
      await _loadDevices();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF2A2A37),
        toolbarHeight: 100,
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Твой дом', style: TextStyle(color: Colors.white, fontSize: 24)),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_on, color: Color(0xFF94949B)),
                SizedBox(width: 4),
                Text(
                  widget.address, // Отображаем адрес
                  style: TextStyle(color: Color(0xFF94949B), fontSize: 16),
                ),
              ],
            )
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 24.0),
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Color(0xFF0B50A0),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: IconButton(
                  icon: Icon(Icons.settings, size: 30),
                  color: Colors.white,
                  onPressed: () {
                    // Действие при нажатии на иконку настроек
                  },
                ),
              ),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          indicatorColor: Color(0xFF0B50A0),
          tabs: [
            Tab(text: 'Комнаты'),
            Tab(text: 'Устройства'),
            Tab(text: 'Пользователи'),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildRoomsTab(),
                _buildDevicesTab(),
                _buildUsersTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF0B50A0),
        onPressed: () {
          if (_tabController.index == 0) {
            _addRoom(); // Добавление комнаты
          } else if (_tabController.index == 1) {
            _addDevice(); // Добавление устройства
          }
        },
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildRoomsTab() {
    return _rooms.isEmpty
        ? Center(child: Text('Нет комнат'))
        : ListView.builder(
      itemCount: _rooms.length,
      itemBuilder: (context, index) {
        final room = _rooms[index];
        return Card(
          margin: EdgeInsets.all(16),
          color: Colors.white,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Color(0xFF0B50A0), width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Container(
            width: 300,
            height: 150,
            child: Row(
              children: [
                SizedBox(width: 24),
                Image.network(
                  room.imageUrl,
                  height: 100,
                  width: 100,
                ),
                SizedBox(width: 24),
                Text(
                  room.name,
                  style: TextStyle(
                    fontSize: 24,
                    color: Color(0xFF0B50A0),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDevicesTab() {
    return _devices.isEmpty
        ? Center(child: Text('Нет устройств'))
        : ListView.builder(
      itemCount: _devices.length,
      itemBuilder: (context, index) {
        final device = _devices[index];
        return Card(
          margin: EdgeInsets.all(16),
          color: Colors.white,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Color(0xFF0B50A0), width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Container(
            width: 300,
            height: 150,
            child: Row(
              children: [
                SizedBox(width: 24),
                Image.network(
                  device.imageUrl,
                  height: 100,
                  width: 100,
                ),
                SizedBox(width: 24),
                Text(
                  device.name,
                  style: TextStyle(
                    fontSize: 24,
                    color: Color(0xFF0B50A0),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Switch(
                  value: device.isOn,
                  onChanged: (value) async {
                    await _supabaseService.updateDeviceStatus(device.id.toString(), value);
                    _loadDevices(); // Обновляем список устройств
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildUsersTab() {
    return Center(child: Text('Пользователи (в разработке)'));
  }
}