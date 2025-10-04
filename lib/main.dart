import 'package:flutter/material.dart';
import 'pages/landing_page.dart';
import 'pages/login.dart';
import 'pages/register_page.dart';
import 'pages/home_page.dart';
import 'pages/menu_page.dart';
import 'pages/pesanan_page.dart';
import 'pages/tentang_kami_page.dart';
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
        '/': (context) => LandingPage(
              onLoginSuccess: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const MainController()),
              ),
            ),
        '/login': (context) => LoginPage(
              onLoginSuccess: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const MainController()),
              ),
            ),
        '/regist': (context) => RegisterPage(
              onRegisterSuccess: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const MainController()),
              ),
            ),
      },
    );
  }
}

// 👇 Pengontrol navigasi utama setelah login
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
