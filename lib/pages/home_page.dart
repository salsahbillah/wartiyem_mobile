// home_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:wartiyem_mobile/widgets/topbar.dart';
import 'package:wartiyem_mobile/widgets/menu_card.dart';
import '../providers/cart_provider.dart';
import '../providers/search_provider.dart';
import '../services/format.dart';
import 'dart:async';

// ===================================================
// MODEL: Food
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
    } else if (j['price'] is double) {
      parsedPrice = j['price'];
    } else if (j['price'] is String) {
      parsedPrice = double.tryParse(j['price']) ?? 0;
    }

    return Food(
      id: j['_id']?.toString() ?? j['id']?.toString() ?? '',
      name: j['name'] ?? j['nama'] ?? '',
      description: j['description'] ?? j['deskripsi'] ?? '',
      price: parsedPrice,
      status: j['status'],
      image: j['image'] ?? j['imagePath'] ?? '',
      category: j['category'] ?? j['kategori'] ?? 'Umum',
      avgRating:
          (j['avgRating'] is num) ? (j['avgRating'] as num).toDouble() : 0.0,
      totalReviews: j['totalReviews'] is int ? j['totalReviews'] : 0,
      ratingCounts:
          (j['ratingCounts'] is Map) ? Map<String, int>.from(j['ratingCounts']) : {},
      qty: j['qty'] is int ? j['qty'] : 0,
    );
  }

  String resolvedImageUrl(String baseUrl) {
    if (image.toLowerCase().startsWith('http')) return image;

    final base =
        baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;

    return '$base/images/$image';
  }

  void mergeRating(Map<String, dynamic> agg) {
    if (agg.containsKey('avgRating')) {
      avgRating = (agg['avgRating'] is num)
          ? (agg['avgRating'] as num).toDouble()
          : avgRating;
    }
    if (agg.containsKey('totalReviews')) {
      totalReviews = agg['totalReviews'] is int ? agg['totalReviews'] : totalReviews;
    }
    if (agg.containsKey('ratingCounts') && agg['ratingCounts'] is Map) {
      ratingCounts = Map<String, int>.from(agg['ratingCounts']);
    }
  }
}

// ===================================================
// API SERVICE
// ===================================================
class ApiService {
  static const String base =
      'https://kedaiwartiyem.my.id';

  static const String foodsEndpoint = '$base/api/food';
  static const String reviewsTopEndpoint = '$base/api/reviews/top';
  static const String recommendationsEndpoint =
      '$base/api/food/recommendations';

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

  static Future<List<Food>> fetchRecommendations() async {
    final res = await http.get(Uri.parse(recommendationsEndpoint));

    if (res.statusCode != 200) {
      throw Exception('Gagal ambil data rekomendasi (${res.statusCode})');
    }

    final body = json.decode(res.body);
    final List list = body is List ? body : (body['data'] ?? []);

    return list.map((e) => Food.fromJson(Map<String, dynamic>.from(e))).toList();
  }
}

// ===================================================
// HOME PAGE
// ===================================================
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}


class _HomePageState extends State<HomePage> {
  // ====== Banner Slider ======
  late PageController _pageController;
  int _currentPage = 0;

  // ====== Animasi Text ======
  double titleScale = 1.0;
  double subtitleScale = 1.0;

  // ====== Menu / Data ======
  String selectedCategory = "";
  List<Food> allFoods = [];
  List<Food> recommendedMenus = [];
  List<String> uniqueCategories = [];
  bool isLoading = true;
  String? errorMessage;

List<String> rotatingTexts = [
  "Telusuri Menu Terbaik Kami",
  "Nikmati Hidangan Favorit Anda",
  "Pesan Sekarang, Langsung Antar",
];

int currentTextIndex = 0;


  @override

  void initState() {
    Timer.periodic(const Duration(seconds: 4), (timer) {
  setState(() {
    currentTextIndex = (currentTextIndex + 1) % rotatingTexts.length;
  });
});

    super.initState();
  
  

    // --- PAGEVIEW SLIDER ---
    _pageController = PageController(initialPage: 0);

    Future.delayed(Duration.zero, () {
      Timer.periodic(const Duration(seconds: 3), (timer) {
        if (!_pageController.hasClients) return;

        _currentPage++;
        if (_currentPage == 3) _currentPage = 0;

        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      });
    });

    // --- LOAD DATA MENU ---
    _loadMenusFromApi();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }


