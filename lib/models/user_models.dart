class UserProfile {
  final String uid;
  String name;
  String bio;
  final List<String> collection;
  final String photoUrl;


  UserProfile({
    required this.uid,
    this.name = '',
    this.bio = '',
    this.collection = const [],
    this.photoUrl = '',
  });

  // Konversi dari Map (data Firestore) ke objek UserProfile
  factory UserProfile.fromMap(Map<String, dynamic> data, String documentId) {
    return UserProfile(
      uid: documentId,
      name: data['name'] ?? '',
      bio: data['bio'] ?? '',
      collection: List<String>.from(data['collection'] ?? []),
      photoUrl: data['photoUrl'] ?? '',
    );
  }

  // Konversi dari objek UserProfile ke Map (untuk disimpan ke Firestore)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'bio': bio,
      'collection': collection,
      'photoUrl': photoUrl,
    };
  }
  UserProfile copyWith({
    String? name,
    String? bio,
    String? photoUrl,
    List<String>? collection,
  }) {
    return UserProfile(
      uid: uid,
      name: name ?? this.name,
      bio: bio ?? this.bio,
      photoUrl: photoUrl ?? this.photoUrl,
      collection: collection ?? this.collection,
    );
  }
}