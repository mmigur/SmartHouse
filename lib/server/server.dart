import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:smart_house/models/models.dart' as smart_house_models; // Используем псевдоним для избежания конфликта

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
            'pin_code': user.pinCode, // Сохраняем PIN-код
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
      final User? user = res.user;

      if (user != null) {
        print('User logged in: $user');
        return smart_house_models.User(
          id: user.id,
          username: user.userMetadata?['username'] ?? '',
          email: user.email ?? '',
          password: '', // Пароль не возвращаем
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

      print('Rooms response: $response'); // Добавляем отладочное сообщение

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
      // Получаем house_id пользователя
      final profileResponse = await _supabaseClient.from('profiles')
          .select('house_id')
          .eq('id', userId)
          .single();

      final houseId = profileResponse['house_id'];

      if (houseId != null) {
        // Добавляем комнату в таблицу room
        final roomResponse = await _supabaseClient.from('room').insert([
          {
            'name': roomName,
            'type_id': typeId,
            'house_id': houseId,
          },
        ]).select();

        if (roomResponse.isNotEmpty) {
          final roomId = roomResponse[0]['id'];

          // Обновляем таблицу house, добавляя room_id
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
      // Получаем house_id пользователя
      final profileResponse = await _supabaseClient.from('profiles')
          .select('house_id')
          .eq('id', userId)
          .single();

      final houseId = profileResponse['house_id'];

      if (houseId != null) {
        // Удаляем комнату из таблицы room
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
          imageUrl: imageUrl,
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
}