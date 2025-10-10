import 'package:flutter/material.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  int quantity = 1;
  int selectedMethod = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.red),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Keranjang',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🧺 Card Produk
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'assets/tes.png',
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 80,
                            height: 80,
                            color: Colors.grey.shade300,
                            child: const Icon(Icons.image_not_supported),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "NASI LIWET AYAM GORENG",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "nasi, ayam,\nlalapan, sambel",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              height: 1.3,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Rp 20.000",
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline,
                                  color: Colors.red),
                              onPressed: () {
                                if (quantity > 1) {
                                  setState(() => quantity--);
                                }
                              },
                            ),
                            Text(
                              '$quantity',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline,
                                  color: Colors.green),
                              onPressed: () {
                                setState(() => quantity++);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 🔘 Pilih Metode Pemesanan
            const Divider(thickness: 1, height: 30),
            const Text(
              "Pilih Metode Pemesanan",
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 10),
            Column(
              children: [
                RadioListTile(
                  title: const Text("Makan di Tempat"),
                  value: 0,
                  groupValue: selectedMethod,
                  activeColor: Colors.red,
                  onChanged: (value) {
                    setState(() {
                      selectedMethod = value!;
                    });
                  },
                ),
                RadioListTile(
                  title: const Text("Bungkus"),
                  value: 1,
                  groupValue: selectedMethod,
                  activeColor: Colors.red,
                  onChanged: (value) {
                    setState(() {
                      selectedMethod = value!;
                    });
                  },
                ),
                RadioListTile(
                  title: const Text("Diantar"),
                  value: 2,
                  groupValue: selectedMethod,
                  activeColor: Colors.red,
                  onChanged: (value) {
                    setState(() {
                      selectedMethod = value!;
                    });
                  },
                ),
              ],
            ),

            const Divider(thickness: 1, height: 30),

            // 💰 Subtotal
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Subtotal",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                Text(
                  "Rp ${(20000 * quantity).toStringAsFixed(0)}",
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 🔴 Tombol Konfirmasi Pesanan
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: selectedMethod == -1
                    ? null
                    : () {
                        Navigator.pushNamed(context, '/order');
                      },
                child: const Text(
                  "Konfirmasi Pesanan",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
