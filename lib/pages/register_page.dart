import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool agree = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Gambar di atas (contoh dari assets)
              SizedBox(
                height: 180,
                child: Image.asset(
                  "assets/images/delivery.png", // ganti sesuai path asset gambar
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 20),

              // Judul
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Daftar Akun",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Input Nama Pengguna
              _buildTextField("Nama Pengguna"),
              const SizedBox(height: 16),

              // Input Nomor Telepon
              _buildTextField("Nomor Telepon", keyboardType: TextInputType.phone),
              const SizedBox(height: 16),

              // Input Buat Kata Sandi
              _buildTextField("Buat Kata Sandi", isPassword: true),
              const SizedBox(height: 16),

              // Input Konfirmasi Kata Sandi
              _buildTextField("Konfirmasi Kata Sandi", isPassword: true),
              const SizedBox(height: 20),

              // Checkbox Syarat & Ketentuan
              Row(
                children: [
                  Checkbox(
                    value: agree,
                    activeColor: Colors.red,
                    onChanged: (value) {
                      setState(() {
                        agree = value ?? false;
                      });
                    },
                  ),
                  Expanded(
                    child: RichText(
                      text: const TextSpan(
                        text: "Saya setuju dengan ",
                        style: TextStyle(color: Colors.black),
                        children: [
                          TextSpan(
                            text: "[Syarat dan Ketentuan]",
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Tombol Daftar
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[800],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: agree
                      ? () {
                          Navigator.pushNamed(context, "/login");
                        }
                      : null,
                  child: const Text(
                    "Daftar",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String hint,
      {bool isPassword = false, TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      obscureText: isPassword,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
    );
  }
}
