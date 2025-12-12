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
      qty: j['qty'] is int ? j['qty'] : 0,
    );
  }

  String resolvedImageUrl(String baseUrl) {
    if (image.toLowerCase().startsWith('http')) return image;
    final base = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    return '$base/images/$image';
  }

  void mergeRating(Map<String, dynamic> agg) {
    if (agg.containsKey('avgRating')) {
      avgRating = (agg['avgRating'] is num) ? (agg['avgRating'] as num).toDouble() : avgRating;
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
  static const String base = 'https://unflamboyant-undepreciable-emilia.ngrok-free.dev';

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
// MENU PAGE — FIXED & FULL
// ===================================================
class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  List<Map<String, dynamic>> semuaMenu = []; // sections: {kategori, items}
  List<Food> allItemsFlat = []; // flattened items
  bool isLoading = true;
  String? errorMessage;

  String selectedSortFilter = "Default"; // Default / HighToLow / LowToHigh / rating_3 etc.

  // fixed category order (will appear first)
  final List<String> fixedCategoriesOrder = [
    "Aneka Lauk",
    "Aneka Mie",
    "Paket Nasi Liwet",
    "Paket Nasi Tutug",
    "Minuman",
  ];

  bool _handledRouteArgs = false;

  @override
  void initState() {
    super.initState();
    _loadMenusFromApi();
  }

  // If navigated with arguments (e.g. TopBar -> /menu with {"search": query}),
  // ensure SearchProvider is updated once.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_handledRouteArgs) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map && args.containsKey('search')) {
        final q = (args['search'] ?? '').toString();
        if (q.isNotEmpty) {
          Provider.of<SearchProvider>(context, listen: false).setQuery(q);
        }
      }
      _handledRouteArgs = true;
    }
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

      // merge ratings
      final Map<String, Map<String, dynamic>> agg = {};
      for (final r in top) {
        final id = (r['_id'] ?? r['foodId'] ?? '')?.toString();
        if (id != null && id.isNotEmpty) agg[id] = r;
      }
      for (final f in foods) {
        if (agg.containsKey(f.id)) f.mergeRating(agg[f.id]!);
      }

      // group by category
      final Map<String, List<Food>> grouped = {};
      for (final f in foods) {
        grouped.putIfAbsent(f.category, () => []).add(f);
      }

      // build ordered sections
      final List<Map<String, dynamic>> newData = [];

      // add fixed categories first
      for (final cat in fixedCategoriesOrder) {
        if (grouped.containsKey(cat)) {
          newData.add({"kategori": cat, "items": grouped[cat]!});
          grouped.remove(cat);
        }
      }

      // remaining categories sorted alphabetically
      final remaining = grouped.keys.toList()..sort();
      for (final k in remaining) {
        newData.add({"kategori": k, "items": grouped[k]!});
      }

      // flatten
      final List<Food> flat = [];
      for (final sec in newData) {
        final items = (sec["items"] as List<Food>);
        flat.addAll(items);
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
  // FILTER & SORTing
  // ===================================================
  List<Food> applyFilterAndSort(List<Food> source) {
    List<Food> result = List.from(source);

    // rating_x filters
    if (selectedSortFilter.startsWith("rating_")) {
      final parts = selectedSortFilter.split("_");
      if (parts.length >= 2) {
        final minRating = int.tryParse(parts[1]) ?? 0;
        result = result.where((m) => (m.avgRating.round()) >= minRating).toList();
      }
    }

    // sort by price
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
    return "Semua Menu";
  }

  // ===================================================
  // CART HELPERS
  // ===================================================
  int getQtyFromCart(String id) {
    final cart = Provider.of<CartProvider>(context, listen: false).items;
    final item = cart.firstWhere(
      (e) => (e['id'] ?? e['_id']) == id,
      orElse: () => {},
    );
    if (item == null || item.isEmpty) return 0;
    return item['qty'] ?? 0;
  }

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
    setState(() {});
  }

  void removeFromCart(Food f) {
    final p = Provider.of<CartProvider>(context, listen: false);
    final index = p.items.indexWhere((e) => (e['id'] ?? e['_id']) == f.id);
    if (index != -1) {
      final currentQty = p.items[index]['qty'] ?? 0;
      if (currentQty <= 1) {
        p.removeItem(index);
      } else {
        p.updateQty(index, currentQty - 1);
      }
      setState(() {});
    }
  }

  // ===================================================
  // UI helpers
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
  // FILTER POPUP
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
                  width: 300,
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
                        "Urutkan / Filter",
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
                                    (x) => const Icon(Icons.star, color: Colors.orange, size: 18),
                                  ) +
                                  List.generate(
                                    5 - star,
                                    (x) => const Icon(Icons.star_border, color: Colors.grey, size: 18),
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
        Radio<String>(
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
  // BUILD
  // ===================================================
  @override
  Widget build(BuildContext context) {
    final cartLength = Provider.of<CartProvider>(context).items.length;
    final query = Provider.of<SearchProvider>(context).query; // already lowercase

    // 1) start from flat list
    List<Food> baseList = List.from(allItemsFlat);

    // 2) apply search (if any)
    final q = query.trim();
    if (q.isNotEmpty) {
      baseList = baseList.where((f) {
        final name = f.name.toLowerCase();
        final desc = f.description.toLowerCase();
        final cat = f.category.toLowerCase();
        final priceStr = f.price.toString().toLowerCase();
        return name.contains(q) || desc.contains(q) || cat.contains(q) || priceStr.contains(q);
      }).toList();
    }

    // 3) apply sort/filter rules
    final List<Food> finalItems = applyFilterAndSort(baseList);

    final bool isDefaultMode = selectedSortFilter == "Default";

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
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(errorMessage!),
                      const SizedBox(height: 8),
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
                    padding: const EdgeInsets.only(bottom: 120, top: 8),
                    children: [
                      // If Default mode -> show categories (but only items that exist in finalItems)
                      if (isDefaultMode) ...[
                        // iterate sections
                        ...semuaMenu.map((section) {
                          final kategori = section["kategori"] as String;
                          final items = (section["items"] as List<Food>);

                          // Only keep visible items from this section that are also in finalItems
                          final visible = items.where((f) => finalItems.any((fi) => fi.id == f.id)).toList();

                          if (visible.isEmpty) return const SizedBox.shrink();

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // header
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      kategori,
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red.shade800,
                                      ),
                                    ),
                                    // show filter icon on top-right (first section)
                                    if (semuaMenu.first == section)
                                      GestureDetector(
                                        onTap: _openFilterPopup,
                                        child: Row(
                                          children: [
                                            Icon(Icons.filter_alt, color: Colors.red.shade800),
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

                              // grid of visible items
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: visible.length,
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 0.60,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 16,
                                ),
                                itemBuilder: (_, i) => _buildMenuCard(visible[i]),
                              ),
                            ],
                          );
                        }).toList(),
                      ] else ...[
                        // Non-default (filter mode) => show one big grid with finalItems
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                                    Icon(Icons.filter_alt, color: Colors.red.shade800),
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
                          itemCount: finalItems.length,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.60,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 16,
                          ),
                          itemBuilder: (_, i) => _buildMenuCard(finalItems[i]),
                        ),
                      ],

                      const SizedBox(height: 24),
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
