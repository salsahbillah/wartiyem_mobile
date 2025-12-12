// lib/pages/order/order_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'struk_page.dart';
import 'package:intl/intl.dart';
import '/../providers/store_provider.dart';
import 'midtrans_payment_page.dart'; // <-- pastikan path ini benar (../midtrans_payment_page.dart)

class OrderPage extends StatefulWidget {
  final String? orderMethod;
  const OrderPage({super.key, this.orderMethod});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  // Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController tableController = TextEditingController();

  // State
  bool isLoading = false;

  bool _ensureLoggedIn() {
    final store = Provider.of<StoreProvider>(context, listen: false);

    if (store.token == null || store.token!.isEmpty || store.user == null) {
      showMsg("Silakan login terlebih dahulu");
      return false;
    }
    return true;
  }

  @override
  void dispose() {
    nameController.dispose();
    noteController.dispose();
    phoneController.dispose();
    addressController.dispose();
    tableController.dispose();
    super.dispose();
  }

  // Voucher
  List<Map<String, dynamic>> voucherList = [];
  Map<String, dynamic>? voucherApplied;
  bool voucherDropdown = false;
  double discountAmount = 0.0;

  // Payment & method
  String paymentMethod = ""; // "tunai" or "non_tunai"
  late String orderMethodLocal;

  // route args (optional)
  double? argsSubtotal;
  List? argsItems;
  bool _didReadRouteArgs = false;

  final String vouchersUrl = 'https://kedaiwartiyem.my.id/api/vouchers';
  final String applyVoucherUrl = 'https://kedaiwartiyem.my.id/api/vouchers/apply';
  final String createOrderUrl = 'https://kedaiwartiyem.my.id/api/order';

