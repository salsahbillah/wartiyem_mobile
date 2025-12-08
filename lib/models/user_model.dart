// lib/models/user_model.dart

class User {
  final String id;
  String name;
  String email;
  final String token;

  User({required this.id, required this.name, required this.email, required this.token});

  // Helper untuk membuat instance User dari respons API (Map)
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      token: json['token'] as String, // Biasanya token dikirim saat login, bukan update profile
    );
  }
}