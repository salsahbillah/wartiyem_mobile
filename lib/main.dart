import 'package:flutter/material.dart';
import 'pages/landing_page.dart';
import 'pages/login.dart';
import 'pages/register_page.dart';
import 'pages/home_page.dart';
import 'pages/menu_page.dart';
import 'pages/pesanan_page.dart';
import 'pages/tentang_kami_page.dart';
import 'pages/cart_page.dart'; // ✅ Ganti dari keranjang_page.dart
import 'pages/order_page.dart'; // ✅ Ganti dari pesan_page.dart
import 'widgets/navbar.dart';

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
        // 🟡 Landing Page
        '/': (context) => LandingPage(
              onLoginSuccess: () =>
                  Navigator.pushReplacementNamed(context, '/login'),
            ),

        // 🟢 Login
        '/login': (context) => LoginPage(
              onLoginSuccess: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const MainController()),
              ),
            ),

        // 🔵 Register
        '/regist': (context) => RegisterPage(
              onRegisterSuccess: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const MainController()),
              ),
            ),

        // 🛒 Cart Page
        '/cart': (context) => const CartPage(), // ✅ ganti dari /keranjang

        // 📦 Order Page
        '/order': (context) => const OrderPage(), // ✅ ganti dari /pesan
      },
    );
  }
}

// 👇 Controller utama setelah login
class MainController extends StatefulWidget {
  const MainController({super.key});

  @override
  State<MainController> createState() => _MainControllerState();
}

class _MainControllerState extends State<MainController> {
  int currentTabIndex = 0;

  void goToTab(int index) {
    setState(() {
      currentTabIndex = index;
    });
  }

  void logout() {
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: currentTabIndex,
        children: const [
          HomePage(),
          MenuPage(),
          PesananPage(),
          TentangKamiPage(),
        ],
      ),
      bottomNavigationBar: BottomNavbar(
        selectedIndex: currentTabIndex,
        onItemTapped: (index) {
          if (index == 4) {
            logout();
          } else {
            goToTab(index);
          }
        },
      ),
    );
  }
}
