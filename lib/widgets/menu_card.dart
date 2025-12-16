import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MenuCard extends StatefulWidget {
  final String nama;
  final String deskripsi;
  final String harga;
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
  State<MenuCard> createState() => _MenuCardState();
}

class _MenuCardState extends State<MenuCard>
    with SingleTickerProviderStateMixin {
  bool _hover = false;
  bool _pressed = false;

  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    _fade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // POPUP FULLSCREEN IMAGE DENGAN BLUR BACKGROUND
  void _showImagePopup() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.2),
      builder: (context) {
        return GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Stack(
            children: [
              // BLUR BACKGROUND
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 9, sigmaY: 9),
                child: Container(color: Colors.black.withOpacity(0)),
              ),

              // IMAGE POPUP
              Center(
                child: AnimatedScale(
                  scale: 1,
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutBack,
                  child: Hero(
                    tag: widget.imagePath,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        widget.imagePath,
                        width: 300,
                        height: 300,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isHabis = widget.status == "Habis";

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: MouseRegion(
          onEnter: (_) => setState(() => _hover = true),
          onExit: (_) => setState(() => _hover = false),
          child: GestureDetector(
            onTapDown: (_) => setState(() => _pressed = true),
            onTapUp: (_) => setState(() => _pressed = false),
            onTapCancel: () => setState(() => _pressed = false),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 230),
              width: 170,
              margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
              transform: Matrix4.identity()
                ..translate(0.0, _hover ? -4.0 : 0.0)
                ..scale(_pressed ? 0.97 : _hover ? 1.035 : 1.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(_hover ? 0.28 : 0.12),
                    blurRadius: _hover ? 20 : 8,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildImage(isHabis),
                  _buildText(isHabis),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImage(bool isHabis) {
    return Stack(
      children: [
        GestureDetector(
          onTap: _showImagePopup, // OPEN POPUP IMAGE
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 260),
              opacity: _hover ? 0.88 : 1,
              child: ColorFiltered(
                colorFilter: isHabis
                    ? const ColorFilter.mode(Colors.grey, BlendMode.saturation)
                    : const ColorFilter.mode(
                        Colors.transparent, BlendMode.multiply),
                child: Hero(
                  tag: widget.imagePath,
                  child: Image.network(
                    widget.imagePath,
                    width: double.infinity,
                    height: 125,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
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
              color: isHabis ? Colors.grey.shade400 : const Color(0xFFFFB23E),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.star,
                  size: 13,
                  color: isHabis ? Colors.grey.shade700 : const Color(0xFFB30000),
                ),
                const SizedBox(width: 2),
                Text(
                  widget.rating.toStringAsFixed(1),
                  style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isHabis ? Colors.grey.shade900 : Colors.black),
                ),
              ],
            ),
          ),
        ),

        // ➕ ADD / REMOVE
        if (!isHabis)
          Positioned(
            bottom: 8,
            right: 8,
            child: widget.qty == 0
                ? GestureDetector(
                    onTap: widget.onAdd,
                    child: const CircleAvatar(
                      radius: 18,
                      backgroundColor: Color(0xFF800000),
                      child: Icon(Icons.add, color: Colors.white, size: 20),
                    ),
                  )
                : Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle,
                              color: Colors.red, size: 20),
                          onPressed: widget.onRemove,
                        ),
                        Text("${widget.qty}",
                            style: GoogleFonts.poppins(fontSize: 13)),
                        IconButton(
                          icon: const Icon(Icons.add_circle,
                              color: Colors.green, size: 20),
                          onPressed: widget.onAdd,
                        ),
                      ],
                    ),
                  ),
          ),
      ],
    );
  }

  Widget _buildText(bool isHabis) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.nama,
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
            widget.deskripsi,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: isHabis ? Colors.grey : Colors.black54,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 5),
          Text(
            "Rp ${widget.harga}",
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: isHabis ? Colors.grey : Colors.red.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            widget.status,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isHabis ? Colors.grey.shade700 : Colors.green,
            ),
          ),
        ],
      ),
    );
  }
}