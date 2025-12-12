import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/search_provider.dart';
import '../providers/store_provider.dart'; 

class TopBar extends StatefulWidget {
  final int totalCartItems;

  const TopBar({super.key, required this.totalCartItems});

  @override
  State<TopBar> createState() => _TopBarState();
}

class _TopBarState extends State<TopBar> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

    void handleSearch(BuildContext context) {
    final query = _searchController.text.trim();

    if (query.isEmpty) {
      context.read<SearchProvider>().clear();
      return;
    }

    context.read<SearchProvider>().setQuery(query);

    Navigator.pushNamed(
      context,
      "/menu",
      arguments: {"search": query},
    );
  }


  @override
  Widget build(BuildContext context) {
    // 1. Akses StoreProvider untuk mendapatkan data User
    final user = context.watch<StoreProvider>().user; 
    
    // 2. Tentukan inisial secara ringkas
    // Jika user tidak null: 
    // Coba ambil huruf pertama dari nama. Jika nama kosong, ambil dari email. Jika email kosong, gunakan 'U'.
    // Jika user null, gunakan 'U' (Default)
    String initial = user != null
      ? (user.name.isNotEmpty
          ? user.name[0].toUpperCase()
          : (user.email.isNotEmpty ? user.email[0].toUpperCase() : ''))
      : '';

    return Padding(
      padding: const EdgeInsets.only(top: 50, left: 13, right: 13, bottom: 20),
      child: Row(
        children: [
          // SEARCH BAR
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                if (value.trim().isEmpty) {
                  context.read<SearchProvider>().clear();
                } else {
                  context.read<SearchProvider>().setQuery(value);
                }
              },
              onSubmitted: (_) => handleSearch(context),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                hintText: "Mau Cari Apa...",
                prefixIcon: GestureDetector(
                  onTap: () => handleSearch(context),
                  child: const Icon(Icons.search, color: Colors.red),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),          ),

          const SizedBox(width: 12),

          // CART ICON
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
                      color: Color.fromARGB(255, 155, 10, 0),   // 🔥 WARNA BADGE MERAH
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
            onTap: () => Navigator.pushNamed(context, '/edit-profile'),
            child: CircleAvatar(
              // Warna yang lebih sesuai dengan tema yang sudah Anda tetapkan (primaryColor = merah)
              backgroundColor: const Color.fromARGB(255, 138, 11, 2),   // 🔥 Avatar merah 
              radius: 18,
              child: Text(
                initial, 
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