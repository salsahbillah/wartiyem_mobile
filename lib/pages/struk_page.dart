import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class StrukPage extends StatelessWidget {
  final Map<String, dynamic> order;
  const StrukPage({super.key, required this.order});

  Future<void> generatePDF(BuildContext context) async {
    final pdf = pw.Document();

    final items = (order["items"] as List<dynamic>)
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
    final subtotal =
        items.fold<double>(0, (sum, item) => sum + (item["price"] * item["qty"]));

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(24),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Center(
                    child: pw.Text("KEDAI WARTIYEM",
                        style: pw.TextStyle(
                            fontSize: 20, fontWeight: pw.FontWeight.bold))),
                pw.SizedBox(height: 20),
                pw.Text("Kode Pesanan: ${order["id"] ?? '-'}"),
                pw.Text("Tanggal: ${order["createdAt"] ?? '-'}"),
                pw.SizedBox(height: 10),
                pw.Divider(),
                pw.SizedBox(height: 10),
                ...items.map((item) {
                  final total = item["price"] * item["qty"];
                  return pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text("${item["name"]} x${item["qty"]}"),
                      pw.Text("Rp ${total.toStringAsFixed(0)}"),
                    ],
                  );
                }),
                pw.Divider(),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text("TOTAL",
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text("Rp ${subtotal.toStringAsFixed(0)}",
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File("${output.path}/struk_${order["id"]}.pdf");
    await file.writeAsBytes(await pdf.save());
    await OpenFile.open(file.path);
  }

  @override
  Widget build(BuildContext context) {
    final items = (order["items"] as List<dynamic>)
        .map((e) => Map<String, dynamic>.from(e))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Struk Pembelian"),
        backgroundColor: Colors.red,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text("Kode Pesanan: ${order["id"] ?? '-'}",
                style: GoogleFonts.poppins(fontSize: 16)),
            const Divider(),
            Expanded(
              child: ListView(
                children: items
                    .map((item) => ListTile(
                          title: Text(item["name"]),
                          subtitle: Text("Qty: ${item["qty"]}"),
                          trailing: Text(
                              "Rp ${(item["price"] * item["qty"]).toStringAsFixed(0)}"),
                        ))
                    .toList(),
              ),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.download),
              label: const Text("Unduh Struk"),
              onPressed: () => generatePDF(context),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
