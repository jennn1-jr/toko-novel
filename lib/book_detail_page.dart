import 'package:flutter/material.dart';
import 'package:tokonovel/services/firestore_service.dart';
import 'package:tokonovel/theme.dart';
import 'models/book_model.dart';
import 'utils/image_proxy.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Book Detail',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFF1A1A1A),
      ),
      home: const BookDetailPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class BookDetailPage extends StatefulWidget {
  final BookModel? book;

  const BookDetailPage({Key? key, this.book}) : super(key: key);

  @override
  State<BookDetailPage> createState() => _BookDetailPageState();
}

class _BookDetailPageState extends State<BookDetailPage> {
  final FirestoreService _firestoreService = FirestoreService();
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    if (widget.book != null) {
      print('DEBUG BookDetail: Book = ${widget.book!.title}');
      print('DEBUG BookDetail: ImageUrl = ${widget.book!.imageUrl}');
      print(
        'DEBUG BookDetail: ImageUrl isEmpty = ${widget.book!.imageUrl.isEmpty}',
      );
    }
  }

  /// Build book cover image with fallback handling
  Widget _buildBookImage(String imageUrl, {required bool isDarkMode}) {
    // Use coverProxy to optimize image loading
    final proxiedUrl = coverProxy(imageUrl, w: 400, h: 600);
    print('DEBUG: Original imageUrl: $imageUrl');
    print('DEBUG: Proxied imageUrl: $proxiedUrl');

    // If proxied URL is empty, show placeholder
    if (proxiedUrl.isEmpty) {
      print('DEBUG: Image URL is empty, showing placeholder');
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.grey[800]!, Colors.grey[900]!],
          ),
        ),
        child: const Center(
          child: Icon(Icons.book, size: 80, color: Colors.white54),
        ),
      );
    }

    // Try to load image from URL
    return Image.network(
      proxiedUrl,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.grey[700]!, Colors.grey[800]!],
            ),
          ),
          child: const Center(
            child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        print('DEBUG: Image load error: $error, showing placeholder');
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.grey[800]!, Colors.grey[900]!],
            ),
          ),
          child: const Center(
            child: Icon(Icons.book, size: 80, color: Colors.white54),
          ),
        );
      },
    );
  }

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
              // Custom App Bar
              SliverAppBar(
                backgroundColor: isDarkMode ? Colors.black : Colors.white,
                elevation: 0,
                pinned: true,
                expandedHeight: 0,
                toolbarHeight: 70,
                leading: Container(
                  margin: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? const Color(0xFF2A2A2A)
                        : const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFD4AF37).withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                actions: [
                  Container(
                    margin: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? const Color(0xFF2A2A2A)
                          : const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFD4AF37).withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.share,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                      onPressed: () {},
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 12,
                    ),
                    child: StreamBuilder<bool>(
                      stream: widget.book != null
                          ? _firestoreService.isBookInCollection(widget.book!.id)
                          : Stream.value(false),
                      builder: (context, snapshot) {
                        final isFavorite = snapshot.data ?? false;
                        return Container(
                          decoration: BoxDecoration(
                            gradient: isFavorite
                                ? const LinearGradient(
                                    colors: [Color(0xFFD4AF37), Color(0xFFFFD700)],
                                  )
                                : null,
                            color: isFavorite
                                ? null
                                : (isDarkMode
                                    ? const Color(0xFF2A2A2A)
                                    : const Color(0xFFF5F5F5)),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFD4AF37).withOpacity(0.3),
                              width: 1.5,
                            ),
                          ),
                          child: IconButton(
                            icon: Icon(
                              isFavorite ? Icons.favorite : Icons.favorite_border,
                              color: isFavorite
                                  ? Colors.black
                                  : (isDarkMode ? Colors.white : Colors.black),
                            ),
                            onPressed: () {
                              if (widget.book != null) {
                                if (isFavorite) {
                                  _firestoreService.removeFromCollection(widget.book!.id);
                                } else {
                                  _firestoreService.addToCollection(widget.book!.id);
                                }
                              }
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
                flexibleSpace: Container(
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.black : Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),

              // Book Content
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Book Cover Section with Hero Image
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 40,
                        horizontal: 24,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: isDarkMode
                              ? [Colors.black, const Color(0xFF1A1A1A)]
                              : [Colors.white, const Color(0xFFF5F5F5)],
                        ),
                      ),
                      child: Center(
                        child: Stack(
                          children: [
                            // Glow effect behind book
                            Positioned.fill(
                              child: Container(
                                margin: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFFD4AF37,
                                      ).withOpacity(0.3),
                                      blurRadius: 60,
                                      spreadRadius: 10,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Book Cover
                            Container(
                              width: 220,
                              height: 320,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: const Color(
                                    0xFFD4AF37,
                                  ).withOpacity(0.3),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.4),
                                    blurRadius: 30,
                                    offset: const Offset(0, 15),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(18),
                                child: widget.book != null
                                    ? _buildBookImage(
                                        widget.book!.imageUrl,
                                        isDarkMode: isDarkMode,
                                      )
                                    : Image.network(
                                        'https://images.unsplash.com/photo-1621351183012-e2f9972dd9bf?w=400',
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Container(
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                                colors: [
                                                  Colors.grey[800]!,
                                                  Colors.grey[900]!,
                                                ],
                                              ),
                                            ),
                                            child: const Center(
                                              child: Icon(
                                                Icons.book,
                                                size: 80,
                                                color: Colors.white54,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                              ),
                            ),
                            // Discount Badge
                            Positioned(
                              top: 10,
                              left: 10,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Colors.red, Color(0xFFD32F2F)],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.red.withOpacity(0.4),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Text(
                                  '-20%',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Rating Section
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isDarkMode
                              ? [
                                  const Color(0xFF2A2A2A),
                                  const Color(0xFF1F1F1F),
                                ]
                              : [Colors.white, const Color(0xFFFAFAFA)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFFD4AF37).withOpacity(0.3),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildRatingItem(
                            icon: Icons.star,
                            value: '${widget.book?.rating ?? 0.0}',
                            label: 'Rating',
                            isDarkMode: isDarkMode,
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: Colors.grey.withOpacity(0.3),
                          ),
                          _buildRatingItem(
                            icon: Icons.people,
                            value: '${widget.book?.voters ?? 0} K',
                            label: 'Voters',
                            isDarkMode: isDarkMode,
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: Colors.grey.withOpacity(0.3),
                          ),
                          _buildRatingItem(
                            icon: Icons.local_fire_department,
                            value:
                                '${(widget.book?.price ?? 0).toStringAsFixed(0)}',
                            label: 'Harga',
                            isDarkMode: isDarkMode,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Book Info Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [Color(0xFFD4AF37), Color(0xFFFFD700)],
                            ).createShader(bounds),
                            child: Text(
                              widget.book?.title ?? "Book Title",
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                color: isDarkMode ? Colors.white : Colors.black,
                                height: 1.3,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFD4AF37),
                                      Color(0xFFFFD700),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'by ${widget.book?.author ?? "Unknown Author"}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 28),

                          // Description Section
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: isDarkMode
                                    ? [
                                        const Color(0xFF2A2A2A),
                                        const Color(0xFF1F1F1F),
                                      ]
                                    : [Colors.white, const Color(0xFFFAFAFA)],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFFD4AF37).withOpacity(0.3),
                                width: 1.5,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 4,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFFD4AF37),
                                            Color(0xFFFFD700),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Sinopsis',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: isDarkMode
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  widget.book?.description ??
                                      'Tidak ada deskripsi.',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: isDarkMode
                                        ? Colors.grey[400]
                                        : Colors.grey[700],
                                    height: 1.8,
                                    letterSpacing: 0.3,
                                  ),
                                  textAlign: TextAlign.justify,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Book Details
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: isDarkMode
                                    ? [
                                        const Color(0xFF2A2A2A),
                                        const Color(0xFF1F1F1F),
                                      ]
                                    : [Colors.white, const Color(0xFFFAFAFA)],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFFD4AF37).withOpacity(0.3),
                                width: 1.5,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 4,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFFD4AF37),
                                            Color(0xFFFFD700),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Detail Buku',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: isDarkMode
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                _buildDetailRow(
                                  icon: Icons.category,
                                  label: 'Penerbit',
                                  value: widget.book?.publisher ?? 'N/A',
                                  isDarkMode: isDarkMode,
                                ),
                                const SizedBox(height: 16),
                                _buildDetailRow(
                                  icon: Icons.numbers,
                                  label: 'ISBN',
                                  value: widget.book?.isbn ?? 'N/A',
                                  isDarkMode: isDarkMode,
                                ),
                                const SizedBox(height: 16),
                                _buildDetailRow(
                                  icon: Icons.format_align_left,
                                  label: 'Format',
                                  value: widget.book?.format ?? 'Digital',
                                  isDarkMode: isDarkMode,
                                ),
                                const SizedBox(height: 16),
                                _buildDetailRow(
                                  icon: Icons.star,
                                  label: 'Rating',
                                  value: '${widget.book?.rating ?? 0.0}/5.0',
                                  isDarkMode: isDarkMode,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Bottom Action Bar
          bottomNavigationBar: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.black : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFD4AF37), Color(0xFFFFD700)],
                        ),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFD4AF37).withOpacity(0.4),
                            blurRadius: 15,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          if (widget.book != null) {
                            _firestoreService.addToCart(widget.book!);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Buku ditambahkan ke keranjang'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.shopping_bag,
                              color: Colors.black,
                              size: 22,
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Beli Sekarang',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? const Color(0xFF2A2A2A)
                          : const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: const Color(0xFFD4AF37),
                        width: 2,
                      ),
                    ),
                    child: IconButton(
                      onPressed: () {
                        if (widget.book != null) {
                          _firestoreService.addToCart(widget.book!);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Buku ditambahkan ke keranjang'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                      padding: const EdgeInsets.all(16),
                      icon: const Icon(
                        Icons.shopping_cart_outlined,
                        color: Color(0xFFD4AF37),
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRatingItem({
    required IconData icon,
    required String value,
    required String label,
    required bool isDarkMode,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFD4AF37), Color(0xFFFFD700)],
            ),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.black, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required bool isDarkMode,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFD4AF37), Color(0xFFFFD700)],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.black, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}