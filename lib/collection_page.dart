import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tokonovel/models/book_model.dart';
import 'package:tokonovel/services/firestore_service.dart';
import 'package:tokonovel/book_detail_page.dart';
import 'package:tokonovel/theme.dart';
import 'package:tokonovel/utils/image_proxy.dart';

class CollectionPage extends StatefulWidget {
  @override
  _CollectionPageState createState() => _CollectionPageState();
}

class _CollectionPageState extends State<CollectionPage> {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Color>(
      valueListenable: backgroundColorNotifier,
      builder: (context, backgroundColor, child) {
        final isDarkMode = backgroundColor == const Color(0xFF1A1A1A);
        return Scaffold(
          backgroundColor: backgroundColor,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: isDarkMode ? Colors.black : Colors.white,
                elevation: 0,
                pinned: true,
                floating: false,
                toolbarHeight: 80,
                automaticallyImplyLeading: false,
                flexibleSpace: Container(
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.black : Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(
                          (0.1 * 255).round(),
                        ),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                title: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32.0,
                    vertical: 12.0,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFD4AF37), Color(0xFFFFD700)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.favorite,
                          color: Colors.black,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 12),
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Color(0xFFD4AF37), Color(0xFFFFD700)],
                        ).createShader(bounds),
                        child: const Text(
                          'KOLEKSI SAYA',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: Icon(
                          Icons.arrow_back,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),
                titleSpacing: 0,
              ),
              StreamBuilder<User?>(
                stream: _auth.authStateChanges(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (!snapshot.hasData) {
                    return SliverFillRemaining(
                      child: Center(
                        child: Text(
                          'Silakan login untuk melihat koleksi Anda.',
                          style: TextStyle(
                            color: isDarkMode ? Colors.white70 : Colors.black54,
                          ),
                        ),
                      ),
                    );
                  }

                  final user = snapshot.data!;
                  return StreamBuilder<List<BookModel>>(
                    stream: _firestoreService.getCollection(user.uid),
                    builder: (context, bookSnapshot) {
                      if (bookSnapshot.connectionState == ConnectionState.waiting) {
                        return SliverFillRemaining(
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      if (bookSnapshot.hasError) {
                        return SliverFillRemaining(
                          child: Center(
                            child: Text(
                              'Terjadi kesalahan: ${bookSnapshot.error}',
                              style: TextStyle(
                                color: isDarkMode ? Colors.white70 : Colors.black54,
                              ),
                            ),
                          ),
                        );
                      }
                      if (!bookSnapshot.hasData || bookSnapshot.data!.isEmpty) {
                        return SliverFillRemaining(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.favorite_border,
                                  size: 80,
                                  color: isDarkMode ? Colors.white30 : Colors.black26,
                                ),
                                SizedBox(height: 20),
                                Text(
                                  'Koleksi Anda masih kosong',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: isDarkMode ? Colors.white70 : Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      final books = bookSnapshot.data!;
                      return SliverToBoxAdapter(
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton.icon(
                                    onPressed: () {
                                      _firestoreService.clearCollection();
                                    },
                                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                                    label: const Text(
                                      'Hapus Semua',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: books.length,
                              itemBuilder: (context, index) {
                                final book = books[index];
                                return CollectionItemCard(
                                  item: book,
                                  onRemove: () => _firestoreService.removeFromCollection(book.id),
                                  isDarkMode: isDarkMode,
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class CollectionItemCard extends StatelessWidget {
  final BookModel item;
  final VoidCallback onRemove;
  final bool isDarkMode;

  const CollectionItemCard({
    Key? key,
    required this.item,
    required this.onRemove,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BookDetailPage(book: item),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDarkMode ? Color(0xFF2A2A2A) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                coverProxy(item.imageUrl, w: 100, h: 150),
                width: 80,
                height: 110,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 80,
                    height: 110,
                    color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                    child: Icon(Icons.book, size: 40, color: isDarkMode ? Colors.grey[600] : Colors.grey[400]),
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.author,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (item.price != null)
                    Text(
                      'Rp ${item.price?.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Color(0xFFD4AF37) : Colors.amber[800],
                      ),
                    ),
                ],
              ),
            ),
            IconButton(
              onPressed: onRemove,
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              iconSize: 24,
            ),
          ],
        ),
      ),
    );
  }
}
