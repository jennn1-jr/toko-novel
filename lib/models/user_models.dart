class UserProfile {
  final String uid;
  String name;
  String bio;
  String address; // Tambahkan address
  final List<String> collection;
  final String photoUrl;
  bool isAdmin; // Tambahkan field isAdmin

  UserProfile({
    required this.uid,
    this.name = '',
    this.bio = '',
    this.address = '', // Tambahkan address
    this.collection = const [],
    this.photoUrl = '',
    this.isAdmin = false, // Inisialisasi isAdmin
  });

  // Konversi dari Map (data Firestore) ke objek UserProfile
  factory UserProfile.fromMap(Map<String, dynamic> data, String documentId) {
    return UserProfile(
      uid: documentId,
      name: data['name'] ?? '',
      bio: data['bio'] ?? '',
      address: data['address'] ?? '', // Tambahkan address
      collection: List<String>.from(data['collection'] ?? []),
      photoUrl: data['photoUrl'] ?? '',
      isAdmin: data['isAdmin'] ?? false, // Baca isAdmin
    );
  }

  // Konversi dari objek UserProfile ke Map (untuk disimpan ke Firestore)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'bio': bio,
      'address': address, // Tambahkan address
      'collection': collection,
      'photoUrl': photoUrl,
      'isAdmin': isAdmin, // Simpan isAdmin
    };
  }
  UserProfile copyWith({
    String? name,
    String? bio,
    String? address, // Tambahkan address
    String? photoUrl,
    List<String>? collection,
    bool? isAdmin, // Tambahkan isAdmin
  }) {
    return UserProfile(
      uid: uid,
      name: name ?? this.name,
      bio: bio ?? this.bio,
      address: address ?? this.address, // Tambahkan address
      photoUrl: photoUrl ?? this.photoUrl,
      collection: collection ?? this.collection,
      isAdmin: isAdmin ?? this.isAdmin, // Set isAdmin
    );
  }
}