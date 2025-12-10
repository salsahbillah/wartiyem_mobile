import 'package:flutter/material.dart';

class SearchProvider extends ChangeNotifier {
  String _query = "";
  bool _isSearching = false;

  String get query => _query;
  bool get isSearching => _isSearching;

  void setQuery(String value) {
    _query = value.toLowerCase();

    // 🔥 KUNCI UTAMA
    _isSearching = _query.trim().isNotEmpty;

    notifyListeners();
  }

  void clear() {
    _query = "";
    _isSearching = false;
    notifyListeners();
  }
}
