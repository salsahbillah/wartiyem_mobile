import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// Pastikan path ini benar sesuai struktur folder Anda
import 'package:wartiyem_mobile/widgets/topbar.dart';
import 'package:wartiyem_mobile/widgets/menu_card.dart';
import '../providers/cart_provider.dart';
import '../services/format.dart'; 


// ===================================================
// MODEL: Food (Disarankan berada di models/food.dart)
// ===================================================
class Food {
  final String id;
  final String name;
  final String description;
  final double price;
  final dynamic status;
  final String image;
  final String category;

  double avgRating;
  int totalReviews;
  Map<String, int> ratingCounts;

  int qty;

  Food({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.status,
    required this.image,
    required this.category,
    this.avgRating = 0.0,
    this.totalReviews = 0,
    Map<String, int>? ratingCounts,
    this.qty = 0,
  }) : ratingCounts = ratingCounts ?? {};

  factory Food.fromJson(Map<String, dynamic> j) {
    double parsedPrice = 0;
    if (j['price'] is int) {
      parsedPrice = (j['price'] as int).toDouble();
    } else if (j['price'] is double) parsedPrice = j['price'];
    else if (j['price'] is String) parsedPrice = double.tryParse(j['price']) ?? 0;

    return Food(
      id: j['_id']?.toString() ?? j['id']?.toString() ?? '',
      name: j['name'] ?? j['nama'] ?? '',
      description: j['description'] ?? j['deskripsi'] ?? '',
      price: parsedPrice,
      status: j['status'],
      image: j['image'] ?? j['imagePath'] ?? '',
      category: j['category'] ?? j['kategori'] ?? 'Umum',
      avgRating: (j['avgRating'] is num) ? (j['avgRating'] as num).toDouble() : 0.0,
      totalReviews: j['totalReviews'] is int ? j['totalReviews'] : 0,
      ratingCounts: (j['ratingCounts'] is Map)
          ? Map<String, int>.from(j['ratingCounts'])
          : {},
      qty: j['qty'] is int ? j['qty'] : 0,
    );
  }

  String resolvedImageUrl(String baseUrl) {
    if (image.toLowerCase().startsWith('http')) return image;
    final base = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    // URL disesuaikan dengan asumsi API
    return '$base/images/$image'; 
  }

  void mergeRating(Map<String, dynamic> agg) {
    if (agg.containsKey('avgRating')) {
      avgRating = (agg['avgRating'] is num)
          ? (agg['avgRating'] as num).toDouble()
          : avgRating;
    }
    if (agg.containsKey('totalReviews')) {
      totalReviews = agg['totalReviews'] is int
          ? agg['totalReviews']
          : totalReviews;
    }
    if (agg.containsKey('ratingCounts') && agg['ratingCounts'] is Map) {
      ratingCounts = Map<String, int>.from(agg['ratingCounts']);
    }
  }
}


// ===================================================
// API SERVICE (Disarankan berada di services/api_service.dart)
// ===================================================
class ApiService {
  static const String base =
      'https://unflamboyant-undepreciable-emilia.ngrok-free.dev';

  static const String foodsEndpoint = '$base/api/food';
  static const String reviewsTopEndpoint = '$base/api/reviews/top';

  static Future<List<Food>> fetchFoods() async {
    final res = await http.get(Uri.parse(foodsEndpoint));

    if (res.statusCode != 200) {
      throw Exception('Gagal ambil data menu (${res.statusCode})');
    }

    final body = json.decode(res.body);
    final List list = body is List ? body : (body['data'] ?? []);

    return list.map((e) => Food.fromJson(Map<String, dynamic>.from(e))).toList();
  }

  static Future<List<Map<String, dynamic>>> fetchTopReviews() async {
    final res = await http.get(Uri.parse(reviewsTopEndpoint));

    if (res.statusCode != 200) {
      throw Exception('Gagal ambil rating (${res.statusCode})');
    }

    final body = json.decode(res.body);
    final List list = body is List ? body : (body['data'] ?? []);

    return list.map((e) => Map<String, dynamic>.from(e)).toList();
  }
}


