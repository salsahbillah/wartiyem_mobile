// FULL FIXED PesananPage
// Tidak ada error override, newOrder tidak duplikat,
// alur Struk → Pesanan berfungsi, rating berjalan normal.

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'struk_page.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';


class PesananPage extends StatefulWidget {
  const PesananPage({super.key});

  @override
  State<PesananPage> createState() => _PesananPageState();
}

class _PesananPageState extends State<PesananPage>
    with SingleTickerProviderStateMixin {
  List<dynamic> orders = [];
  bool isLoading = true;
  String? errorMessage;
  IO.Socket? socket;

  // 👉 variabel ini hanya dideklarasikan sekali!
  Map<String, dynamic>? newOrder;

  static const String apiBaseUrl =
      'https://kedaiwartiyem.my.id/api/order/user';

  static const String reviewBaseUrl =
      'https://kedaiwartiyem.my.id/api/reviews';

  Future<String?> getUserId() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  // coba 3 kemungkinan key 
  return prefs.getString('userId') ?? 
         prefs.getString('_id') ?? 
         prefs.getString('id');
}

  Future<String?> getToken() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  // ambil semua kemungkinan key
  return prefs.getString('authToken')   // token baru dari StoreProvider
      ?? prefs.getString('token')       // old fallback
      ?? prefs.getString('_token');     // kalau ada versi lama lain
}

  @override
  void initState() {
    super.initState();
    fetchOrders();
    connectSocket();
  }

  @override
  void dispose() {
    try {
      socket?.disconnect();
      socket?.dispose();
    } catch (_) {}
    super.dispose();
  }


  // Fungsi bantu untuk mem-fetch review sebuah order (mengembalikan Map review atau null)
