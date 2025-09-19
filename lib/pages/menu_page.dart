import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Menu", style: GoogleFonts.poppins()),
        backgroundColor: Colors.red,
      ),
      body: const Center(
        child: Text("Daftar Menu Akan Muncul di sini"),
      ),
    );
  }
}
