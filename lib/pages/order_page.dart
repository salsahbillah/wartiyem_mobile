import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OrderPage extends StatefulWidget {
  final String orderMethod; // "makan_di_tempat", "bungkus", "diantar"
  const OrderPage({super.key, required this.orderMethod});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController tableController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  bool isLoading = false;

  // ======== Voucher UI States ========
  bool showVoucherDropdown = false;
  bool showAllVouchers = false;
  List voucherList = [];
  Map<String, dynamic>? voucherApplied;
  double discountAmount = 0;

  @override
  void initState() {
    super.initState();
    fetchVouchers();
  }

  Future<void> fetchVouchers() async {
    try {
      final res = await http.get(
        Uri.parse('https://unflamboyant-undepreciable-emilia.ngrok-free.dev/api/voucher'),
      );
      final data = json.decode(res.body);
      setState(() {
        voucherList = data['vouchers'];
      });
    } catch (e) {
      debugPrint('Voucher error: $e');
    }
  }

  void applyVoucher(Map<String, dynamic> v, double subtotal) {
    double disc = 0;
    if (v['type'] == 'percentage') {
      disc = subtotal * (v['value'] / 100);
    } else {
      disc = v['value'].toDouble();
    }

    setState(() {
      voucherApplied = v;
      discountAmount = disc;
      showVoucherDropdown = false;
    });
  }

  Future<void> submitOrder(double subtotal, List items) async {
    if (nameController.text.isEmpty) {
      showMsg("Nama harus diisi");
      return;
    }

    if (widget.orderMethod == "makan_di_tempat" &&
        tableController.text.isEmpty) {
      showMsg("Nomor meja harus diisi");
      return;
    }

    if (widget.orderMethod == "diantar") {
      if (phoneController.text.isEmpty || addressController.text.isEmpty) {
        showMsg("No telepon & alamat wajib diisi");
        return;
      }
    }

    setState(() => isLoading = true);

    // Fee
    double serviceFee = subtotal * 0.10;
    double deliveryFee =
        widget.orderMethod == "diantar" ? 8000 : 0;

    double total = subtotal + serviceFee + deliveryFee - discountAmount;

    Map<String, dynamic> payload = {
      "name": nameController.text.trim(),
      "method": widget.orderMethod,
      "items": items,
      "subtotal": subtotal,
      "service_fee": serviceFee,
      "delivery_fee": deliveryFee,
      "discount": discountAmount,
      "totalAmount": total,
      "payment": "cash",
      "note": noteController.text.trim(),
      "voucherId": voucherApplied?["_id"] ?? "",
      "tableNumber": widget.orderMethod == "makan_di_tempat"
          ? tableController.text.trim()
          : "",
      "phone": widget.orderMethod == "diantar"
          ? phoneController.text.trim()
          : "",
      "address": widget.orderMethod == "diantar"
          ? addressController.text.trim()
          : "",
    };

    try {
      final res = await http.post(
        Uri.parse('https://unflamboyant-undepreciable-emilia.ngrok-free.dev/api/order/place'),
        headers: {"Content-Type": "application/json"},
        body: json.encode(payload),
      );

      final data = json.decode(res.body);

      if (data["success"] == true) {
        if (mounted) {
          Provider.of<CartProvider>(context, listen: false).clearCart();
        }
        showMsg("Pesanan berhasil dibuat!");
      } else {
        showMsg("Gagal membuat pesanan");
      }
    } catch (e) {
      showMsg("Terjadi kesalahan");
    }

    setState(() => isLoading = false);
  }

  void showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    double subtotal = cart.subtotal;

    return Scaffold(
      appBar: AppBar(title: const Text("Buat Pesanan")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            title("Nama Pemesan"),
            inputField(nameController, "Masukkan nama"),

            if (widget.orderMethod == "makan_di_tempat") ...[
              title("Nomor Meja"),
              inputField(tableController, "Meja berapa?"),
            ],

            if (widget.orderMethod == "diantar") ...[
              title("No Telepon"),
              inputField(phoneController, "08xxxx"),
              title("Alamat Lengkap"),
              inputField(addressController, "Masukkan alamat"),
            ],

            title("Catatan"),
            inputField(noteController, "Catatan tambahan (opsional)"),

            const SizedBox(height: 20),
            buildVoucherDropdown(subtotal),

            const SizedBox(height: 20),
            buildSummary(subtotal),

            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () => submitOrder(subtotal, cart.items),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Buat Pesanan"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget title(String s) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, top: 12),
      child: Text(s, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  Widget inputField(TextEditingController c, String hint) {
    return TextField(
      controller: c,
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ========================
  //   VOUCHER UI
  // ========================
  Widget buildVoucherDropdown(double subtotal) {
    List displayed = showAllVouchers
        ? voucherList
        : voucherList.take(4).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        title("Voucher"),

        GestureDetector(
          onTap: () {
            setState(() => showVoucherDropdown = !showVoucherDropdown);
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade400),
            ),
            child: Row(
              children: [
                Text(
                  voucherApplied != null
                      ? voucherApplied!["name"]
                      : "Pilih Voucher",
                ),
                const Spacer(),
                Icon(showVoucherDropdown
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down),
              ],
            ),
          ),
        ),

        if (voucherApplied != null)
          Container(
            margin: const EdgeInsets.only(top: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.green.shade300),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    "${voucherApplied!['name']} - terpasang",
                    style: TextStyle(color: Colors.green.shade800),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      voucherApplied = null;
                      discountAmount = 0;
                    });
                  },
                )
              ],
            ),
          ),

        if (showVoucherDropdown)
          Column(
            children: [
              const SizedBox(height: 10),
              for (var v in displayed)
                GestureDetector(
                  onTap: () => applyVoucher(v, subtotal),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text("${v['name']} - ${v['description']}"),
                        ),
                      ],
                    ),
                  ),
                ),
              if (voucherList.length > 4)
                TextButton(
                  onPressed: () {
                    setState(() {
                      showAllVouchers = !showAllVouchers;
                    });
                  },
                  child:
                      Text(showAllVouchers ? "Lihat lebih sedikit" : "Lihat lainnya"),
                )
            ],
          ),
      ],
    );
  }

  // ========================
  //   SUMMARY
  // ========================
  Widget buildSummary(double subtotal) {
    double serviceFee = subtotal * 0.10;
    double deliveryFee =
        widget.orderMethod == "diantar" ? 8000 : 0;
    double total = subtotal + serviceFee + deliveryFee - discountAmount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        title("Ringkasan Pembayaran"),
        summaryRow("Subtotal", "Rp ${subtotal.toStringAsFixed(0)}"),
        summaryRow("Service Fee (10%)", "Rp ${serviceFee.toStringAsFixed(0)}"),
        if (deliveryFee > 0)
          summaryRow("Delivery Fee", "Rp ${deliveryFee.toStringAsFixed(0)}"),
        if (discountAmount > 0)
          summaryRow("Diskon", "- Rp ${discountAmount.toStringAsFixed(0)}"),
        const Divider(),
        summaryRow("Total", "Rp ${total.toStringAsFixed(0)}",
            isBold: true),
      ],
    );
  }

  Widget summaryRow(String left, String right, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(left,
              style:
                  TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          const Spacer(),
          Text(right,
              style:
                  TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}