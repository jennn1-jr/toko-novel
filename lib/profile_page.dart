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

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _bioController = TextEditingController();
    // Tidak load data di initState jika menggunakan StreamBuilder
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil berhasil diperbarui'), backgroundColor: Colors.green),
        );
        setState(() {
           _isEditing = false; // Kembali ke mode lihat setelah simpan
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memperbarui profil: $e'), backgroundColor: Colors.red),
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
            title: const Text('Hapus Akun'),
            content: const Text('Apakah Anda yakin ingin menghapus akun Anda secara permanen? Tindakan ini tidak dapat diurungkan.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Hapus', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ) ?? false; // ?? false jika dialog ditutup tanpa memilih

    if (confirm) {
      setState(() => _isLoading = true);
      try {
        await _firestoreService.deleteUserAccount();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Akun berhasil dihapus'), backgroundColor: Colors.green),
          );
          // Navigasi ke halaman login setelah akun dihapus
          Navigator.of(context).pushAndRemoveUntil(
             MaterialPageRoute(builder: (context) => const LoginPage()),
             (Route<dynamic> route) => false, // Hapus semua route sebelumnya
          );
        }
      } catch (e) {
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Gagal menghapus akun: ${e.toString()}'), backgroundColor: Colors.red),
           );
        }
      } finally {
        if (mounted) {
           setState(() => _isLoading = false);
        }
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Pengguna'),
        backgroundColor: const Color(0xFF6B5844),
        actions: [
          // Tombol Edit/Simpan
          StreamBuilder<UserProfile?>(
             stream: _firestoreService.getUserProfileStream(),
             builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data == null) {
                  return const SizedBox.shrink(); // Jangan tampilkan tombol jika data belum ada
                }
                final userProfile = snapshot.data!;
                return IconButton(
                   icon: Icon(_isEditing ? Icons.save : Icons.edit),
                   onPressed: _isLoading ? null : () {
                      if (_isEditing) {
                         _saveProfile(userProfile);
                      } else {
                         // Masuk mode edit, isi controller dengan data saat ini
                         _nameController.text = userProfile.name;
                         _bioController.text = userProfile.bio;
                         setState(() => _isEditing = true);
                      }
                   },
                );
             }
          ),
          // Tombol Logout
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if(mounted) {
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
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data == null) {
            // Ini seharusnya tidak terjadi jika getUserProfileStream membuat profil default
            return const Center(child: Text('Profil tidak ditemukan.'));
          }

          final userProfile = snapshot.data!;
          // Pastikan controller diupdate saat data stream berubah & tidak dalam mode edit
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
                                     CircleAvatar(
                                        radius: 50,
                                        backgroundColor: Colors.grey.shade300,
                                        // Tambahkan child untuk menampilkan gambar profil jika ada
                                        // child: userProfile.photoUrl != null && userProfile.photoUrl!.isNotEmpty
                                        //     ? ClipOval(child: Image.network(userProfile.photoUrl!, fit: BoxFit.cover))
                                        //     : Icon(Icons.person, size: 50, color: Colors.grey.shade700),
                                        child: Icon(Icons.person, size: 50, color: Colors.grey.shade700),
                                     ),
                                     if (_isEditing)
                                        Positioned(
                                           bottom: 0,
                                           right: 0,
                                           child: CircleAvatar(
                                              radius: 18,
                                              backgroundColor: Theme.of(context).primaryColor,
                                              child: IconButton(
                                                 icon: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                                                 onPressed: () {
                                                    // TODO: Implement image picking logic
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                       const SnackBar(content: Text('Fitur ganti foto belum diimplementasikan.')),
                                                    );
                                                 },
                                              ),
                                           ),
                                        ),
                                  ],
                               ),
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: _nameController,
                              enabled: _isEditing, // Aktifkan hanya saat mode edit
                              decoration: const InputDecoration(
                                labelText: 'Nama',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.person_outline),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Nama tidak boleh kosong';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _bioController,
                              enabled: _isEditing, // Aktifkan hanya saat mode edit
                              decoration: const InputDecoration(
                                labelText: 'Bio',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.info_outline),
                              ),
                              maxLines: 3,
                              // Validator opsional untuk bio
                            ),
                            const SizedBox(height: 30),
                            // Hanya tampilkan tombol Hapus Akun jika tidak sedang mengedit profil
                             if (!_isEditing)
                               Center(
                                 child: TextButton.icon(
                                  icon: const Icon(Icons.delete_forever, color: Colors.red),
                                  label: const Text('Hapus Akun', style: TextStyle(color: Colors.red)),
                                  onPressed: _isLoading ? null : _deleteAccount,
                                                                 ),
                               ),

                         ],
                      ),
                   ),
                ),
                 // Loading Indicator
                 if (_isLoading)
                   Container(
                     color: Colors.black.withOpacity(0.5),
                     child: const Center(
                       child: CircularProgressIndicator(),
                     ),
                   ),
             ],
          );
        },
      ),
    );
  }
}