// ===================================================
// HOME PAGE UTAMA
// ===================================================
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // State Filter Kategori (sama seperti useState("All") di React)
  String selectedCategory = "Semua"; 
  
  // State untuk Data API
  List<Food> allFoods = []; 
  List<Food> recommendedMenus = []; // Daftar menu yang ditampilkan setelah difilter
  List<String> uniqueCategories = ["Semua"]; 
  bool isLoading = true;
  String? errorMessage;

  // Data kategori statis (Digunakan untuk mapping gambar kategori)
  final List<Map<String, String>> kategoriMenu = [
    {"name": "Paket Nasi Liwet", "image": "assets/images/nasii.png"},
    {"name": "Aneka Mie", "image": "assets/images/buket.png"},
    {"name": "Aneka Lauk", "image": "assets/images/ikan.png"},
    {"name": "Paket Nasi Tutug", "image": "assets/images/TUTUG.png"},
    {"name": "Minuman", "image": "assets/images/teh.png"},
    // Jika ada kategori lain dari API, mereka akan menggunakan gambar placeholder.
  ];

  @override
  void initState() {
    super.initState();
    _loadMenusFromApi();
  }

  // Fungsi untuk memuat data dari API
  Future<void> _loadMenusFromApi() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final foods = await ApiService.fetchFoods();
      final top = await ApiService.fetchTopReviews();

      // Logika penggabungan rating
      final Map<String, Map<String, dynamic>> agg = {};
      for (final r in top) {
        final id = (r['_id'] ?? r['foodId'] ?? '')?.toString();
        if (id != null && id.isNotEmpty) agg[id] = r;
      }
      for (final f in foods) {
        if (agg.containsKey(f.id)) f.mergeRating(agg[f.id]!);
      }
      
      // Ambil kategori unik
      final categories = foods.map((f) => f.category).toSet().toList();

      setState(() {
        allFoods = foods; 
        uniqueCategories = ["Semua", ...categories];
        isLoading = false;
      });
      
      // Terapkan filter awal setelah data dimuat
      _applyCategoryFilter(selectedCategory);

    } catch (e) {
      setState(() {
        errorMessage = "Terjadi kesalahan: ${e.toString()}";
        isLoading = false;
      });
    }
  }

  // Fungsi Filter Kategori (seperti setCategory di React)
  void _applyCategoryFilter(String newCategory) {
    List<Food> filteredList;

    if (newCategory == "Semua") {
      // Jika "Semua" dipilih, tampilkan semua makanan
      filteredList = allFoods;
    } else {
      // Filter berdasarkan kategori yang dipilih
      filteredList = allFoods.where((food) => food.category == newCategory).toList();
    }

    setState(() {
      selectedCategory = newCategory;
      recommendedMenus = filteredList;
    });
  }

  // Fungsi Tambah ke Keranjang
  void addToCart(Food f) {
    Provider.of<CartProvider>(context, listen: false).addItem({
      "id": f.id,
      "name": f.name,
      "description": f.description,
      "price": f.price,
      "qty": 1,
      "image": f.resolvedImageUrl(ApiService.base),
      "total": f.price * 1,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("${f.name} ditambahkan ke keranjang")),
    );
  }
  
  // Total item keranjang di TopBar
  int get totalCartItems {
    final provider = Provider.of<CartProvider>(context, listen: false);
    return provider.items.length;
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

          // 🍲 Kategori Menu (DINAMIS DARI API)
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
          
          if (isLoading)
             const Center(child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Text("Memuat kategori..."),
            ))
          else
            SizedBox(
              height: 110,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: uniqueCategories.length,
                itemBuilder: (context, index) {
                  final categoryName = uniqueCategories[index];
                  
                  // Mencari gambar yang cocok di daftar statis
                  final categoryData = kategoriMenu.firstWhere(
                    (k) => k["name"] == categoryName,
                    orElse: () => {"name": categoryName, "image": "assets/images/nasii.png"}, 
                  );

                  return GestureDetector(
                    onTap: () {
                      _applyCategoryFilter(categoryName); 
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
                                color: selectedCategory == categoryName
                                    ? Colors.red
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.grey.shade200,
                              backgroundImage: AssetImage(categoryData["image"]!),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            categoryName,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: selectedCategory == categoryName
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: selectedCategory == categoryName
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

          // 🍴 Menu Rekomendasi (DIFILTER DARI API)
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
          
          if (isLoading)
            const Center(child: Padding(
              padding: EdgeInsets.all(20.0),
              child: CircularProgressIndicator(),
            ))
          else if (errorMessage != null)
            Center(child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(errorMessage!),
            ))
          else if (recommendedMenus.isEmpty)
             const Center(child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Text("Tidak ada menu yang tersedia dalam kategori ini."),
            ))
          else
            GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.60,
                crossAxisSpacing: 12,
                mainAxisSpacing: 16,
              ),
              itemCount: recommendedMenus.length,
              itemBuilder: (context, index) {
                final f = recommendedMenus[index];
                return MenuCard(
                  nama: f.name,
                  deskripsi: f.description,
                  harga: FormatHelper.price(f.price), 
                  status: f.status,
                  qty: f.qty,
                  rating: f.avgRating,
                  imagePath: f.resolvedImageUrl(ApiService.base), 
                  onAdd: () => addToCart(f),
                  onRemove: () {}, 
                );
              },
            ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}