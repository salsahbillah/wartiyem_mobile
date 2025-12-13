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

  static const Color yellowBackground = Color(0xFFFFCC00);
  static const Color maroon = Color(0xFF800000);

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
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected
                      ? maroon.withOpacity(0.2)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: maroon.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      item['icon'] as IconData,
                      size: 24,
                      color: isSelected
                          ? maroon
                          : const Color.fromARGB(255, 150, 0, 0),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item['label'] as String,
                      style: TextStyle(
                        fontSize: 10,
                        color: isSelected
                            ? maroon
                            : const Color.fromARGB(255, 150, 0, 0),
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}