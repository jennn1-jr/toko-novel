import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  final String userId;
  final String userName;
  final String? photoUrl; // Opsional: untuk menampilkan foto profil reviewer
  final int rating;
  final String comment;
  final DateTime timestamp;

  ReviewModel({
    required this.userId,
    required this.userName,
    this.photoUrl,
    required this.rating,
    required this.comment,
    required this.timestamp,
  });

  factory ReviewModel.fromMap(Map<String, dynamic> data) {
    return ReviewModel(
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? 'Anonymous',
      photoUrl: data['photoUrl'],
      rating: (data['rating'] as num?)?.toInt() ?? 0,
      comment: data['comment'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'photoUrl': photoUrl,
      'rating': rating,
      'comment': comment,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }
}