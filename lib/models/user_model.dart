// lib/models/user_model.dart

class UserModel {
  // Pastikan semua properti di set sebagai final (Immutable)
  final String id;
  final String name;
  final String email;
  final Map<String, dynamic> cartData;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? token; // Ditambahkan untuk menampung JWT dari backend

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.cartData = const {},
    this.createdAt,
    this.updatedAt,
    this.token,
  });

  // --- SERIALIZATION (Dari Backend ke Flutter) ---

  // ✅ Factory constructor untuk konversi dari JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Backend sering menggunakan '_id' (MongoDB) atau 'id'. Kita ambil yang 'id' atau '_id'.
    // Pastikan kita menangani data 'user' yang mungkin ada di dalam respons login
    final userData = json['user'] ?? json;
    
    return UserModel(
      id: userData['id'] ?? userData['_id'] ?? '',
      name: userData['name'] ?? '',
      email: userData['email'] ?? '',
      // Jika cartData null, gunakan Map kosong
      cartData: userData['cartData'] is Map ? userData['cartData'] : {}, 
      
      createdAt: userData['createdAt'] != null 
          ? DateTime.tryParse(userData['createdAt'].toString()) 
          : null,
          
      updatedAt: userData['updatedAt'] != null 
          ? DateTime.tryParse(userData['updatedAt'].toString()) 
          : null,
          
      // Token bisa berada di root JSON (saat login) atau di dalam objek user (jarang)
      token: json['token'] ?? userData['token'], 
    );
  }

  // --- DESERIALIZATION (Dari Flutter ke Backend, misal saat update) ---
  
  // ✅ Method untuk konversi ke JSON
  // Catatan: Biasanya hanya properti yang ingin di-update yang dikirim.
  // Method ini paling sering digunakan untuk menyimpan user ke local storage.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'cartData': cartData,
      // Sertakan token agar bisa disimpan di SharedPreferences jika perlu
      if (token != null) 'token': token, 
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  // --- IMMUTABILITY HELPER ---

  // ✅ Method copyWith: Memungkinkan pembuatan salinan objek dengan properti yang diubah
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    Map<String, dynamic>? cartData,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? token,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      cartData: cartData ?? this.cartData,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      token: token ?? this.token,
    );
  }
}