// Replace existing fetchReviewForOrder with this
Future<Map<String, dynamic>?> fetchReviewForOrder(String orderId) async {
  try {
    final token = await getToken();
    final userId = await getUserId();

    final uri = Uri.parse("$reviewBaseUrl/order/$orderId?userId=$userId");

    final res = await http.get(
      uri,
      headers: token != null ? {'Authorization': 'Bearer $token'} : {},
    );

    print("DEBUG REVIEW: status=${res.statusCode}, body=${res.body}");

    if (res.statusCode == 200) {
      final parsed = jsonDecode(res.body);

      // backend kamu pakai "reviews"
      if (parsed["reviews"] is List && parsed["reviews"].isNotEmpty) {
        return parsed["reviews"][0];
      }

      return null;
    }

    return null;
  } catch (e) {
    print("ERROR REVIEW FETCH: $e");
    return null;
  }
}

  Future<void> lihatRating(Map order) async {
  try {
    final review = await fetchReviewForOrder(order['_id']);

    if (review == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Rating tidak ditemukan")),
      );
      return;
    }

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withOpacity(0.3),
                blurRadius: 30,
                spreadRadius: 2,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title -----------------------------------------------------
              const Text(
                "Rating Kamu",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Stars -----------------------------------------------------
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  5,
                  (i) {
                    final filled = i < (review["rating"] ?? 0);
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(
                        Icons.star_rounded,
                        size: 40,
                        color: filled ? Colors.orange : Colors.grey.shade300,
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              // Comment box -----------------------------------------------
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  review["comment"]?.toString().trim().isNotEmpty == true
                      ? review["comment"]
                      : "Tidak ada komentar",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14),
                ),
              ),

              const SizedBox(height: 24),

              // Close button ----------------------------------------------
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Tutup",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Terjadi kesalahan: $e")),
    );
  }
}


  Future<void> connectSocket() async {
    final token = await getToken();   // FIX TOKEN
    if (token == null) return;

    socket = IO.io(
      "https://kedaiwartiyem.my.id",
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .setAuth({'token': token})
          .build(),
    );

    socket!.on("orderStatusUpdate", (data) async {
      final orderId = data["orderId"];
      final newStatus = data["newStatus"];
      setState(() {
        for (var o in orders) {
          if (o["_id"] == orderId) {
            o["status"] = newStatus;
            o["updatedAt"] = data['updatedAt'] ?? DateTime.now().toIso8601String();
          }
        }
      });

      // optionally re-check review state for the updated order (tidak wajib, tapi aman)
      try {
        final idx = orders.indexWhere((o) => o['_id'] == orderId);
        if (idx != -1) {
          final rev = await fetchReviewForOrder(orderId);
          setState(() {
            orders[idx]['reviewed'] = rev != null;
            if (rev != null) {
              orders[idx]['_userRating'] = rev['rating'];
              orders[idx]['_userComment'] = rev['comment'];
            }
          });
        }
      } catch (_) {}
    });
  }

  Future<void> fetchOrders() async {
    try {
      final token = await getToken();
      final response = await http.get(
        Uri.parse(apiBaseUrl),
        headers: token != null ? {'Authorization': 'Bearer $token'} : {},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<dynamic> loaded = data['data'] ?? [];

        // cek review untuk setiap order secara paralel
        await Future.wait(loaded.map((o) async {
          try {
            final review = await fetchReviewForOrder(o['_id']);
            o['reviewed'] = review != null;
            if (review != null) {
              o['_userRating'] = review['rating'];
              o['_userComment'] = review['comment'];
            }
          } catch (_) {
            o['reviewed'] = false;
          }
        }));

        setState(() {
          orders = loaded;
          isLoading = false;
        });

        // === MASUKKAN ORDER BARU DARI STRUK KE URUTAN PALING ATAS ===
        if (newOrder != null) {
          bool exists = orders.any((o) => o["_id"] == newOrder!["_id"]);
          if (!exists) {
            orders.insert(0, newOrder!);
          }
        }
      } else {
        setState(() {
          errorMessage = 'Gagal memuat data pesanan (${response.statusCode})';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Terjadi kesalahan: $e';
        isLoading = false;
      });
    }
  }

  String formatDateTime(String? iso) {
    if (iso == null || iso.isEmpty) return "-";
    try {
      final dt = DateTime.parse(iso).toLocal();
      return "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} • ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
    } catch (_) {
      return iso;
    }
  }

  String getDisplayDate(Map order) {
    return formatDateTime(order['updatedAt'] ?? order['createdAt']);
  }

  Future<void> beriRating(Map order) async {
  int rating = 0;
  TextEditingController komentarC = TextEditingController();

  await showDialog(
    context: context,
    builder: (_) {
      return StatefulBuilder(builder: (context, setState2) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Beri Rating"),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Wrap(
                  spacing: 4,
                  children: List.generate(5, (i) {
                    final idx = i + 1;
                    return GestureDetector(
                      onTap: () => setState2(() => rating = idx),
                      child: Icon(
                        Icons.star,
                        size: 36,
                        color: idx <= rating ? Colors.orange : Colors.grey.shade400,
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: komentarC,
                  decoration: const InputDecoration(
                    hintText: "Tambahkan komentar...",
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (rating == 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Pilih rating terlebih dahulu!")),
                  );
                  return;
                }

                final token = await getToken();
                // NOTE: do NOT include userId in the body; backend reads it from the token
                final userId = await getUserId();

                  final body = {
                    "userId": userId,
                    "orderId": order["_id"],
                    "rating": rating,
                    "comment": komentarC.text,
                  };

                // Debug prints — copy log output if something fails
                print("DEBUG SEND RATING -> token=${token != null}, orderId=${order['_id']}, rating=$rating");

                try {
                  final res = await http.post(
                    Uri.parse(reviewBaseUrl),
                    headers: {
                      "Content-Type": "application/json",
                      if (token != null) 'Authorization': 'Bearer $token'
                    },
                    body: jsonEncode(body),
                  );

                  print("DEBUG RATING RESPONSE: status=${res.statusCode}, body=${res.body}");

                  if (res.statusCode == 201 || res.statusCode == 200) {
                    final review = await fetchReviewForOrder(order["_id"]);
                      setState(() {
                        order["reviewed"] = true;
                        order["_userRating"] = review?["rating"] ?? rating;
                        order["_userComment"] = review?["comment"] ?? komentarC.text;
                      });

                    Navigator.pop(context);

                    String msg = "Terima kasih atas rating Anda!";
                    try {
                      final j = jsonDecode(res.body);
                      if (j is Map && j["message"] != null) msg = j["message"];
                    } catch (_) {}
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
                  } else if (res.statusCode == 409) {
                    // sudah pernah di-review
                    Navigator.pop(context);
                    setState(() {
                      for (var o in orders) {
                        if (o["_id"] == order["_id"]) {
                          o["reviewed"] = true;
                          break;
                        }
                      }
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Pesanan ini sudah di-rating")));
                  } else {
                    String msg = "Gagal mengirim rating (${res.statusCode})";
                    try {
                      final j = jsonDecode(res.body);
                      if (j is Map && j["message"] != null) msg = j["message"];
                    } catch (_) {}
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
                  }
                } catch (e) {
                  print("ERROR SEND RATING: $e");
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Terjadi kesalahan: $e")));
                }
              },
              child: const Text("Kirim"),
            ),
          ],
        );
      });
    },
  );
}

  void beliLagi(Map order) {
  final cartProvider = Provider.of<CartProvider>(context, listen: false);

  cartProvider.clearCart();

  final items = order["items"] as List<dynamic>? ?? [];

  for (var i in items) {
    final id = i['productId'] ?? i['product']?['_id'] ?? i['_id'] ?? i['id'];
    final name = i['productName'] ?? i['name'] ?? i['product']?['name'] ?? '-';

    final priceRaw = i['price'] ?? i['product']?['price'] ?? i['subTotal'] ?? 0;
    final price = (priceRaw is num) ? priceRaw : double.tryParse('$priceRaw') ?? 0;

    final qtyRaw = i['qty'] ?? i['quantity'] ?? 1;
    final qty = (qtyRaw is int) ? qtyRaw : int.tryParse('$qtyRaw') ?? 1;

    // ===========================
// FIX IMAGE (SIMPLE & AKURAT)
// ===========================
String img = "";

final product = i['product'] ?? {};

img = product['image'] ??
      product['img'] ??
      product['image_url'] ??
      product['imageUrl'] ??
      "";

// fallback kalau item punya langsung
if (img.isEmpty) {
  img = i['image'] ??
        i['img'] ??
        i['image_url'] ??
        i['imageUrl'] ??
        "";
}

// kalau masih kosong, cek array images[]
if (img.isEmpty && product['images'] is List && product['images'].isNotEmpty) {
  img = product['images'][0].toString();
}

if (img.isNotEmpty && !img.startsWith("http")) {
  img = "https://kedaiwartiyem.my.id/$img";
}

    final desc = i['description'] ?? i['product']?['description'] ?? '';

    cartProvider.addItem({
      '_id': id,
      'id': id,
      'name': name,
      'price': price,
      'qty': qty,
      'image': img,   // 🎉 FINAL FIX DI SINI
      'description': desc,
    });
  }

  Navigator.pushNamed(context, "/cart");
}


  @override
  Widget build(BuildContext context) {
     // AMBIL DATA ORDER BARU DARI STRUK
  final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is Map<String, dynamic> && newOrder == null) {
      setState(() {
        newOrder = args;
      });

      // refresh daftar pesanan supaya order baru muncul
      fetchOrders();
    }

    if (isLoading) {
      return const Scaffold(
        body: Center(
            child: CircularProgressIndicator(
          color: Colors.red,
        )),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Riwayat Pesanan")),
        body: Center(child: Text(errorMessage!)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // ⬅️ tombol back DIHAPUS
        backgroundColor: const Color(0xFF800000),
        title: const Text(
          "Riwayat Pesanan",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 4,
      ),

      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, i) {
          final Map<String, dynamic> order = orders[i];

          final items = order["items"] as List<dynamic>? ?? [];
          final pesananText = items.map((it) => it["name"]).join(", ");
          final tanggal = getDisplayDate(order);
          final rawStatus = (order["status"] ?? "").toString().toLowerCase();

          bool isSelesai = rawStatus.contains("selesai");
          bool reviewed = order["reviewed"] == true;

          return _OrderCard(
            tanggal: tanggal,
            pesananText: pesananText,
            payment: order["payment"] ?? "",
            method: order["method"] ?? "",
            totalAmount: order["totalAmount"] ?? 0,
            isSelesai: isSelesai,
            reviewed: reviewed,
            onTapDetail: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => StrukPage(order: order),
                ),
              );
            },
            onBeliLagi: () => beliLagi(order),
            onBeriRating: () async {
              // jika sudah review, tampilkan; jika belum, beri rating
              if (order["reviewed"] == true) {
                await lihatRating(order);
              } else {
                await beriRating(order);
              }
            },
          );
        },
      ),
    );
  }
}

