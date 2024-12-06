class User {
  final int? id;
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