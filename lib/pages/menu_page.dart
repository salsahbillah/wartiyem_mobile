import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Text(
            "Daftar Menu Akan Muncul di sini",
            style: GoogleFonts.poppins(fontSize: 16),
          ),
        ),
      ),
    );
  }
}
