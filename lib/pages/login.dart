// lib/pages/login_page.dart

// ignore: unused_import
import 'dart:convert'; // Tetap diperlukan untuk jsonEncode jika menggunakan http di sini, TAPI akan dihapus di versi baru
import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http; // TIDAK PERLU lagi di widget
import 'package:provider/provider.dart'; // WAJIB untuk mengakses StoreProvider
import '../providers/store_provider.dart'; // Import StoreProvider

class LoginPage extends StatefulWidget {
  final VoidCallback onLoginSuccess;

  const LoginPage({super.key, required this.onLoginSuccess});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  
  // State isLoading dan Error Message sekarang diurus oleh StoreProvider
  // bool isLoading = false; // TIDAK PERLU LAGI

  Future<void> loginUser() async {
    // 1. Ambil instance StoreProvider
    final storeProvider = context.read<StoreProvider>();
    
    // 2. Reset error message
    storeProvider.clearErrorMessage(); // (Asumsi Anda tambahkan method ini di StoreProvider)

    // 3. Panggil fungsi login dari Provider
    final success = await storeProvider.login(
      emailController.text,
      passwordController.text,
    );

    if (success) {
      // Login berhasil, panggil callback untuk navigasi
      widget.onLoginSuccess();
    } else if (storeProvider.errorMessage != null) {
      // Tampilkan error message dari provider
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(storeProvider.errorMessage!),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 🟢 Ambil state isLoading dari provider menggunakan context.watch
    final isLoading = context.watch<StoreProvider>().isLoading;
    
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Masuk",
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.red)),
            const SizedBox(height: 30),
            // ... (TextFields tetap sama) ...
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                hintText: "Email",
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(4.0)),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: "Password Akun",
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(4.0)),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[800],
                  shape:
                      RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
                // 🟢 Menggunakan state isLoading dari StoreProvider
                onPressed: isLoading ? null : loginUser, 
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Masuk",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Belum Memiliki Akun? "),
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, "/regist");
                  },
                  child: const Text(
                    "Daftar Sekarang",
                    style:
                        TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}