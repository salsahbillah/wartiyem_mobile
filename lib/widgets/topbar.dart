import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // 👈 Tambahkan ini
import '../providers/store_provider.dart'; // 👈 Import StoreProvider

class TopBar extends StatelessWidget {
  final int totalCartItems;

  const TopBar({super.key, required this.totalCartItems});

  @override
  Widget build(BuildContext context) {
    // 1. Akses StoreProvider untuk mendapatkan data User
    final storeProvider = context.watch<StoreProvider>();
    final user = storeProvider.user; // Ambil object User
    
    // 2. Tentukan inisial. Default '?' jika user null
    String initial = '?';
    
    if (user != null && user.name.isNotEmpty) {
      // Ambil inisial dari properti 'name'
      initial = user.name[0].toUpperCase();
    } else if (user != null && user.email.isNotEmpty) {
      // Fallback: Jika nama kosong, ambil inisial dari properti 'email'
      initial = user.email[0].toUpperCase();
    }

    return Padding(
      padding:
          const EdgeInsets.only(top: 32, left: 16, right: 16, bottom: 20),
      child: Row(
        children: [
          // 🔍 Search bar (Tidak Berubah)
          Expanded(
            // ... (TextField Anda) ...
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

          // 🛒 Cart icon with badge (Tidak Berubah)
          Stack(
            clipBehavior: Clip.none,
            children: [
              InkWell(
                onTap: () {
                  Navigator.pushNamed(context, '/cart');
                },
                child: Image.asset(
                  'assets/images/cart.png',
                  width: 36,
                  height: 36,
                ),
              ),
              if (totalCartItems > 0)
                // ... (Badge count) ...
                Positioned(
                  right: -4,
                  top: -4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 192, 0, 0),
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

          // 👤 Profil circle dengan INISIAL USER
          InkWell(
          onTap: () {
                  Navigator.pushNamed(context, '/edit-profile');
            },
          child: CircleAvatar(
          backgroundColor: Colors.red.shade900,
            radius: 18,
            child: Text( // 👈 Menggunakan Text Widget
              initial, // 👈 Menggunakan variabel initial yang sudah dihitung
                style: const TextStyle(
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