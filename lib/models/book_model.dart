import 'package:cloud_firestore/cloud_firestore.dart';

class BookModel {
  final String id; // doc id atau field "id"
  final String
  genreId; // "genre_id" di data kamu adalah string angka ("1","2",...)
  final String slug;
  final String title;
  final String author;
  final String imageUrl;
  final String? description;
  final String? publisher;
  final String? isbn;
  final int? price; // di data kamu "price" string angka -> kita cast ke int
  final String? format;
  final String? sourceUrl;
  final double? rating; // opsional: kalau tidak ada, biarkan null
  final String? voters; // opsional
  final DateTime? createdAt; // new field for creation timestamp

  BookModel({
    required this.id,
    required this.genreId,
    required this.slug,
    required this.title,
    required this.author,
    required this.imageUrl,
    this.description,
    this.publisher,
    this.isbn,
    this.price,
    this.format,
    this.sourceUrl,
    this.rating,
    this.voters,
    this.createdAt,
  });

  factory BookModel.fromMap(Map<String, dynamic> json, String docId) {
    int? _tryInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      final s = v.toString().replaceAll('.', '').replaceAll(',', '');
      return int.tryParse(s);
    }

    double? _tryDouble(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString());
    }

    Timestamp? _tryTimestamp(dynamic v) {
      if (v == null) return null;
      if (v is Timestamp) return v;
      if (v is DateTime) return Timestamp.fromDate(v);
      return null;
    }

    return BookModel(
      id: (json['id']?.toString().isNotEmpty == true)
          ? json['id'].toString()
          : docId,
      genreId: (json['genre_id'] ?? '').toString(),
      slug: (json['slug'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      author: (json['author'] ?? '').toString(),
      imageUrl: (json['image_url'] ?? '').toString(),
      description: json['description']?.toString(),
      publisher: json['publisher']?.toString(),
      isbn: json['isbn']?.toString(),
      price: _tryInt(json['price']),
      format: json['format']?.toString(),
      sourceUrl: json['source_url']?.toString(),
      rating: _tryDouble(json['rating']),
      voters: json['voters']?.toString(),
      createdAt: _tryTimestamp(json['created_at'])?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'genre_id': genreId,
    'slug': slug,
    'title': title,
    'author': author,
    'image_url': imageUrl,
    'description': description,
    'publisher': publisher,
    'isbn': isbn,
    'price': price,
    'format': format,
    'source_url': sourceUrl,
    'rating': rating,
    'voters': voters,
    'created_at': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
  };
}

class BookRef {
  static CollectionReference<BookModel> col(FirebaseFirestore db) => db
      .collection('books')
      .withConverter<BookModel>(
        fromFirestore: (snap, _) =>
            BookModel.fromMap(snap.data() ?? {}, snap.id),
        toFirestore: (b, _) => b.toMap(),
      );
}
