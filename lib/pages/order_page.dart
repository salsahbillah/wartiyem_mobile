import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'struk_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

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

  bool isLoading = false;

  // Voucher
  List<Map<String, dynamic>> voucherList = [];
  Map<String, dynamic>? voucherApplied;
  bool voucherDropdown = false;
  double discountAmount = 0;

  // Payment
  String paymentMethod = "tunai";

  // Local derived values (read from widget or route arguments)
  late String orderMethodLocal; // "makan_di_tempat" | "bungkus" | "diantar"
  double? argsSubtotal;
  List? argsItems;

  bool _didReadRouteArgs = false;

  // API endpoints
  final String vouchersUrl =
      'https://unflamboyant-undepreciable-emilia.ngrok-free.dev/api/vouchers';
  final String applyVoucherUrl =
      'https://unflamboyant-undepreciable-emilia.ngrok-free.dev/api/vouchers/apply';

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
        if (m is String && m.isNotEmpty) {
          orderMethodLocal = m;
        }
        final s = args["subtotal"];
        if (s != null) {
          try {
            argsSubtotal =
                (s is num) ? s.toDouble() : double.parse(s.toString());
          } catch (_) {
            argsSubtotal = null;
          }
        }
        final it = args["items"];
        if (it is List) {
          argsItems = it;
        }
      }
      _didReadRouteArgs = true;
    }
  }

  // ============================================================
  // API GET VOUCHER
  // ============================================================
  Future<void> fetchVouchers() async {
    try {
      final res = await http.get(Uri.parse(vouchersUrl));
      if (res.statusCode != 200) {
        debugPrint('Voucher GET HTTP ${res.statusCode}: ${res.body}');
        return;
      }
      final data = json.decode(res.body);

      List parsed = [];

      if (data is List) {
        parsed = data;
      } else if (data is Map) {
        if (data["vouchers"] is List) {
          parsed = data["vouchers"];
        } else if (data["data"] is List) {
          parsed = data["data"];
        } else if (data["results"] is List) {
          parsed = data["results"];
        } else {
          parsed = [data];
        }
      } else {
        debugPrint("Voucher API unexpected type: ${data.runtimeType}");
      }

      final safeList = parsed
          .where((e) => e is Map)
          .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
          .toList();

      setState(() => voucherList = safeList);
      debugPrint("Voucher fetched: ${voucherList.length}");
    } catch (e) {
      debugPrint("Voucher API Exception: $e");
    }
  }

  // Helper: dapatkan title voucher
  String _voucherTitle(Map<String, dynamic> v) {
    return (v['title'] ?? v['name'] ?? v['nama'] ?? v['label'] ?? '-').toString();
  }

  // Helper: minimal order
  double _voucherMinOrder(Map<String, dynamic> v) {
    final possibleKeys = ['minimumOrder', 'minOrder', 'min_order', 'minPurchase', 'minimum_order', 'minimum'];
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

  // Helper: safe ambil id
  String _voucherId(Map<String, dynamic> v) {
    return (v['_id'] ?? v['id'] ?? v['voucherId'] ?? '').toString();
  }

  String _formatMoney(double value) => _cur.format(value);

  // ============================================================
  // APPLY VOUCHER (CALL BACKEND API) — robust parsing
  // ============================================================
  Future<void> applyVoucher(Map<String, dynamic> v, double subtotal) async {
    final minOrder = _voucherMinOrder(v);
    if (subtotal < minOrder) {
      showMsg("Voucher ini membutuhkan minimal order ${_formatMoney(minOrder)}");
      return;
    }

    final vid = _voucherId(v);
    if (vid.isEmpty) {
      showMsg("Voucher tidak memiliki ID yang valid");
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");
      if (token == null || token.isEmpty) {
        showMsg("Token tidak ditemukan");
        return;
      }

      final body = json.encode({
        "voucherId": vid,
        "orderTotal": subtotal,
      });

      final res = await http.post(
        Uri.parse(applyVoucherUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: body,
      );

      debugPrint("Apply voucher HTTP ${res.statusCode}: ${res.body}");

      if (res.statusCode != 200 && res.statusCode != 201) {
        final decoded = (res.body.isNotEmpty) ? json.decode(res.body) : null;
        final msg = decoded is Map
            ? (decoded['message'] ?? decoded['error'] ?? 'Gagal apply voucher')
            : 'Gagal apply voucher';
        showMsg(msg);
        return;
      }

      final data = json.decode(res.body);

      final success =
          (data['success'] == true) || (data['ok'] == true) || (data['discount'] != null) || (data['discountAmount'] != null);

      if (!success) {
        showMsg(data['message'] ?? "Voucher tidak valid");
        return;
      }

      // Compute discount robustly
      double discount = 0;
      try {
        // Common numeric fields
        final possibleAmountKeys = ['discount', 'discountAmount', 'discount_value', 'amount', 'value', 'nominal'];
        bool found = false;
        for (final k in possibleAmountKeys) {
          if (data[k] != null) {
            final raw = data[k];
            if (raw is num) {
              discount = raw.toDouble();
              found = true;
              break;
            } else {
              discount = double.tryParse(raw.toString()) ?? discount;
              found = true;
              break;
            }
          }
        }

        // If not found, maybe backend returned percentage
        if (!found) {
          final possiblePercentKeys = ['percent', 'percentage', 'discountPercent', 'discount_percentage'];
          for (final k in possiblePercentKeys) {
            if (data[k] != null) {
              final raw = data[k];
              double pct = (raw is num) ? raw.toDouble() : (double.tryParse(raw.toString()) ?? 0);
              discount = subtotal * (pct / 100.0);
              found = true;
              break;
            }
          }
        }

        // As fallback, try data['voucher'] object fields
        if (!found && data['voucher'] is Map) {
          final voucherObj = Map<String, dynamic>.from(data['voucher']);
          for (final k in possibleAmountKeys) {
            if (voucherObj[k] != null) {
              final raw = voucherObj[k];
              if (raw is num) {
                discount = raw.toDouble();
                found = true;
                break;
              } else {
                discount = double.tryParse(raw.toString()) ?? discount;
                found = true;
                break;
              }
            }
          }
          if (!found) {
            for (final k in ['percent', 'percentage']) {
              if (voucherObj[k] != null) {
                final raw = voucherObj[k];
                double pct = (raw is num) ? raw.toDouble() : (double.tryParse(raw.toString()) ?? 0);
                discount = subtotal * (pct / 100.0);
                found = true;
                break;
              }
            }
          }
        }
      } catch (e) {
        debugPrint("Parse discount error: $e");
        discount = 0;
      }

      // Get voucher applied detail (prefer returned voucher object)
      Map<String, dynamic>? applied;
      if (data['voucher'] is Map) {
        applied = Map<String, dynamic>.from(data['voucher']);
      } else {
        applied = Map<String, dynamic>.from(v);
      }

      setState(() {
        voucherApplied = applied;
        discountAmount = discount;
        voucherDropdown = false;
      });

      final title = _voucherTitle(voucherApplied!);
      showMsg("Voucher $title berhasil diterapkan; diskon ${_formatMoney(discountAmount)}");
    } catch (e) {
      debugPrint("Apply Voucher Error: $e");
      showMsg("Voucher gagal diterapkan");
    }
  }

  // ============================================================
  // SUBMIT ORDER
  // ============================================================
  Future<void> submitOrder(double subtotal, List items) async {
    if (nameController.text.isEmpty) {
      showMsg("Nama harus diisi");
      return;
    }
    if (orderMethodLocal == "makan_di_tempat" && tableController.text.isEmpty) {
      showMsg("Nomor meja harus diisi");
      return;
    }
    if (orderMethodLocal == "diantar") {
      if (phoneController.text.isEmpty || addressController.text.isEmpty) {
        showMsg("Nomor telepon dan alamat wajib diisi");
        return;
      }
    }

    setState(() => isLoading = true);

    double serviceFee = subtotal * 0.10;
    double deliveryFee = orderMethodLocal == "diantar" ? 3000 : 0;
    double total = subtotal + serviceFee + deliveryFee - discountAmount;
    if (total < 0) total = 0;

    Map<String, dynamic> payload = {
      "name": nameController.text.trim(),
      "method": orderMethodLocal,
      "items": items,
      "subtotal": subtotal,
      "service_fee": serviceFee,
      "delivery_fee": deliveryFee,
      "discount": discountAmount,
      "totalAmount": total,
      "payment": paymentMethod,
      "note": noteController.text.trim(),
      "voucherId": voucherApplied?["_id"] ?? voucherApplied?['id'] ?? voucherApplied?['voucherId'] ?? "",
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
      debugPrint("Submit order error: $e");
      showMsg("Terjadi kesalahan saat submit");
    }

    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  void showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // ============================================================
  // UI
  // ============================================================
  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    double subtotal = argsSubtotal ?? cart.subtotal;
    List items = argsItems ?? cart.items;

    double serviceFee = subtotal * 0.10;
    double deliveryFee = orderMethodLocal == "diantar" ? 3000 : 0;
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
            Text(
              methodLabel,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
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

            // Items
            ...items.map((item) {
              int qty = (item['qty'] is int) ? item['qty'] as int : int.tryParse('${item['qty']}') ?? 1;
              final price = (item['price'] is num)
                  ? (item['price'] as num).toDouble()
                  : double.tryParse('${item['price']}') ?? 0.0;
              final totalItemPrice = (price * qty);
              return summaryRow("${item['name']} x$qty", _formatMoney(totalItemPrice));
            }),

            summaryRow(
              "Biaya Layanan 10%",
              _formatMoney(serviceFee),
            ),

            if (orderMethodLocal == "diantar")
              summaryRow("Ongkir", _formatMoney(deliveryFee)),

            // Diskon (jika ada)
            if (voucherApplied != null)
              summaryRow(
                "Diskon (${_voucherTitle(voucherApplied!)})",
                "- ${_formatMoney(discountAmount)}",
              ),

            const Divider(),
            summaryRow(
              "TOTAL",
              _formatMoney(total),
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
                  onChanged: (v) => setState(() => paymentMethod = v.toString()),
                ),
                const Text("Tunai"),
                const SizedBox(width: 20),
                Radio(
                  value: "non_tunai",
                  groupValue: paymentMethod,
                  activeColor: Colors.red,
                  onChanged: (v) => setState(() => paymentMethod = v.toString()),
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
                onPressed: isLoading ? null : () => submitOrder(subtotal, items),
                child: isLoading
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : const Text(
                        "Pesan",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
    final title = voucherApplied != null ? _voucherTitle(voucherApplied!) : "Pilih Voucher";
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
            Expanded(
              child: Row(
                children: [
                  Text(title),
                  const SizedBox(width: 8),
                  if (voucherApplied != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green.shade700),
                      ),
                      child: Row(
                        children: [
                          Text("Dipakai", style: TextStyle(color: Colors.green.shade700, fontSize: 12)),
                          const SizedBox(width: 6),
                          const Icon(Icons.check_box, size: 16, color: Colors.green),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            Icon(voucherDropdown ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down),
          ],
        ),
      ),
    );
  }

  Widget buildVoucherList(double subtotal) {
    return Column(
      children: [
        const SizedBox(height: 10),
        if (voucherList.isEmpty)
          Container(
            padding: const EdgeInsets.all(12),
            alignment: Alignment.centerLeft,
            child: const Text("Tidak ada voucher tersedia"),
          ),
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
                    "${_voucherTitle(v)}\nMin. Order ${_formatMoney(_voucherMinOrder(v))}",
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
                const SizedBox(width: 8),
                if (voucherApplied != null && _voucherId(voucherApplied!) == _voucherId(v))
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.green.shade700),
                    ),
                    child: Row(
                      children: [
                        Text("Dipakai", style: TextStyle(color: Colors.green.shade700)),
                        const SizedBox(width: 6),
                        const Icon(Icons.check_circle, color: Colors.green, size: 18),
                      ],
                    ),
                  )
                else
                  ElevatedButton(
                    onPressed: subtotal < _voucherMinOrder(v)
                        ? null
                        : () => applyVoucher(v, subtotal),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: subtotal < _voucherMinOrder(v) ? Colors.grey : Colors.red,
                      minimumSize: const Size(70, 35),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    child: Text(
                      subtotal < _voucherMinOrder(v) ? "Tidak bisa" : "Pakai",
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
