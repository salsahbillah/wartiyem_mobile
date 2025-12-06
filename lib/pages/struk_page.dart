import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../services/struk_pdf.dart';

class StrukPage extends StatelessWidget {
  final Map<String, dynamic> order;

  StrukPage({super.key, required this.order});

  final NumberFormat _cur =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  double _toDouble(dynamic v) {
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final name = order["name"] ?? "-";
    final method = order["method"] ?? "-";
    final payment = order["payment"] ?? "-";
    final voucherType = order["voucherType"]?.toString() ?? "";
    final discount = _toDouble(order["discount"] ?? 0);

    final List items = order["items"] is List
        ? order["items"]
        : (order["items"]?["items"] ?? []);

    // === HITUNG SUBTOTAL ===
    final double subtotal = items.fold<double>(0, (sum, item) {
      final qty = _toDouble(item["quantity"] ?? item["qty"] ?? 1);
      final price = _toDouble(item["price"]);
      return sum + (qty * price);
    });

    final double serviceFee = subtotal * 0.10;
    final double deliveryFee = _toDouble(order["deliveryFee"]);
    final double total = subtotal + serviceFee + deliveryFee - discount;
    final code = order["orderCode"] ?? _generateOrderCode();
    final now = DateTime.now();
    final date = DateFormat('dd-MM-yyyy').format(now);
    final time = DateFormat('HH:mm').format(now);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 65),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              Center(
                child: Column(
                  children: [
                    Text(
                      "KEDAI WARTIYEM",
                      style: GoogleFonts.montserrat(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Jl. Ampera No.57, Rt/Rw 002/023 Bulak,\n"
                      "Kec. Jatibarang, Kabupaten Indramayu,\n"
                      "Jawa Barat 45273\n"
                      "No.Telp: 0813955878510",
                      style: GoogleFonts.montserrat(
                        fontSize: 11.3,
                        height: 1.28,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),
              _divider(),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(date, style: _reg(12)),
                  Text("$time WIB", style: _reg(12)),
                ],
              ),

              const SizedBox(height: 3),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Kode Pesanan", style: _reg(12)),
                  Text(code, style: _reg(12)),
                ],
              ),

              const SizedBox(height: 12),
              _divider(),

              Text(
                name,
                style: GoogleFonts.montserrat(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 10),

              // ITEM LIST
              ...items.map((it) {
                final qty = it["qty"] ?? it["quantity"] ?? 1;
                final price = _toDouble(it["price"]);
                final itemName = it["name"] ?? "Item";

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          itemName.toString().toUpperCase(),
                          style: GoogleFonts.montserrat(
                            fontSize: 13.2,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Text("${qty}x", style: _bold(13)),
                      const SizedBox(width: 8),
                      Text(_cur.format(price * qty), style: _bold(13)),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 6),
              _divider(),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Total QTY :", style: _reg(13)),
                  Text(
                    "${items.fold<int>(0, (a, b) {
                      final qty = b["qty"] ?? b["quantity"] ?? 1;
                      return a + int.parse(qty.toString());
                    })}",
                    style: _reg(13),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              _priceRow("Subtotal", subtotal),

              // === VOUCHER DISKON DI SINI (di atas biaya layanan) ===
              if (discount > 0)
                _priceRow(
                  "Voucher Diskon ${voucherType != "" ? "($voucherType)" : ""}",
                  -discount,
                  color: Colors.green,
                ),

              _priceRow("Biaya Layanan (10%)", serviceFee),

              if (deliveryFee > 0) _priceRow("Ongkos Kirim", deliveryFee),

              const SizedBox(height: 8),
              _divider(),

              _priceRow("TOTAL", total, bold: true, big: true),

              const SizedBox(height: 16),

              _priceRow("Metode Pemesanan", method, isCurrency: false),
              _priceRow(payment, total),

              const SizedBox(height: 20),

              Center(
                child: Text(
                  "Terima kasih atas transaksi Anda",
                  style: GoogleFonts.montserrat(
                    fontStyle: FontStyle.italic,
                    fontSize: 12,
                  ),
                ),
              ),

              const SizedBox(height: 26),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.download, color: Colors.white),
                      style: _btn,
                      onPressed: () async {
                          final Map<String, dynamic> fixedOrder = {
                            ...order,
                            "orderCode": code, // paksa kirim code yg dipakai halaman
                          };

                          final pdf = await StrukPDF.generate(fixedOrder);
                          await Printing.layoutPdf(onLayout: (format) async => pdf.save());
                        },
                      label: Text(
                        "Unduh Struk",
                        style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: _btn,
                      onPressed: () {
                        Navigator.pushNamed(context, "/pesanan", arguments: order);
                      },
                      child: Text(
                        "Lihat Pesanan",
                        style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
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

  // STYLE
  ButtonStyle get _btn => ElevatedButton.styleFrom(
        backgroundColor: const Color(0xffC62828),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      );

  Widget _priceRow(String label, dynamic value,
      {bool isCurrency = true, Color? color, bool bold = false, bool big = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.montserrat(
              fontSize: big ? 17 : 13,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
          Text(
            isCurrency ? _cur.format(value) : value.toString(),
            style: GoogleFonts.montserrat(
              fontSize: big ? 17 : 13,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  TextStyle _reg(double size) {
    return GoogleFonts.montserrat(
      fontSize: size,
      fontWeight: FontWeight.w400,
    );
  }

  TextStyle _bold(double size) {
    return GoogleFonts.montserrat(
      fontSize: size,
      fontWeight: FontWeight.w700,
    );
  }

  Widget _divider() {
    return Container(
      height: 1,
      color: const Color(0xffD7D7D7),
      margin: const EdgeInsets.symmetric(vertical: 10),
    );
  }

  String _generateOrderCode() {
    final now = DateTime.now().millisecondsSinceEpoch;
    return now.toRadixString(36).toUpperCase().substring(3, 8);
  }

  // === PDF ===
  Future<void> _generatePDF(Map<String, dynamic> order) async {
    final pdf = pw.Document();

    final List items = order["items"] is List
        ? order["items"]
        : (order["items"]?["items"] ?? []);

    final double subtotal = items.fold<double>(0, (sum, item) {
      final qty = _toDouble(item["quantity"] ?? item["qty"] ?? 1);
      final price = _toDouble(item["price"]);
      return sum + (qty * price);
    });

    final double serviceFee = subtotal * 0.10;
    final double deliveryFee = _toDouble(order["deliveryFee"]);
    final double discount = _toDouble(order["voucher"]?["value"] ?? 0);
    final voucherType = order["voucher"]?["type"] ?? "";

    final double total = subtotal + serviceFee + deliveryFee - discount;

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(
                      "KEDAI WARTIYEM",
                      style: pw.TextStyle(
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text(
                      "Jl. Ampera No.57, Rt/Rw 002/023 Bulak,\n"
                      "Kec. Jatibarang, Kabupaten Indramayu,\n"
                      "Jawa Barat 45273\n"
                      "No.Telp: 0813955878510",
                      textAlign: pw.TextAlign.center,
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 14),
              pw.Divider(),

              ...items.map((it) {
                final qty = it["qty"] ?? it["quantity"] ?? 1;
                final price = _toDouble(it["price"]);
                return pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 3),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(it["name"] ?? ""),
                      pw.Text("$qty x"),
                      pw.Text(_cur.format(price * qty)),
                    ],
                  ),
                );
              }),

              pw.SizedBox(height: 12),
              pw.Divider(),

              pw.Text("Subtotal: ${_cur.format(subtotal)}"),
              pw.Text("Biaya Layanan (10%): ${_cur.format(serviceFee)}"),
              if (deliveryFee > 0)
                pw.Text("Biaya Antar: ${_cur.format(deliveryFee)}"),

              if (discount > 0)
                pw.Text(
                  "Voucher Diskon ${voucherType != "" ? "($voucherType)" : ""}: -${_cur.format(discount)}",
                ),


              pw.SizedBox(height: 8),
              pw.Divider(),

              pw.Text(
                "TOTAL: ${_cur.format(total)}",
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }
}
