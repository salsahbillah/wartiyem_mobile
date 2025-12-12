// lib/providers/store_provider.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/user_api.dart';

class StoreProvider extends ChangeNotifier {
  final UserApi _userApi = UserApi();

  UserModel? _user;
  String? _token;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  static const String _tokenKey = 'authToken';
  static const String _userIdKey = 'userId';            // 👉 FIX (userId key)

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

  // ========================================================
  // 1. LOAD USER FROM STORAGE
  // ========================================================
  Future<void> loadUserFromStorage() async {
    _setLoading(true);

    final prefs = await SharedPreferences.getInstance();
    final storedToken = prefs.getString(_tokenKey);
    final storedUserId = prefs.getString(_userIdKey);   // 👉 FIX load userId

    if (storedToken != null && storedToken.isNotEmpty) {
      _token = storedToken;

      await _fetchUserProfile();

      // 👉 FIX Inject userId dari storage (tanpa ubah logika lain)
      if (storedUserId != null && _user != null && _user!.id.isEmpty) {
        _user = _user!.copyWith(id: storedUserId);
      }
      // END FIX
    }

    _setLoading(false);
  }

  // ========================================================
  // 2. LOGIN
  // ========================================================
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _setErrorMessage(null);

    try {
      final response = await _userApi.loginUser(email, password);

      if (response.success) {
        final userData = response.data;
        final token = response.token;

        _user = UserModel.fromJson(userData as Map<String, dynamic>);
        _token = token;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_tokenKey, token!);

        // 👉 FIX: simpan userId
        await prefs.setString(_userIdKey, _user!.id);
        // END FIX

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

  // ========================================================
  // 3. UPDATE PROFILE
  // ========================================================
  Future<bool> updateUserProfile({
    String? name,
    String? email,
    String? oldPassword,
    String? newPassword,
  }) async {
    if (_token == null) {
      _setErrorMessage("Token tidak ditemukan. Mohon login.");
      return false;
    }

    _setLoading(true);
    _setErrorMessage(null);

    try {
      final response = await _userApi.updateUserProfile(
        token: _token!,
        name: name,
        email: email,
        oldPassword: oldPassword,
        newPassword: newPassword,
      );

      if (response.success) {
        final updatedUserData = response.data as Map<String, dynamic>;

        _user = UserModel.fromJson(updatedUserData).copyWith(token: _token);

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
      rethrow;
    }
  }

  // ========================================================
  // 4. LOGOUT
  // ========================================================
  Future<void> logout() async {
    _user = null;
    _token = null;
    _errorMessage = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);  // 👉 FIX clear userId

    notifyListeners();
  }

  // ========================================================
  // 5. FETCH PROFILE BY TOKEN
  // ========================================================
  Future<void> _fetchUserProfile() async {
    if (_token == null) return;

    try {
      final response = await _userApi.getUserProfile(_token!);

      if (response.success) {
        final userData = response.data as Map<String, dynamic>;

        _user = UserModel.fromJson(userData).copyWith(token: _token);
      } else {
        await logout();
      }
    } catch (e) {
      print("Error fetching profile: $e");
      await logout();
    }
  }

  // ========================================================
  // 6. SET USER (tetap seperti versi kamu)
  // ========================================================
  void setUser(Map<String, dynamic> json) {
    final existingToken = _token;

    UserModel newUser = UserModel.fromJson(json);

    _user = newUser.copyWith(token: newUser.token ?? existingToken);
    _token = _user?.token;

    notifyListeners();
  }
}
