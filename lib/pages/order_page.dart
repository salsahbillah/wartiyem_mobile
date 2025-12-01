import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'struk_page.dart';

class OrderPage extends StatefulWidget {
  final String orderMethod;

  const OrderPage({super.key, required this.orderMethod});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController tableController = TextEditingController();

  bool isLoading = false;

  // Voucher
  List voucherList = [];
  Map<String, dynamic>? voucherApplied;
  bool voucherDropdown = false;
  double discountAmount = 0;

  // Payment
  String paymentMethod = "tunai";

  @override
  void initState() {
    super.initState();
    fetchVouchers();
  }

  // ============================================================
  //                    API GET VOUCHER
  // ============================================================
  Future<void> fetchVouchers() async {
    try {
      final res = await http.get(
        Uri.parse(
          'https://unflamboyant-undepreciable-emilia.ngrok-free.dev/api/vouchers',
        ),
      );

      final data = json.decode(res.body);

      if (data is List) {
        setState(() => voucherList = data);
      } else if (data is Map && data["vouchers"] is List) {
        setState(() => voucherList = data["vouchers"]);
      } else if (data is Map && data["data"] is List) {
        setState(() => voucherList = data["data"]);
      } else {
        debugPrint("Voucher API unexpected: $data");
      }
    } catch (e) {
      debugPrint("Voucher API Exception: $e");
    }
  }

