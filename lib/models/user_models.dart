class UserProfile {
  final String uid;
  String name;
  String bio;
  // Tambahkan field lain sesuai kebutuhan (misal: photoUrl, dob, dll.)

  UserProfile({required this.uid, this.name = '', this.bio = ''});

  // Konversi dari Map (data Firestore) ke objek UserProfile
  factory UserProfile.fromMap(Map<String, dynamic> data, String documentId) {
    return UserProfile(
      uid: documentId,
      name: data['name'] ?? '',
      bio: data['bio'] ?? '',
    );
  }

  // Konversi dari objek UserProfile ke Map (untuk disimpan ke Firestore)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'bio': bio,
    };
  }
}