import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tokonovel/login_register.dart'; // Import halaman login
import 'package:tokonovel/models/user_models.dart';
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
  static const Color kBackgroundColor = Color(0xFF121212);
  static const Color kPrimaryColor = Color(0xFFFDE047); // Estimasi kuning
  static const Color kSecondaryTextColor = Color(0xFFBDBDBD);
  static const Color kTextFieldColor = Color(0xFF1E1E1E);
  static const Color kErrorColor = Colors.red;
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
              backgroundColor: Colors.green),
        );
        setState(() {
          _isEditing = false;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Gagal memperbarui profil: $e'),
              backgroundColor: Colors.red),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteAccount() async {
    final bool confirm = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            // --- UI DIALOG DIUBAH ---
            backgroundColor: kTextFieldColor,
            title: const Text('Hapus Akun',
                style: TextStyle(color: Colors.white)),
            content: const Text(
              'Apakah Anda yakin ingin menghapus akun Anda secara permanen? Tindakan ini tidak dapat diurungkan.',
              style: TextStyle(color: kSecondaryTextColor),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Batal',
                    style: TextStyle(color: kSecondaryTextColor)),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Hapus', style: TextStyle(color: kErrorColor)),
              ),
            ],
            // --- END OF UI DIALOG ---
          ),
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
                backgroundColor: Colors.green),
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
                backgroundColor: Colors.red),
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
    return Scaffold(
      // --- UI SCAFFOLD DIUBAH ---
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: const Text('Profil Pengguna',
            style: TextStyle(color: Colors.white)),
        // Mengubah warna panah kembali
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kPrimaryColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: kBackgroundColor,
        elevation: 0, // Hapus bayangan app bar
        actionsIconTheme: const IconThemeData(
            color: kPrimaryColor), // Ubah warna ikon di actions
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
              }),
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
            return const Center(
                child: CircularProgressIndicator(color: kPrimaryColor));
          }
          if (snapshot.hasError) {
            // --- UI ERROR DIUBAH ---
            return Center(
                child: Text('Error: ${snapshot.error}',
                    style: const TextStyle(color: kSecondaryTextColor)));
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(
                child: Text('Profil tidak ditemukan.',
                    style: TextStyle(color: kSecondaryTextColor)));
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
                              backgroundColor: kPrimaryColor,
                              child: CircleAvatar(
                                radius: 50,
                                backgroundColor: kTextFieldColor,
                                child: Icon(Icons.person,
                                    size: 50, color: kPrimaryColor),
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
                                  backgroundColor: kPrimaryColor,
                                  child: IconButton(
                                    icon: const Icon(Icons.camera_alt,
                                        color: kBackgroundColor, size: 18),
                                    onPressed: () {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                'Fitur ganti foto belum diimplementasikan.')),
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
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Nama',
                          labelStyle:
                              const TextStyle(color: kSecondaryTextColor),
                          prefixIcon:
                              const Icon(Icons.person_outline, color: kPrimaryColor),
                          filled: true,
                          fillColor: kTextFieldColor,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0),
                            borderSide: BorderSide(color: Colors.grey[800]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0),
                            borderSide: const BorderSide(color: kPrimaryColor),
                          ),
                          disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0),
                            borderSide: BorderSide(color: Colors.grey[800]!),
                          ),
                          errorStyle: const TextStyle(color: kErrorColor),
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
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Bio',
                          labelStyle:
                              const TextStyle(color: kSecondaryTextColor),
                          prefixIcon:
                              const Icon(Icons.info_outline, color: kPrimaryColor),
                          filled: true,
                          fillColor: kTextFieldColor,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0),
                            borderSide: BorderSide(color: Colors.grey[800]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0),
                            borderSide: const BorderSide(color: kPrimaryColor),
                          ),
                          disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0),
                            borderSide: BorderSide(color: Colors.grey[800]!),
                          ),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 30),

                      // --- UI TOMBOL HAPUS AKUN DIUBAH ---
                      if (!_isEditing)
                        Center(
                          child: TextButton.icon(
                            icon: const Icon(Icons.delete_forever,
                                color: kErrorColor),
                            label: const Text('Hapus Akun',
                                style: TextStyle(color: kErrorColor)),
                            onPressed: _isLoading ? null : _deleteAccount,
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                                side: const BorderSide(color: kErrorColor)
                              )
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
                  color: kBackgroundColor.withOpacity(0.7),
                  child: const Center(
                    child: CircularProgressIndicator(color: kPrimaryColor),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}