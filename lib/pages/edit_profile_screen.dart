// lib/pages/edit_profile_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';

// Import Provider dan Model dari lokasi yang benar
import '../providers/store_provider.dart'; 
import '../models/user_model.dart'; 
import '../services/user_api.dart'; 

class EditProfileScreen extends HookWidget {
  EditProfileScreen({super.key});

  final UserApi apiService = UserApi(); 

  // Helper toggle password
  void _togglePasswordVisibility(ValueNotifier<Map<String, bool>> showPasswords, String field) {
    showPasswords.value = {
      ...showPasswords.value,
      field: !showPasswords.value[field]!,
    };
  }

  // Helper Toast
  void _showToast(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade800 : Colors.green.shade800,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final storeProvider = context.watch<StoreProvider>();
    final user = storeProvider.user;

    // State Hooks
    final activeSection = useState('profile'); // 'profile' atau 'security'
    final isLoading = useState(false);
    final showPasswords = useState<Map<String, bool>>({
      'oldPassword': false, 'newPassword': false, 'confirmNewPassword': false,
    });
    
    // Controllers
    final nameController = useTextEditingController(text: user?.name ?? '');
    final emailController = useTextEditingController(text: user?.email ?? '');
    final oldPasswordController = useTextEditingController();
    final newPasswordController = useTextEditingController();
    final confirmNewPasswordController = useTextEditingController();

    // Sinkronisasi data awal
    useEffect(() {
      if (user != null) {
        nameController.text = user.name;
        emailController.text = user.email;
      }
      return null;
    }, [user]);

    // Fungsi Submit
    Future<void> handleUpdateProfile() async {
      if (isLoading.value) return;
      isLoading.value = true;
      
      final currentName = nameController.text.trim();
      final currentEmail = emailController.text.trim();
      final oldPassword = oldPasswordController.text;
      final newPassword = newPasswordController.text;
      final confirmNewPassword = confirmNewPasswordController.text;

      // Validasi Password
      if (newPassword.isNotEmpty) {
        if (newPassword != confirmNewPassword) {
          _showToast(context, "Konfirmasi kata sandi tidak cocok!", isError: true);
          isLoading.value = false;
          return;
        }
        if (oldPassword.isEmpty) {
          _showToast(context, "Harap masukkan kata sandi lama!", isError: true);
          isLoading.value = false;
          return;
        }
      }

      // Filter Data
      final Map<String, dynamic> dataToSend = {};
      if (currentName != user?.name) dataToSend['name'] = currentName;
      if (currentEmail != user?.email) dataToSend['email'] = currentEmail;
      
      if (newPassword.isNotEmpty) {
        dataToSend['oldPassword'] = oldPassword;
        dataToSend['newPassword'] = newPassword;
      }

      if (dataToSend.isEmpty) {
        _showToast(context, "Tidak ada perubahan yang terdeteksi.");
        isLoading.value = false;
        return;
      }

      try {
        final token = context.read<StoreProvider>().token; 
        if (token == null) throw Exception("Token tidak ditemukan.");

        final updatedResponse = await apiService.updateProfile(token, dataToSend);
        
        storeProvider.setUser(User(
          id: user!.id,
          name: updatedResponse['name'] ?? user.name, 
          email: updatedResponse['email'] ?? user.email, 
          token: user.token,
        ));
        
        _showToast(context, "✅ Profil berhasil diperbarui!");

        // Reset password fields
        oldPasswordController.clear();
        newPasswordController.clear();
        confirmNewPasswordController.clear();
        showPasswords.value = { 'oldPassword': false, 'newPassword': false, 'confirmNewPassword': false };

      } on Exception catch (e) {
        _showToast(context, e.toString().replaceFirst('Exception: ', '❌ '), isError: true);
      } catch (e) {
        _showToast(context, "❌ Terjadi kesalahan tidak terduga.", isError: true);
      } finally {
        isLoading.value = false;
      }
    }

    void clearPasswordFields() {
      oldPasswordController.clear();
      newPasswordController.clear();
      confirmNewPasswordController.clear();
      showPasswords.value = {
        'oldPassword': false, 'newPassword': false, 'confirmNewPassword': false,
      };
    }

    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade50, // Background sedikit abu agar Card menonjol
      appBar: AppBar(
        title: const Text('Edit Profil'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(context),
            const SizedBox(height: 20),

            // 🔽 1. DROPDOWN SELECTION (Pengganti Sidebar)
            _buildSectionDropdown(context, activeSection),
            
            const SizedBox(height: 20),

            // 📦 2. FORM BOX (Card)
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tampilkan form sesuai pilihan dropdown
                      if (activeSection.value == 'profile')
                        _buildProfileForm(context, nameController, emailController, user)
                      else
                        _buildSecurityForm(
                          context,
                          oldPasswordController,
                          newPasswordController,
                          confirmNewPasswordController,
                          showPasswords,
                          clearPasswordFields,
                          _togglePasswordVisibility,
                        ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
            
            // TOMBOL SIMPAN
            ElevatedButton.icon(
              onPressed: isLoading.value ? null : handleUpdateProfile,
              icon: isLoading.value 
                  ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) 
                  : const Icon(Icons.check_circle_outline),
              label: Text(
                isLoading.value ? 'Menyimpan Perubahan...' : 'Simpan Perubahan',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // ===================================================
  // WIDGET BUILDERS
  // ===================================================

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Pengaturan Akun", 
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black87)
        ),
        const SizedBox(height: 6),
        Text(
          "Perbarui profil atau ubah kata sandi Anda di sini.", 
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600)
        ),
      ],
    );
  }
  
  // 🔽 WIDGET BARU: DROPDOWN MENU
  Widget _buildSectionDropdown(BuildContext context, ValueNotifier<String> activeSection) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: activeSection.value,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down, color: Colors.red.shade700),
          style: const TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.w600),
          onChanged: (String? newValue) {
            if (newValue != null) {
              activeSection.value = newValue;
            }
          },
          items: [
            DropdownMenuItem(
              value: 'profile',
              child: Row(
                children: [
                  Icon(Icons.person, color: activeSection.value == 'profile' ? Colors.red.shade700 : Colors.grey),
                  const SizedBox(width: 12),
                  const Text('Informasi Profil'),
                ],
              ),
            ),
            DropdownMenuItem(
              value: 'security',
              child: Row(
                children: [
                  Icon(Icons.lock, color: activeSection.value == 'security' ? Colors.red.shade700 : Colors.grey),
                  const SizedBox(width: 12),
                  const Text('Keamanan & Kata Sandi'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileForm(BuildContext context, TextEditingController nameController, TextEditingController emailController, User user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.badge_outlined, color: Colors.red.shade700),
            const SizedBox(width: 8),
            const Text("Data Diri", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        const Divider(height: 30),
        _buildTextField('Nama Lengkap', nameController, Icons.person_outline, context),
        const SizedBox(height: 20),
        _buildTextField('Alamat Email', emailController, Icons.email_outlined, context, isReadOnly: true, hint: "Email tidak dapat diubah"),
      ],
    );
  }

  Widget _buildSecurityForm(
    BuildContext context, 
    TextEditingController oldPasswordController, 
    TextEditingController newPasswordController, 
    TextEditingController confirmNewPasswordController, 
    ValueNotifier<Map<String, bool>> showPasswords, 
    VoidCallback clearPasswordFields, 
    Function(ValueNotifier<Map<String, bool>>, String) toggleVisibility
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.security, color: Colors.red.shade700),
                const SizedBox(width: 8),
                const Text("Ubah Kata Sandi", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            TextButton(
              onPressed: clearPasswordFields,
              child: Text('Reset', style: TextStyle(color: Colors.red.shade400)),
            ),
          ],
        ),
        const Divider(height: 30),
        _buildPasswordField(
          'Kata Sandi Lama', 
          oldPasswordController, 
          'oldPassword', 
          showPasswords, 
          toggleVisibility, 
          context
        ),
        const SizedBox(height: 16),
        _buildPasswordField(
          'Kata Sandi Baru', 
          newPasswordController, 
          'newPassword', 
          showPasswords, 
          toggleVisibility, 
          context
        ),
        const SizedBox(height: 16),
        _buildPasswordField(
          'Konfirmasi Kata Sandi Baru', 
          confirmNewPasswordController, 
          'confirmNewPassword', 
          showPasswords, 
          toggleVisibility, 
          context
        ),
      ],
    );
  }

  // Helper TextField
  Widget _buildTextField(String label, TextEditingController controller, IconData icon, BuildContext context, {bool isReadOnly = false, String? hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey.shade700)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: isReadOnly,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: Colors.grey.shade600),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.red.shade700, width: 1.5)),
            filled: isReadOnly,
            fillColor: isReadOnly ? Colors.grey.shade100 : Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
          ),
          style: TextStyle(color: isReadOnly ? Colors.grey.shade600 : Colors.black87),
        ),
      ],
    );
  }

  // Helper Password Field
  Widget _buildPasswordField(String label, TextEditingController controller, String fieldKey, ValueNotifier<Map<String, bool>> showPasswords, Function(ValueNotifier<Map<String, bool>>, String) toggleVisibility, BuildContext context) {
    final isVisible = showPasswords.value[fieldKey] ?? false;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey.shade700)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: !isVisible,
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.lock_outline, color: Colors.grey.shade600),
            suffixIcon: IconButton(
              icon: Icon(isVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: Colors.grey),
              onPressed: () => toggleVisibility(showPasswords, fieldKey),
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.red.shade700, width: 1.5)),
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ],
    );
  }
}