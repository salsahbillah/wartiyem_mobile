import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MenuCard extends StatelessWidget {
  final String nama;
  final String deskripsi;
  final int harga;
  final String status;
  final int qty;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const MenuCard({
    super.key,
    required this.nama,
    required this.deskripsi,
    required this.harga,
    required this.status,
    required this.qty,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gambar placeholder
          Container(
            height: 90,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              color: Colors.orange.shade200,
            ),
            child: const Center(
              child: Icon(Icons.fastfood, size: 40, color: Colors.white),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(nama, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13)),
                  Text(deskripsi, style: GoogleFonts.poppins(fontSize: 11)),
                  Text(
                    "$harga",
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.red.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    status,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: status == "Habis" ? Colors.red : Colors.green,
                    ),
                  ),
                  const Spacer(),
                  qty == 0
                      ? Align(
                          alignment: Alignment.centerRight,
                          child: InkWell(
                            onTap: onAdd,
                            child: Container(
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFF800000),
                              ),
                              padding: const EdgeInsets.all(6),
                              child: const Icon(Icons.add, color: Colors.white, size: 18),
                            ),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle, color: Colors.red, size: 20),
                              onPressed: onRemove,
                            ),
                            Text("$qty", style: GoogleFonts.poppins(fontSize: 13)),
                            IconButton(
                              icon: const Icon(Icons.add_circle, color: Colors.green, size: 20),
                              onPressed: onAdd,
                            ),
                          ],
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