class _OrderCard extends StatefulWidget {
  final String tanggal;
  final String pesananText;
  final String payment;
  final String method;
  final num totalAmount;
  final bool isSelesai;
  final bool reviewed;
  final VoidCallback onTapDetail;
  final VoidCallback onBeliLagi;
  final VoidCallback onBeriRating;

  const _OrderCard({
    required this.tanggal,
    required this.pesananText,
    required this.payment,
    required this.method,
    required this.totalAmount,
    required this.isSelesai,
    required this.reviewed,
    required this.onTapDetail,
    required this.onBeliLagi,
    required this.onBeriRating,
  });

  @override
  State<_OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<_OrderCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final enableBeli = widget.isSelesai;
    final enableRating = widget.isSelesai;
    

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 120),
        scale: _pressed ? 1.02 : 1,
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),

              // BORDER MAROON TIPIS BIAR LEBIH KELIHATAN
              border: Border.all(
                color: const Color(0xFF800000), // maroon
                width: 1.2,
              ),

              // SHADOW DIBIKIN LEBIH DALAM
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(_pressed ? 0.23 : 0.12),
                  blurRadius: _pressed ? 26 : 16,
                  spreadRadius: _pressed ? 2 : 1,
                  offset: const Offset(0, 6),
                ),
              ],
            ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(widget.tanggal,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 13)),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: widget.isSelesai
                          ? Colors.green.withOpacity(0.15)
                          : Colors.blue.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      widget.isSelesai ? "Selesai" : "Diproses",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: widget.isSelesai ? Colors.green : Colors.blue),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 12),
              Text("Pesanan: ${widget.pesananText}"),
              const SizedBox(height: 4),
              Text("Pembayaran: ${widget.payment} | Layanan: ${widget.method}"),
              const SizedBox(height: 12),
              Text(
                "Total: Rp ${widget.totalAmount.toString().replaceAllMapped(RegExp(r'\\B(?=(\\d{3})+(?!\\d))'), (m) => '.')}",
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: widget.onTapDetail,
                child: const Text(
                  "Lihat Detail",
                  style: TextStyle(
                      color: Color(0xFF2ECC71),
                      fontWeight: FontWeight.bold,
                      fontSize: 14),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: enableBeli ? widget.onBeliLagi : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            enableBeli ? const Color(0xFFE74C3C) : Colors.grey,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text("Beli Lagi",
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: enableRating ? widget.onBeriRating : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: enableRating
                            ? const Color(0xFFF5A623)
                            : Colors.grey,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text(
                        widget.reviewed ? "Lihat Rating" : "Beri Rating",
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}