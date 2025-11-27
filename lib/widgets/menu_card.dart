import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MenuCard extends StatelessWidget {
  final String nama;
  final String deskripsi;
  final String harga; // <<< SUDAH JADI STRING
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
    final bool isHabis = status == "Habis";

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🖼️ GAMBAR
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                child: ColorFiltered(
                  colorFilter: isHabis
                      ? const ColorFilter.mode(Colors.grey, BlendMode.saturation)
                      : const ColorFilter.mode(Colors.transparent, BlendMode.multiply),
                  child: Image.network(
                    imagePath,
                    width: double.infinity,
                    height: 120,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 120,
                        width: double.infinity,
                        alignment: Alignment.center,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.broken_image,
                            size: 40, color: Colors.grey),
                      );
                    },
                  ),
                ),
              ),

              // ⭐ RATING
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isHabis
                        ? Colors.grey.shade400
                        : const Color.fromARGB(255, 255, 178, 62),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.star,
                        color: isHabis
                            ? Colors.grey.shade700
                            : const Color.fromARGB(255, 179, 0, 0),
                        size: 13,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        rating.toStringAsFixed(1),
                        style: GoogleFonts.poppins(
                          color: isHabis ? Colors.grey.shade800 : Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ➕ TOMBOL ADD / QTY
              if (!isHabis)
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: qty == 0
                      ? GestureDetector(
                          onTap: onAdd,
                          child: const CircleAvatar(
                            radius: 16,
                            backgroundColor: Color(0xFF800000),
                            child: Icon(Icons.add, color: Colors.white, size: 20),
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

          // 📋 TEXT BAWAH
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
                    color: isHabis ? Colors.grey : Colors.black,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  deskripsi,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: isHabis ? Colors.grey : Colors.black54,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),

                // 💰 HARGA (SUDAH FORMAT)
                Text(
                  "Rp $harga",
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: isHabis ? Colors.grey : Colors.red.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 3),
                Text(
                  status,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isHabis ? Colors.grey.shade700 : Colors.green,
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
