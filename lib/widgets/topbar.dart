import 'package:flutter/material.dart';

class TopBar extends StatelessWidget {
  final int totalCartItems;

  const TopBar({super.key, required this.totalCartItems});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 32, left: 16, right: 16, bottom: 20),
      child: Row(
        children: [
          // 🔍 Search bar
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                hintText: "Apa yang ingin kamu nikmati hari ini?",
                prefixIcon: const Icon(Icons.search, color: Colors.red),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // 🛒 Cart icon with badge
          Stack(
            clipBehavior: Clip.none,
            children: [
              InkWell(
                onTap: () {},
                child: Image.asset(
                  'assets/images/cart.png',
                  width: 36,
                  height: 36,
                ),
              ),
              if (totalCartItems > 0)
                Positioned(
                  right: -4,
                  top: -4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 192, 0, 0), // 💥 Maroon
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      "$totalCartItems",
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(width: 12),

          // 👤 Profil circle dengan huruf P
          InkWell(
            onTap: () {
            },
            child: CircleAvatar(
              backgroundColor: Colors.red.shade900,
              radius: 18,
              child: const Text(
                "P",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
