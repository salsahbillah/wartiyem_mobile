import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TentangKamiPage extends StatelessWidget {
  const TentangKamiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Text(
            "Aplikasi Wartiyem Mobile dibuat untuk memudahkan kamu "
            "pesan makanan favorit tanpa ribet!",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 16),
          ),
        ),
      ),
    );
  }
}
