// user_api.dart
import 'package:dio/dio.dart';

class UserApi {
  // URL API yang telah disesuaikan dengan ngrok
  static const String _baseUrl = "https://unflamboyant-undepreciable-emilia.ngrok-free.dev"; 
  
  // Instance Dio statis untuk digunakan kembali (mengatasi warning unused_field)
  static final Dio _dio = Dio(BaseOptions(baseUrl: _baseUrl));

  Future<Map<String, dynamic>> updateProfile(String token, Map<String, dynamic> data) async {
    
    try {
      // 1. Set header Authorization menggunakan instance _dio yang sama
      _dio.options.headers['Authorization'] = 'Bearer $token';

      // 2. Kirim permintaan PATCH ke endpoint update profil
      final response = await _dio.patch(
        '/api/user/profile', // Ganti jika endpoint Anda berbeda
        data: data,
      );

      // Backend diharapkan merespons dengan 200 OK
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Mengembalikan data user yang diperbarui dari server
        return response.data;
      } else {
        // Menangani respons status code non-200/201
        throw Exception("Server merespons dengan status: ${response.statusCode}");
      }
    } on DioException catch (e) {
      // Menangani error jaringan atau error 4xx/5xx dari server
      String errorMessage = "Terjadi kesalahan jaringan atau server tidak merespon.";
      
      // Coba ambil pesan error dari body response server
      if (e.response?.data is Map && e.response?.data['message'] != null) {
        errorMessage = e.response!.data['message'];
      } else if (e.message != null) {
        errorMessage = e.message!;
      }
      
      throw Exception(errorMessage);
    } catch (e) {
      // Catch all other exceptions
      throw Exception("Kesalahan tidak terduga: ${e.toString()}");
    }
  }
}