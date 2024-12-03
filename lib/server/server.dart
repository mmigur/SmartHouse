import 'package:gotrue/src/types/user.dart' as gotrue_user;
import 'package:smart_house/models/models.dart' as smart_house_models;
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  Future<bool> registerUser(smart_house_models.User user) async {
    try {
      // Регистрация пользователя через Supabase Auth
      final authResponse = await _supabaseClient.auth.signUp(
        email: user.email,
        password: user.password,
      );

      if (authResponse.user != null) {
        // Получение идентификатора пользователя
        final userId = authResponse.user!.id;

        // Запись данных в таблицу profiles
        final profileResponse = await _supabaseClient.from('profiles').insert([
          {
            'id': userId,
            'username': user.username,
          },
        ]);

        print('User registered: $user');
        return true;
      } else {
        print('Error registering user: User not created');
        return false;
      }
    } catch (e) {
      print('Error registering user: $e');
      return false;
    }
  }

  Future<bool> loginUser(String email, String password) async {
    try {
      final response = await _supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        print('User logged in: ${response.user}');
        return true;
      } else {
        print('User not found or incorrect password');
        return false;
      }
    } catch (e) {
      print('Error logging in user: $e');
      return false;
    }
  }
}