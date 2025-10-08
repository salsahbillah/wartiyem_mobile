import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wartiyem_mobile/widgets/topbar.dart';
import 'package:wartiyem_mobile/widgets/menu_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedCategory = 0;

  final List<Map<String, String>> kategoriMenu = [
    {"name": "Paket Nasi Liwet", "image": "assets/images/nasii.png"},
    {"name": "Aneka Mie", "image": "assets/images/buket.png"},
    {"name": "Aneka Lauk", "image": "assets/images/ikan.png"},
    {"name": "Paket Nasi Tutug", "image": "assets/images/TUTUG.png"},
    {"name": "Minuman", "image": "assets/images/teh.png"},
  ];

  final List<Map<String, dynamic>> menuRekomendasi = [
    {
      "nama": "BRIANI",
      "deskripsi": "rice, chicken",
      "harga": 25000,
      "status": "Habis",
      "rating": 4.2,
      "qty": 0,
      "imagePath": "assets/images/tes.png",
    },
    {
      "nama": "SEAFOOD BOIL",
      "deskripsi": "crab, sauce",
      "harga": 25000,
      "status": "Tersedia",
      "rating": 4.1,
      "qty": 2,
      "imagePath": "assets/images/tes.png",
    },
    {
      "nama": "MIE GORENG SPESIAL",
      "deskripsi": "mie, telur, ayam",
      "harga": 18000,
      "status": "Tersedia",
      "rating": 4.5,
      "qty": 0,
      "imagePath": "assets/images/tes.png",
    },
    {
      "nama": "NASI TUTUG",
      "deskripsi": "nasi, sambal, ayam",
      "harga": 22000,
      "status": "Tersedia",
      "rating": 4.6,
      "qty": 1,
      "imagePath": "assets/images/tes.png",
    },
  ];

  int get totalCartItems {
    int total = 0;
    for (var menu in menuRekomendasi) {
      total += menu["qty"] as int;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TopBar(totalCartItems: totalCartItems),

          // 🎉 Banner
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                "assets/images/banner.png",
                height: 140,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 📝 Headline
          Center(
            child: Column(
              children: [
                Text(
                  "Telusuri Menu Terbaik Kami",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Makan enak itu bukan sekadar mengisi perut, tapi juga cara menikmati hidup.\n"
                  "Setiap suapan membawa kebahagiaan tersendiri!",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 12.5,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey[800],
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 🍲 Kategori Menu
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "Kategori Menu",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade800,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 110,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: kategoriMenu.length,
              itemBuilder: (context, index) {
                final kategori = kategoriMenu[index];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedCategory = index;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: selectedCategory == index
                                  ? Colors.red
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.grey.shade200,
                            backgroundImage: AssetImage(kategori["image"]!),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          kategori["name"]!,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: selectedCategory == index
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: selectedCategory == index
                                ? Colors.red
                                : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),

          // 🍴 Menu Rekomendasi
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "Menu Rekomendasi",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.65,
              crossAxisSpacing: 12,
              mainAxisSpacing: 16,
            ),
            itemCount: menuRekomendasi.length,
            itemBuilder: (context, index) {
              final menu = menuRekomendasi[index];
              return MenuCard(
                nama: menu["nama"],
                deskripsi: menu["deskripsi"],
                harga: menu["harga"],
                status: menu["status"],
                qty: menu["qty"],
                rating: menu["rating"],
                imagePath: menu["imagePath"],
                onAdd: () {
                  setState(() {
                    menu["qty"]++;
                  });
                },
                onRemove: () {
                  setState(() {
                    if (menu["qty"] > 0) menu["qty"]--;
                  });
                },
              );
            },
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}
