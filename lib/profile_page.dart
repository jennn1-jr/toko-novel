import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tokonovel/login_register.dart';
import 'package:tokonovel/models/user_models.dart';
import 'package:tokonovel/theme.dart';
import 'package:tokonovel/user_order_history_page.dart';
import 'services/firestore_service.dart';
import 'settings_page.dart'; // Pastikan file ini ada

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirestoreService _firestoreService = FirestoreService();

  // --- FUNGSI KONFIRMASI LOGOUT ---
  Future<void> _confirmLogout(BuildContext context, bool isDarkMode) async {
    final surfaceColor = isDarkMode ? const Color(0xFF2A2A2A) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;

    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              "Ingin Keluar?",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Anda perlu login kembali untuk mengakses akun ini.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: Colors.grey[600]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      "Batal",
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context); // Tutup modal
                      await FirebaseAuth.instance.signOut();
                      if (mounted) {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (_) => const LoginPage(),
                          ),
                          (route) => false,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      "Ya, Keluar",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  // --- LOGIKA HAPUS AKUN (Tetap Dipertahankan) ---
  Future<void> _deleteAccount(BuildContext context, bool isDarkMode) async {
    final surfaceColor = isDarkMode ? const Color(0xFF2A2A2A) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;

    final bool confirm = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              backgroundColor: surfaceColor,
              title: Text('Hapus Akun?', style: TextStyle(color: textColor)),
              content: Text(
                'Tindakan ini akan menghapus semua data Anda secara permanen dan tidak dapat dibatalkan.',
                style: TextStyle(
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[700]),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Batal', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text(
                      'Hapus', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        ) ??
        false;

    if (confirm) {
      try {
        await _firestoreService.deleteUserAccount();
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginPage()),
            (Route<dynamic> route) => false,
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Color>(
      valueListenable: backgroundColorNotifier,
      builder: (context, backgroundColor, child) {
        final isDarkMode = backgroundColor == const Color(0xFF1A1A1A);

        // Palette Warna Premium
        final surfaceColor =
            isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
        final scaffoldBg =
            isDarkMode ? const Color(0xFF121212) : const Color(0xFFF5F5F7);
        final primaryGold = const Color(0xFFD4AF37);
        final textColor = isDarkMode ? Colors.white : const Color(0xFF1A1A1A);
        final subTextColor = isDarkMode ? Colors.grey[400] : Colors.grey[600];
        final labelColor = isDarkMode ? Colors.grey[500] : Colors.grey[500];

        return Scaffold(
          backgroundColor: scaffoldBg,
          appBar: AppBar(
            backgroundColor: scaffoldBg,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: textColor),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              "Profil Saya",
              style: TextStyle(
                  color: textColor, fontWeight: FontWeight.bold, fontSize: 18),
            ),
            centerTitle: true,
          ),
          body: StreamBuilder<UserProfile?>(
            stream: _firestoreService.getUserProfileStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                    child: CircularProgressIndicator(color: primaryGold));
              }

              final profile = snapshot.data;
              if (profile == null) {
                return const Center(child: Text("Data tidak ditemukan"));
              }

              // Decode Image Logic
              Uint8List? photoBytes;
              if (profile.photoUrl.isNotEmpty) {
                try {
                  photoBytes = base64Decode(profile.photoUrl);
                } catch (_) {}
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // --- 1. HEADER PROFILE ---
                    Center(
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: primaryGold.withOpacity(0.5), width: 1),
                              boxShadow: [
                                BoxShadow(
                                  color: primaryGold.withOpacity(0.1),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                )
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 55,
                              backgroundColor: surfaceColor,
                              backgroundImage: photoBytes != null
                                  ? MemoryImage(photoBytes)
                                  : null,
                              child: photoBytes == null
                                  ? Icon(Icons.person,
                                      size: 50, color: Colors.grey[400])
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            profile.name.isEmpty ? "Pengguna Baru" : profile.name,
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: textColor),
                          ),
                          const SizedBox(height: 4),
                          if (profile.bio.isNotEmpty)
                            Text(
                              profile.bio,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: subTextColor, fontSize: 14),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // --- 2. INFORMASI (READ ONLY) ---
                    _buildSectionLabel("Informasi Pribadi", labelColor),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 4)),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildInfoRow("Nama Lengkap", profile.name,
                              Icons.person_outline, textColor, subTextColor),
                          Divider(
                              height: 1,
                              color: isDarkMode
                                  ? Colors.grey[800]
                                  : Colors.grey[200],
                              indent: 60),
                          _buildInfoRow(
                              "Alamat",
                              profile.address.isEmpty
                                  ? "Belum diatur"
                                  : profile.address,
                              Icons.location_on_outlined,
                              textColor,
                              subTextColor),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // --- 3. MENU PENGATURAN (NAVIGASI) ---
                    _buildSectionLabel("Menu & Pengaturan", labelColor),
                    Container(
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 4)),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Tombol Riwayat Pesanan
                          _buildMenuTile(
                            icon: Icons.shopping_bag_outlined,
                            title: "Riwayat Pesanan",
                            textColor: textColor,
                            iconColor: primaryGold,
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        const UserOrderHistoryPage())),
                          ),
                          Divider(
                              height: 1,
                              color: isDarkMode
                                  ? Colors.grey[800]
                                  : Colors.grey[200]),

                          // Tombol ke Halaman Settings (Edit Profil)
                          _buildMenuTile(
                            icon: Icons.settings_outlined,
                            title: "Pengaturan Akun & Edit Profil",
                            textColor: textColor,
                            iconColor: primaryGold,
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        SettingsPage(userProfile: profile))),
                          ),

                          Divider(
                              height: 1,
                              color: isDarkMode
                                  ? Colors.grey[800]
                                  : Colors.grey[200]),

                          // Tombol Logout (SEKARANG DENGAN KONFIRMASI)
                          _buildMenuTile(
                            icon: Icons.logout,
                            title: "Keluar",
                            textColor: Colors.redAccent,
                            iconColor: Colors.redAccent,
                            isDestructive: true,
                            onTap: () => _confirmLogout(context, isDarkMode),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    // --- 4. DANGER ZONE ---
                    TextButton(
                      onPressed: () => _deleteAccount(context, isDarkMode),
                      child: Text(
                        "Hapus Akun Permanen",
                        style:
                            TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  // --- WIDGET HELPERS ---

  Widget _buildSectionLabel(String label, Color? color) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          label.toUpperCase(),
          style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon,
      Color textColor, Color? subColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: subColor),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: subColor, fontSize: 12)),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                      color: textColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required Color textColor,
    required Color iconColor,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDestructive
                    ? Colors.red.withOpacity(0.1)
                    : iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                    color: textColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w600),
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey[600]),
          ],
        ),
      ),
    );
  }
}