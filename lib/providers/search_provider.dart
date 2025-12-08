import 'package:flutter/material.dart';

class SearchProvider extends ChangeNotifier {
  String _query = "";
  String get query => _query;

  void setQuery(String value) {
    _query = value.toLowerCase();
    notifyListeners();
  }

  void clear() {
    _query = "";
    notifyListeners();
  }
}
