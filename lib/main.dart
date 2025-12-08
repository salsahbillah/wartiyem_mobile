import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/cart_provider.dart';
import 'providers/search_provider.dart'; // <-- WAJIB DITAMBAHKAN

import 'pages/landing_page.dart';
import 'pages/login.dart';
import 'pages/register_page.dart';
import 'pages/home_page.dart';
import 'pages/menu_page.dart';
import 'pages/pesanan_page.dart';
import 'pages/tentang_kami_page.dart';
import 'pages/cart_page.dart';
import 'pages/order_page.dart';
import 'pages/struk_page.dart';
import 'widgets/navbar.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => SearchProvider()), // <-- DITAMBAHKAN
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Wartiyem Mobile',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        primarySwatch: Colors.red,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LandingPage(
              onLoginSuccess: () =>
                  Navigator.pushReplacementNamed(context, '/login'),
            ),

        '/login': (context) => LoginPage(
              onLoginSuccess: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const MainController()),
              ),
            ),

        '/regist': (context) => const RegisterPage(),
        '/cart': (context) => const CartPage(),

        // ORDER PAGE
        '/order': (context) => const OrderPage(orderMethod: "makan_di_tempat"),

        // STRUK fallback
        '/struk': (context) => StrukPage(order: const {}),

        // PESANAN PAGE
        '/pesanan': (context) => const PesananPage(),
      },
    );
  }
}

// ============================================================
// 👇 Controller utama setelah login
// ============================================================
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
