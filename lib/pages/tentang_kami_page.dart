
// lib/pages/tentang_kami_page.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class TentangKamiPage extends StatefulWidget {
  const TentangKamiPage({super.key});

  @override
  State<TentangKamiPage> createState() => _TentangKamiPageState();
}

class _TentangKamiPageState extends State<TentangKamiPage> {
  
  static const Color themeRed = Color(0xFF7A1F1F);
  static const Color bg = Color(0xFFF6F6F6);

  final ScrollController _scrollController = ScrollController();

  late PageController _headerController;
  int _currentHeader = 0;
  Timer? _headerTimer;

  

  final List<Map<String, dynamic>> headerSlides = [
    {
      "title": "Kedai Wartiyem",
      "subtitle": "Rasa Tradisional • Sentuhan Digital",
      "gradient": const LinearGradient(
        colors: [Color(0xFF7A1F1F), Color(0xFFF3E5D8)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    },
    {
      "title": "Masakan Rumahan",
      "subtitle": "Hangat • Autentik • Penuh Cinta",
      "gradient": const LinearGradient(
        colors: [Color(0xFFFBC02D), Color(0xFFFFF9C4)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    },
    {
      "title": "Lebih Mudah & Cepat",
      "subtitle": "Pesan Sekarang • Kami Antar",
      "gradient": const LinearGradient(
        colors: [Color(0xFF212121), Color(0xFF616161)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    },
  ];

  String get _wa => '6285943622000';
  String get _waUrl =>
      'https://wa.me/$_wa?text=${Uri.encodeComponent("Halo Kedai Wartiyem 👋")}';
  String get _fbUrl =>
      'https://www.facebook.com/p/Kedai-Wartiyem-Bulak-100087412186742/';
  String get _igUrl => 'https://www.instagram.com/wartiyembulak/';
  String get _mapsUrl =>
      'https://www.google.com/maps/search/?api=1&query=Jl.+Ampera+No.57,+Bulak,+Jatibarang,+Indramayu';

  Future<void> _open(String url) async {
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

    @override
  void initState() {
    super.initState();

    _headerController = PageController();

    _headerTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!_headerController.hasClients) return;

      _currentHeader =
          (_currentHeader + 1) % headerSlides.length;

      _headerController.animateToPage(
        _currentHeader,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    });
  }


  @override
void dispose() {
  _headerTimer?.cancel();
  _headerController.dispose();
  _scrollController.dispose();
  super.dispose();
}


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
  backgroundColor: themeRed,
  
  // HAPUS TOMBOL BACK
  automaticallyImplyLeading: false,

  title: Text(
    'Tentang Kami',
    style: GoogleFonts.poppins(
      fontWeight: FontWeight.w600,
      color: Colors.white, // WARNA PUTIH
    ),
  ),
  centerTitle: true,
),

      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // =========================
            // HEADER CARAUSEL
            // =========================
           SizedBox(
                    height: 150,
                    child: PageView.builder(
                      controller: _headerController,
                      itemCount: headerSlides.length,
                      itemBuilder: (context, i) {
                        final slide = headerSlides[i];

                      return PressableHeader(
                        themeRed: themeRed,
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: slide["gradient"],
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(.25),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              )
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                slide["title"],
                                style: GoogleFonts.poppins(
                                  fontSize: 26,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                slide["subtitle"],
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(.95),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),


            // KISAH KAMI
            _sectionTitle("Kisah Kami", themeRed),
            const SizedBox(height: 8),
            AnimatedOnScroll(
            controller: _scrollController,
            child: PressableCard(
              themeRed: themeRed,
              child: Column(
                children: [
                  Text(
                    'Kedai Wartiyem didirikan oleh Ibu Dewi Karmila Wulandari pada tahun 2020, '
                    'setelah sebelumnya melayani pelanggan melalui WhatsApp dan Facebook sejak 2018.',
                    style: GoogleFonts.poppins(fontSize: 13, height: 1.6),
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Untuk menjawab tantangan operasional dan permintaan pelanggan, '
                    'kami mengembangkan sistem pemesanan digital yang mendukung layanan '
                    'makan di tempat, bungkus, dan antar.',
                    style: GoogleFonts.poppins(fontSize: 13, height: 1.6),
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 20),
ClipRRect(
  borderRadius: BorderRadius.circular(12),
  child: Image.asset(
    'assets/images/logo_kedai.png',
    height: 180,
    width: double.infinity,
    fit: BoxFit.cover,
  ),
),
const SizedBox(height: 20),
                ],
              ),
            ), // <<==== TUTUP PressableCard DI SINI !!
            ),
            // VISI MISI
            AnimatedOnScroll(
  controller: _scrollController,
  child: _sectionTitle("Visi & Misi", themeRed),
),
const SizedBox(height: 8),

AnimatedOnScroll(
  controller: _scrollController,
  child: PressableSubCard(
    themeRed: themeRed,
    title: "Visi",
    text:
        "Menjadi rumah makan pilihan utama yang menggabungkan rasa autentik "
        "dengan pelayanan berbasis teknologi modern.",
  ),
),

const SizedBox(height: 12),

AnimatedOnScroll(
  controller: _scrollController,
  child: PressableSubCard(
    themeRed: themeRed,
    title: "Misi",
    text:
        "- Menyediakan makanan berkualitas dengan harga terjangkau\n"
        "- Mengutamakan kepuasan pelanggan\n"
        "- Terus berinovasi dalam pelayanan",
  ),
),

            const SizedBox(height: 20),

            // HUBUNGI KAMI
            _sectionTitle("Hubungi Kami", themeRed),
            const SizedBox(height: 10),
            AnimatedOnScroll(
  controller: _scrollController,
  child: Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      UpgradedContactIcon(
        icon: Icons.chat_bubble_rounded,
        label: 'WhatsApp',
        activeColor: const Color(0xFF25D366),
        onTap: () => _open(_waUrl),
        themeRed: themeRed,
      ),
      const SizedBox(width: 16),
      UpgradedContactIcon(
        icon: Icons.facebook_rounded,
        label: 'Facebook',
        activeColor: const Color(0xFF1877F2),
        onTap: () => _open(_fbUrl),
        themeRed: themeRed,
      ),
      const SizedBox(width: 16),
      UpgradedContactIcon(
        icon: Icons.camera_alt_rounded,
        label: 'Instagram',
        activeColor: const Color(0xFFC13584),
        onTap: () => _open(_igUrl),
        themeRed: themeRed,
      ),
      const SizedBox(width: 16),
      UpgradedContactIcon(
        icon: Icons.location_on_rounded,
        label: 'Maps',
        activeColor: themeRed,
        onTap: () => _open(_mapsUrl),
        themeRed: themeRed,
      ),
    ],
  ),
),

const SizedBox(height: 24),


            // KEUNGGULAN
            _sectionTitle("Kenapa Harus Pilih Kami?", themeRed),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: themeRed,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  FeatureItem(text: "✔️ Cepat & Praktis", themeRed: themeRed),
                  FeatureItem(text: "✔️ Rasa Autentik", themeRed: themeRed),
                  FeatureItem(text: "✔️ Pemesanan Digital", themeRed: themeRed),
                  FeatureItem(text: "✔️ Bahan Berkualitas", themeRed: themeRed),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // CTA
            PressableCard(
              themeRed: themeRed,
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: themeRed,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    Text(
                      '🍽️ Ingin Coba Masakan Kami?',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Pesan sekarang dan rasakan sensasi kuliner rumahan yang berbeda!',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 13,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // MAP STATIC
            _sectionTitle("Lokasi Kami 📍", themeRed),
            const SizedBox(height: 8),
            PressableCard(
              themeRed: themeRed,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  'https://maps.googleapis.com/maps/api/staticmap?center=Jl.+Ampera+No.57,+Jatibarang,+Indramayu&zoom=15&size=800x500&markers=color:red|Jl.+Ampera+No.57,+Jatibarang,+Indramayu&key=AIzaSyDLLgRGwOoo8AinJ1oX6-jkHfL4F6megWo',
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // TEAM
            _sectionTitle("Dikembangkan Oleh", themeRed),
            const SizedBox(height: 14),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: const [
                PressableTeamCard('assets/images/eka.jpg', 'Eka Dava Fadilah Juliansah'),
                PressableTeamCard('assets/images/maba.jpeg', 'Naba Imelda Nurussauba'),
                PressableTeamCard('assets/images/cc.jpeg', 'Salsah Billah'),
              ],
            ),
            const SizedBox(height: 40),
          ],

        ),
      ),
    );
  }

  Widget _sectionTitle(String text, Color red) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: red,
      ),
    );
  }
}