  final List<Map<String, String>> kategoriMenu = [
    {"name": "Paket Nasi Liwet", "image": "assets/images/nasii.png"},
    {"name": "Aneka Mie", "image": "assets/images/buket.png"},
    {"name": "Aneka Lauk", "image": "assets/images/ikan.png"},
    {"name": "Paket Nasi Tutug", "image": "assets/images/TUTUG.png"},
    {"name": "Minuman", "image": "assets/images/teh.png"},
  ];


  Future<void> _loadMenusFromApi() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final foods = await ApiService.fetchFoods();
      final top = await ApiService.fetchTopReviews();
      final recs = await ApiService.fetchRecommendations();

      final Map<String, Map<String, dynamic>> agg = {};
      for (final r in top) {
        final id = (r['_id'] ?? r['foodId'] ?? '')?.toString();
        if (id != null && id.isNotEmpty) agg[id] = r;
      }

      for (final f in foods) {
        if (agg.containsKey(f.id)) f.mergeRating(agg[f.id]!);
      }

      List<Food> mergedRecs = recs.map((r) {
        final found = foods.firstWhere((f) => f.id == r.id, orElse: () => r);
        if (agg.containsKey(found.id)) found.mergeRating(agg[found.id]!);
        return found;
      }).toList();

      final apiCategories = foods.map((f) => f.category).toSet().toList();

      final List<String> finalCategories = [];

      for (var k in kategoriMenu) {
        if (!finalCategories.contains(k["name"])) {
          finalCategories.add(k["name"]!);
        }
      }

      for (var c in apiCategories) {
        if (!finalCategories.contains(c)) {
          finalCategories.add(c);
        }
      }

