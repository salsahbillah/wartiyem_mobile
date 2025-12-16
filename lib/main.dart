import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/cart_provider.dart';
import 'providers/search_provider.dart';
import 'providers/store_provider.dart';

import 'pages/landing_page.dart';
import 'pages/login.dart';
import 'pages/register_page.dart';
import 'pages/home_page.dart';
import 'pages/menu_page.dart';
import 'pages/edit_profile_screen.dart';
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
        /// 1️⃣ StoreProvider utama
        ChangeNotifierProvider(create: (_) => StoreProvider()),

        /// 2️⃣ CartProvider tergantung StoreProvider
        ChangeNotifierProxyProvider<StoreProvider, CartProvider>(
          create: (_) => CartProvider(),
          update: (_, store, cart) {
            cart ??= CartProvider();
            cart.setUser(store.user?.id);
            return cart;
          },
        ),

        /// 3️⃣ SearchProvider bebas
        ChangeNotifierProvider(create: (_) => SearchProvider()),
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
              onLoginSuccess: () {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const MainController(),
                    ),
                  );
                });
              },
            ),

        '/regist': (context) => const RegisterPage(),
        '/cart': (context) => const CartPage(),
        '/order': (context) =>
            const OrderPage(orderMethod: "makan_di_tempat"),
        '/struk': (context) => StrukPage(order: const {}),
        '/pesanan': (context) => const PesananPage(),
        '/edit-profile': (context) => EditProfileScreen(),
      },
    );
  }
}

// ============================================================
//  MAIN CONTROLLER (SETELAH LOGIN)
// ============================================================

class MainController extends StatefulWidget {
  final int startIndex;

  const MainController({
    super.key,
    this.startIndex = 0,
  });

  @override
  State<MainController> createState() => _MainControllerState();
}

class _MainControllerState extends State<MainController> {
  late int currentTabIndex;

  @override
  void initState() {
    super.initState();
    currentTabIndex = widget.startIndex;
  }

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
      // ================ 🔥 ANIMATED SWITCHER SMOOTH TRANSITION ================
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.05, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: _buildPage(currentTabIndex),
      ),

      // ===================== 🔥 NAVBAR TETAP ======================
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

  // ============== 🔥 PAGE BUILDER WAJIB ADA UNTUK ANIMATION ==============
  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return const HomePage(key: ValueKey(0));
      case 1:
        return const MenuPage(key: ValueKey(1));
      case 2:
        return const PesananPage(key: ValueKey(2));
      case 3:
        return const TentangKamiPage(key: ValueKey(3));
      default:
        return const HomePage(key: ValueKey(99));
    }
  }

}