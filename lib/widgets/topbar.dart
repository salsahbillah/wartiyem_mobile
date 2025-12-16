import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/search_provider.dart';
import '../providers/store_provider.dart';

class TopBar extends StatefulWidget {
  final int totalCartItems;

  const TopBar({super.key, required this.totalCartItems});

  @override
  State<TopBar> createState() => _TopBarState();
}

class _TopBarState extends State<TopBar> {
  final TextEditingController _searchController = TextEditingController();

  // =========================
  // ANIMASI TYPING (UI ONLY)
  // =========================
  final List<String> _hintTexts = [
    "Mau Cari Apa...",
    "cari makanan?",
    "cari minuman? ☕",
  ];

  int _textIndex = 0;
  int _charIndex = 0;
  String _animatedHint = "";
  bool _isDeleting = false;
  Timer? _typingTimer;

  @override
  void initState() {
    super.initState();
    _startTypingAnimation();
  }

  void _startTypingAnimation() {
    _typingTimer = Timer.periodic(const Duration(milliseconds: 120), (timer) {
      final currentText = _hintTexts[_textIndex];

      setState(() {
        if (!_isDeleting) {
          // Typing
          if (_charIndex < currentText.length) {
            _charIndex++;
            _animatedHint = currentText.substring(0, _charIndex);
          } else {
            _isDeleting = true;
          }
        } else {
          // Deleting
          if (_charIndex > 0) {
            _charIndex--;
            _animatedHint = currentText.substring(0, _charIndex);
          } else {
            _isDeleting = false;
            _textIndex = (_textIndex + 1) % _hintTexts.length;
          }
        }
      });
    });
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  // =========================
  // LOGIKA SEARCH (TIDAK DIUBAH)
  // =========================
  void handleSearch(BuildContext context) {
    final query = _searchController.text.trim();

    if (query.isEmpty) {
      context.read<SearchProvider>().clear();
      return;
    }

    context.read<SearchProvider>().setQuery(query);

    Navigator.pushNamed(
      context,
      "/menu",
      arguments: {"search": query},
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<StoreProvider>().user;

    String initial = user != null
        ? (user.name.isNotEmpty
            ? user.name[0].toUpperCase()
            : (user.email.isNotEmpty ? user.email[0].toUpperCase() : 'U'))
        : 'U';

    return Padding(
      padding: const EdgeInsets.only(top: 50, left: 13, right: 13, bottom: 20),
      child: Row(
        children: [
          // ==========================
          // SEARCH BAR (ANIMATED HINT)
          // ==========================
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                if (value.trim().isEmpty) {
                  context.read<SearchProvider>().clear();
                } else {
                  context.read<SearchProvider>().setQuery(value);
                }
              },
              onSubmitted: (_) => handleSearch(context),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                hintText:
                    _animatedHint.isEmpty ? "Mau Cari Apa..." : _animatedHint,
                hintStyle: const TextStyle(
                  color: Colors.grey,
                  fontStyle: FontStyle.normal, // ✅ TIDAK ITALIC
                ),
                prefixIcon: GestureDetector(
                  onTap: () => handleSearch(context),
                  child: const Icon(
                    Icons.search,
                    color: Color.fromARGB(255, 150, 0, 0),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(
                    color: Color.fromARGB(255, 150, 0, 0),
                    width: 1.4,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(
                    color: Color.fromARGB(255, 150, 0, 0),
                    width: 2,
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // CART ICON
          Stack(
            clipBehavior: Clip.none,
            children: [
              InkWell(
                onTap: () => Navigator.pushNamed(context, '/cart'),
                child: Image.asset(
                  'assets/images/cart.png',
                  width: 36,
                  height: 36,
                ),
              ),
              if (widget.totalCartItems > 0)
                Positioned(
                  right: -4,
                  top: -4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 155, 10, 0),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      "${widget.totalCartItems}",
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(width: 12),

          // PROFILE ICON
          InkWell(
            onTap: () => Navigator.pushNamed(context, '/edit-profile'),
            child: CircleAvatar(
              backgroundColor: const Color.fromARGB(255, 138, 11, 2),
              radius: 18,
              child: Text(
                initial,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