      setState(() {
        allFoods = foods;
        uniqueCategories = finalCategories;

        if (selectedCategory.isEmpty) {
          recommendedMenus = mergedRecs;
        } else {
          recommendedMenus =
              allFoods.where((f) => f.category == selectedCategory).toList();
        }
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = "Terjadi kesalahan: ${e.toString()}";
        isLoading = false;
      });
    }
  }

  void _applyCategoryFilter(String newCategory) {
    if (selectedCategory == newCategory) {
      setState(() {
        selectedCategory = "";
      });
      _loadRecommendationsOnly();
      return;
    }

    final filtered = allFoods.where((f) => f.category == newCategory).toList();

    setState(() {
      selectedCategory = newCategory;
      recommendedMenus = filtered;
    });
  }

  Future<void> _loadRecommendationsOnly() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final top = await ApiService.fetchTopReviews();
      final recs = await ApiService.fetchRecommendations();

      final Map<String, Map<String, dynamic>> agg = {};
      for (final r in top) {
        final id = (r['_id'] ?? r['foodId'] ?? '')?.toString();
        if (id != null && id.isNotEmpty) agg[id] = r;
      }

      List<Food> mergedRecs = recs.map((r) {
        final found = allFoods.firstWhere((f) => f.id == r.id, orElse: () => r);
        if (agg.containsKey(found.id)) found.mergeRating(agg[found.id]!);
        return found;
      }).toList();

      setState(() {
        recommendedMenus = mergedRecs;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = "Terjadi kesalahan: ${e.toString()}";
        isLoading = false;
      });
    }
  }

  // ========== CART HELPERS ==========
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

  void removeFromCart(Food f) {
    final provider = Provider.of<CartProvider>(context, listen: false);
    // assume provider.items is List<Map> with 'id' and 'qty'
    final idx = provider.items.indexWhere((it) => (it['id'] ?? it['_id']) == f.id);
    if (idx != -1) {
      final currentQty = provider.items[idx]['qty'] ?? 0;
      if (currentQty <= 1) {
        // if CartProvider has remove by id, use that; else update to 0
        try {
          provider.removeItem(idx);
        } catch (_) {
          provider.updateQty(idx, 0);
        }
      } else {
        provider.updateQty(idx, currentQty - 1);
      }
      setState(() {});
    }
  }

  int getQtyFromCart(String id) {
    final provider = Provider.of<CartProvider>(context, listen: false);
    final item = provider.items.firstWhere(
      (it) => (it['id'] ?? it['_id']) == id,
      orElse: () => {},
    );
    if (item == null || item.isEmpty) return 0;
    return item['qty'] ?? 0;
  }

  Widget _buildMenuCard(Food f) {
    return MenuCard(
      nama: f.name,
      deskripsi: f.description,
      harga: FormatHelper.price(f.price),
      status: f.status,
      rating: f.avgRating,
      qty: getQtyFromCart(f.id),
      imagePath: f.resolvedImageUrl(ApiService.base),
      onAdd: () => addToCart(f),
      onRemove: () => removeFromCart(f),
    );
  }

  @override
  Widget build(BuildContext context) {
    final searchQuery = context.watch<SearchProvider>().query.trim().toLowerCase();
    final cartProvider = Provider.of<CartProvider>(context);
    final totalCartItems = cartProvider.items.length;

    // Decide what to display:
    // 1) If searchQuery not empty => show search grid (from allFoods)
    // 2) else if selectedCategory empty => show recommendedMenus
    // 3) else show category filtered list (recommendedMenus already set)
    List<Food> searchResults = [];
    if (searchQuery.isNotEmpty) {
      searchResults = allFoods.where((f) {
        final name = f.name.toLowerCase();
        final desc = f.description.toLowerCase();
        final cat = f.category.toLowerCase();
        final price = f.price.toString().toLowerCase();
        return name.contains(searchQuery) ||
            desc.contains(searchQuery) ||
            cat.contains(searchQuery) ||
            price.contains(searchQuery);
      }).toList();
    }

    final bool showingSearch = searchQuery.isNotEmpty;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TopBar(totalCartItems: totalCartItems),

          Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SizedBox(
            height: 160,
            child: PageView(
              controller: _pageController,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    'assets/images/banner.png',
                    fit: BoxFit.cover,
                  ),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    'assets/images/banner.png',
                    fit: BoxFit.cover,
                  ),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    'assets/images/banner.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
          ),
        ),


          const SizedBox(height: 16),

          Center(
            child: Column(
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: child,
                  ),
                  child: Text(
                    rotatingTexts[currentTextIndex],
                    key: ValueKey<String>(rotatingTexts[currentTextIndex]),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE53935), // warna tema Kedai Wartiyem
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 8),
                GestureDetector(
                onTapDown: (_) => setState(() => subtitleScale = 1.05),
                onTapUp: (_) => setState(() => subtitleScale = 1.0),
                onTapCancel: () => setState(() => subtitleScale = 1.0),
                child: AnimatedScale(
                  scale: subtitleScale,
                  duration: const Duration(milliseconds: 150),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      "Makan enak itu bukan sekadar mengisi perut, tapi juga cara menikmati hidup. "
                      "Setiap suapan membawa kebahagiaan tersendiri!",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 12.5,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey[800],
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
              ),

              ],
            ),
          ),

          const SizedBox(height: 20),

          // KATEGORI
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
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Text("Memuat kategori..."),
              ),
            )
          else
            SizedBox(
              height: 110,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: uniqueCategories.length,
                itemBuilder: (context, index) {
                  final categoryName = uniqueCategories[index];

                  final categoryData = kategoriMenu.firstWhere(
                    (k) => k["name"] == categoryName,
                    orElse: () =>
                        {"name": categoryName, "image": "assets/images/nasii.png"},
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
                              backgroundImage:
                                  AssetImage(categoryData["image"]!),
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

          // HEADER
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              showingSearch ? "Hasil Pencarian" : "Menu Rekomendasi",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // CONTENT
          if (isLoading)
            const Center(child: CircularProgressIndicator())
          else if (errorMessage != null)
            Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(errorMessage!),
              ),
            )
          else if (showingSearch)
            // SHOW SEARCH GRID
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                padding: const EdgeInsets.only(bottom: 20),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.60,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 16,
                ),
                itemCount: searchResults.length,
                itemBuilder: (context, index) {
                  final f = searchResults[index];
                  return _buildMenuCard(f);
                },
              ),
            )
          else if (recommendedMenus.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text("Tidak ada menu dalam kategori ini."),
              ),
            )
          else
            // SHOW RECOMMENDATIONS / CATEGORY RESULTS
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
                return _buildMenuCard(f);
              },
            ),

          const SizedBox(height: 80),
        ],
      ),
    );
  }
}