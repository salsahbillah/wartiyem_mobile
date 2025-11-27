// menu_page.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:wartiyem_mobile/widgets/topbar.dart';
import 'package:wartiyem_mobile/widgets/menu_card.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import 'package:wartiyem_mobile/services/format.dart';



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

  // Fix URL gambar — sesuai backend Cece (uploads → images)
  String resolvedImageUrl(String baseUrl) {
    if (image.toLowerCase().startsWith('http')) return image;

    final base = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;

    if (image.contains('images/')) {
      return '$base/$image';
    }

    return '$base/images/$image';
  }

  void mergeRating(Map<String, dynamic> agg) {
    if (agg.containsKey('avgRating')) {
      avgRating =
          (agg['avgRating'] is num) ? (agg['avgRating'] as num).toDouble() : avgRating;
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
      'https://unflamboyant-undepreciable-emilia.ngrok-free.dev';

  static const String foodsEndpoint = '$base/api/food';
  static const String reviewsTopEndpoint = '$base/api/reviews/top';

  static Future<List<Food>> fetchFoods() async {
    final res =
        await http.get(Uri.parse(foodsEndpoint)).timeout(const Duration(seconds: 20));

    if (res.statusCode != 200) {
      throw Exception('Gagal ambil data menu (${res.statusCode})');
    }

    final body = json.decode(res.body);
    final List list = body is List ? body : (body['data'] ?? body['foods'] ?? []);

    return list.map((e) => Food.fromJson(Map<String, dynamic>.from(e))).toList();
  }

  static Future<List<Map<String, dynamic>>> fetchTopReviews() async {
    final res = await http
        .get(Uri.parse(reviewsTopEndpoint))
        .timeout(const Duration(seconds: 20));

    if (res.statusCode != 200) {
      throw Exception('Gagal ambil rating (${res.statusCode})');
    }

    final body = json.decode(res.body);
    final List list =
        body is List ? body : (body['data'] ?? body['results'] ?? []);

    return list.map((e) => Map<String, dynamic>.from(e)).toList();
  }
}

// ===================================================
// MENU PAGE (UI SAMA, LOGIKA SAMA DGN WEB)
// ===================================================
class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  List<Map<String, dynamic>> semuaMenu = [];

  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadMenusFromApi();
  }

  Future<void> _loadMenusFromApi() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final foods = await ApiService.fetchFoods();
      final top = await ApiService.fetchTopReviews();

      final Map<String, Map<String, dynamic>> agg = {};
      for (final r in top) {
        final id =
            (r['_id'] ?? r['foodId'] ?? r['id'])?.toString() ?? '';
        if (id.isNotEmpty) agg[id] = r;
      }

      for (final f in foods) {
        if (agg.containsKey(f.id)) f.mergeRating(agg[f.id]!);
      }

      final Map<String, List<Food>> grouped = {};
      for (final f in foods) {
        final cat = f.category.isNotEmpty ? f.category : 'Umum';
        grouped.putIfAbsent(cat, () => []).add(f);
      }

      final List<Map<String, dynamic>> newData = [];
      grouped.forEach((cat, items) {
        newData.add({"kategori": cat, "items": items});
      });

      newData.sort((a, b) =>
          (a['kategori'] as String).compareTo(b['kategori'] as String));

      setState(() {
        semuaMenu = newData;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = "Terjadi kesalahan: $e";
        isLoading = false;
      });
    }
  }

  int get totalCartItems {
    int total = 0;
    for (var kategori in semuaMenu) {
      for (var item in kategori['items'] as List<Food>) {
        total += item.qty;
      }
    }
    return total;
  }

  void addToCart(Food f) {
  Provider.of<CartProvider>(context, listen: false).addItem({
    "id": f.id,
    "name": f.name,
    "price": f.price,
    "qty": 1,
    "image": f.resolvedImageUrl(ApiService.base),
  });

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text("${f.name} ditambahkan ke keranjang")),
  );
}


  void removeFromCart(Food m) {
    setState(() {
      if (m.qty > 0) m.qty--;
    });
  }

  Widget _buildMenuCardFromFood(Food f) {
    final img = f.image.isNotEmpty
        ? f.resolvedImageUrl(ApiService.base)
        : 'assets/images/tes.png';

    return MenuCard(
      nama: f.name,
      deskripsi: f.description,
      harga: FormatHelper.price(f.price),
      status: f.status,
      rating: f.avgRating,
      qty: f.qty,
      imagePath: img,
      onAdd: () => addToCart(f),
      onRemove: () => removeFromCart(f),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            TopBar(totalCartItems: totalCartItems),

            if (isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (errorMessage != null)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(errorMessage!),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _loadMenusFromApi,
                        child: const Text("Coba Lagi"),
                      )
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _loadMenusFromApi,
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 90),
                    itemCount: semuaMenu.length,
                    itemBuilder: (context, sectionIndex) {
                      final kategori = semuaMenu[sectionIndex];
                      final items = kategori["items"] as List<Food>;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                kategori["kategori"],
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red.shade800,
                                ),
                              ),
                            ],
                          ),
                        ),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: items.length,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.60,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 16,
                            ),
                            itemBuilder: (c, i) {
                              return _buildMenuCardFromFood(items[i]);
                            },
                          )
                        ],
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
