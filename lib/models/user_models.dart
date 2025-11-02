class UserProfile {
  final String uid;
  String name;
  String bio;
  final List<String> collection;

  UserProfile({
    required this.uid,
    this.name = '',
    this.bio = '',
    this.collection = const [],
  });

  // Konversi dari Map (data Firestore) ke objek UserProfile
  factory UserProfile.fromMap(Map<String, dynamic> data, String documentId) {
    return UserProfile(
      uid: documentId,
      name: data['name'] ?? '',
      bio: data['bio'] ?? '',
      collection: List<String>.from(data['collection'] ?? []),
    );
  }

  // Konversi dari objek UserProfile ke Map (untuk disimpan ke Firestore)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'bio': bio,
      'collection': collection,
    };
  }
}