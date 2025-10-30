import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DebugFirestorePage extends StatefulWidget {
  const DebugFirestorePage({Key? key}) : super(key: key);

  @override
  State<DebugFirestorePage> createState() => _DebugFirestorePageState();
}

class _DebugFirestorePageState extends State<DebugFirestorePage> {
  final _db = FirebaseFirestore.instance;
  String _output = '';

  @override
  void initState() {
    super.initState();
    _checkFirestore();
  }

  Future<void> _checkFirestore() async {
    final sb = StringBuffer();
    try {
      // Check genres collection
      sb.writeln('=== GENRES COLLECTION ===');
      final genreSnap = await _db.collection('genres').get();
      sb.writeln('Total genres: ${genreSnap.docs.length}');
      for (var doc in genreSnap.docs.take(10)) {
        sb.writeln('  - ID: ${doc.id}, Data: ${doc.data()}');
      }

      sb.writeln('\n=== BOOKS COLLECTION ===');
      final bookSnap = await _db.collection('books').limit(10).get();
      sb.writeln('Total books (first 10): ${bookSnap.docs.length}');
      for (var doc in bookSnap.docs) {
        final data = doc.data();
        sb.writeln('  - ID: ${doc.id}');
        sb.writeln('    title: ${data['title']}');
        sb.writeln('    genre_id: ${data['genre_id']}');
      }

      sb.writeln('\n=== QUERY TEST: whereIn genre_id ===');
      final testGenreIds = genreSnap.docs
          .map((d) => d.id)
          .toList()
          .take(3)
          .toList();
      sb.writeln('Testing with genre IDs: $testGenreIds');
      final testSnap = await _db
          .collection('books')
          .where('genre_id', whereIn: testGenreIds)
          .limit(5)
          .get();
      sb.writeln('Books found: ${testSnap.docs.length}');
      for (var doc in testSnap.docs) {
        final data = doc.data();
        sb.writeln('  - ${data['title']} (genre_id: ${data['genre_id']})');
      }
    } catch (e) {
      sb.writeln('ERROR: $e');
    }

    setState(() => _output = sb.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Debug Firestore')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: SelectableText(
          _output,
          style: const TextStyle(fontFamily: 'Courier'),
        ),
      ),
    );
  }
}
