// lib/providers/store_provider.dart

import 'package:flutter/material.dart';
// Impor model yang baru
import '../models/user_model.dart'; 

class StoreProvider extends ChangeNotifier {
  // Data user dummy: Pastikan token ada, dan sesuaikan dengan model yang baru
  User? _user = User(id: '', name: '', email: '', token: ''); 
  String? _token = ''; // Token yang akan dikirim ke API

  User? get user => _user;
  String? get token => _token;

  void setUser(User? newUser) {
    _user = newUser;
    notifyListeners();
  }
  
  // Method login/logout lain dapat ditambahkan di sini
}