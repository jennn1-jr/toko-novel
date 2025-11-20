// profile_page.dart (LENGKAP DAN SUDAH DIPERBAIKI)

import 'dart:convert'; // <-- 1. IMPORT DIPERLUKAN
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart'; // <-- 2. IMPORT DIPERLUKAN
import 'package:image/image.dart' as img; // <-- 3. IMPORT DIPERLUKAN
import 'package:tokonovel/login_register.dart';
import 'package:tokonovel/models/user_models.dart';
import 'package:tokonovel/theme.dart';
import 'package:tokonovel/user_order_history_page.dart'; // Import UserOrderHistoryPage
import 'services/firestore_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirestoreService _firestoreService = FirestoreService();
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late TextEditingController _addressController; // Tambahkan controller untuk address
  bool _isLoading = false;
  bool _isEditing = false;

  final ImagePicker _picker = ImagePicker(); // <-- 4. VARIABEL DIPERLUKAN

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _bioController = TextEditingController();
    _addressController = TextEditingController(); // Inisialisasi address controller
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _addressController.dispose(); // Dispose address controller
    super.dispose();
  }

  // --- FUNGSI LOGIKA (DIPERBAIKI) ---
  Future<void> _saveProfile(UserProfile currentProfile) async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        // 5. DIPERBAIKI: Menggunakan copyWith agar photoUrl tidak hilang
        final updatedProfile = currentProfile.copyWith(
          name: _nameController.text.trim(),
          bio: _bioController.text.trim(),
          address: _addressController.text.trim(), // Tambahkan address
        );

        await _firestoreService.setUserProfile(updatedProfile);

        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await user.updateDisplayName(_nameController.text.trim());
          await user.reload();
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil berhasil diperbarui'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          _isEditing = false;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memperbarui profil: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  // --- 6. FUNGSI BARU UNTUK PILIH & UPLOAD GAMBAR ---
  Future<void> _pickAndUploadImage() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // 1. Pilih Gambar
    final XFile? imageFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (imageFile == null) return; // User membatalkan

    setState(() => _isLoading = true);

    try {
      // 2. Baca file sebagai bytes
      final Uint8List imageBytes = await imageFile.readAsBytes();

      // 3. RESIZE GAMBAR (SANGAT PENTING!)
      img.Image? originalImage = img.decodeImage(imageBytes);
      if (originalImage == null) {
        throw Exception("Format gambar tidak didukung");
      }

      // Resize ke lebar 300px (kualitas akan turun, tapi aman untuk Firestore)
      img.Image resizedImage = img.copyResize(originalImage, width: 300);

      // Ubah kembali ke Uint8List (sebagai JPEG terkompresi)
      final Uint8List resizedBytes = Uint8List.fromList(
        img.encodeJpg(resizedImage, quality: 85),
      );

      // 4. Ubah ke Base64
      String base64Image = base64Encode(resizedBytes);

      // 5. Panggil service untuk menyimpan string Base64
      // Sesuai firestore_service.dart Anda, fungsi ini hanya perlu 1 argumen
      await _firestoreService.uploadProfileImage(base64Image);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Foto profil berhasil diperbarui!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengunggah foto: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
  // --- BATAS FUNGSI BARU ---

  Future<void> _deleteAccount() async {
    // ... (Fungsi _deleteAccount Anda sudah benar, tidak diubah) ...
    final bool confirm =
        await showDialog<bool>(
          context: context,
          builder: (context) {
            final bg = backgroundColorNotifier.value;
            final isDark = bg == const Color(0xFF1A1A1A);
            final dialogBg = isDark
                ? const Color(0xFF2A2A2A)
                : const Color(0xFFF5F5F5);
            final secondaryText = isDark
                ? Colors.grey[400]!
                : Colors.grey[700]!;
            final errorColor = Colors.red[400]!;

            return AlertDialog(
              backgroundColor: dialogBg,
              title: Text(
                'Hapus Akun',
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              ),
              content: Text(
                'Apakah Anda yakin ingin menghapus akun Anda secara permanen? Tindakan ini tidak dapat diurungkan.',
                style: TextStyle(color: secondaryText),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text('Batal', style: TextStyle(color: secondaryText)),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text('Hapus', style: TextStyle(color: errorColor)),
                ),
              ],
            );
          },
        ) ??
        false;

    if (confirm) {
      setState(() => _isLoading = true);
      try {
        await _firestoreService.deleteUserAccount();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Akun berhasil dihapus'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginPage()),
            (Route<dynamic> route) => false,
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal menghapus akun: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }
  // --- END OF FUNGSI LOGIKA ---

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Color>(
      valueListenable: backgroundColorNotifier,
      builder: (context, backgroundColor, child) {
        final isDarkMode = backgroundColor == const Color(0xFF1A1A1A);
        final Color primaryColor = const Color(0xFFD4AF37);
        final Color secondaryTextColor = isDarkMode
            ? Colors.grey[400]!
            : Colors.grey[700]!;
        final Color textFieldColor = isDarkMode
            ? const Color(0xFF2A2A2A)
            : const Color(0xFFF5F5F5);
        final Color textColor = isDarkMode ? Colors.white : Colors.black87;

        return Scaffold(
          backgroundColor: backgroundColor,
          appBar: AppBar(
            title: Text('Profil Pengguna', style: TextStyle(color: textColor)),
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: primaryColor),
              onPressed: () => Navigator.of(context).pop(),
            ),
            backgroundColor: backgroundColor,
            elevation: 0,
            actionsIconTheme: IconThemeData(color: primaryColor),
            actions: [
              StreamBuilder<UserProfile?>(
                stream: _firestoreService.getUserProfileStream(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data == null) {
                    return const SizedBox.shrink();
                  }
                  final userProfile = snapshot.data!;
                  return IconButton(
                    icon: Icon(_isEditing ? Icons.save : Icons.edit),
                    onPressed: _isLoading
                        ? null
                        : () {
                            if (_isEditing) {
                              _saveProfile(userProfile);
                            } else {
                              _nameController.text = userProfile.name;
                              _bioController.text = userProfile.bio;
                              setState(() => _isEditing = true);
                            }
                          },
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  if (mounted) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                    );
                  }
                },
              ),
            ],
          ),
          body: StreamBuilder<UserProfile?>(
            stream: _firestoreService.getUserProfileStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(color: primaryColor),
                );
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error: ${snapshot.error}',
                    style: TextStyle(color: secondaryTextColor),
                  ),
                );
              }
              if (!snapshot.hasData || snapshot.data == null) {
                return Center(
                  child: Text(
                    'Profil tidak ditemukan.',
                    style: TextStyle(color: secondaryTextColor),
                  ),
                );
              }

              final userProfile = snapshot.data!;
              if (!_isEditing) {
                _nameController.text = userProfile.name;
                _bioController.text = userProfile.bio;
                _addressController.text = userProfile.address; // Populate address field
              }

              // --- 7. LOGIKA BARU UNTUK DECODE GAMBAR BASE64 ---
              final bool hasPhotoData = userProfile.photoUrl.isNotEmpty;
              Uint8List? photoBytes;
              if (hasPhotoData) {
                try {
                  // Coba decode string Base64
                  photoBytes = base64Decode(userProfile.photoUrl);
                } catch (e) {
                  print("Gagal decode Base64: $e");
                  photoBytes = null; // Gagal decode, anggap tidak ada foto
                }
              }
              // --- BATAS LOGIKA BARU ---

              return Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: ListView(
                        children: [
                          Center(
                            child: Stack(
                              children: [
                                // --- 8. UI AVATAR DIPERBAIKI ---
                                CircleAvatar(
                                  radius: 52,
                                  backgroundColor: primaryColor,
                                  child: CircleAvatar(
                                    radius: 50,
                                    backgroundColor: textFieldColor,
                                    backgroundImage: (photoBytes != null)
                                        ? MemoryImage(
                                            photoBytes,
                                          ) // Tampilkan gambar
                                        : null,
                                    child: (photoBytes != null)
                                        ? null // Sembunyikan ikon jika ada gambar
                                        : Icon(
                                            Icons.person,
                                            size: 50,
                                            color: primaryColor,
                                          ),
                                  ),
                                ),
                                // --- 9. TOMBOL KAMERA DIPERBAIKI ---
                                if (_isEditing)
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: CircleAvatar(
                                      radius: 18,
                                      backgroundColor: primaryColor,
                                      child: IconButton(
                                        icon: Icon(
                                          Icons.camera_alt,
                                          color: backgroundColor,
                                          size: 18,
                                        ),
                                        // Panggil fungsi upload yang benar
                                        onPressed: _isLoading
                                            ? null
                                            : _pickAndUploadImage,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // --- FORM 'NAMA' (Sudah Benar) ---
                          TextFormField(
                            controller: _nameController,
                            enabled: _isEditing,
                            style: TextStyle(color: textColor),
                            decoration: InputDecoration(
                              labelText: 'Nama',
                              labelStyle: TextStyle(color: secondaryTextColor),
                              prefixIcon: Icon(
                                Icons.person_outline,
                                color: primaryColor,
                              ),
                              filled: true,
                              fillColor: textFieldColor,
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15.0),
                                borderSide: BorderSide(
                                  color: isDarkMode
                                      ? Colors.grey[800]!
                                      : Colors.grey[300]!,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15.0),
                                borderSide: BorderSide(color: primaryColor),
                              ),
                              disabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15.0),
                                borderSide: BorderSide(
                                  color: isDarkMode
                                      ? Colors.grey[800]!
                                      : Colors.grey[300]!,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Nama tidak boleh kosong';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // --- FORM 'BIO' (Sudah Benar) ---
                          TextFormField(
                            controller: _bioController,
                            enabled: _isEditing,
                            style: TextStyle(color: textColor),
                            decoration: InputDecoration(
                              labelText: 'Bio',
                              labelStyle: TextStyle(color: secondaryTextColor),
                              prefixIcon: Icon(
                                Icons.info_outline,
                                color: primaryColor,
                              ),
                              filled: true,
                              fillColor: textFieldColor,
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15.0),
                                borderSide: BorderSide(
                                  color: isDarkMode
                                      ? Colors.grey[800]!
                                      : Colors.grey[300]!,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15.0),
                                borderSide: BorderSide(color: primaryColor),
                              ),
                              disabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15.0),
                                borderSide: BorderSide(
                                  color: isDarkMode
                                      ? Colors.grey[800]!
                                      : Colors.grey[300]!,
                                ),
                              ),
                            ),
                            maxLines: 3,
                          ),
                          const SizedBox(height: 16),

                          // --- FORM 'ADDRESS' ---
                          TextFormField(
                            controller: _addressController,
                            enabled: _isEditing,
                            style: TextStyle(color: textColor),
                            decoration: InputDecoration(
                              labelText: 'Alamat',
                              labelStyle: TextStyle(color: secondaryTextColor),
                              prefixIcon: Icon(
                                Icons.home_outlined,
                                color: primaryColor,
                              ),
                              filled: true,
                              fillColor: textFieldColor,
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15.0),
                                borderSide: BorderSide(
                                  color: isDarkMode
                                      ? Colors.grey[800]!
                                      : Colors.grey[300]!,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15.0),
                                borderSide: BorderSide(color: primaryColor),
                              ),
                              disabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15.0),
                                borderSide: BorderSide(
                                  color: isDarkMode
                                      ? Colors.grey[800]!
                                      : Colors.grey[300]!,
                                ),
                              ),
                            ),
                            maxLines: 3,
                          ),
                          const SizedBox(height: 30),

                          // --- RIWAYAT PESANAN ---
                          if (!_isEditing)
                            ListTile(
                              leading: Icon(Icons.history, color: primaryColor),
                              title: Text(
                                'Riwayat Pesanan',
                                style: TextStyle(color: textColor),
                              ),
                              trailing: Icon(Icons.arrow_forward_ios,
                                  color: secondaryTextColor, size: 16),
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const UserOrderHistoryPage(),
                                  ),
                                );
                              },
                            ),
                          const SizedBox(height: 30),

                          // --- TOMBOL HAPUS AKUN (Sudah Benar) ---
                          if (!_isEditing)
                            Center(
                              child: TextButton.icon(
                                icon: Icon(
                                  Icons.delete_forever,
                                  color: Colors.red[400],
                                ),
                                label: Text(
                                  'Hapus Akun',
                                  style: TextStyle(color: Colors.red[400]),
                                ),
                                onPressed: _isLoading ? null : _deleteAccount,
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30.0),
                                    side: BorderSide(color: Colors.red[400]!),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  // --- LOADING OVERLAY (Sudah Benar) ---
                  if (_isLoading)
                    Container(
                      color: backgroundColor.withOpacity(0.7),
                      child: Center(
                        child: CircularProgressIndicator(color: primaryColor),
                      ),
                    ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
