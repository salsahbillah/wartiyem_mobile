import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wartiyem_mobile/widgets/topbar.dart';
import 'package:wartiyem_mobile/widgets/menu_card.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  // 🛒 Data menu dan qty-nya
  final List<Map<String, dynamic>> semuaMenu = [
    {
      "kategori": "Aneka Mie",
      "items": [
        {
          "nama": "AYM GRNG",
          "deskripsi": "rice, chicken",
          "harga": 25000,
          "status": "Habis",
          "rating": 4.1,
          "qty": 0,
          "imagePath": "assets/images/tes.png",
        },
        {
          "nama": "TLR GRNG",
          "deskripsi": "crab, sauce",
          "harga": 25000,
          "status": "Tersedia",
          "rating": 4.1,
          "qty": 0,
          "imagePath": "assets/images/tes.png",
        },
      ]
    },
    {
      "kategori": "Paket Nasi Liwet Ayam Goreng",
      "items": List.generate(4, (i) => {
            "nama": "TLR GRNG",
            "deskripsi": "crab, sauce",
            "harga": 25000,
            "status": "Tersedia",
            "rating": 4.1,
            "qty": 0,
            "imagePath": "assets/images/tes.png",
          }),
    },
  ];

  // 🔢 Hitung total item di cart
  int get totalCartItems {
    int total = 0;
    for (var kategori in semuaMenu) {
      for (var item in kategori["items"]) {
        total += item["qty"] as int;
      }
    }
    return total;
  }

  // ➕ Tambah item
  void addToCart(Map<String, dynamic> menu) {
    setState(() {
      menu["qty"]++;
    });
  }

  // ➖ Kurangi item
  void removeFromCart(Map<String, dynamic> menu) {
    setState(() {
      if (menu["qty"] > 0) menu["qty"]--;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 🧭 Top bar dengan jumlah item cart dinamis
            TopBar(totalCartItems: totalCartItems),

            // 📜 Daftar menu
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 90),
                itemCount: semuaMenu.length,
                itemBuilder: (context, sectionIndex) {
                  final kategori = semuaMenu[sectionIndex];
                  final items = kategori["items"] as List;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 🔴 Judul kategori
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              kategori["kategori"],
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.red.shade800,
                              ),
                            ),
                            const Icon(Icons.filter_alt_rounded, color: Colors.red),
                          ],
                        ),
                      ),

                      // 🍽️ Grid menu per kategori
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: items.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.65,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 16,
                        ),
                        itemBuilder: (context, index) {
                          final menu = items[index];

                          return MenuCard(
                            nama: menu["nama"],
                            deskripsi: menu["deskripsi"],
                            harga: menu["harga"],
                            status: menu["status"],
                            rating: menu["rating"],
                            qty: menu["qty"],
                            imagePath: menu["imagePath"],
                            onAdd: () => addToCart(menu),
                            onRemove: () => removeFromCart(menu),
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
