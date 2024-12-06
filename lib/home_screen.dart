import 'package:flutter/material.dart';
import 'package:smart_house/server/server.dart';
import 'package:smart_house/add_room_screen.dart';
import 'package:smart_house/models/models.dart';

class HomeScreen extends StatefulWidget {
  final String userId;
  final String address;

  HomeScreen({required this.userId, required this.address});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  List<Room> _rooms = [];

  @override
  void initState() {
    super.initState();
    _loadRooms();
  }

  Future<void> _loadRooms() async {
    final rooms = await _supabaseService.getRooms(widget.userId);
    print('Loaded rooms: $rooms'); // Добавляем отладочное сообщение
    setState(() {
      _rooms = rooms;
    });
  }

  Future<void> _deleteRoom(String roomName) async {
    await _supabaseService.deleteRoom(widget.userId, roomName);
    await _loadRooms();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Твой дом'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              // Логика выхода из аккаунта
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              '${widget.address}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _rooms.length,
              itemBuilder: (context, index) {
                final room = _rooms[index];
                return ListTile(
                  leading: Image.network(room.imageUrl),
                  title: Text(room.name),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => _deleteRoom(room.name),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AddRoomScreen(userId: widget.userId),
            ),
          ).then((newRoom) {
            if (newRoom != null) {
              _loadRooms();
            }
          });
        },
        child: Icon(Icons.add),
      ),
    );
  }
}