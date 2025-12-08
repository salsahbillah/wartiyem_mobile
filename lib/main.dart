import 'package:flutter/material.dart';
<<<<<<< Updated upstream
=======
import 'package:provider/provider.dart';

import 'providers/cart_provider.dart';
// 🔑 PERUBAHAN 1: Menghapus prefix 'as sp' karena konflik nama sudah teratasi
import 'providers/store_provider.dart'; 

>>>>>>> Stashed changes
import 'pages/landing_page.dart';
import 'pages/login.dart';
import 'pages/register_page.dart';
import 'pages/home_page.dart';
import 'pages/menu_page.dart';
import 'pages/edit_profile_screen.dart';
import 'pages/pesanan_page.dart';
import 'pages/tentang_kami_page.dart';
<<<<<<< Updated upstream

void main() {
  runApp(const MyApp());
=======
import 'pages/cart_page.dart';
import 'pages/order_page.dart';
import 'pages/struk_page.dart';
import 'widgets/navbar.dart';
import 'models/user_model.dart'; // Tetap dipertahankan

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        // 🔑 PERUBAHAN 2: Memanggil StoreProvider tanpa prefix
        ChangeNotifierProvider(create: (_) => StoreProvider()),
      ],
      child: const MyApp(),
    ),
  );
>>>>>>> Stashed changes
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
<<<<<<< Updated upstream
        '/home': (context) => const HomePage(),
        '/menu': (context) => const MenuPage(),
        '/pesanan': (context) => const PesananPage(),
        '/tentang': (context) => const TentangKamiPage(),
=======
        '/cart': (context) => const CartPage(),

        // ORDER PAGE
        '/order': (context) => const OrderPage(orderMethod: "makan_di_tempat"),

        // STRUK fallback
        '/struk': (context) => StrukPage(order: const {}),

        // Rute lainnya
        '/pesanan': (context) => const PesananPage(),
        
        // Rute Edit Profile Screen
        '/edit-profile': (context) => EditProfileScreen(),
>>>>>>> Stashed changes
      },
    );
  }
}
<<<<<<< Updated upstream
=======

// ============================================================
// 👇 Controller utama setelah login (Tidak ada perubahan di sini)
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
>>>>>>> Stashed changes
