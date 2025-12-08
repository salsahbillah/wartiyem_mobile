import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/search_provider.dart';
import '../providers/store_provider.dart'; // 👈 Tambahkan StoreProvider

class TopBar extends StatefulWidget {
  final int totalCartItems;

  const TopBar({super.key, required this.totalCartItems});

  @override
  State<TopBar> createState() => _TopBarState();
}

class _TopBarState extends State<TopBar> {
  final TextEditingController _searchController = TextEditingController();

  void handleSearch(BuildContext context) {
    final query = _searchController.text.trim();

    if (query.isNotEmpty) {
      context.read<SearchProvider>().setQuery(query);

      Navigator.pushNamed(
        context,
        "/menu",
        arguments: {"search": query},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. Akses StoreProvider untuk mendapatkan data User
    final storeProvider = context.watch<StoreProvider>();
    final user = storeProvider.user; 
    
    // 2. Tentukan inisial
    String initial = '?';
    
    if (user != null) {
      // Prioritas 1: Ambil inisial dari 'name'
      if (user.name.isNotEmpty) {
        initial = user.name[0].toUpperCase();
      } 
      // Prioritas 2: Fallback ke inisial dari 'email'
      else if (user.email.isNotEmpty) {
        initial = user.email[0].toUpperCase();
      }
    }

    return Padding(
      padding: const EdgeInsets.only(top: 32, left: 16, right: 16, bottom: 20),
      child: Row(
        children: [
          // SEARCH BAR (Tidak Berubah)
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (v) => context.read<SearchProvider>().setQuery(v),
              onSubmitted: (_) => handleSearch(context),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                hintText: "Apa yang ingin kamu nikmati hari ini?",
                prefixIcon: GestureDetector(
                  onTap: () => handleSearch(context),
                  child: const Icon(Icons.search, color: Colors.red),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // CART ICON (Tidak Berubah)
          Stack(
            clipBehavior: Clip.none,
            children: [
              InkWell(
                onTap: () => Navigator.pushNamed(context, '/cart'),
                child: Image.asset(
                  'assets/images/cart.png',
                  width: 36,
                  height: 36,
                ),
              ),
              if (widget.totalCartItems > 0)
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
                      "${widget.totalCartItems}",
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

          // PROFILE ICON DENGAN INISIAL DINAMIS
          InkWell(
            // 3. Rute sudah diarahkan ke '/profile' (atau '/edit-profile' jika itu yang Anda inginkan)
            onTap: () => Navigator.pushNamed(context, '/edit-profile'),
            child: CircleAvatar(
              backgroundColor: Colors.red.shade900,
              radius: 18,
              child: Text(
                initial, // 👈 Menggunakan inisial dinamis
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