import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';

class StrukPDF {
  static Future<pw.Document> generate(Map<String, dynamic> order) async {
    final pdf = pw.Document();
    final NumberFormat cur =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    double toDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0.0;
    }

    String toStringSafe(dynamic v) {
      if (v == null) return "";
      return v.toString();
    }

    // items (support array or nested)
    final List items = (order["items"] is List)
        ? order["items"]
        : (order["items"]?["items"] is List
            ? order["items"]["items"]
            : []);

    // compute subtotal
    final double subtotal = items.fold<double>(0, (sum, item) {
      final qty = toDouble(item["quantity"] ?? item["qty"] ?? 1);
      final price =
          toDouble(item["price"] ?? item["harga"] ?? item["amount"] ?? 0);
      return sum + (qty * price);
    });

    // service fee (default 10%)
    final double serviceFee =
        (order.containsKey("serviceFee") && order["serviceFee"] != null)
            ? toDouble(order["serviceFee"])
            : (subtotal * 0.10);

    // delivery fee
    final double deliveryFee =
        (order.containsKey("deliveryFee") && order["deliveryFee"] != null)
            ? toDouble(order["deliveryFee"])
            : (toDouble(order["delivery_fee"]) > 0
                ? toDouble(order["delivery_fee"])
                : 0.0);

    // voucher/discount
    double discount = 0.0;
    String voucherType = "";

    if (order.containsKey("discount") && order["discount"] != null) {
      discount = toDouble(order["discount"]);
    } else if (order.containsKey("voucher") && order["voucher"] is Map) {
      final v = Map<String, dynamic>.from(order["voucher"]);
      voucherType = toStringSafe(
          v["type"] ?? v["title"] ?? v["discountType"] ?? v["name"] ?? "");
      discount =
          toDouble(v["value"] ?? v["discountValue"] ?? v["amount"] ?? 0);
    } else {
      discount = toDouble(order["voucherValue"] ??
          order["voucher_amount"] ??
          order["voucherDiscount"] ??
          order["voucher_value"] ??
          0);
      voucherType =
          toStringSafe(order["voucherType"] ?? order["voucher_title"] ?? "");
    }

    final double total = subtotal + serviceFee + deliveryFee - discount;

    // basic fields
    final name = toStringSafe(order["name"] ?? order["customerName"] ?? "-");
    final method =
        toStringSafe(order["method"] ?? order["orderMethod"] ?? "-");
    final payment =
        toStringSafe(order["payment"] ?? order["paymentMethod"] ?? "-");

    // ------------ FIX: Kode Pesanan hanya dari orderCode --------------
    final String code =
        toStringSafe(order["orderCode"] ?? ""); // No fallback ke _id lagi
    // -------------------------------------------------------------------

    final now = DateTime.now();
    final date = DateFormat('dd-MM-yyyy').format(now);
    final time = DateFormat('HH:mm').format(now);

    pdf.addPage(
      pw.Page(
        margin: const pw.EdgeInsets.all(30),
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
                        fontSize: 22,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      "Jl. Ampera No.57, Rt/Rw 002/023 Bulak,\n"
                      "Kec. Jatibarang, Kabupaten Indramayu,\n"
                      "Jawa Barat 45273\n"
                      "No.Telp: 0813955878510",
                      textAlign: pw.TextAlign.center,
                      style: const pw.TextStyle(fontSize: 11),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 12),
              pw.Divider(),

              // date & code
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(date, style: const pw.TextStyle(fontSize: 12)),
                  pw.Text("$time WIB",
                      style: const pw.TextStyle(fontSize: 12)),
                ],
              ),
              pw.SizedBox(height: 4),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text("Kode Pesanan",
                      style: const pw.TextStyle(fontSize: 12)),
                  pw.Text(code, style: const pw.TextStyle(fontSize: 12)),
                ],
              ),

              pw.SizedBox(height: 12),
              pw.Divider(),

              pw.Text(
                name,
                style: pw.TextStyle(
                  fontSize: 15,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),

              pw.SizedBox(height: 10),

              // items
              ...items.map<pw.Widget>((it) {
                final qty = toDouble(it["quantity"] ?? it["qty"] ?? 1);
                final price = toDouble(it["price"] ?? it["harga"] ?? 0);
                final itemName = toStringSafe(it["name"] ?? "-");

                return pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 4),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Expanded(
                        child: pw.Text(
                          itemName.toUpperCase(),
                          style: pw.TextStyle(
                            fontSize: 13,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                      pw.Text("${qty.toInt()}x"),
                      pw.SizedBox(width: 8),
                      pw.Text(cur.format(price * qty)),
                    ],
                  ),
                );
              }).toList(),

              pw.SizedBox(height: 6),
              pw.Divider(),

              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text("Total QTY :",
                      style: const pw.TextStyle(fontSize: 13)),
                  pw.Text(
                    "${items.fold<int>(0, (a, b) {
                      final qty = b["qty"] ?? b["quantity"] ?? 1;
                      return a + int.parse(qty.toString());
                    })}",
                    style: const pw.TextStyle(fontSize: 13),
                  ),
                ],
              ),

              pw.SizedBox(height: 12),

              _pdfPrice("Subtotal", cur.format(subtotal)),
              if (discount > 0)
                _pdfPrice(
                  "Voucher Diskon ${voucherType.isNotEmpty ? "($voucherType)" : ""}",
                  "-${cur.format(discount)}",
                ),
              _pdfPrice("Biaya Layanan (10%)", cur.format(serviceFee)),
              if (deliveryFee > 0)
                _pdfPrice("Ongkos Kirim", cur.format(deliveryFee)),

              pw.SizedBox(height: 8),
              pw.Divider(),

              _pdfPrice("TOTAL", cur.format(total), bold: true, big: true),

              pw.SizedBox(height: 16),

              _pdfPrice("Metode Pemesanan", method, currency: false),
              _pdfPrice(payment, cur.format(total)),

              pw.SizedBox(height: 20),

              pw.Center(
                child: pw.Text(
                  "Terima kasih atas transaksi Anda",
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontStyle: pw.FontStyle.italic,
                  ),
                ),
              )
            ],
          );
        },
      ),
    );

    return pdf;
  }

  static pw.Widget _pdfPrice(String label, String value,
      {bool bold = false, bool big = false, bool currency = true}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: big ? 17 : 13,
              fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: big ? 17 : 13,
              fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
