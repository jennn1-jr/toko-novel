import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tokonovel/models/user_models.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Mendapatkan UID user yang sedang login
  String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }

  // Referensi ke koleksi users
  CollectionReference<UserProfile> get usersCollection => _db.collection('users').withConverter<UserProfile>(
        fromFirestore: (snapshot, _) => UserProfile.fromMap(snapshot.data()!, snapshot.id),
        toFirestore: (profile, _) => profile.toMap(),
      );

  // --- Operasi CRUD ---

  // CREATE / UPDATE profile (Upsert)
  Future<void> setUserProfile(UserProfile profile) async {
    final userId = getCurrentUserId();
    if (userId == null) throw Exception("User not logged in");
    // Gunakan UID user sebagai ID dokumen
    await usersCollection.doc(userId).set(profile, SetOptions(merge: true)); // merge: true agar tidak menimpa field yang tidak diubah
  }

  // READ profile
  Future<UserProfile?> getUserProfile() async {
    final userId = getCurrentUserId();
    if (userId == null) return null;
    final docSnapshot = await usersCollection.doc(userId).get();
    if (docSnapshot.exists) {
      return docSnapshot.data();
    } else {
      // Jika profil belum ada, buat profil default
      final newUserProfile = UserProfile(uid: userId, name: _auth.currentUser?.displayName ?? 'New User', bio: '');
      await setUserProfile(newUserProfile);
      return newUserProfile;
    }
  }

  // READ profile (Stream - untuk update real-time)
  Stream<UserProfile?> getUserProfileStream() {
    final userId = getCurrentUserId();
    if (userId == null) return Stream.value(null);
    return usersCollection.doc(userId).snapshots().map((snapshot) {
       if (snapshot.exists) {
          return snapshot.data();
       } else {
         // Opsional: Handle jika data tidak ditemukan, mungkin buat default?
         return UserProfile(uid: userId, name: _auth.currentUser?.displayName ?? 'New User');
       }
    });
  }

  // UPDATE specific fields (Contoh: hanya update nama)
  Future<void> updateUserName(String newName) async {
    final userId = getCurrentUserId();
    if (userId == null) throw Exception("User not logged in");
    await usersCollection.doc(userId).update({'name': newName});
  }

  // DELETE profile (Hati-hati: ini menghapus data profil, bukan akun user)
  Future<void> deleteUserProfile() async {
    final userId = getCurrentUserId();
    if (userId == null) throw Exception("User not logged in");
    await usersCollection.doc(userId).delete();
  }

  // --- Tambahan ---
  // DELETE Akun User (Firebase Auth & Profil Firestore)
  Future<void> deleteUserAccount() async {
     final user = _auth.currentUser;
     if (user == null) throw Exception("User not logged in");
     final userId = user.uid;

     try {
       // Hapus data profil di Firestore terlebih dahulu
       await usersCollection.doc(userId).delete();
       // Kemudian hapus akun di Firebase Authentication
       await user.delete();
     } catch (e) {
       // Handle error (misal: perlu re-autentikasi)
       print("Error deleting account: $e");
       // Anda mungkin perlu meminta user login kembali sebelum menghapus
       throw Exception("Failed to delete account. Please re-authenticate and try again.");
     }
  }
}