// =========================
// PressableHeader widget
// =========================
class PressableHeader extends StatefulWidget {
  final Widget child;
  final Color themeRed;
  const PressableHeader({super.key, required this.child, required this.themeRed});

  @override
  State<PressableHeader> createState() => _PressableHeaderState();
}

class _PressableHeaderState extends State<PressableHeader>
    with SingleTickerProviderStateMixin {
  bool pressed = false;
  late AnimationController ctrl;
  late Animation<double> scale;

  @override
  void initState() {
    super.initState();
    ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 110),
    );
    scale = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: ctrl, curve: Curves.easeOut),
    );
  }

  void _down() {
    setState(() {
      pressed = true;
    });
    ctrl.forward();
  }

  void _up() {
    setState(() {
      pressed = false;
    });
    ctrl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _down(),
      onTapUp: (_) => _up(),
      onTapCancel: _up,
      child: AnimatedBuilder(
        animation: ctrl,
        builder: (_, child) {
          return Transform.scale(
            scale: scale.value,
            child: child,
          );
        },
        child: widget.child,
      ),
    );
  }
}

// Reusable PressableCard for mobile tap animation (Style C)
class PressableCard extends StatefulWidget {
  final Widget child;
  final Color themeRed;
  final VoidCallback? onTap;

  const PressableCard({super.key, required this.child, required this.themeRed, this.onTap});