  final NumberFormat _cur = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    orderMethodLocal = widget.orderMethod ?? "makan_di_tempat";
    fetchVouchers();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didReadRouteArgs) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args != null && args is Map) {
        final m = args["method"];
        if (m is String && m.isNotEmpty) orderMethodLocal = m;
        final s = args["subtotal"];
        if (s != null) {
          try {
            argsSubtotal = (s is num) ? s.toDouble() : double.parse(s.toString());
          } catch (_) {
            argsSubtotal = null;
          }
        }
        final it = args["items"];
        if (it is List) argsItems = it;
      }
      _didReadRouteArgs = true;
    }
  }

  Future<void> fetchVouchers() async {
    try {
      final store = Provider.of<StoreProvider>(context, listen: false);

      final res = await http.get(
        Uri.parse(vouchersUrl),
        headers: store.token != null ? {"Authorization": "Bearer ${store.token}"} : null,
      );
      if (res.statusCode != 200) return;
      final data = json.decode(res.body);
      List parsed = [];
      if (data is List) {
        parsed = data;
      } else if (data is Map) {
        if (data["vouchers"] is List) {
          parsed = data["vouchers"];
        } else if (data["data"] is List) parsed = data["data"];
        else parsed = [data];
      }
      final safeList = parsed.whereType<Map>().map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e)).toList();
      if (mounted) setState(() => voucherList = safeList);
    } catch (e) {
      // ignore fetch errors silently
    }
  }

  bool isVoucherUsable(Map<String, dynamic> v, double subtotal) {
    final now = DateTime.now();
    if (v["startDate"] != null) {
      final start = DateTime.tryParse(v["startDate"].toString());
      if (start != null && now.isBefore(start)) return false;
    }
    if (v["endDate"] != null) {
      final end = DateTime.tryParse(v["endDate"].toString());
      if (end != null && now.isAfter(end)) return false;
    }
    if (subtotal < _voucherMinOrder(v)) return false;
    if (v["sisaHariIni"] != null && v["sisaHariIni"].toString().toLowerCase() != "unlimited") {
      int sisa = int.tryParse(v["sisaHariIni"].toString()) ?? 0;
      if (sisa <= 0) return false;
    }
    return true;
  }

  double _voucherMinOrder(Map<String, dynamic> v) {
    final possibleKeys = [
      'minimumOrder',
      'minOrder',
      'min_order',
      'minPurchase',
      'minimum_order',
      'minimum',
      'minPurchaseValue',
      'min'
    ];
    for (final k in possibleKeys) {
      if (v.containsKey(k) && v[k] != null) {
        try {
          final val = v[k];
          if (val is num) return val.toDouble();
          return double.parse(val.toString());
        } catch (_) {}
      }
    }
    return 0.0;
  }

  String _formatMoney(double value) => _cur.format(value);

  String voucherTitleText(Map<String, dynamic> v) {
    final name = v["nama"] ?? v["title"] ?? "Voucher";
    final type = (v["discountType"] ?? "").toString().toLowerCase();
    final value = v["discountValue"] ?? v["discount"] ?? v["nominal"];
    if (type == "percent" && value != null) return "DISKON $name ${value.toString()}%";
    if (value != null) {
      final parsed = double.tryParse(value.toString());
      if (parsed != null) return "DISKON $name ${_formatMoney(parsed)}";
    }
    return "DISKON $name";
  }

  String voucherTypeText(Map<String, dynamic> v) {
    final type = (v["discountType"] ?? "").toString().toLowerCase();
    final value = v["discountValue"] ?? v["discount"] ?? v["nominal"];
    if (type == "percent" && value != null) return "${value.toString()}%";
    if (value != null) {
      final parsed = double.tryParse(value.toString());
      if (parsed != null) return _formatMoney(parsed);
    }
    return "";
  }

  Future<void> applyVoucher(Map<String, dynamic> v, double subtotal) async {
    if (!_ensureLoggedIn()) return;

    final store = Provider.of<StoreProvider>(context, listen: false);
    final token = store.token!;

    final voucherId = v["_id"] ?? v["id"] ?? v["voucherId"];
    if (voucherId == null) {
      showMsg("Voucher tidak valid.");
      return;
    }

    final body = json.encode({
      "voucherId": voucherId,
      "subtotal": subtotal,
    });

    try {
      final res = await http.post(
        Uri.parse(applyVoucherUrl),
        headers: {"Content-Type": "application/json", "Authorization": "Bearer $token"},
        body: body,
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        final data = json.decode(res.body);
        double discount = 0;
        if (data["discount"] != null) discount = (data["discount"] as num).toDouble();

        if (mounted) {
          setState(() {
            voucherApplied = Map<String, dynamic>.from(v);
            discountAmount = discount;
            voucherDropdown = false;
          });
        }
        showMsg("Voucher berhasil diterapkan! Diskon: ${_formatMoney(discountAmount)}");
      } else {
        String msg = "Gagal menerapkan voucher.";
        try {
          final data = json.decode(res.body);
          if (data is Map && data["message"] != null) msg = data["message"];
        } catch (_) {}
        showMsg(msg);
      }
    } catch (e) {
      showMsg("Terjadi kesalahan. Silakan coba lagi.");
    }
  }

  String _generateOrderCode() {
    final now = DateTime.now();
    return "KW-${now.millisecondsSinceEpoch}";
  }

  Map<String, dynamic> buildPayload(BuildContext context, double subtotal, double totalAmount) {
    final cart = Provider.of<CartProvider>(context, listen: false);
    final cartItems = argsItems ?? cart.items;

    String methodBackend = "Makan di Tempat";
    if (orderMethodLocal == "bungkus") methodBackend = "Bungkus";
    if (orderMethodLocal == "diantar") methodBackend = "Diantar";
    String paymentBackend = paymentMethod == "tunai" ? "Tunai" : "Non-Tunai";

    final items = cartItems.map((item) {
      final idVal = item["_id"] ?? item["id"] ?? item["foodId"];
      final qtyVal = item["qty"] ?? item["quantity"] ?? 1;
      final priceVal = item["price"] is num ? item["price"] : double.tryParse('${item["price"]}') ?? 0;
      return {
        "_id": idVal.toString(),
        "name": item["name"] ?? "",
        "quantity": (qtyVal is num) ? qtyVal : int.tryParse(qtyVal.toString()) ?? 1,
        "price": (priceVal is num) ? priceVal : double.tryParse(priceVal.toString()) ?? 0,
      };
    }).toList();

    return {
      "name": nameController.text.trim(),
      "tableNumber": methodBackend == "Makan di Tempat" ? (int.tryParse(tableController.text.trim())) : null,
      "phone": methodBackend == "Diantar" ? phoneController.text.trim() : null,
      "address": methodBackend == "Diantar" ? addressController.text.trim() : null,
      "note": noteController.text.trim(),
      "payment": paymentBackend,
      "method": methodBackend,
      "items": items,
      "subtotal": subtotal,
      "serviceFee": (subtotal * 0.10).roundToDouble(),
      "deliveryFee": (orderMethodLocal == "diantar") ? 10000.0 : 0.0,
      "discount": discountAmount,
      "voucherId": voucherApplied != null ? (voucherApplied!["_id"] ?? voucherApplied!["id"]) : null,
      "voucherType": voucherApplied != null ? voucherTypeText(voucherApplied!) : null,
      "totalAmount": totalAmount,
      "localOrderCode": _generateOrderCode(),
    };
  }

  Future<void> submitOrder(double subtotal, List items) async {
    // Validasi input
    if (nameController.text.isEmpty) return showMsg("Nama harus diisi");
    if (orderMethodLocal == "makan_di_tempat" && tableController.text.isEmpty) {
      return showMsg("Nomor meja harus diisi");
    }
    if (orderMethodLocal == "diantar" && (phoneController.text.isEmpty || addressController.text.isEmpty)) {
      return showMsg("Nomor telepon dan alamat wajib diisi");
    }
    if (paymentMethod.isEmpty) return showMsg("Pilih metode pembayaran terlebih dahulu");

    setState(() => isLoading = true);

    final cart = Provider.of<CartProvider>(context, listen: false);
    final double subtotalCalc = argsSubtotal ?? cart.subtotal;
    final double serviceFee = (subtotalCalc * 0.10).roundToDouble();
    final double deliveryFee = (orderMethodLocal == "diantar") ? 10000.0 : 0.0;
    double total = subtotalCalc + serviceFee + deliveryFee - discountAmount;
    if (total < 0) total = 0;

    Map<String, dynamic> payload = buildPayload(context, subtotalCalc, total);

    try {
      final store = Provider.of<StoreProvider>(context, listen: false);
      final token = store.token!;

      final res = await http.post(
        Uri.parse(createOrderUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode(payload),
      );

      final data = json.decode(res.body);
      if (!mounted) return;

      if (res.statusCode == 200 || res.statusCode == 201) {
        if (data["success"] == true) {
          // clear cart locally (you already did in original flow)
          Provider.of<CartProvider>(context, listen: false).clearCart();

          final returnedOrder = data["order"] ?? {};

          final mergedOrder = {
            ...Map<String, dynamic>.from(returnedOrder),
            "subtotal": payload["subtotal"],
            "serviceFee": payload["serviceFee"],
            "deliveryFee": payload["deliveryFee"],
            "discount": payload["discount"],
            "voucherId": payload["voucherId"],
            "voucherType": payload["voucherType"],
            "totalAmount": payload["totalAmount"],
            "localOrderCode": payload["localOrderCode"],
          };

          // NOTE: ambil redirect_url dari backend
          final redirectUrl = data["redirect_url"];

          // NON TUNAI → buka WebView Midtrans
          if (payload["payment"] == "Non-Tunai" && redirectUrl != null) {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MidtransPaymentPage(redirectUrl: redirectUrl),
              ),
            );

            // === HANDLE BALIKAN DARI WEBVIEW ===
            if (result == "open_receipt") {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => StrukPage(order: mergedOrder),
                ),
              );
            }

            if (result == "open_history") {
              Navigator.pushNamedAndRemoveUntil(
                context,
                "/pesanan",  // halaman riwayat pesanan mobile
                (route) => false,
              );
            }

            return; // STOP supaya tidak lanjut ke tunai
          }
          else {
            // pembayaran tunai → langsung ke struk
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => StrukPage(order: mergedOrder),
              ),
            );
          }
        } else {
          showMsg(data["message"] ?? "Gagal membuat pesanan");
        }
      } else {
        String err = data["message"] ?? "Gagal membuat pesanan (server error)";
        showMsg(err);
      }
    } catch (e) {
      showMsg("Terjadi kesalahan saat submit");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void showMsg(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Widget buildInput(TextEditingController c, String hint) {
    return TextField(
      controller: c,
      decoration: InputDecoration(
        hintText: hint,
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
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
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }

  Widget buildVoucherDropdown(double subtotal) {
    final title = voucherApplied != null ? voucherTitleText(voucherApplied!) : "Pilih Voucher";

    return GestureDetector(
      onTap: () => setState(() => voucherDropdown = !voucherDropdown),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: voucherApplied != null ? const Color.fromARGB(160, 88, 255, 116) : Colors.white,
          border: Border.all(color: Colors.red, width: 1.6),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color.fromARGB(221, 0, 0, 0),
                ),
              ),
            ),
            Icon(
              voucherDropdown ? Icons.expand_less : Icons.expand_more,
              color: Colors.red,
              size: 26,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildVoucherList(double subtotal) {
    const int initialCount = 3;
    bool showAll = false;

    return StatefulBuilder(
      builder: (context, setStateSB) {
        final visibleVouchers = showAll ? voucherList : voucherList.take(initialCount).toList();

        return Column(
          children: [
            ...visibleVouchers.map<Widget>((v) {
              bool bisaPakai = isVoucherUsable(v, subtotal);
              bool isApplied = (voucherApplied?["_id"] ?? voucherApplied?["id"]) == (v["_id"] ?? v["id"]);

              return Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isApplied ? const Color.fromARGB(160, 88, 255, 116) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: bisaPakai ? Colors.grey.shade300 : Colors.grey.shade400,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: bisaPakai ? Colors.red.shade300 : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Icon(
                        Icons.local_offer,
                        color: bisaPakai ? Colors.red.shade800 : Colors.grey.shade600,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            voucherTitleText(v),
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: bisaPakai ? Colors.black87 : Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Min. Pembelian ${_formatMoney(_voucherMinOrder(v))}",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          if (v["endDate"] != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              "Berlaku hingga ${DateFormat("dd.MM.yyyy").format(DateTime.parse(v["endDate"]))}",
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (!isApplied)
                      SizedBox(
                        width: 90,
                        child: ElevatedButton(
                          onPressed: bisaPakai
                              ? () async {
                                  await applyVoucher(v, subtotal);
                                  setStateSB(() {});
                                  setState(() {});
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: bisaPakai ? Colors.red.shade600 : Colors.grey,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text("Pakai", style: TextStyle(fontSize: 14)),
                        ),
                      ),
                  ],
                ),
              );
            }),
            if (voucherList.length > initialCount)
              TextButton(
                onPressed: () {
                  setStateSB(() {
                    showAll = !showAll;
                  });
                },
                child: Text(
                  showAll ? "Lihat Lebih Sedikit" : "Lihat Lainnya",
                  style: const TextStyle(color: Colors.red),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget summaryRow(String left, String right, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Text(left, style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
          const Spacer(),
          Text(right, style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }

  // Handle place order (tunai vs non_tunai)
  Future<void> handlePlaceOrder(double subtotal, List items) async {
    if (!_ensureLoggedIn()) return;

    if (paymentMethod.isEmpty) {
      return showMsg("Pilih metode pembayaran terlebih dahulu");
    }

    if (paymentMethod == "tunai") {
      await submitOrder(subtotal, items);
      return;
    }

    // non tunai -> open Midtrans flow
    if (paymentMethod == "non_tunai") {
      final cart = Provider.of<CartProvider>(context, listen: false);
      final double subtotalCalc = argsSubtotal ?? cart.subtotal;
      final double serviceFee = (subtotalCalc * 0.10).roundToDouble();
      final double deliveryFee = (orderMethodLocal == "diantar") ? 10000.0 : 0.0;
      double total = subtotalCalc + serviceFee + deliveryFee - discountAmount;
      if (total < 0) total = 0;

      final payload = buildPayload(context, subtotalCalc, total);

      // Instead of simulation page, call submitOrder which will open WebView when backend returns redirect_url
      setState(() => isLoading = true);
      await submitOrder(subtotal, items);
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    double subtotal = argsSubtotal ?? cart.subtotal;
    List items = argsItems ?? cart.items;

    double serviceFee = subtotal * 0.10;
    double deliveryFee = orderMethodLocal == "diantar" ? 10000 : 0;
    double total = subtotal + serviceFee + deliveryFee - discountAmount;
    if (total < 0) total = 0;

    String methodLabel = orderMethodLocal == "makan_di_tempat"
        ? "Informasi Pemesanan (Makan di Tempat)"
        : orderMethodLocal == "bungkus"
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
            Text(methodLabel, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            buildInput(nameController, "Nama"),
            if (orderMethodLocal == "makan_di_tempat") ...[
              const SizedBox(height: 12),
              buildInput(tableController, "Nomor Meja"),
            ],
            if (orderMethodLocal == "diantar") ...[
              const SizedBox(height: 12),
              buildInput(phoneController, "Nomor Telepon"),
              const SizedBox(height: 12),
              buildInput(addressController, "Alamat Lengkap"),
            ],
            const SizedBox(height: 12),
            buildTextArea(noteController, "Catatan Untuk Pesanan (Opsional)"),
            const SizedBox(height: 25),
            const Text("Voucher Tersedia", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            buildVoucherDropdown(subtotal),
            if (voucherDropdown) ...[
              buildVoucherList(subtotal),
            ],
            const SizedBox(height: 25),
            const Text("Ringkasan Pesanan", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...items.map((item) {
              int qty = (item['qty'] is int) ? item['qty'] : int.tryParse('${item['qty']}') ?? 1;
              final price = (item['price'] is num) ? (item['price'] as num).toDouble() : double.tryParse('${item['price']}') ?? 0;

              return summaryRow("${item['name']} x$qty", _formatMoney(price * qty));
            }),
            if (orderMethodLocal == "diantar")
              summaryRow("Ongkos Kirim", _formatMoney(deliveryFee)),
            summaryRow("Biaya Layanan 10%", _formatMoney(serviceFee)),
            if (discountAmount > 0)
              summaryRow(
                  "Voucher Diskon ${voucherApplied != null ? voucherTypeText(voucherApplied!) : ''}",
                  "-${_formatMoney(discountAmount)}"),
            const Divider(thickness: 1, color: Colors.grey),
            summaryRow("Total", _formatMoney(total), bold: true),
            const SizedBox(height: 30),
            const Text("Pilih Metode Pembayaran", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() {
                      paymentMethod = "tunai";
                    }),
                    child: Row(
                      children: [
                        Radio<String>(
                          value: "tunai",
                          groupValue: paymentMethod,
                          onChanged: (v) => setState(() {
                            paymentMethod = v ?? "";
                          }),
                        ),
                        const SizedBox(width: 6),
                        const Text("Tunai"),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() {
                      paymentMethod = "non_tunai";
                    }),
                    child: Row(
                      children: [
                        Radio<String>(
                          value: "non_tunai",
                          groupValue: paymentMethod,
                          onChanged: (v) => setState(() {
                            paymentMethod = v ?? "";
                          }),
                        ),
                        const SizedBox(width: 6),
                        const Text("Non Tunai"),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: isLoading ? null : () => handlePlaceOrder(subtotal, items),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                child: Text(isLoading ? "Memproses..." : "Pesan Sekarang"),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
