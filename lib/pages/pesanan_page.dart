import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PesananPage extends StatelessWidget {
  const PesananPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Pesanan", style: GoogleFonts.poppins()),
        backgroundColor: Colors.red,
      ),
      body: const Center(
        child: Text("Halaman Pesanan Kamu"),
      ),
    );
  }
}
