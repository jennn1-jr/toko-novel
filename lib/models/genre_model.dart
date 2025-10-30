import 'package:cloud_firestore/cloud_firestore.dart';

class GenreModel {
  final String id;        // doc id atau field "id" dari data
  final String name;
  final String slug;

  GenreModel({
    required this.id,
    required this.name,
    required this.slug,
  });

  factory GenreModel.fromMap(Map<String, dynamic> json, String docId) {
    return GenreModel(
      id: (json['id']?.toString().isNotEmpty == true) ? json['id'].toString() : docId,
      name: (json['name'] ?? '').toString(),
      slug: (json['slug'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'slug': slug,
      };
}

class GenreRef {
  static CollectionReference<GenreModel> col(FirebaseFirestore db) =>
      db.collection('genres').withConverter<GenreModel>(
            fromFirestore: (snap, _) => GenreModel.fromMap(snap.data() ?? {}, snap.id),
            toFirestore: (g, _) => g.toMap(),
          );
}
