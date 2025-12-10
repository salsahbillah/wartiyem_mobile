import 'package:flutter/material.dart';

class CartProvider with ChangeNotifier {
  final List<Map<String, dynamic>> _items = [];
  String? _userId;

  List<Map<String, dynamic>> get items => _items;
  String? get userId => _userId;

  // ✅ DIPANGGIL DARI main.dart (ProxyProvider)
  void setUser(String? userId) {
    if (_userId != userId) {
      _userId = userId;
      _items.clear(); // ✅ reset cart saat login / logout / ganti akun
      notifyListeners();
    }
  }


  void addItem(Map<String, dynamic> item) {
  int index = _items.indexWhere((e) =>
    (e['_id'] != null && item['_id'] != null && e['_id'] == item['_id']) ||
    (e['id'] != null && item['id'] != null && e['id'] == item['id'])
  );
  if (index != -1) {
    _items[index]['qty'] = (_items[index]['qty'] ?? 0) + (item['qty'] ?? 1);
  } else {
    _items.add(item);
  }
  notifyListeners();
}


  void updateQty(int index, int newQty) {
    if (newQty <= 0) {
      _items.removeAt(index);
    } else {
      _items[index]['qty'] = newQty;
    }
    notifyListeners();
  }

  void removeItem(int index) {
    _items.removeAt(index);
    notifyListeners();
  }

  double get subtotal {
    double total = 0;
    for (var item in _items) {
      total += (item['price'] as num) * (item['qty'] as num);
    }
    return total;
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