  @override
  State<PressableCard> createState() => _PressableCardState();
}

class _PressableCardState extends State<PressableCard> {
  bool _pressed = false;

  static const double pressedScale = 1.06;
  static const double normalScale = 1.0;

  void _onTapDown(TapDownDetails _) {
    setState(() => _pressed = true);
  }

  void _onTapUp(TapUpDetails _) {
    setState(() => _pressed = false);
    widget.onTap?.call();
  }

  void _onTapCancel() {
    setState(() => _pressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final boxShadow = _pressed
        ? [
            BoxShadow(
              color: widget.themeRed.withOpacity(.40),
              blurRadius: 32,
              spreadRadius: 4,
              offset: const Offset(0, 12),
            )
          ]
        : [
            BoxShadow(
              color: Colors.black.withOpacity(.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ];

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        transform: Matrix4.identity()..scale(_pressed ? pressedScale : normalScale),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: boxShadow,
          border: _pressed
              ? Border.all(color: widget.themeRed.withOpacity(.9), width: 2)
              : null,
        ),
        padding: const EdgeInsets.all(16),
        child: widget.child,
      ),
    );
  }
}

// PressableSubCard specific styling (left border accent)
class PressableSubCard extends StatefulWidget {
  final Color themeRed;
  final String title;
  final String text;

  const PressableSubCard({super.key, required this.themeRed, required this.title, required this.text});

  @override
  State<PressableSubCard> createState() => _PressableSubCardState();
}

class _PressableSubCardState extends State<PressableSubCard> {
  bool _pressed = false;

  void _onTapDown(TapDownDetails _) => setState(() => _pressed = true);
  void _onTapUp(TapUpDetails _) => setState(() => _pressed = false);
  void _onTapCancel() => setState(() => _pressed = false);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _pressed ? widget.themeRed.withOpacity(.06) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border(
            left: BorderSide(color: widget.themeRed, width: _pressed ? 6 : 4),
          ),
          boxShadow: _pressed
              ? [
                  BoxShadow(
                    color: widget.themeRed.withOpacity(.40),
                    blurRadius: 32,
                    spreadRadius: 4,
                    offset: const Offset(0, 12),
                  )
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(.03),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.title,
                style: GoogleFonts.poppins(
                    fontSize: 15, fontWeight: FontWeight.w600, color: widget.themeRed)),
            const SizedBox(height: 6),
            Text(widget.text, style: GoogleFonts.poppins(fontSize: 13, height: 1.6)),
          ],
        ),
      ),
    );
  }
}

// Feature item with slide + fade when pressed (keunggulan)
class FeatureItem extends StatefulWidget {
  final String text;
  final Color themeRed;

  const FeatureItem({super.key, required this.text, required this.themeRed});

  @override
  State<FeatureItem> createState() => _FeatureItemState();
}

class _FeatureItemState extends State<FeatureItem> {
  bool _pressed = false;

  void _onTapDown(TapDownDetails _) => setState(() => _pressed = true);
  void _onTapUp(TapUpDetails _) => setState(() => _pressed = false);
  void _onTapCancel() => setState(() => _pressed = false);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOut,
        transform: Matrix4.identity()..scale(_pressed ? 1.04 : 1.0),
        child: Row(
          children: [
            AnimatedSlide(
              duration: const Duration(milliseconds: 260),
              offset: _pressed ? const Offset(0.02, 0) : Offset.zero,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 260),
                opacity: _pressed ? 1.0 : 0.95,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    widget.text,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: _pressed ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Upgraded contact icon to use tap-down animation (matches Style C)
class UpgradedContactIcon extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color activeColor;
  final VoidCallback onTap;
  final Color themeRed;

  const UpgradedContactIcon({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    required this.activeColor,
    required this.themeRed,
  });

  @override
  State<UpgradedContactIcon> createState() => _UpgradedContactIconState();
}

class _UpgradedContactIconState extends State<UpgradedContactIcon> with SingleTickerProviderStateMixin {
  bool _pressed = false;
  late final AnimationController _ctrl;
  late final Animation<double> _scaleAnim;

  
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 180));
    _scaleAnim = Tween<double>(begin: 1.0, end: 1.08).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _setPressed(bool val) {
    setState(() {
      _pressed = val;
      if (_pressed) _ctrl.forward();
      else _ctrl.reverse();
    });
  }

