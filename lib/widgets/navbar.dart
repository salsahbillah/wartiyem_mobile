import 'package:flutter/material.dart';

class BottomNavbar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const BottomNavbar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: onItemTapped,
      type: BottomNavigationBarType.fixed,
      backgroundColor: const Color(0xFFFFC107), // 💛 Warna kuning terang
      selectedItemColor: const Color(0xFF800000), // ❤️ Maroon
      unselectedItemColor: Colors.black87, // ⚫ Hitam untuk unselected
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: "Beranda",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.menu_book),
          label: "Menu",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.receipt_long),
          label: "Pesanan",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.info),
          label: "Tentang Kami",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.logout),
          label: "Keluar",
        ),
      ],
    );
  }
}
