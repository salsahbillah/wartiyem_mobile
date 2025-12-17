import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/search_provider.dart';
import '../providers/store_provider.dart';
import '../providers/notification_provider.dart';
import '../main.dart';

class TopBar extends StatefulWidget {
  final int totalCartItems;
  final bool isScrolled;
  const TopBar({
    super.key,
    required this.totalCartItems,
    this.isScrolled = false,
  });

  @override
  State<TopBar> createState() => _TopBarState();
}

class _TopBarState extends State<TopBar> {
  final TextEditingController _searchController = TextEditingController();

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

  static const Color themeRed = Color(0xFFB71C1C);

  @override
  void initState() {
    super.initState();
    _startTypingAnimation();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<NotificationProvider>().fetchNotifications();
    });
  }

  void _startTypingAnimation() {
    _typingTimer = Timer.periodic(const Duration(milliseconds: 120), (_) {
      final text = _hintTexts[_textIndex];
      setState(() {
        if (!_isDeleting) {
          if (_charIndex < text.length) {
            _charIndex++;
            _animatedHint = text.substring(0, _charIndex);
          } else {
            _isDeleting = true;
          }
        } else {
          if (_charIndex > 0) {
            _charIndex--;
            _animatedHint = text.substring(0, _charIndex);
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

  void handleSearch(BuildContext context) {
    final q = _searchController.text.trim();
    if (q.isEmpty) {
      context.read<SearchProvider>().clear();
      return;
    }
    context.read<SearchProvider>().setQuery(q);
    Navigator.pushNamed(context, "/menu", arguments: {"search": q});
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<StoreProvider>().user;
    final initial =
        user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : "U";

    return SafeArea(
      bottom: false,
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            decoration: BoxDecoration(
            color: widget.isScrolled
                ? Colors.white.withOpacity(0.65)
                : Colors.white.withOpacity(0.92),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 6,
                )
              ],
            ),
            child: Row(
              children: [
                // SEARCH
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (v) => v.trim().isEmpty
                        ? context.read<SearchProvider>().clear()
                        : context.read<SearchProvider>().setQuery(v),
                    onSubmitted: (_) => handleSearch(context),
                    decoration: InputDecoration(
                      hintText: _animatedHint.isEmpty
                          ? "Mau Cari Apa..."
                          : _animatedHint,
                      prefixIcon:
                          const Icon(Icons.search, color: themeRed),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide:
                            const BorderSide(color: themeRed, width: 1.4),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // 🛒 CART
                _buildBadge(
                  count: widget.totalCartItems,
                  child: InkWell(
                    onTap: () => Navigator.pushNamed(context, '/cart'),
                    child: Image.asset(
                      'assets/images/cart.png',
                      width: 34,
                      color: themeRed,
                    ),
                  ),
                ),

                const SizedBox(width: 14),

                // 🔔 NOTIF
                Consumer<NotificationProvider>(
                  builder: (_, notif, __) {
                    return _buildBadge(
                      count: notif.unreadCount,
                      child: InkWell(
                        onTap: () => _openNotif(context),
                        child: const Icon(Icons.notifications,
                            size: 30, color: themeRed),
                      ),
                    );
                  },
                ),

                const SizedBox(width: 12),

                // PROFILE
                InkWell(
                  onTap: () =>
                      Navigator.pushNamed(context, '/edit-profile'),
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: themeRed,
                    child: Text(initial,
                        style: const TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBadge({required int count, required Widget child}) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        if (count > 0)
          Positioned(
            right: -6,
            top: -6,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: themeRed,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              child: Center(
                child: Text(
                  count > 9 ? "9+" : "$count",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _openNotif(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.25),
      barrierLabel: "notif",
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (_, __, ___) => const _NotificationOverlay(),
      transitionBuilder: (_, anim, __, child) {
        return FadeTransition(
          opacity: anim,
          child: SlideTransition(
            position: Tween(
              begin: const Offset(0, -0.15),
              end: Offset.zero,
            ).animate(anim),
            child: child,
          ),
        );
      },
    );
  }
}

// ===================================================
// 🔔 NOTIFICATION OVERLAY
// ===================================================
class _NotificationOverlay extends StatelessWidget {
  const _NotificationOverlay();

  @override
  Widget build(BuildContext context) {
    final notif = context.watch<NotificationProvider>();
    final count = notif.notifications.length;

    final double maxHeight = min(160.0 + (count * 90.0), 400.0);

    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: Material(
          color: Colors.transparent,
          child: Container(
            margin: const EdgeInsets.only(top: 90),
            width: MediaQuery.of(context).size.width * 0.92,
            constraints: BoxConstraints(maxHeight: maxHeight),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                  color: Colors.black.withOpacity(0.15),
                )
              ],
            ),
            child: Column(
              children: [
                // HEADER
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Notifikasi",
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold)),
                      notif.unreadCount > 0
                          ? GestureDetector(
                              onTap: notif.markAllAsRead,
                              child: const Text(
                                "Tandai Semua Dibaca",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                  fontSize: 12,
                                ),
                              ),
                            )
                          : const Text(
                              "Sudah Dibaca Semua",
                              style:
                                  TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                    ],
                  ),
                ),
                const Divider(height: 1),

                // LIST
                Expanded(
                  child: notif.notifications.isEmpty
                      ? const Center(
                          child: Text(
                            "Tidak ada notifikasi",
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(12),
                          itemCount: count,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (_, i) {
                            final n = notif.notifications[i];
                            return InkWell(
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const MainController(startIndex: 2),
                                  ),
                                  (_) => false,
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: n["isRead"]
                                      ? Colors.white
                                      : const Color(0xFFFFF3F3),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: n["isRead"]
                                        ? Colors.grey.shade300
                                        : const Color(0xFFEDC7C7),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      n["message"],
                                      style: TextStyle(
                                        fontWeight: n["isRead"]
                                            ? FontWeight.normal
                                            : FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      DateTime.parse(n["createdAt"])
                                          .toLocal()
                                          .toString()
                                          .substring(11, 16),
                                      style: const TextStyle(
                                          fontSize: 11, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),

                const Divider(height: 1),

                // FOOTER
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const MainController(startIndex: 2),
                      ),
                      (_) => false,
                    );
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      "Lihat Semua Pesanan",
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
