import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:tokonovel/login_register.dart';
import 'package:tokonovel/models/user_models.dart';
import 'package:tokonovel/services/firestore_service.dart';
import 'package:tokonovel/theme.dart';

class SettingsPage extends StatefulWidget {
  final UserProfile userProfile;

  const SettingsPage({Key? key, required this.userProfile}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final FirestoreService _firestoreService = FirestoreService();
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late TextEditingController _addressController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userProfile.name);
    _bioController = TextEditingController(text: widget.userProfile.bio);
    _addressController = TextEditingController(text: widget.userProfile.address);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final updatedProfile = widget.userProfile.copyWith(
          name: _nameController.text.trim(),
          bio: _bioController.text.trim(),
          address: _addressController.text.trim(),
        );

        await _firestoreService.setUserProfile(updatedProfile);

        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await user.updateDisplayName(_nameController.text.trim());
          await user.reload();
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profil berhasil disimpan!'), backgroundColor: Colors.green),
          );
          Navigator.pop(context); // Kembali ke profil setelah simpan
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal: $e'), backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _pickAndUploadImage() async {
    final XFile? imageFile = await _picker.pickImage(source: ImageSource.gallery);
    if (imageFile == null) return;

    setState(() => _isLoading = true);

    try {
      final Uint8List imageBytes = await imageFile.readAsBytes();
      img.Image? originalImage = img.decodeImage(imageBytes);
      if (originalImage == null) throw Exception("Format gambar tidak didukung");

      img.Image resizedImage = img.copyResize(originalImage, width: 300);
      final Uint8List resizedBytes = Uint8List.fromList(img.encodeJpg(resizedImage, quality: 85));
      String base64Image = base64Encode(resizedBytes);

      await _firestoreService.uploadProfileImage(base64Image);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Foto diperbarui!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal upload: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteAccount() async {
    final bool confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        final isDark = backgroundColorNotifier.value == const Color(0xFF1A1A1A);
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF2A2A2A) : Colors.white,
          title: Text('Hapus Akun?', style: TextStyle(color: isDark ? Colors.white : Colors.black)),
          content: Text('Semua data akan hilang permanen.', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.black87)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Batal")),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("Hapus", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    ) ?? false;

    if (confirm) {
      setState(() => _isLoading = true);
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
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal: $e")));
          setState(() => _isLoading = false);
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
        final surfaceColor = isDarkMode ? const Color(0xFF2A2A2A) : Colors.white;
        final textColor = isDarkMode ? Colors.white : Colors.black87;
        final primaryGold = const Color(0xFFD4AF37);

        // Ambil foto realtime via stream agar update langsung terlihat
        return StreamBuilder<UserProfile?>(
          stream: _firestoreService.getUserProfileStream(),
          initialData: widget.userProfile,
          builder: (context, snapshot) {
            final profile = snapshot.data ?? widget.userProfile;
            Uint8List? photoBytes;
            if (profile.photoUrl.isNotEmpty) {
              try { photoBytes = base64Decode(profile.photoUrl); } catch (_) {}
            }

            return Scaffold(
              backgroundColor: backgroundColor,
              appBar: AppBar(
                backgroundColor: surfaceColor,
                elevation: 0,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back, color: textColor),
                  onPressed: () => Navigator.pop(context),
                ),
                title: Text("Edit Profil", style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
                actions: [
                  if (!_isLoading)
                    IconButton(
                      icon: const Icon(Icons.check, color: Colors.green),
                      onPressed: _saveProfile,
                    )
                ],
              ),
              body: Stack(
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Center(
                            child: Stack(
                              children: [
                                CircleAvatar(
                                  radius: 60,
                                  backgroundColor: Colors.grey[200],
                                  backgroundImage: photoBytes != null ? MemoryImage(photoBytes) : null,
                                  child: photoBytes == null ? Icon(Icons.person, size: 60, color: Colors.grey[400]) : null,
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: GestureDetector(
                                    onTap: _pickAndUploadImage,
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: primaryGold,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: surfaceColor, width: 3),
                                      ),
                                      child: const Icon(Icons.camera_alt, size: 20, color: Colors.black),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 30),
                          _buildTextField(controller: _nameController, label: "Nama Lengkap", icon: Icons.person, isDark: isDarkMode, gold: primaryGold),
                          const SizedBox(height: 16),
                          _buildTextField(controller: _bioController, label: "Bio", icon: Icons.info_outline, isDark: isDarkMode, gold: primaryGold),
                          const SizedBox(height: 16),
                          _buildTextField(controller: _addressController, label: "Alamat", icon: Icons.location_on, isDark: isDarkMode, gold: primaryGold, maxLines: 3),
                          
                          const SizedBox(height: 40),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.red.withOpacity(0.3)),
                            ),
                            child: Column(
                              children: [
                                const Text("Zona Bahaya", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                ElevatedButton(
                                  onPressed: _deleteAccount,
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red, elevation: 0),
                                  child: const Text("Hapus Akun Permanen", style: TextStyle(color: Colors.white)),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  if (_isLoading)
                    Container(
                      color: Colors.black54,
                      child: Center(child: CircularProgressIndicator(color: primaryGold)),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDark,
    required Color gold,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: TextStyle(color: isDark ? Colors.white : Colors.black),
      validator: (val) => val!.isEmpty ? "$label tidak boleh kosong" : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
        prefixIcon: Icon(icon, color: gold),
        filled: true,
        fillColor: isDark ? const Color(0xFF2A2A2A) : Colors.grey[50],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: gold)),
      ),
    );
  }
}