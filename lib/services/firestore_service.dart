
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tokonovel/models/book_model.dart';
import 'package:tokonovel/models/user_models.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Mendapatkan UID user yang sedang login
  String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }

  // Referensi ke koleksi users
  CollectionReference<UserProfile> get usersCollection =>
      _db.collection('users').withConverter<UserProfile>(
            fromFirestore: (snapshot, _) =>
                UserProfile.fromMap(snapshot.data()!, snapshot.id),
            toFirestore: (profile, _) => profile.toMap(),
          );

  // Referensi ke koleksi books
  CollectionReference<BookModel> get booksCollection =>
      _db.collection('books').withConverter<BookModel>(
            fromFirestore: (snapshot, _) =>
                BookModel.fromMap(snapshot.data()!, snapshot.id),
            toFirestore: (book, _) => book.toMap(),
          );

  // Referensi ke subkoleksi cart
  CollectionReference<Map<String, dynamic>> getCartCollection(String userId) {
    return usersCollection.doc(userId).collection('cart');
  }

  // --- Operasi CRUD User ---

  // CREATE / UPDATE profile (Upsert)
  Future<void> setUserProfile(UserProfile profile) async {
    final userId = getCurrentUserId();
    if (userId == null) throw Exception("User not logged in");
    await usersCollection.doc(userId).set(profile, SetOptions(merge: true));
  }

  // READ profile
  Future<UserProfile?> getUserProfile() async {
    final userId = getCurrentUserId();
    if (userId == null) return null;
    final docSnapshot = await usersCollection.doc(userId).get();
    if (docSnapshot.exists) {
      return docSnapshot.data();
    } else {
      final newUserProfile = UserProfile(
          uid: userId, name: _auth.currentUser?.displayName ?? 'New User', bio: '');
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
        return UserProfile(
            uid: userId, name: _auth.currentUser?.displayName ?? 'New User');
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

  // --- Operasi CRUD Cart ---

  // Add a book to the cart
  Future<void> addToCart(BookModel book) async {
    final userId = getCurrentUserId();
    if (userId == null) throw Exception("User not logged in");
    await getCartCollection(userId).doc(book.id).set(book.toMap());
  }

  // Remove a book from the cart
  Future<void> removeFromCart(BookModel book) async {
    final userId = getCurrentUserId();
    if (userId == null) throw Exception("User not logged in");
    await getCartCollection(userId).doc(book.id).delete();
  }

  // Clear the cart
  Future<void> clearCart() async {
    final userId = getCurrentUserId();
    if (userId == null) throw Exception("User not logged in");
    final cart = await getCartCollection(userId).get();
    for (final doc in cart.docs) {
      await doc.reference.delete();
    }
  }

  // Get the cart as a stream
  Stream<List<BookModel>> getCartStream() {
    final userId = getCurrentUserId();
    if (userId == null) return Stream.value([]);
    return getCartCollection(userId).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return BookModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
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
      throw Exception(
          "Failed to delete account. Please re-authenticate and try again.");
    }
  }
}
