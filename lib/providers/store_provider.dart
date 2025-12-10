// lib/providers/store_provider.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// 🟢 Menggunakan UserModel yang sudah diperbarui
import '../models/user_model.dart'; 
// 🟢 Mengimpor API Service
import '../services/user_api.dart'; 

class StoreProvider extends ChangeNotifier {
  
  // --- INSTANCE & API ---
  final UserApi _userApi = UserApi();

  // --- STATE VARIABLES ---
  
  // 🟢 PERBAIKAN: Ganti User menjadi UserModel
  UserModel? _user; 
  String? _token;
  bool _isLoading = false;
  String? _errorMessage;

  // --- GETTERS ---
  
  UserModel? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // --- PRIVATE UTILITY ---

  static const String _tokenKey = 'authToken'; 
  
  void _setLoading(bool status) {
    _isLoading = status;
    notifyListeners();
  }

  void _setErrorMessage(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void clearErrorMessage() {
    _errorMessage = null;
    notifyListeners();
  }
  
  // 1. Inisialisasi: Memuat token saat aplikasi dimulai
  Future<void> loadUserFromStorage() async {
    _setLoading(true);
    final prefs = await SharedPreferences.getInstance();
    final storedToken = prefs.getString(_tokenKey);
    
    if (storedToken != null && storedToken.isNotEmpty) {
      _token = storedToken;
      // Memanggil API untuk mendapatkan data profil
      await _fetchUserProfile(); 
    }
    _setLoading(false);
  }

  // 2. Login (Memanggil API)
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _setErrorMessage(null);
    try {
      final response = await _userApi.loginUser(email, password); 
      
      if (response.success) {
        final userData = response.data;
        final token = response.token; 
        
        // Menggunakan UserModel.fromJson
        _user = UserModel.fromJson(userData as Map<String, dynamic>);
        _token = token;
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_tokenKey, token!);
        
        _setLoading(false);
        return true;
      } else {
        _setErrorMessage(response.message);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setErrorMessage("Login gagal: $e");
      _setLoading(false);
      return false;
    }
  }
  
  // 3. Update Profil (Dipanggil oleh EditProfileScreen)
  Future<bool> updateUserProfile({
    String? name, 
    String? email, 
    String? oldPassword, 
    String? newPassword
  }) async {
    if (_token == null) {
      _setErrorMessage("Token tidak ditemukan. Mohon login.");
      return false;
    }

    _setLoading(true);
    _setErrorMessage(null);

    try {
      // 🟢 Memanggil fungsi yang benar di UserApi
      final response = await _userApi.updateUserProfile(
        token: _token!,
        name: name,
        email: email,
        oldPassword: oldPassword,
        newPassword: newPassword,
      ); 

      if (response.success) {
        final updatedUserData = response.data as Map<String, dynamic>;
        
        // Membuat salinan user dengan data baru dari API
        _user = UserModel.fromJson(updatedUserData).copyWith(
          // Memastikan token lama tetap ada
          token: _token, 
        );
        
        _setLoading(false);
        return true;
      } else {
        _setErrorMessage(response.message);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setErrorMessage("Gagal memperbarui profil: $e");
      _setLoading(false);
      // Lempar error agar bisa ditangkap oleh UI (EditProfileScreen)
      rethrow; 
    }
  }
  
  // 4. Logout
  Future<void> logout() async {
    _user = null;
    _token = null;
    _errorMessage = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    notifyListeners();
  }
  
  // 5. Fetch Profil
  Future<void> _fetchUserProfile() async {
    if (_token == null) return;
    
    try {
      final response = await _userApi.getUserProfile(_token!);
      if (response.success) {
        final userData = response.data as Map<String, dynamic>;
        
        // Menggunakan fromJson dan copyWith untuk mempertahankan token
        _user = UserModel.fromJson(userData).copyWith(
          token: _token,
        );
      } else {
        // Jika token invalid/expired, paksa logout
        await logout();
      }
    } catch (e) {
      print("Error fetching profile: $e");
      await logout();
    }
  }
  
  // 6. 🟢 Method Setter yang disesuaikan (digunakan di EditProfileScreen)
  // Catatan: Di implementasi yang sudah ada, ini tidak lagi diperlukan karena
  // updateUserProfile sudah mengelola state. Tapi jika Anda ingin mempertahankannya:
  void setUser(Map<String, dynamic> json) {
    // Ambil token saat ini jika tidak disediakan di JSON (untuk keamanan)
    final existingToken = _token;
    
    // Konversi JSON menjadi UserModel
    UserModel newUser = UserModel.fromJson(json);
    
    // Pastikan token tetap ada (diambil dari token yang sudah tersimpan di provider)
    _user = newUser.copyWith(token: newUser.token ?? existingToken); 
    _token = _user?.token;
    
    notifyListeners();
  }
}