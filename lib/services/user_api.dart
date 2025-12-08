// user_api.dart
import 'package:dio/dio.dart';

class UserApi {
  static const String _baseUrl = "https://unflamboyant-undepreciable-emilia.ngrok-free.dev"; 
  
  // Variabel _dio ini yang memunculkan warning
  static final Dio _dio = Dio(BaseOptions(baseUrl: _baseUrl)); // <-- Dio sudah diinisialisasi di sini

  Future<Map<String, dynamic>> updateProfile(String token, Map<String, dynamic> data) async {
    
    // HAPUS inisialisasi ini (yang menyebabkan _dio di atas tidak digunakan):
    // final Dio dioClient = Dio(BaseOptions(baseUrl: _baseUrl)); 
    
    // GANTI dengan menggunakan _dio yang sudah ada
    try {
      // 1. Set header pada instance _dio
      _dio.options.headers['Authorization'] = 'Bearer $token';

      // 2. Gunakan _dio untuk request
      final response = await _dio.patch(
        '/api/user/profile', 
        data: data,
      );

      // ... (sisa logika penanganan respons tetap sama)
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      } else {
        throw Exception("Server merespons dengan status: ${response.statusCode}");
      }
    } on DioException catch (e) {
      String errorMessage = "Terjadi kesalahan jaringan atau server tidak merespon.";
      if (e.response?.data is Map && e.response?.data['message'] != null) {
        errorMessage = e.response!.data['message'];
      } else if (e.message != null) {
        errorMessage = e.message!;
      }
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception("Kesalahan tidak terduga: ${e.toString()}");
    }
  }
}