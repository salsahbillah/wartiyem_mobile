import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TentangKamiPage extends StatelessWidget {
  const TentangKamiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Tentang Kami", style: GoogleFonts.poppins()),
        backgroundColor: Colors.red,
      ),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          "Aplikasi Wartiyem Mobile dibuat untuk memudahkan kamu "
          "pesan makanan favorit tanpa ribet!",
          style: TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
