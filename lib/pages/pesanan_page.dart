import 'package:flutter/material.dart';
import 'struk_page.dart';

class PesananPage extends StatelessWidget {
  const PesananPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> orders = [
      {
        "tanggal": "25/09/2025 • 20:13",
        "pesanan": "AYAM x3",
        "pembayaran": "Tunai",
        "layanan": "Bungkus",
        "total": "Rp 66.000",
        "status": "Selesai"
      },
      {
        "tanggal": "25/09/2025 • 19:50",
        "pesanan": "NAILONG",
        "pembayaran": "Tunai",
        "layanan": "Bungkus",
        "total": "Rp 27.500",
        "status": "Menunggu Konfirmasi"
      },
      {
        "tanggal": "25/09/2025 • 20:13",
        "pesanan": "AYAM x3",
        "pembayaran": "Tunai",
        "layanan": "Bungkus",
        "total": "Rp 66.000",
        "status": "Selesai"
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        title: const Text(
          "Riwayat Pesanan",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
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
                  Text(
                    order["tanggal"],
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(color: Colors.black, fontSize: 14),
                      children: [
                        const TextSpan(
                          text: "Pesanan: ",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: order["pesanan"]),
                      ],
                    ),
                  ),
                  Text(
                    "Pembayaran: ${order["pembayaran"]}   |   Layanan: ${order["layanan"]}",
                    style: const TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Total: ${order["total"]}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),

                  if (order["status"] == "Menunggu Konfirmasi") ...[
                    const Row(
                      children: [
                        Icon(Icons.info_outline, size: 16, color: Colors.grey),
                        SizedBox(width: 4),
                        Text(
                          "Menunggu Konfirmasi",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],

                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // ✅ Kirim data order ke StrukPage
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const StrukPage(), // ✅ ini aman buat UI dulu
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[800],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          child: const Text(
                            "Lihat Detail",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          child: const Text(
                            "Beri Rating",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
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
