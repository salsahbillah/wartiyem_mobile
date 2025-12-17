import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';


class NotificationProvider with ChangeNotifier {
  List<dynamic> notifications = [];

  int get unreadCount =>
      notifications.where((n) => n["isRead"] == false).length;

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  Future<void> fetchNotifications() async {
    final token = await _getToken();
    if (token == null) return;

    final res = await http.get(
      Uri.parse("https://kedaiwartiyem.my.id/api/notifications"),
      headers: { "Authorization": "Bearer $token" },
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      notifications = data["data"];
      notifyListeners();
    }
  }

  Future<void> markAllAsRead() async {
    final token = await _getToken();
    if (token == null) return;

    await http.patch(
      Uri.parse("https://kedaiwartiyem.my.id/api/notifications"),
      headers: { "Authorization": "Bearer $token" },
    );

    for (var n in notifications) {
      n["isRead"] = true;
    }
    notifyListeners();
  }
}
