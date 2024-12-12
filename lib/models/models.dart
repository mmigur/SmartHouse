class User {
  final String? id;
  final String username;
  final String email;
  final String password;
  final int? pinCode; // Изменим тип на int, так как в базе данных он int8

  User({
    this.id,
    required this.username,
    required this.email,
    required this.password,
    this.pinCode,
  });

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'email': email,
      'password': password,
      'pin_code': pinCode, // Добавляем поле для PIN-кода
    };
  }
}

class Room {
  final int? id; // Добавляем id
  final String name;
  final String imageUrl;
  final String houseId; // Добавляем houseId

  Room({
    this.id, // Добавляем id
    required this.name,
    required this.imageUrl,
    required this.houseId,
  });
}
class Device {
  final int id;
  final String name;
  final String imageUrl;
  final bool isOn;
  final int roomId;
  final String customId; // Добавляем customId

  Device({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.isOn,
    required this.roomId,
    required this.customId, // Добавляем customId
  });
}

class RoomType {
  final String id;
  final String image;
  final String name;

  RoomType({
    required this.id,
    required this.image,
    required this.name,
  });
}