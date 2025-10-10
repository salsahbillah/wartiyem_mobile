import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'pesanan_page.dart'; // ✅ tambahkan import ini

class StrukPage extends StatelessWidget {
  const StrukPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Struk Pembelian",
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "KEDAI WARTIYEM",
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              "Jl. Ampera No.57, Rt/Rw 002/023 Bulak,\nKec. Jatibarang, Kabupaten Indramayu,\nJawa Barat 45273\nNo.Telp: 0813955878510",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 13),
            ),
            const SizedBox(height: 10),
            const Divider(thickness: 1, color: Colors.black54),
            const SizedBox(height: 10),

            // Info pesanan
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("25-09-2025", style: GoogleFonts.poppins(fontSize: 13)),
                Text("20:13 WIB", style: GoogleFonts.poppins(fontSize: 13)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Kode Pesanan", style: GoogleFonts.poppins(fontSize: 13)),
                Text("2CB2E3", style: GoogleFonts.poppins(fontSize: 13)),
              ],
            ),
            const SizedBox(height: 10),
            Text("caca",
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600, fontSize: 15)),
            const SizedBox(height: 10),
            const Divider(thickness: 1, color: Colors.black54),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("NASI LIWET AYAM GORENG",
                    style: GoogleFonts.poppins(fontSize: 14)),
                Text("Rp 20.000", style: GoogleFonts.poppins(fontSize: 14)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Total QTY : 1", style: GoogleFonts.poppins(fontSize: 13)),
              ],
            ),
            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Subtotal", style: GoogleFonts.poppins(fontSize: 14)),
                Text("Rp 20.000", style: GoogleFonts.poppins(fontSize: 14)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Biaya Layanan (10%)",
                    style: GoogleFonts.poppins(fontSize: 14)),
                Text("Rp 2.000", style: GoogleFonts.poppins(fontSize: 14)),
              ],
            ),
            const Divider(thickness: 1, color: Colors.black54),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("TOTAL",
                    style: GoogleFonts.poppins(
                        fontSize: 15, fontWeight: FontWeight.w700)),
                Text("Rp 22.000",
                    style: GoogleFonts.poppins(
                        fontSize: 15, fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Metode Pemesanan",
                    style: GoogleFonts.poppins(fontSize: 14)),
                Text("Bungkus", style: GoogleFonts.poppins(fontSize: 14)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Tunai", style: GoogleFonts.poppins(fontSize: 14)),
                Text("Rp 22.000", style: GoogleFonts.poppins(fontSize: 14)),
              ],
            ),
            const SizedBox(height: 15),
            Text(
              "Terima kasih atas transaksi Anda",
              style: GoogleFonts.poppins(
                fontStyle: FontStyle.italic,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 20),

            // Tombol bawah
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.download, color: Colors.white),
                    label: Text("Unduh Struk",
                        style: GoogleFonts.poppins(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {},
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // ✅ Navigasi ke halaman PesananPage
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PesananPage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      "Lihat Riwayat Pesanan",
                      style: GoogleFonts.poppins(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
