import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:smart_house/models/models.dart' as smart_house_models;
import 'package:gotrue/src/types/user.dart' as gotrue_user; // Переименовываем импорт
import '../models/models.dart'; // Импортируем ваши модели

class SupabaseService {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  // Регистрация пользователя
  Future<String?> registerUser(smart_house_models.User user) async {
    try {
      final authResponse = await _supabaseClient.auth.signUp(
        email: user.email,
        password: user.password,
      );

      if (authResponse.user != null) {
        final userId = authResponse.user!.id;

        await _supabaseClient.from('profiles').insert([
          {
            'id': userId,
            'username': user.username,
            'pin_code': user.pinCode,
          },
        ]);

        print('User registered: $user');
        return userId;
      } else {
        print('Error registering user: User not created');
        return null;
      }
    } catch (e) {
      print('Error registering user: $e');
      return null;
    }
  }

  // Вход пользователя
  Future<smart_house_models.User?> loginUser(String email, String password) async {
    try {
      final AuthResponse res = await _supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );
      final Session? session = res.session;
      final gotrue_user.User? user = res.user;

      if (user != null) {
        print('User logged in: $user');
        return smart_house_models.User(
          id: user.id,
          username: user.userMetadata?['username'] ?? '',
          email: user.email ?? '',
          password: '',
          pinCode: user.userMetadata?['pin_code'],
        );
      } else {
        print('User not found or incorrect password');
        return null;
      }
    } catch (e) {
      print('Error logging in user: $e');
      return null;
    }
  }

  // Добавление дома
  Future<String?> addHouse(String address) async {
    try {
      final response = await _supabaseClient.from('house').insert([
        {'address': address},
      ]).select();

      if (response.isNotEmpty) {
        return response[0]['id'];
      } else {
        print('Error adding house');
        return null;
      }
    } catch (e) {
      print('Error adding house: $e');
      return null;
    }
  }

  // Обновление профиля с house_id
  Future<bool> updateProfileWithHouseId(String userId, String houseId) async {
    try {
      final response = await _supabaseClient.from('profiles').update({
        'house_id': houseId,
      }).eq('id', userId).execute();

      if (response.status == 204) {
        return true;
      } else {
        print('Error updating profile with house_id');
        return false;
      }
    } catch (e) {
      print('Error updating profile with house_id: $e');
      return false;
    }
  }

  // Сохранение PIN-кода
  Future<bool> savePinCode(String userId, int pinCode) async {
    try {
      final response = await _supabaseClient.from('profiles').update({
        'pin_code': pinCode,
      }).eq('id', userId).execute();

      if (response.status == 204) {
        return true;
      } else {
        print('Error saving PIN code');
        return false;
      }
    } catch (e) {
      print('Error saving PIN code: $e');
      return false;
    }
  }

  // Проверка PIN-кода
  Future<bool> verifyPinCode(String userId, int pinCode) async {
    try {
      final response = await _supabaseClient.from('profiles')
          .select('pin_code')
          .eq('id', userId)
          .single();

      if (response['pin_code'] == pinCode) {
        return true;
      } else {
        print('Incorrect PIN code');
        return false;
      }
    } catch (e) {
      print('Error verifying PIN code: $e');
      return false;
    }
  }

  // Получение списка комнат
  Future<List<smart_house_models.Room>> getRooms(String userId) async {
    try {
      final profileResponse = await _supabaseClient.from('profiles')
          .select('house_id')
          .eq('id', userId)
          .single();

      final houseId = profileResponse['house_id'];

      if (houseId == null) {
        print('Error getting rooms: house_id is null');
        return [];
      }

      final response = await _supabaseClient.from('room')
          .select('name, type_id, house_id')
          .eq('house_id', houseId);

      print('Rooms response: $response');

      final List<smart_house_models.Room> rooms = [];
      for (var room in response) {
        final typeResponse = await _supabaseClient.from('type_room')
            .select('name, image')
            .eq('id', room['type_id'])
            .single();

        final imageUrl = _supabaseClient.storage.from('images').getPublicUrl(typeResponse['image']);

        rooms.add(smart_house_models.Room(
          name: room['name'],
          imageUrl: imageUrl,
          houseId: houseId,
        ));
      }

      return rooms;
    } catch (e) {
      print('Error getting rooms: $e');
      return [];
    }
  }

  // Добавление комнаты
  Future<void> addRoom(String userId, String roomName, String typeId) async {
    try {
      final profileResponse = await _supabaseClient.from('profiles')
          .select('house_id')
          .eq('id', userId)
          .single();

      final houseId = profileResponse['house_id'];

      if (houseId != null) {
        final roomResponse = await _supabaseClient.from('room').insert([
          {
            'name': roomName,
            'type_id': typeId,
            'house_id': houseId,
          },
        ]).select();

        if (roomResponse.isNotEmpty) {
          final roomId = roomResponse[0]['id'];

          await _supabaseClient.from('house').update({
            'room_id': roomId,
          }).eq('id', houseId).execute();
        }
      } else {
        print('Error adding room: house_id is null');
      }
    } catch (e) {
      print('Error adding room: $e');
    }
  }

  // Удаление комнаты
  Future<void> deleteRoom(String userId, String roomName) async {
    try {
      final profileResponse = await _supabaseClient.from('profiles')
          .select('house_id')
          .eq('id', userId)
          .single();

      final houseId = profileResponse['house_id'];

      if (houseId != null) {
        await _supabaseClient.from('room')
            .delete()
            .eq('house_id', houseId)
            .eq('name', roomName);
      } else {
        print('Error deleting room: house_id is null');
      }
    } catch (e) {
      print('Error deleting room: $e');
    }
  }

  // Получение типов комнат
  Future<List<smart_house_models.RoomType>> getRoomTypes() async {
    try {
      final response = await _supabaseClient.from('type_room').select('id, name, image');

      final List<smart_house_models.RoomType> roomTypes = [];
      for (var type in response) {
        final imageUrl = _supabaseClient.storage.from('images').getPublicUrl(type['image']);

        roomTypes.add(smart_house_models.RoomType(
          id: type['id'],
          name: type['name'],
          image: imageUrl,
        ));
      }

      return roomTypes;
    } catch (e) {
      print('Error getting room types: $e');
      return [];
    }
  }

  // Получение адреса пользователя
  Future<String> getAddress(String userId) async {
    try {
      final response = await _supabaseClient.from('profiles')
          .select('house_id')
          .eq('id', userId)
          .single();

      final houseId = response['house_id'];

      final addressResponse = await _supabaseClient.from('house')
          .select('address')
          .eq('id', houseId)
          .single();

      return addressResponse['address'];
    } catch (e) {
      print('Error getting address: $e');
      return '';
    }
  }

  // Получение списка устройств
  Future<List<smart_house_models.Device>> getDevices(String userId) async {
    try {
      final profileResponse = await _supabaseClient.from('profiles')
          .select('house_id')
          .eq('id', userId)
          .single();

      final houseId = profileResponse['house_id'];

      if (houseId == null) {
        print('Error getting devices: house_id is null');
        return [];
      }

      // Получаем комнаты пользователя
      final roomsResponse = await _supabaseClient.from('room')
          .select('id')
          .eq('house_id', houseId);

      final List<int> roomIds = roomsResponse.map((room) => room['id'] as int).toList();

      // Получаем устройства, связанные с комнатами
      final response = await _supabaseClient.from('device')
          .select('id, name, custom_id, type_id, is_on, room_id')
          .in_('room_id', roomIds);

      final List<smart_house_models.Device> devices = [];
      for (var device in response) {
        final typeResponse = await _supabaseClient.from('type_device')
            .select('name, image')
            .eq('id', device['type_id'])
            .single();

        final imageUrl = _supabaseClient.storage.from('images').getPublicUrl(typeResponse['image']);

        devices.add(smart_house_models.Device(
          id: device['id'],
          name: device['name'],
          customId: device['custom_id'],
          imageUrl: imageUrl,
          isOn: device['is_on'],
          roomId: device['room_id']
        ));
      }

      return devices;
    } catch (e) {
      print('Error getting devices: $e');
      return [];
    }
  }

  // Добавление устройства
  Future<void> addDevice(String userId, String name, String customId, String typeId) async {
    try {
      final profileResponse = await _supabaseClient.from('profiles')
          .select('house_id')
          .eq('id', userId)
          .single();

      final houseId = profileResponse['house_id'];

      if (houseId != null) {
        // Получаем комнаты пользователя
        final roomsResponse = await _supabaseClient.from('room')
            .select('id')
            .eq('house_id', houseId);

        if (roomsResponse.isEmpty) {
          print('Error adding device: no rooms found for user');
          return;
        }

        final roomId = roomsResponse[0]['id']; // Используем первую комнату

        await _supabaseClient.from('device').insert([
          {
            'name': name,
            'custom_id': customId,
            'type_id': typeId,
            'room_id': roomId,
            'is_on': false,
          },
        ]);
      } else {
        print('Error adding device: house_id is null');
      }
    } catch (e) {
      print('Error adding device: $e');
    }
  }

  // Обновление статуса устройства
  Future<void> updateDeviceStatus(String deviceId, bool isOn) async {
    try {
      await _supabaseClient.from('device').update({
        'is_on': isOn,
      }).eq('id', deviceId).execute();
    } catch (e) {
      print('Error updating device status: $e');
    }
  }

  // Получение типов устройств
  Future<List<smart_house_models.RoomType>> getDeviceTypes() async {
    try {
      final response = await _supabaseClient.from('type_device').select('id, name, image');

      final List<smart_house_models.RoomType> deviceTypes = [];
      for (var type in response) {
        final imageUrl = _supabaseClient.storage.from('images').getPublicUrl(type['image']);

        deviceTypes.add(smart_house_models.RoomType(
          id: type['id'].toString(),
          name: type['name'],
          image: imageUrl,
        ));
      }

      return deviceTypes;
    } catch (e) {
      print('Error getting device types: $e');
      return [];
    }
  }

  // Метод для загрузки устройств по адресу дома
  Future<List<Map<String, dynamic>>> loadDevicesByHouse(String address) async {
    try {
      // Получаем house_id по адресу
      final houseResponse = await _supabaseClient.from('house')
          .select('id')
          .eq('address', address)
          .single();

      final houseId = houseResponse['id'];

      // Получаем устройства, связанные с этим house_id
      final devicesResponse = await _supabaseClient.from('device')
          .select('id, name, is_on, type_id, room_id')
          .eq('house_id', houseId);

      final List<Map<String, dynamic>> devices = [];
      for (var device in devicesResponse) {
        final typeResponse = await _supabaseClient.from('type_device')
            .select('name, image')
            .eq('id', device['type_id'])
            .single();

        final imageUrl = _supabaseClient.storage.from('images').getPublicUrl(typeResponse['image']);

        devices.add({
          'id': device['id'],
          'name': device['name'],
          'imageUrl': imageUrl,
          'isOn': device['is_on'],
          'room_id': device['room_id'],
        });
      }

      return devices;
    } catch (e) {
      print('Error loading devices by house: $e');
      return [];
    }
  }

// Метод для загрузки комнат по адресу дома
  Future<List<Room>> getRoomsByAddress(String address) async {
    try {
      // Получаем house_id по адресу
      final houseResponse = await _supabaseClient.from('house')
          .select('id')
          .eq('address', address)
          .single();

      final houseId = houseResponse['id'];

      // Получаем комнаты, связанные с этим house_id
      final roomsResponse = await _supabaseClient.from('room')
          .select('id, name, type_id, house_id')
          .eq('house_id', houseId);

      final List<Room> rooms = [];
      for (var room in roomsResponse) {
        final typeResponse = await _supabaseClient.from('type_room')
            .select('name, image')
            .eq('id', room['type_id'])
            .single();

        final imageUrl = _supabaseClient.storage.from('images').getPublicUrl(typeResponse['image']);

        rooms.add(Room(
          id: room['id'], // Добавляем id
          name: room['name'],
          imageUrl: imageUrl,
          houseId: room['house_id'],
        ));
      }

      return rooms;
    } catch (e) {
      print('Error loading rooms by address: $e');
      return [];
    }
  }
}