  void _onTapDown(TapDownDetails _) => _setPressed(true);
  void _onTapUp(TapUpDetails _) {
    _setPressed(false);
    widget.onTap();
  }

  void _onTapCancel() => _setPressed(false);

  @override
  Widget build(BuildContext context) {
    
    final boxShadow = _pressed
        ? [
            BoxShadow(
              color: widget.themeRed.withOpacity(.40),
              blurRadius: 32,
              spreadRadius: 4,
              offset: const Offset(0, 12),
            )
          ]
        : [
            BoxShadow(
              color: Colors.black.withOpacity(.08),
              blurRadius: 6,
              offset: const Offset(0, 4),
            )
          ];

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, child) {
          final double scale = _scaleAnim.value;
          return Transform.scale(
            scale: scale,
            child: Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 62,
                  height: 62,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _pressed ? widget.activeColor : Colors.white,
                    border: Border.all(
                      color: _pressed ? widget.activeColor.withOpacity(.9) : Colors.transparent,
                      width: 2,
                    ),
                    boxShadow: boxShadow,
                  ),
                  child: Icon(
                    widget.icon,
                    size: 30,
                    color: _pressed ? Colors.white : widget.themeRed,
                  ),
                ),
                const SizedBox(height: 6),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 160),
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: _pressed ? FontWeight.w600 : FontWeight.w400,
                    color: _pressed ? widget.activeColor : widget.themeRed,
                  ),
                  child: Text(widget.label),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// PressableTeamCard with image zoom + rotate on tap (Style C)
class PressableTeamCard extends StatefulWidget {
  final String image;
  final String name;
  const PressableTeamCard(this.image, this.name, {super.key});

  @override
  State<PressableTeamCard> createState() => _PressableTeamCardState();
}

class _PressableTeamCardState extends State<PressableTeamCard> with SingleTickerProviderStateMixin {
  bool _pressed = false;
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _rotate;

  static const double pressedScale = 1.06;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(duration: const Duration(milliseconds: 240), vsync: this);
    _scale = Tween<double>(begin: 1.0, end: pressedScale).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _rotate = Tween<double>(begin: 0.0, end: 0.0175).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut)); // ~1 degree
  }

  @override
  void dispose() {
    super.dispose();
  }


  void _onTapDown(TapDownDetails _) {
    setState(() => _pressed = true);
    _ctrl.forward();
  }

  void _onTapUp(TapUpDetails _) {
    setState(() => _pressed = false);
    _ctrl.reverse();
  }

  void _onTapCancel() {
    setState(() => _pressed = false);
    _ctrl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, child) {
          return Transform.scale(
            scale: _scale.value,
            child: Container(
              width: 150,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: _pressed
                    ? [
                        BoxShadow(
                          color: Color(0xFF7A1F1F).withOpacity(.40),
                          blurRadius: 32,
                          spreadRadius: 4,
                          offset: const Offset(0, 12),
                        )
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                border: _pressed ? Border.all(color: Color(0xFF7A1F1F).withOpacity(.9), width: 2) : null,
              ),
              child: Column(
                children: [
                  Transform.rotate(
                    angle: _rotate.value,
                    child: ClipOval(
                      child: Image.asset(
                        widget.image,
                        width: 90,
                        height: 90,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.name,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class AnimatedOnScroll extends StatefulWidget {
  final Widget child;
  final ScrollController controller;

  const AnimatedOnScroll({
    super.key,
    required this.child,
    required this.controller,
  });

  @override
  State<AnimatedOnScroll> createState() => _AnimatedOnScrollState();
}

class _AnimatedOnScrollState extends State<AnimatedOnScroll> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_check);
    WidgetsBinding.instance.addPostFrameCallback((_) => _check());
  }

  void _check() {
    if (!mounted) return;

    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;

    final pos = box.localToGlobal(Offset.zero);
    final screenH = MediaQuery.of(context).size.height;

    final shouldShow =
        pos.dy < screenH * 0.85 && pos.dy > -box.size.height;

    if (shouldShow != _visible) {
      setState(() => _visible = shouldShow);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_check);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 400),
      opacity: _visible ? 1 : 0,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
        offset: _visible ? Offset.zero : const Offset(0, 0.25),
        child: widget.child,
      ),
    );
  }
}