  // ============================================================
  //           APPLY VOUCHER (CALL BACKEND API)
  // ============================================================
  Future<void> applyVoucher(Map<String, dynamic> v, double subtotal) async {
    try {
      final res = await http.post(
        Uri.parse(
            "https://unflamboyant-undepreciable-emilia.ngrok-free.dev/api/vouchers/apply"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "voucherId": v["_id"],
          "subtotal": subtotal,
        }),
      );

      final data = json.decode(res.body);
      debugPrint("VOUCHER APPLY RESPONSE MOBILE: $data");

      if (data["success"] != true) {
        showMsg(data["message"] ?? "Voucher tidak valid");
        return;
      }

      setState(() {
        voucherApplied = data["voucher"];
        discountAmount = (data["discount"] ?? 0).toDouble();
        voucherDropdown = false;
      });

      showMsg("Voucher ${voucherApplied!['name']} berhasil diterapkan");
    } catch (e) {
      debugPrint("Apply Voucher Error: $e");
      showMsg("Voucher gagal diterapkan");
    }
  }

  // ============================================================
  //                     SUBMIT ORDER
  // ============================================================
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
        showMsg("Nomor telepon dan alamat wajib diisi");
        return;
      }
    }

    setState(() => isLoading = true);

    double serviceFee = subtotal * 0.10;
    double deliveryFee = widget.orderMethod == "diantar" ? 3000 : 0;
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
      "payment": paymentMethod,
      "note": noteController.text.trim(),
      "voucherId": voucherApplied?["_id"] ?? "",
      "phone": phoneController.text.trim(),
      "address": addressController.text.trim(),
      "tableNumber": tableController.text.trim(),
    };

    try {
      final res = await http.post(
        Uri.parse(
            "https://unflamboyant-undepreciable-emilia.ngrok-free.dev/api/order/place"),
        headers: {"Content-Type": "application/json"},
        body: json.encode(payload),
      );

      final data = json.decode(res.body);

      if (!mounted) return;

      if (data["success"] == true) {
        Provider.of<CartProvider>(context, listen: false).clearCart();

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => StrukPage(order: data["order"]),
          ),
        );
      } else {
        showMsg(data["message"] ?? "Gagal membuat pesanan");
      }
    } catch (e) {
      showMsg("Terjadi kesalahan");
    }

    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  void showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // ============================================================
  //                           UI
  // ============================================================
  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    double subtotal = cart.subtotal;

    String methodLabel = widget.orderMethod == "makan_di_tempat"
        ? "Informasi Pemesanan (Makan di Tempat)"
        : widget.orderMethod == "bungkus"
            ? "Informasi Pemesanan (Bungkus)"
            : "Informasi Pemesanan (Diantar)";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Padding(
            padding: EdgeInsets.only(left: 8),
            child: Icon(Icons.arrow_back, color: Colors.red, size: 28),
          ),
        ),
        title: const Text(
          "Pesan",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            Text(
              methodLabel,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            buildInput(nameController, "Nama"),

            if (widget.orderMethod == "makan_di_tempat") ...[
              const SizedBox(height: 12),
              buildInput(tableController, "Nomor Meja"),
            ],

            if (widget.orderMethod == "diantar") ...[
              const SizedBox(height: 12),
              buildInput(phoneController, "Nomor Telepon"),
              const SizedBox(height: 12),
              buildInput(addressController, "Alamat Lengkap"),
            ],

            const SizedBox(height: 12),

            buildTextArea(noteController, "Catatan Untuk Pesanan (Opsional)"),

            const SizedBox(height: 25),

            // ================== VOUCHER ===================
            const Text("Voucher Tersedia",
                style: TextStyle(fontWeight: FontWeight.bold)),

            const SizedBox(height: 8),

            buildVoucherDropdown(subtotal),

            if (voucherDropdown) buildVoucherList(subtotal),

            const SizedBox(height: 25),

            // ================== RINGKASAN ===================
            const Text("Ringkasan Pesanan",
                style: TextStyle(fontWeight: FontWeight.bold)),

            const SizedBox(height: 12),

            ...cart.items.map((item) {
              int qty = item['qty'] ?? 1;
              return summaryRow(
                  "${item['name']} x$qty", "Rp ${item['price'] * qty}");
            }),

            summaryRow(
              "Biaya Layanan 10%",
              "Rp ${(subtotal * 0.10).toStringAsFixed(0)}",
            ),

            if (widget.orderMethod == "diantar")
              summaryRow("Ongkir", "Rp 3000"),

            if (voucherApplied != null)
              summaryRow(
                "Diskon (${voucherApplied!['name']})",
                "- Rp ${discountAmount.toStringAsFixed(0)}",
              ),

            const Divider(),
            summaryRow(
              "TOTAL",
              "Rp ${(subtotal + (subtotal * 0.10) + (widget.orderMethod == "diantar" ? 3000 : 0) - discountAmount).toStringAsFixed(0)}",
              bold: true,
            ),

            const SizedBox(height: 25),

            // ================== PEMBAYARAN ===================
            const Text("Pilih Metode Pembayaran",
                style: TextStyle(fontWeight: FontWeight.bold)),

            Row(
              children: [
                Radio(
                  value: "tunai",
                  groupValue: paymentMethod,
                  activeColor: Colors.red,
                  onChanged: (v) =>
                      setState(() => paymentMethod = v.toString()),
                ),
                const Text("Tunai"),
                const SizedBox(width: 20),
                Radio(
                  value: "non_tunai",
                  groupValue: paymentMethod,
                  activeColor: Colors.red,
                  onChanged: (v) =>
                      setState(() => paymentMethod = v.toString()),
                ),
                const Text("Non Tunai"),
              ],
            ),

            const SizedBox(height: 25),

            // ================== BUTTON ===================
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: isLoading
                    ? null
                    : () => submitOrder(subtotal, cart.items),
                child: isLoading
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : const Text(
                        "Pesan",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // WIDGET BUILDER
  // ============================================================
  Widget buildInput(TextEditingController c, String hint) {
    return TextField(
      controller: c,
      decoration: InputDecoration(
        hintText: hint,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }

  Widget buildTextArea(TextEditingController c, String hint) {
    return TextField(
      controller: c,
      maxLines: 3,
      decoration: InputDecoration(
        hintText: hint,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }

  Widget buildVoucherDropdown(double subtotal) {
    return GestureDetector(
      onTap: () => setState(() => voucherDropdown = !voucherDropdown),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            Text(
              voucherApplied != null
                  ? voucherApplied!["name"]
                  : "Pilih Voucher",
            ),
            const Spacer(),
            Icon(voucherDropdown
                ? Icons.keyboard_arrow_up
                : Icons.keyboard_arrow_down),
          ],
        ),
      ),
    );
  }

  Widget buildVoucherList(double subtotal) {
    return Column(
      children: [
        const SizedBox(height: 10),
        for (var v in voucherList)
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.red.shade300),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    "${v['name']}\nMin. Order Rp ${v['minOrder']}",
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => applyVoucher(v, subtotal),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        voucherApplied != null &&
                                voucherApplied!["_id"] == v["_id"]
                            ? Colors.red
                            : Colors.grey,
                    minimumSize: const Size(70, 35),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6)),
                  ),
                  child: Text(
                    voucherApplied != null &&
                            voucherApplied!["_id"] == v["_id"]
                        ? "Dipakai"
                        : "Pakai",
                    style: const TextStyle(color: Colors.white),
                  ),
                )
              ],
            ),
          ),
      ],
    );
  }

  Widget summaryRow(String left, String right, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Text(
            left,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          const Spacer(),
          Text(
            right,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
