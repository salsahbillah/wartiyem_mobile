import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../services/format.dart';
import '../providers/store_provider.dart';


class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  // -1 = belum pilih, 0 = Makan di Tempat, 1 = Bungkus, 2 = Diantar
  int _selectedMethod = -1;

  // BASE URL backend kamu
  final String baseUrl = "https://kedaiwartiyem.my.id/";

  String _methodValueLabel(int v) {
    switch (v) {
      case 0:
        return "makan_di_tempat";
      case 1:
        return "bungkus";
      case 2:
        return "diantar";
      default:
        return "";
    }
  }

  // Build full image URL
  String buildImageUrl(String? image) {
    if (image == null || image.isEmpty) return "";

    // Jika full URL
    if (image.startsWith("http://") || image.startsWith("https://")) {
      return image;
    }

    // Jika relative path
    return "$baseUrl/images/$image";
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final cart = cartProvider.items;

    final isCartEmpty = cart.isEmpty;
    final canConfirm = !isCartEmpty && _selectedMethod != -1;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.red),
        title: const Text(
          'Keranjang',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
        ),
      ),

      body: isCartEmpty
          ? const Center(child: Text("Keranjang masih kosong"))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // =================== ITEM LIST ===================
                  ...cart.asMap().entries.map((entry) {
                    int index = entry.key;
                    var item = entry.value;

                    final double priceDouble = (item['price'] is num)
                        ? (item['price'] as num).toDouble()
                        : double.tryParse('${item['price']}') ?? 0.0;

                    final int qty = (item['qty'] is int)
                        ? item['qty']
                        : int.tryParse('${item['qty']}') ?? 0;

                    final String imgRaw = item['image']?.toString() ?? "";
                    final String imageUrl = buildImageUrl(imgRaw);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 18),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 5,
                          )
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // IMAGE FIXED
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: SizedBox(
                              width: 90,
                              height: 90,
                              child: imageUrl.isNotEmpty
                                  ? Image.network(
                                      imageUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          const Icon(Icons.image_not_supported,
                                              size: 48, color: Colors.grey),
                                    )
                                  : const Icon(Icons.image_not_supported,
                                      size: 48, color: Colors.grey),
                            ),
                          ),

                          const SizedBox(width: 12),

                          // TEXT SECTION
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['name'] ?? '-',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 4),

                                Text(
                                  item['description'] ?? "",
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 12,
                                  ),
                                ),

                                const SizedBox(height: 4),

                                Text(
                                  "Rp ${FormatHelper.price(priceDouble)}",
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 8),

                                // QTY Controls
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        final newQty = qty - 1;
                                        cartProvider.updateQty(index, newQty);
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.red,
                                        ),
                                        child: const Icon(Icons.remove,
                                            size: 16, color: Colors.white),
                                      ),
                                    ),

                                    Padding(
                                      padding:
                                          const EdgeInsets.symmetric(horizontal: 10),
                                      child: Text(
                                        "$qty",
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),

                                    GestureDetector(
                                      onTap: () {
                                        cartProvider.updateQty(index, qty + 1);
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.green,
                                        ),
                                        child: const Icon(Icons.add,
                                            size: 16, color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Delete Button
                          IconButton(
                            onPressed: () {
                              showDialog<bool>(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text('Hapus item'),
                                  content: Text(
                                      'Hapus "${item['name']}" dari keranjang?'),
                                  actions: [
                                    TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: const Text('Batal')),
                                    TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: const Text('Ya')),
                                  ],
                                ),
                              ).then((confirmed) {
                                if (confirmed == true) {
                                  cartProvider.updateQty(index, 0);
                                }
                              });
                            },
                            icon: const Icon(Icons.delete_outline,
                                color: Colors.black54),
                          )
                        ],
                      ),
                    );
                  }),

                  const SizedBox(height: 16),

                  // =================== METODE PEMESANAN ===================
                  Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 6)
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Pilih Metode Pemesanan',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w700),
                        ),

                        RadioListTile<int>(
                          value: 0,
                          groupValue: _selectedMethod,
                          activeColor: Colors.red,
                          title: const Text('Makan di Tempat'),
                          onChanged: (v) =>
                              setState(() => _selectedMethod = v ?? -1),
                        ),

                        RadioListTile<int>(
                          value: 1,
                          groupValue: _selectedMethod,
                          activeColor: Colors.red,
                          title: const Text('Bungkus'),
                          onChanged: (v) =>
                              setState(() => _selectedMethod = v ?? -1),
                        ),

                        RadioListTile<int>(
                          value: 2,
                          groupValue: _selectedMethod,
                          activeColor: Colors.red,
                          title: const Text('Diantar'),
                          onChanged: (v) =>
                              setState(() => _selectedMethod = v ?? -1),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // =================== SUBTOTAL ===================
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Subtotal",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "Rp ${FormatHelper.price(cartProvider.subtotal)}",
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),

      // =================== BUTTON CONFIRM ===================
      bottomNavigationBar: isCartEmpty
          ? null
          : Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      canConfirm ? Colors.red : Colors.grey.shade400,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: canConfirm
                  ? () {
                      final store = context.read<StoreProvider>();

                      if (store.user == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Silakan login dulu")),
                        );
                        return;
                      }

                      Navigator.pushNamed(
                        context,
                        '/order',
                        arguments: {
                          "method": _methodValueLabel(_selectedMethod),
                          "subtotal": cartProvider.subtotal,
                          "items": cartProvider.items,
                        },
                      );
                    }
    : null,
                child: Text(
                  "Konfirmasi Pesanan",
                  style: TextStyle(
                    color: canConfirm ? Colors.white : Colors.white70,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
    );
  }
}
