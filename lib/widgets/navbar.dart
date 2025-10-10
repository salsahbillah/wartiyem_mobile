// File: widgets/navbar.dart

import 'package:flutter/material.dart';

class BottomNavbar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const BottomNavbar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  // Warna kuning yang dominan di mockup
  static const Color yellowBackground = Color(0xFFFFCC00); 
  // Semua elemen berwarna hitam
  static const Color iconColor = Colors.black; 

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> items = [
      {'icon': Icons.home, 'label': 'Beranda'},
      {'icon': Icons.list_alt, 'label': 'Menu'}, 
      {'icon': Icons.receipt, 'label': 'Pesanan'}, 
      {'icon': Icons.info, 'label': 'Tentang Kami'},
      {'icon': Icons.exit_to_app, 'label': 'Keluar'},
    ];

    return Container(
      height: 60, 
      color: yellowBackground,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: items.asMap().entries.map((entry) {
          int index = entry.key;
          Map<String, dynamic> item = entry.value;

          bool isSelected = index == selectedIndex;
          
          return Expanded(
            child: InkWell(
              onTap: () => onItemTapped(index),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    item['icon'] as IconData,
                    size: 24,
                    color: const Color.fromARGB(255, 150, 0, 0), 
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item['label'] as String,
                    style: TextStyle(
                      fontSize: 10,
                      color: const Color.fromARGB(255, 150, 0, 0),
                      // Membuat label terpilih menjadi bold
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, 
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}