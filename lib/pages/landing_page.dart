import 'dart:async';
import 'package:flutter/material.dart';

class LandingPage extends StatefulWidget {
  final VoidCallback onLoginSuccess;

  const LandingPage({super.key, required this.onLoginSuccess});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>
    with TickerProviderStateMixin {
  late AnimationController _introController;
  late AnimationController _zoomController;

  late Animation<double> _fadeIntro;
  late Animation<double> _scaleIntro;
  late Animation<double> _logoZoom;

  Timer? _redirectTimer;
  bool _isNavigating = false;
  bool _fadeOut = false;

  @override
  void initState() {
    super.initState();

    // ===== Animasi MASUK =====
    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeIntro =
        CurvedAnimation(parent: _introController, curve: Curves.easeIn);

    _scaleIntro = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(parent: _introController, curve: Curves.easeOutBack),
    );

    // ===== Animasi ZOOM LOGO (KELUAR) =====
    _zoomController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _logoZoom = Tween<double>(begin: 1.0, end: 2.2).animate(
      CurvedAnimation(parent: _zoomController, curve: Curves.easeInCubic),
    );

    _introController.forward();
    _startRedirectTimer();
  }

  void _startRedirectTimer() {
    _redirectTimer?.cancel();
    _isNavigating = false;

    _redirectTimer = Timer(const Duration(seconds: 3), () async {
      if (!mounted || _isNavigating) return;
      _isNavigating = true;

      // Mulai animasi keluar
      _zoomController.forward();
      setState(() => _fadeOut = true);

      await Future.delayed(const Duration(milliseconds: 450));

      // ===== INI KUNCI FIX =====
      // Landing DIBUANG dari stack
      Navigator.pushReplacementNamed(context, '/login');
    });
  }

  @override
  void dispose() {
    _redirectTimer?.cancel();
    _introController.dispose();
    _zoomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedOpacity(
        duration: const Duration(milliseconds: 450),
        opacity: _fadeOut ? 0 : 1,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF6A1B1B), // Maroon gelap
                Color(0xFF8E2424), // Maroon hangat
                Color(0xFFF3EDED), // Cream lembut
              ],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: FadeTransition(
                opacity: _fadeIntro,
                child: ScaleTransition(
                  scale: _scaleIntro,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // ===== LOGO =====
                      AnimatedBuilder(
                        animation: _logoZoom,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _logoZoom.value,
                            child: child,
                          );
                        },
                        child: Image.asset(
                          "assets/images/logo_kedai.png",
                          height: 180,
                        ),
                      ),

                      const SizedBox(height: 28),

                      Text(
                        "Kedai Wartiyem",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white.withOpacity(0.95),
                        ),
                      ),

                      const SizedBox(height: 8),

                      const Text(
                        "Pesan Mudah • Cepat • Praktis",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: 42),

                      const CircularProgressIndicator(
                        strokeWidth: 3,
                        color: Color(0xFF6A1B1B),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
