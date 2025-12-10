// menu_page.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/search_provider.dart';
import 'package:wartiyem_mobile/widgets/topbar.dart';
import 'package:wartiyem_mobile/widgets/menu_card.dart';
import '../services/format.dart';

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
  }) : ratingCounts = ratingCounts ?? {};

  factory Food.fromJson(Map<String, dynamic> j) {
    double parsedPrice = 0;
    if (j['price'] is int) parsedPrice = (j['price'] as int).toDouble();
    else if (j['price'] is double) parsedPrice = j['price'];
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
    );
  }

  String resolvedImageUrl(String baseUrl) {
    if (image.toLowerCase().startsWith('http')) return image;
    final base = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    return '$base/images/$image';
  }

  void mergeRating(Map<String, dynamic> agg) {
    if (agg.containsKey('avgRating')) {
      avgRating = (agg['avgRating'] as num).toDouble();
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
// API SERVICE
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
// MENU PAGE — UPDATED FILTERING + SEARCH (search aktif hanya di DEFAULT)
// ===================================================
class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  List<Map<String, dynamic>> semuaMenu = [];
  List<Food> allItemsFlat = [];

  bool isLoading = true;
  String? errorMessage;

  String selectedSortFilter = "Default"; // pastikan tidak ke-overwrite // pastikan tidak ke-overwrite

  // ========== FIXED KATEGORI ORDER ==========
  final List<String> fixedCategoriesOrder = [
    "Aneka Lauk",
    "Aneka Mie",
    "Paket Nasi Liwet",
    "Paket Nasi Tutug",
    "Minuman",
  ];

  @override
  void initState() {
    super.initState();
    _loadMenusFromApi();
  }

  // ===================================================
  // LOAD DATA
  // ===================================================
  Future<void> _loadMenusFromApi() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final foods = await ApiService.fetchFoods();
      final top = await ApiService.fetchTopReviews();

      // gabungkan rating
      final Map<String, Map<String, dynamic>> agg = {};
      for (final r in top) {
        final id = (r['_id'] ?? r['foodId'] ?? '')?.toString();
        if (id != null && id.isNotEmpty) agg[id] = r;
      }
      for (final f in foods) {
        if (agg.containsKey(f.id)) f.mergeRating(agg[f.id]!);
      }

      // GROUPING
      final Map<String, List<Food>> grouped = {};
      for (final f in foods) {
        grouped.putIfAbsent(f.category, () => []).add(f);
      }

      final List<Map<String, dynamic>> newData = [];

      // first add fixed categories
      for (final cat in fixedCategoriesOrder) {
        if (grouped.containsKey(cat)) {
          newData.add({"kategori": cat, "items": grouped[cat]!});
          grouped.remove(cat);
        }
      }

      // remaining categories
      final remaining = grouped.keys.toList()..sort();
      for (final k in remaining) {
        newData.add({"kategori": k, "items": grouped[k]!});
      }

      // FLATTEN ALL ITEMS
      final List<Food> flat = [];
      for (final sec in newData) {
        flat.addAll(sec["items"]);
      }

      setState(() {
        semuaMenu = newData;
        allItemsFlat = flat;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = "Terjadi kesalahan: $e";
        isLoading = false;
      });
    }
  }

  // ===================================================
  // FILTERING LOGIC
  // ===================================================
  List<Food> applyFilter() {
    List<Food> result = List.from(allItemsFlat);

    if (selectedSortFilter.startsWith("rating_")) {
      int minRating = int.tryParse(selectedSortFilter.split("_")[1]) ?? 0;
      result = result.where((m) => m.avgRating >= minRating).toList();
    }

    switch (selectedSortFilter) {
      case "HighToLow":
        result.sort((a, b) => b.price.compareTo(a.price));
        break;
      case "LowToHigh":
        result.sort((a, b) => a.price.compareTo(b.price));
        break;
      case "Default":
      default:
        break;
    }

    return result;
  }

  String filterTitle() {
    switch (selectedSortFilter) {
      case "HighToLow":
        return "Harga Tertinggi - Terendah";
      case "LowToHigh":
        return "Harga Terendah - Tertinggi";
      default:
        if (selectedSortFilter.startsWith("rating_")) {
          final r = selectedSortFilter.split("_")[1];
          return "Rating $r ke atas";
        }
    }
    return "";
  }

  // ===================================================
  // CART LOGIC
  // ===================================================
  int getQtyFromCart(String id) {
    final cart = Provider.of<CartProvider>(context, listen: false).items;
    final item = cart.firstWhere(
      (e) => e['id'] == id,
      orElse: () => {},
    );
    return item.isNotEmpty ? item['qty'] : 0;
  }

  void addToCart(Food f) {
    Provider.of<CartProvider>(context, listen: false).addItem({
      "_id": f.id,
      "name": f.name,
      "description": f.description,
      "price": f.price,
      "qty": 1,
      "image": f.resolvedImageUrl(ApiService.base),
      "total": f.price * 1,
    });
    setState(() {});
  }

  void removeFromCart(Food f) {
    final p = Provider.of<CartProvider>(context, listen: false);
    final index = p.items.indexWhere((e) => e['id'] == f.id);
    if (index != -1) {
      p.updateQty(index, p.items[index]['qty'] - 1);
      setState(() {});
    }
  }

  // ===================================================
  // MENU CARD
  // ===================================================
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

  // ===================================================
  // POPUP FILTER MINI
  // (tidak diubah — UI kamu tetap)
  // ===================================================
  void _openFilterPopup() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.35),
      builder: (ctx) {
        return Stack(
          children: [
            Positioned(
              right: 12,
              top: MediaQuery.of(context).size.height * 0.22,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: 260,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(ctx),
                          child: const Icon(Icons.close, size: 22),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Urutkan Berdasarkan",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _filterOption("Default", "Default"),
                      _filterOption("HighToLow", "Harga Tertinggi - Terendah"),
                      _filterOption("LowToHigh", "Harga Terendah - Tertinggi"),
                      const SizedBox(height: 8),
                      Text(
                        "Rating Minimal",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...List.generate(5, (i) {
                        int star = 5 - i;
                        return GestureDetector(
                          onTap: () {
                            setState(() => selectedSortFilter = "rating_$star");
                            Navigator.pop(ctx);
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 3),
                            child: Row(
                              children: [
                                Radio(
                                  value: "rating_$star",
                                  groupValue: selectedSortFilter,
                                  activeColor: Colors.red,
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                                  onChanged: (v) {
                                    setState(() => selectedSortFilter = v!);
                                    Navigator.pop(ctx);
                                  },
                                ),
                                Row(
                                  children: List.generate(
                                    star,
                                    (x) => const Icon(Icons.star,
                                        color: Colors.orange, size: 18),
                                  ) +
                                      List.generate(
                                        5 - star,
                                        (x) => const Icon(Icons.star_border,
                                            color: Colors.grey, size: 18),
                                      ),
                                ),
                                const SizedBox(width: 4),
                                const Text("ke atas", style: TextStyle(fontSize: 12)),
                              ],
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() => selectedSortFilter = "Default");
                            Navigator.pop(ctx);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "Reset",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _filterOption(String value, String label) {
    return Row(
      children: [
        Radio(
          value: value,
          groupValue: selectedSortFilter,
          activeColor: Colors.red,
          onChanged: (v) {
            setState(() => selectedSortFilter = v!);
            Navigator.pop(context);
          },
        ),
        Text(label),
      ],
    );
  }

  // ===================================================
  // BUILD UI
  // ===================================================
  @override
  Widget build(BuildContext context) {
    final cartLength = Provider.of<CartProvider>(context).items.length;
    final query = context.watch<SearchProvider>().query;

    final bool isDefault = selectedSortFilter == "Default";
final List<Food> filteredItems = applyFilter();

// 🔥 tambahkan filtering SEARCH universal
final String q = query.toLowerCase();
List<Food> finalItems = filteredItems.where((f) {
  if (q.isEmpty) return true;
  return f.name.toLowerCase().contains(q) ||
         f.description.toLowerCase().contains(q) ||
         f.price.toString().contains(q) ||
         f.category.toLowerCase().contains(q);
}).toList();


    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            TopBar(totalCartItems: cartLength),

            if (isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (errorMessage != null)
              Expanded(
                child: Center(
                  child: Column(
                    children: [
                      Text(errorMessage!),
                      ElevatedButton(
                        onPressed: _loadMenusFromApi,
                        child: const Text("Coba lagi"),
                      )
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _loadMenusFromApi,
                  child: ListView(
                    padding: const EdgeInsets.only(bottom: 100),
                    children: [
                      // ================================================
                      // DEFAULT MODE → tampil kategori seperti biasa
                      // (SEARCH AKTIF DI SINI SAJA)
                      // ================================================
                      if (isDefault)
                        ...semuaMenu.map((section) {
                          final kategori = section["kategori"];
                          final items = section["items"] as List<Food>;

                          // Jika ada query, filter di dalam kategori (hanya di mode Default)
                          final visible = query.isEmpty
                              ? items
                              : items.where((f) {
                                  final q = query.toLowerCase();
                                  final name = f.name.toLowerCase();
                                  final desc = f.description.toLowerCase();
                                  final price = f.price.toString();
                                  final cat = f.category.toLowerCase();
                                  return name.contains(q) ||
                                      desc.contains(q) ||
                                      price.contains(q) ||
                                      cat.contains(q);
                                }).toList();

                          if (visible.isEmpty) return const SizedBox();

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header kategori + filter icon (hanya di kategori pertama)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      kategori,
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red.shade800,
                                      ),
                                    ),
                                    if (semuaMenu.first == section)
                                      GestureDetector(
                                        onTap: _openFilterPopup,
                                        child: Row(
                                          children: [
                                            Icon(Icons.filter_alt,
                                                color: Colors.red.shade800),
                                            const SizedBox(width: 6),
                                            Text(
                                              "Filter",
                                              style: GoogleFonts.poppins(
                                                color: Colors.red.shade800,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ),

                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: visible.length,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 0.60,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 16,
                                ),
                                itemBuilder: (_, i) => _buildMenuCard(visible[i]),
                              ),
                            ],
                          );
                        }),

                      // ======================================================
                      // FILTER MODE → kategori HILANG, jadi SATU LIST BESAR
                      // (SEARCH TIDAK AKTIF DI SINI — hanya filter & sort)
                      // ======================================================
                      if (!isDefault) ...[
                        // TITLE FILTER
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                filterTitle(),
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red.shade800,
                                ),
                              ),
                              GestureDetector(
                                onTap: _openFilterPopup,
                                child: Row(
                                  children: [
                                    Icon(Icons.filter_alt,
                                        color: Colors.red.shade800),
                                    const SizedBox(width: 6),
                                    Text(
                                      "Filter",
                                      style: GoogleFonts.poppins(
                                        color: Colors.red.shade800,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // LIST GABUNGAN GRID
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: finalItems.length,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.60,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 16,
                          ),
                          itemBuilder: (_, i) => _buildMenuCard(finalItems[i]),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
