import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  int selectedCategory = 0;

  // 🖼️ Data kategori
  final List<Map<String, String>> kategoriMenu = [
    {"name": "Paket Nasi Liwet", "image": "assets/images/nasii.png"},
    {"name": "Aneka Mie", "image": "assets/images/buket.png"},
    {"name": "Aneka Lauk", "image": "assets/images/ikan.png"},
    {"name": "Paket Nasi Tutug", "image": "assets/images/TUTUG.png"},
    {"name": "Minuman", "image": "assets/images/teh.png"},
  ];

  // Dummy menu rekomendasi
  final List<Map<String, dynamic>> menuRekomendasi = [
    {
      "nama": "BRIANI",
      "deskripsi": "rice, chicken",
      "harga": 25000,
      "status": "Habis",
      "rating": 4.2,
      "qty": 0,
    },
    {
      "nama": "SEAFOOD BOIL",
      "deskripsi": "crab, sauce",
      "harga": 25000,
      "status": "Tersedia",
      "rating": 4.1,
      "qty": 2,
    },
  ];

  // 🔢 Hitung total item dalam keranjang
  int get totalCartItems {
    int total = 0;
    for (var menu in menuRekomendasi) {
      total += menu["qty"] as int;
    }
    return total;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔍 Search + Cart
            Padding(
              padding: const EdgeInsets.only(
                  top: 32, left: 16, right: 16, bottom: 20), // 🔥 lebih turun
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Apa yang ingin kamu nikmati hari ini?",
                        prefixIcon: const Icon(Icons.search, color: Colors.red),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // 🛒 Ikon keranjang + Badge
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      InkWell(
                        onTap: () {
                          // Arahkan ke halaman keranjang nanti
                        },
                        child: const Icon(
                          Icons.shopping_cart,
                          color: Color(0xFF800000), // merah marun
                          size: 38, // 🔥 diperbesar biar proporsional
                        ),
                      ),
                      if (totalCartItems > 0)
                        Positioned(
                          right: -6,
                          top: -6,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              "$totalCartItems",
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

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
                    "Makan enak itu bukan sekadar mengisi perut, tapi juga cara terbaik untuk menikmati hidup.\n"
                    "Karena setiap suapan membawa kebahagiaan tersendiri!",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(fontSize: 14),
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
                              backgroundImage:
                                  AssetImage(kategori["image"]!),
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
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Gambar placeholder
                      Container(
                        height: 90,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(15)),
                          color: Colors.orange.shade200,
                        ),
                        child: const Center(
                          child: Icon(Icons.fastfood,
                              size: 40, color: Colors.white),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(6),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(menu["nama"],
                                  style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13)),
                              Text(menu["deskripsi"],
                                  style: GoogleFonts.poppins(fontSize: 11)),
                              Text(
                                "${menu["harga"]}",
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: Colors.red.shade700,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                menu["status"],
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: menu["status"] == "Habis"
                                      ? Colors.red
                                      : Colors.green,
                                ),
                              ),
                              const Spacer(),
                              // 🔥 Tombol Qty
                              menu["qty"] == 0
                                  ? Align(
                                      alignment: Alignment.centerRight,
                                      child: InkWell(
                                        onTap: () {
                                          setState(() {
                                            menu["qty"] = 1;
                                          });
                                        },
                                        child: Container(
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Color(0xFF800000),
                                          ),
                                          padding: const EdgeInsets.all(6),
                                          child: const Icon(Icons.add,
                                              color: Colors.white, size: 18),
                                        ),
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.remove_circle,
                                              color: Colors.red, size: 20),
                                          onPressed: () {
                                            setState(() {
                                              if (menu["qty"] > 0) {
                                                menu["qty"]--;
                                              }
                                            });
                                          },
                                        ),
                                        Text("${menu["qty"]}",
                                            style: GoogleFonts.poppins(
                                                fontSize: 13)),
                                        IconButton(
                                          icon: const Icon(Icons.add_circle,
                                              color: Colors.green, size: 20),
                                          onPressed: () {
                                            setState(() {
                                              menu["qty"]++;
                                            });
                                          },
                                        ),
                                      ],
                                    )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),

      // 📌 Bottom Navbar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Beranda"),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: "Menu"),
          BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long), label: "Pesanan"),
          BottomNavigationBarItem(
              icon: Icon(Icons.info), label: "Tentang Kami"),
        ],
      ),
    );
  }
}
