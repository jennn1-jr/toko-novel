// services/firestore_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tokonovel/models/book_model.dart';
import 'package:tokonovel/models/order_model.dart';
import 'package:tokonovel/models/user_models.dart';
// import 'package:firebase_storage/firebase_storage.dart'; // <-- DIHAPUS (tidak terpakai)

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // final FirebaseStorage _storage = FirebaseStorage.instance; // <-- DIHAPUS (tidak terpakai)

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

  // Referensi ke koleksi orders
  CollectionReference<OrderModel> get ordersCollection =>
      _db.collection('orders').withConverter<OrderModel>(
            fromFirestore: (snapshot, _) =>
                OrderModel.fromMap(snapshot.data()!, snapshot.id),
            toFirestore: (order, _) => order.toMap(),
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
    // .toMap() dari user_models.dart akan otomatis menyertakan photoUrl
    await usersCollection.doc(userId).set(profile, SetOptions(merge: true));
  }

  // READ profile
  Future<UserProfile?> getUserProfile() async {
    final userId = getCurrentUserId();
    if (userId == null) return null;
    final docSnapshot = await usersCollection.doc(userId).get();
    if (docSnapshot.exists) {
      final userProfile = docSnapshot.data();
      print("getUserProfile: userId=${userId}, isAdmin=${userProfile?.isAdmin}");
      return userProfile;
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
        final newUserProfile = UserProfile(
            uid: userId, name: _auth.currentUser?.displayName ?? 'New User');
        // Buat profil default jika belum ada
        setUserProfile(newUserProfile);
        return newUserProfile;
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

  // --- TAMBAHAN FUNGSI UPLOAD GAMBAR (Base64) ---
  // Fungsi ini menerima String Base64 dari profile_page.dart
  Future<void> uploadProfileImage(String base64Image) async {
    final userId = getCurrentUserId();
    if (userId == null) throw Exception("User not logged in");

    try {
      // Langsung simpan string Base64 ke field 'photoUrl' di Firestore
      await usersCollection.doc(userId).update({
        'photoUrl': base64Image,
      });
    } catch (e) {
      print("Error saving Base64 image: $e");
      rethrow;
    }
  }
  // --- BATAS TAMBAHAN FUNGSI ---

  // --- Operasi CRUD Cart ---
  // (Fungsi cart Anda tidak diubah)

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

  // --- Operasi CRUD Koleksi ---
  // (Fungsi koleksi Anda tidak diubah)

  // Menambahkan buku ke koleksi
  Future<void> addToCollection(String bookId) async {
    final userId = getCurrentUserId();
    if (userId == null) throw Exception("User not logged in");
    await usersCollection.doc(userId).update({
      'collection': FieldValue.arrayUnion([bookId])
    });
  }

  // Menghapus buku dari koleksi
  Future<void> removeFromCollection(String bookId) async {
    final userId = getCurrentUserId();
    if (userId == null) throw Exception("User not logged in");
    await usersCollection.doc(userId).update({
      'collection': FieldValue.arrayRemove([bookId])
    });
  }

  // Cek apakah buku ada di koleksi
  Stream<bool> isBookInCollection(String bookId) {
    final userId = getCurrentUserId();
    if (userId == null) return Stream.value(false);
    return usersCollection.doc(userId).snapshots().map((snapshot) {
      if (snapshot.exists) {
        final userProfile = snapshot.data();
        return userProfile?.collection.contains(bookId) ?? false;
      }
      return false;
    });
  }

  // Menghapus semua item dari koleksi
  Future<void> clearCollection() async {
    final userId = getCurrentUserId();
    if (userId == null) throw Exception("User not logged in");
    await usersCollection.doc(userId).update({'collection': []});
  }


  // Mendapatkan semua buku dalam koleksi
  Stream<List<BookModel>> getCollection(String userId) {
    return usersCollection.doc(userId).snapshots().asyncMap((snapshot) async {
      if (snapshot.exists) {
        final userProfile = snapshot.data();
        final bookIds = userProfile?.collection ?? [];
        if (bookIds.isEmpty) {
          return [];
        }

        // Ambil data buku berdasarkan bookIds
        // Batasi 10 per query 'whereIn' untuk menghindari limit Firestore
        List<BookModel> collectedBooks = [];
        for (var i = 0; i < bookIds.length; i += 10) {
          final subList = bookIds.sublist(
              i, i + 10 > bookIds.length ? bookIds.length : i + 10);
          final bookQuery = await booksCollection
              .where(FieldPath.documentId, whereIn: subList)
              .get();
          collectedBooks.addAll(bookQuery.docs.map((doc) => doc.data()));
        }
        return collectedBooks;
      }
      return [];
    });
  }

  // --- Operasi CRUD Buku untuk Admin ---

  // Mendapatkan semua buku (untuk admin)
  Stream<List<BookModel>> getAllBooks() {
    return booksCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  // Menambah buku baru
  Future<void> addBook(BookModel book) {
    final userId = getCurrentUserId();
    print("addBook called by userId: $userId");
    // Jika ID kosong, Firestore akan generate ID otomatis
    return booksCollection.add(book);
  }

  // Memperbarui buku yang ada
  Future<void> updateBook(BookModel book) {
    if (book.id.isEmpty) {
      throw Exception("Book ID cannot be empty for an update.");
    }
    return booksCollection.doc(book.id).update(book.toMap());
  }

  // Menghapus buku
  Future<void> deleteBook(String bookId) {
    if (bookId.isEmpty) {
      throw Exception("Book ID cannot be empty for deletion.");
    }
    return booksCollection.doc(bookId).delete();
  }

  // --- Operasi CRUD Pesanan untuk Admin ---

  // Menambah pesanan baru
  Future<void> createOrder(OrderModel order) {
    return ordersCollection.add(order);
  }

  // Mendapatkan semua pesanan (untuk admin)
  Stream<List<OrderModel>> getAllOrders() {
    return ordersCollection.orderBy('orderDate', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => doc.data()).toList();
    });
  }
  // Mendapatkan pesanan user yang sedang login
  Stream<List<OrderModel>> getUserOrdersStream() {
    final userId = getCurrentUserId();
    if (userId == null) return Stream.value([]);
    return ordersCollection
        .where('userId', isEqualTo: userId)
        .orderBy('orderDate', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  // Memperbarui status pesanan
  Future<void> updateOrderStatus(String orderId, String newStatus) {
    if (orderId.isEmpty) {
      throw Exception("Order ID cannot be empty for an update.");
    }
    return ordersCollection.doc(orderId).update({'status': newStatus});
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