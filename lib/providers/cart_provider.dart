import 'package:flutter/material.dart';

class CartProvider with ChangeNotifier {
  final List<Map<String, dynamic>> _items = [];

  List<Map<String, dynamic>> get items => _items;

  void addItem(Map<String, dynamic> item) {
    // Jika item sudah ada → tambah qty
    int index = _items.indexWhere((e) => e['id'] == item['id']);
    if (index != -1) {
      _items[index]['qty'] += 1;
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
      total += item['price'] * item['qty'];
    }
    return total;
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
