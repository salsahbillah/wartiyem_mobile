// user_api.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

// Ganti dengan URL dasar server backend Anda
const String baseUrl = "https://unflamboyant-undepreciable-emilia.ngrok-free.dev/api/user"; 

// 🎯 KELAS APIRESPONSE DIPINDAH KELUAR (Top-Level Class)
class ApiResponse {
  final bool success;
  final String message;
  final dynamic data; 
  final String? token;

  ApiResponse({required this.success, required this.message, this.data, this.token});
}

class UserApi {
  // --- FUNGSI UPDATE USER PROFILE (Sesuai dengan updateUserProfile backend) ---

  Future<ApiResponse> updateUserProfile({
    required String token, // Token untuk otentikasi
    String? name,
    String? email,
    String? oldPassword,
    String? newPassword,
  }) async {
    final url = Uri.parse('$baseUrl/profile');
    
    // Siapkan body request
    final body = {
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (oldPassword != null) 'oldPassword': oldPassword,
      if (newPassword != null) 'newPassword': newPassword,
    };

    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Kirim token di header
        },
        body: json.encode(body),
      );

      final responseBody = json.decode(response.body);

      if (responseBody['success'] == true) {
        // Berhasil
        return ApiResponse(
          success: true,
          message: responseBody['message'] ?? 'Profil berhasil diperbarui',
          data: responseBody['data'],
        );
      } else {
        // Gagal (Pesan error dari backend: "Email ini sudah terdaftar", "Kata sandi lama salah", dll.)
        return ApiResponse(
          success: false,
          message: responseBody['message'] ?? 'Gagal memperbarui profil',
        );
      }
    } catch (e) {
      print('Error update profile: $e');
      return ApiResponse(
        success: false,
        message: 'Terjadi kesalahan jaringan saat update profil.',
      );
    }
  }

  // --- FUNGSI GET USER PROFILE (Sesuai dengan getUserProfile backend) ---

  Future<ApiResponse> getUserProfile(String token) async {
    final url = Uri.parse('$baseUrl/profile');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Kirim token di header
        },
      );

      final responseBody = json.decode(response.body);

      if (responseBody['success'] == true) {
        return ApiResponse(
          success: true,
          message: responseBody['message'] ?? 'Data user berhasil diambil',
          data: responseBody['data'],
        );
      } else {
        return ApiResponse(
          success: false,
          message: responseBody['message'] ?? 'Gagal mengambil data user',
        );
      }
    } catch (e) {
      print('Error get profile: $e');
      return ApiResponse(
        success: false,
        message: 'Terjadi kesalahan jaringan saat mengambil profil.',
      );
    }
  }

  // --- FUNGSI LOGIN (Sesuai dengan loginUser backend) ---
  
  Future<ApiResponse> loginUser(String email, String password) async {
    final url = Uri.parse('$baseUrl/login');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      final responseBody = json.decode(response.body);

      if (responseBody['success'] == true) {
        return ApiResponse(
          success: true,
          message: responseBody['message'] ?? 'Login berhasil',
          token: responseBody['token'],
          data: responseBody['user'], // Mengambil data user yang dikirim backend
        );
      } else {
        // Gagal (Pesan error dari backend: "Pengguna tidak ada", "Email atau Password Salah")
        return ApiResponse(
          success: false,
          message: responseBody['message'] ?? 'Login gagal',
        );
      }
    } catch (e) {
      print('Error login: $e');
      return ApiResponse(
        success: false,
        message: 'Terjadi kesalahan jaringan saat login.',
      );
    }
  }
  
  // --- FUNGSI REGISTRASI (Sesuai dengan registerUser backend) ---
  
  Future<ApiResponse> registerUser(String name, String email, String password) async {
    final url = Uri.parse('$baseUrl/register');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'name': name, 'email': email, 'password': password}),
      );

      final responseBody = json.decode(response.body);

      if (responseBody['success'] == true) {
        return ApiResponse(
          success: true,
          message: responseBody['message'] ?? 'Registrasi berhasil',
          token: responseBody['token'],
          data: responseBody['user'], // Mengambil data user yang dikirim backend
        );
      } else {
        // Gagal (Pesan error dari backend: "Pengguna sudah ada", "Gunakan email yang valid", dll.)
        return ApiResponse(
          success: false,
          message: responseBody['message'] ?? 'Registrasi gagal',
        );
      }
    } catch (e) {
      print('Error registrasi: $e');
      return ApiResponse(
        success: false,
        message: 'Terjadi kesalahan jaringan saat registrasi.',
      );
    }
  }
}