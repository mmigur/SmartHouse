import 'package:gotrue/src/types/user.dart' as gotrue_user;
import 'package:smart_house/models/models.dart' as smart_house_models;
import 'package:supabase_flutter/supabase_flutter.dart';

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
  Future<User?> loginUser(String email, String password) async {
    try {
      final AuthResponse res = await _supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );
      final Session? session = res.session;
      final User? user = res.user;

      if (user != null) {
        print('User logged in: $user');
        return user;
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
}