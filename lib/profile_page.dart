import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tokonovel/login_register.dart'; // Import halaman login
import 'package:tokonovel/models/user_models.dart';
import 'package:tokonovel/theme.dart';
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
  bool _isLoading = false;
  bool _isEditing = false; // State untuk mode edit

  // --- PALET WARNA TEMA "NOVELKU" ---
  // Warna spesifik sekarang akan mengikuti ValueNotifier di `theme.dart`
  // (Dashboard menggunakan `backgroundColorNotifier` sehingga profil akan sama)
  // --- END OF PALET WARNA ---

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _bioController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  // --- FUNGSI LOGIKA (TIDAK BERUBAH) ---
  Future<void> _saveProfile(UserProfile currentProfile) async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final updatedProfile = UserProfile(
          uid: currentProfile.uid,
          name: _nameController.text.trim(),
          bio: _bioController.text.trim(),
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

  Future<void> _deleteAccount() async {
    final bool confirm =
        await showDialog<bool>(
          context: context,
          builder: (context) {
            // Ambil tema saat ini dari notifier agar dialog ikut mode gelap/terang
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
          // --- UI SCAFFOLD DIUBAH ---
          backgroundColor: backgroundColor,
          appBar: AppBar(
            title: Text('Profil Pengguna', style: TextStyle(color: textColor)),
            // Mengubah warna panah kembali
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: primaryColor),
              onPressed: () => Navigator.of(context).pop(),
            ),
            backgroundColor: backgroundColor,
            elevation: 0, // Hapus bayangan app bar
            actionsIconTheme: IconThemeData(
              color: primaryColor,
            ), // Ubah warna ikon di actions
            // --- END OF UI APPBAR ---
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
                // --- UI LOADING DIUBAH ---
                return Center(
                  child: CircularProgressIndicator(color: primaryColor),
                );
              }
              if (snapshot.hasError) {
                // --- UI ERROR DIUBAH ---
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
              }

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
                                // --- UI AVATAR DIUBAH ---
                                CircleAvatar(
                                  radius: 52,
                                  backgroundColor: primaryColor,
                                  child: CircleAvatar(
                                    radius: 50,
                                    backgroundColor: textFieldColor,
                                    child: Icon(
                                      Icons.person,
                                      size: 50,
                                      color: primaryColor,
                                    ),
                                    // Uncomment di bawah jika Anda punya photoUrl
                                    // backgroundImage: (userProfile.photoUrl != null && userProfile.photoUrl!.isNotEmpty)
                                    //     ? NetworkImage(userProfile.photoUrl!)
                                    //     : null,
                                    // child: (userProfile.photoUrl != null && userProfile.photoUrl!.isNotEmpty)
                                    //     ? null
                                    //     : Icon(Icons.person, size: 50, color: kPrimaryColor),
                                  ),
                                ),
                                // --- UI TOMBOL EDIT FOTO DIUBAH ---
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
                                        onPressed: () {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Fitur ganti foto belum diimplementasikan.',
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // --- UI TEXTFORMFIELD 'NAMA' DIUBAH ---
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

                          // --- UI TEXTFORMFIELD 'BIO' DIUBAH ---
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
                          const SizedBox(height: 30),

                          // --- UI TOMBOL HAPUS AKUN DIUBAH ---
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

                  // --- UI LOADING OVERLAY DIUBAH ---
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
