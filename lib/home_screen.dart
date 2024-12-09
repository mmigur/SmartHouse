import 'package:flutter/material.dart';
import 'package:smart_house/server/server.dart';
import 'package:smart_house/models/models.dart';
import 'package:smart_house/add_room_screen.dart';

class HomeScreen extends StatefulWidget {
  final String userId;
  final String address;

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
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _loadRooms();
    _tabController = TabController(length: 3, vsync: this);
  }

  Future<void> _loadRooms() async {
    final rooms = await _supabaseService.getRooms(widget.userId);
    setState(() {
      _rooms = rooms;
    });
  }

  void _addRoom() async {
    final roomName = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddRoomScreen(userId: widget.userId),
      ),
    );

    if (roomName != null) {
      _loadRooms(); // Обновляем список комнат после добавления новой
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
                Text(widget.address, style: TextStyle(color: Color(0xFF94949B), fontSize: 16)),
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
        onPressed: _addRoom,
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
                      fontWeight: FontWeight.bold
                    )
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDevicesTab() {
    return Center(child: Text('Устройства (в разработке)'));
  }

  Widget _buildUsersTab() {
    return Center(child: Text('Пользователи (в разработке)'));
  }
}