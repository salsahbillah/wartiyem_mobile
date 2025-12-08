import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'struk_page.dart';

class PesananPage extends StatefulWidget {
  const PesananPage({super.key});

  @override
  State<PesananPage> createState() => _PesananPageState();
}

class _PesananPageState extends State<PesananPage> {
  List<dynamic> orders = [];
  bool isLoading = true;
  String? errorMessage;

  static const String apiBaseUrl =
      'https://unflamboyant-undepreciable-emilia.ngrok-free.dev/api/order/user';

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      final response = await http.get(
        Uri.parse(apiBaseUrl),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          orders = data['data'];
          isLoading = false;
        });
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

  String formatCurrency(num number) {
    return "Rp ${number.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => '.',
    )}";
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF9F9F9),
        body: Center(child: CircularProgressIndicator(color: Colors.red)),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF9F9F9),
        appBar: AppBar(
          automaticallyImplyLeading: false, // Hapus tombol back
          title: const Text("Riwayat Pesanan"),
          backgroundColor: Colors.white,
          elevation: 1,
        ),
        body: Center(
          child: Text(
            errorMessage!,
            style: const TextStyle(color: Colors.black87),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        automaticallyImplyLeading: false, // Hapus panah kiri
        title: const Text(
          "Riwayat Pesanan",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 1,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          final items = order["items"] as List<dynamic>? ?? [];
          final pesananText = items.map((i) => i["name"]).join(", ");
          final tanggal = order["createdAt"] ?? "";
          String status = (order["status"] ?? "").toLowerCase();

          if (status != "selesai") status = "diproses";

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// =================== HEADER ===================
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        tanggal.replaceAll("T", " • ").substring(0, 16),
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      /// =================== STATUS ===================
                      Text(
                        status == "selesai" ? "Selesai" : "Diproses",
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.blue, // WARNA BIRU
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Text(
                    "Pesanan: $pesananText",
                    style: const TextStyle(fontSize: 14),
                  ),
                  Text(
                    "Pembayaran: ${order["payment"]}   |   Layanan: ${order["method"]}",
                    style: const TextStyle(fontSize: 13),
                  ),

                  const SizedBox(height: 10),

                  /// ======== LIHAT DETAIL PINDAH KE ATAS TOTAL ========
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => StrukPage(order: order),
                        ),
                      );
                    },
                    child: const Text(
                      "Lihat Detail",
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  /// TOTAL
                  Text(
                    "Total: ${formatCurrency(order["totalAmount"])}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 14),

                  /// =================== BUTTONS ===================
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, "/menu");
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            "Beli Lagi",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFF5A623),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            "Beri Rating",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
