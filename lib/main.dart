import 'package:flutter/material.dart';
import 'pages/landing_page.dart';
import 'pages/login.dart';
import 'pages/register_page.dart';
import 'pages/home_page.dart';
import 'pages/menu_page.dart';
import 'pages/pesanan_page.dart';
import 'pages/tentang_kami_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Wartiyem Mobile',
      initialRoute: '/',
      routes: {
        '/': (context) => const LandingPage(),
        '/login': (context) => const LoginPage(),
        '/regist': (context) => const RegisterPage(),
        '/home': (context) => const HomePage(),
        '/menu': (context) => const MenuPage(),
        '/pesanan': (context) => const PesananPage(),
        '/tentang': (context) => const TentangKamiPage(),
      },
    );
  }
}
