import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MenuCard extends StatelessWidget {
  final String nama;
  final String deskripsi;
  final int harga;
  final String status;
  final int qty;
  final double rating;
  final String imagePath;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const MenuCard({
    super.key,
    required this.nama,
    required this.deskripsi,
    required this.harga,
    required this.status,
    required this.qty,
    required this.rating,
    required this.imagePath,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 170,
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.25),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🖼️ BAGIAN GAMBAR
          Stack(
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(15)),
                child: Image.asset(
                  imagePath,
                  width: double.infinity,
                  height: 120,
                  fit: BoxFit.cover,
                ),
              ),

              // ⭐ RATING DENGAN BINTANG
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 255, 178, 62),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, color: Color.fromARGB(255, 179, 0, 0), size: 13),
                      const SizedBox(width: 2),
                      Text(
                        rating.toStringAsFixed(1),
                        style: GoogleFonts.poppins(
                          color: const Color.fromARGB(255, 0, 0, 0),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ➕/➖ Tombol Qty
              Positioned(
                bottom: 8,
                right: 8,
                child: qty == 0
                    ? GestureDetector(
                        onTap: status == 'Habis' ? null : onAdd,
                        child: CircleAvatar(
                          radius: 16,
                          backgroundColor: status == 'Habis'
                              ? Colors.grey
                              : const Color(0xFF800000),
                          child: const Icon(Icons.add,
                              color: Colors.white, size: 20),
                        ),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle,
                                  color: Colors.red, size: 20),
                              onPressed: onRemove,
                            ),
                            Text(
                              "$qty",
                              style: GoogleFonts.poppins(fontSize: 13),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle,
                                  color: Colors.green, size: 20),
                              onPressed: onAdd,
                            ),
                          ],
                        ),
                      ),
              ),
            ],
          ),

          // 📋 BAGIAN TEKS
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nama,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  deskripsi,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.black54,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                Text(
                  "Rp $harga",
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.red.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  status,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color:
                        status == "Habis" ? Colors.red : Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
