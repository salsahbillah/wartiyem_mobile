import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TentangKamiPage extends StatelessWidget {
  const TentangKamiPage({super.key});

  @override
  Widget build(BuildContext context) {
    final redColor = const Color(0xFFE63946);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // HERO SECTION
            Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 10),
              decoration: BoxDecoration(
                color: redColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    "Kedai Wartiyem",
                    style: GoogleFonts.poppins(
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Rasa Tradisional, Sentuhan Digital",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),

            // STORY SECTION
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Kisah Kami",
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      color: redColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    "Kedai Wartiyem didirikan oleh Ibu Dewi Karmila Wulandari pada tahun 2020, setelah sebelumnya melayani pelanggan melalui WhatsApp dan Facebook sejak 2018. Dengan semangat menghadirkan cita rasa rumahan yang autentik, kami terus berkembang mengikuti perubahan zaman.",
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      height: 1.8,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Untuk menjawab tantangan operasional dan permintaan pelanggan, kami mengembangkan sistem pemesanan digital yang mendukung layanan makan di tempat, di bungkus, dan di antar. Tujuannya: lebih cepat, akurat, dan efisien.",
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      height: 1.8,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 30),
                  Center(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: redColor, width: 5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          )
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.asset(
                          'assets/images/w.png',
                          width: 300,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // VISI MISI SECTION
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              child: Column(
                children: [
                  Text(
                    "Visi & Misi",
                    style: GoogleFonts.poppins(
                      fontSize: 26,
                      fontWeight: FontWeight.w600,
                      color: redColor,
                    ),
                  ),
                  const SizedBox(height: 25),
                  Wrap(
                    runSpacing: 20,
                    spacing: 20,
                    children: [
                      _buildCard(
                        title: "Visi",
                        text:
                            "Menjadi rumah makan pilihan utama yang menggabungkan rasa autentik dengan pelayanan berbasis teknologi modern.",
                        color: redColor,
                      ),
                      _buildCard(
                        title: "Misi",
                        text: "- Menyediakan makanan berkualitas dengan harga terjangkau\n- Mengutamakan kepuasan pelanggan melalui layanan cepat dan tepat\n- Terus berinovasi dalam pelayanan dan teknologi",
                        color: redColor,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // KEUNGGULAN SECTION
            Container(
              margin: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: redColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Text(
                    "Kenapa Harus Pilih Kami?",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 15,
                    runSpacing: 15,
                    children: const [
                      _KeunggulanItem(text: "✔️ Cepat & Praktis"),
                      _KeunggulanItem(text: "✔️ Rasa Autentik"),
                      _KeunggulanItem(text: "✔️ Pemesanan Digital"),
                      _KeunggulanItem(text: "✔️ Bahan Berkualitas"),
                    ],
                  ),
                ],
              ),
            ),

            // CTA SECTION
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: redColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    "🍽️ Ingin Coba Masakan Kami?",
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "🚀 Pesan sekarang dan rasakan sensasi kuliner rumahan yang berbeda!",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // MAP SECTION
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  )
                ],
              ),
              child: Column(
                children: [
                  const SizedBox(height: 15),
                  Text(
                    "Lokasi Kami 📍",
                    style: GoogleFonts.poppins(
                      color: redColor,
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.network(
                      'https://maps.googleapis.com/maps/api/staticmap?center=Jl.+Ampera+No.57,+Jatibarang,+Indramayu&zoom=15&size=600x400&markers=color:red|Jl.+Ampera+No.57,+Jatibarang,+Indramayu&key=YOUR_API_KEY',
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 15),
                ],
              ),
            ),

            // TEAM SECTION
            Container(
              padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: redColor, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                children: [
                  Text(
                    "Dikembangkan Oleh",
                    style: GoogleFonts.poppins(
                      fontSize: 26,
                      fontWeight: FontWeight.w600,
                      color: redColor,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 30,
                    runSpacing: 30,
                    children: const [
                      _TeamCard(
                        image: 'assets/images/om.jpeg',
                        name: 'Eka Dava Fadilah Juliansah',
                      ),
                      _TeamCard(
                        image: 'assets/images/maba.jpeg',
                        name: 'Naba Imelda Nurussauba',
                      ),
                      _TeamCard(
                        image: 'assets/images/cc.jpeg',
                        name: 'Salsah Billah',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============== COMPONENTS ==============
Widget _buildCard({
  required String title,
  required String text,
  required Color color,
}) {
  return Container(
    width: 300,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      border: Border(left: BorderSide(color: color, width: 5)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: color,
            )),
        const SizedBox(height: 10),
        Text(
          text,
          style: GoogleFonts.poppins(fontSize: 14, height: 1.6),
        ),
      ],
    ),
  );
}

class _KeunggulanItem extends StatelessWidget {
  final String text;
  const _KeunggulanItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black87, width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _TeamCard extends StatelessWidget {
  final String image;
  final String name;
  const _TeamCard({required this.image, required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFEFEFE),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.transparent),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          ClipOval(
            child: Image.asset(
              image,
              width: 120,
              height: 120,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            name,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
