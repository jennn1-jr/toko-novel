import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tokonovel/services/firestore_service.dart';
import 'package:tokonovel/theme.dart';
import 'models/book_model.dart';
import 'utils/image_proxy.dart';
import 'package:tokonovel/checkout_page.dart';
import 'package:intl/intl.dart';
import 'package:tokonovel/models/riview_model.dart';
import 'dart:convert'; // Untuk decode base64 foto profil

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

  @override
  void initState() {
    super.initState();
    if (widget.book != null) {
      print('DEBUG BookDetail: Book = ${widget.book!.title}');
    }
  }

  String formatRupiah(num amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }

  Widget _buildBookImage(String imageUrl, {required bool isDarkMode}) {
    final proxiedUrl = coverProxy(imageUrl, w: 400, h: 600);

    if (proxiedUrl.isEmpty) {
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

  // --- MODAL PEMBELIAN ---
  void _showDirectPurchaseModal(BuildContext context, BookModel book) {
    final currentColor = backgroundColorNotifier.value;
    final isDarkMode = currentColor == const Color(0xFF1A1A1A);

    int qty = 1;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            double totalPrice = (book.price ?? 0) * qty.toDouble();

            return Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                border: Border.all(
                  color: Colors.amber.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Mau beli berapa?",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.close,
                          color: isDarkMode ? Colors.grey : Colors.black,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Detail Singkat Buku
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          coverProxy(book.imageUrl),
                          width: 60,
                          height: 90,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => Container(
                            width: 60,
                            height: 90,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              book.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: isDarkMode ? Colors.white : Colors.black,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              formatRupiah(book.price ?? 0),
                              style: const TextStyle(
                                color: Colors.amber,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Kontrol Jumlah
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Jumlah",
                        style: TextStyle(
                          color: isDarkMode
                              ? Colors.grey[400]
                              : Colors.grey[700],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: isDarkMode ? Colors.black45 : Colors.grey[100],
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isDarkMode
                                ? Colors.grey[700]!
                                : Colors.grey[300]!,
                          ),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.remove,
                                color: Colors.amber,
                              ),
                              onPressed: () {
                                if (qty > 1) {
                                  setModalState(() {
                                    qty--;
                                  });
                                }
                              },
                            ),
                            Text(
                              '$qty',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: isDarkMode ? Colors.white : Colors.black,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add, color: Colors.amber),
                              onPressed: () {
                                setModalState(() {
                                  qty++;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Tombol Lanjut
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        _processDirectCheckout(book, qty);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Lanjut Pembayaran",
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            formatRupiah(totalPrice),
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _processDirectCheckout(BookModel book, int qty) {
    double price = (book.price ?? 0).toDouble();
    double subTotal = price * qty;
    double serviceFee = 2000.0 * qty;
    double shippingCost = (subTotal >= 300000) ? 0 : 10000;
    double totalAmount = subTotal + shippingCost + serviceFee;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckoutPage(
          items: [book],
          quantities: {book.id: qty},
          subTotal: subTotal,
          shippingCost: shippingCost,
          serviceFee: serviceFee,
          totalAmount: totalAmount,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 1. STREAM BUILDER UTAMA: Mendengarkan perubahan data buku (rating, voters, dll)
    return StreamBuilder<BookModel?>(
      stream: widget.book != null
          ? _firestoreService.getBookStream(widget.book!.id)
          : const Stream.empty(),
      builder: (context, snapshot) {
        // 2. DATA DISPLAY: Gunakan data terbaru dari stream, jika null pakai data widget lama
        final displayBook = snapshot.data ?? widget.book;

        // Jika tidak ada data sama sekali
        if (displayBook == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

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
                    expandedHeight: 0,
                    toolbarHeight: 70,
                    leading: Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 11,
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
                          onPressed: () {
                            _showShareOptions(context, displayBook);
                          },
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 12,
                        ),
                        child: StreamBuilder<bool>(
                          stream: _firestoreService.isBookInCollection(
                            displayBook.id,
                          ),
                          builder: (context, snapshot) {
                            final isFavorite = snapshot.data ?? false;
                            return Container(
                              decoration: BoxDecoration(
                                gradient: isFavorite
                                    ? const LinearGradient(
                                        colors: [
                                          Color(0xFFD4AF37),
                                          Color(0xFFFFD700),
                                        ],
                                      )
                                    : null,
                                color: isFavorite
                                    ? null
                                    : (isDarkMode
                                        ? const Color(0xFF2A2A2A)
                                        : const Color(0xFFF5F5F5)),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(
                                    0xFFD4AF37,
                                  ).withOpacity(0.3),
                                  width: 1.5,
                                ),
                              ),
                              child: IconButton(
                                icon: Icon(
                                  isFavorite
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: isFavorite
                                      ? Colors.black
                                      : (isDarkMode
                                          ? Colors.white
                                          : Colors.black),
                                ),
                                onPressed: () {
                                  if (isFavorite) {
                                    _firestoreService.removeFromCollection(
                                      displayBook.id,
                                    );
                                  } else {
                                    _firestoreService.addToCollection(
                                      displayBook.id,
                                    );
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

                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                                    child: _buildBookImage(
                                      displayBook.imageUrl,
                                      isDarkMode: isDarkMode,
                                    ),
                                  ),
                                ),
                                // --- BAGIAN DISKON DIHAPUS DARI SINI ---
                              ],
                            ),
                          ),
                        ),

                        // INFO HEADER YANG REAL-TIME
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
                                // Gunakan data real-time dari displayBook
                                value: (displayBook.rating ?? 0.0)
                                    .toStringAsFixed(1),
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
                                value: '${displayBook.voters ?? 0}',
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
                                value: (displayBook.price ?? 0) >= 1000
                                    ? '${(displayBook.price! / 1000).toStringAsFixed(0)}k'
                                    : '${displayBook.price}',
                                label: 'Harga',
                                isDarkMode: isDarkMode,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ShaderMask(
                                shaderCallback: (bounds) =>
                                    const LinearGradient(
                                      colors: [
                                        Color(0xFFD4AF37),
                                        Color(0xFFFFD700),
                                      ],
                                    ).createShader(bounds),
                                child: Text(
                                  displayBook.title,
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w900,
                                    color: isDarkMode
                                        ? Colors.white
                                        : Colors.black,
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
                                      'by ${displayBook.author}',
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

                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: isDarkMode
                                        ? [
                                            const Color(0xFF2A2A2A),
                                            const Color(0xFF1F1F1F),
                                          ]
                                        : [
                                            Colors.white,
                                            const Color(0xFFFAFAFA),
                                          ],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: const Color(
                                      0xFFD4AF37,
                                    ).withOpacity(0.3),
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
                                            borderRadius: BorderRadius.circular(
                                              2,
                                            ),
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
                                      displayBook.description ??
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

                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: isDarkMode
                                        ? [
                                            const Color(0xFF2A2A2A),
                                            const Color(0xFF1F1F1F),
                                          ]
                                        : [
                                            Colors.white,
                                            const Color(0xFFFAFAFA),
                                          ],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: const Color(
                                      0xFFD4AF37,
                                    ).withOpacity(0.3),
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
                                            borderRadius: BorderRadius.circular(
                                              2,
                                            ),
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
                                      value: displayBook.publisher ?? 'N/A',
                                      isDarkMode: isDarkMode,
                                    ),
                                    const SizedBox(height: 16),
                                    _buildDetailRow(
                                      icon: Icons.numbers,
                                      label: 'ISBN',
                                      value: displayBook.isbn ?? 'N/A',
                                      isDarkMode: isDarkMode,
                                    ),
                                    const SizedBox(height: 16),
                                    _buildDetailRow(
                                      icon: Icons.format_align_left,
                                      label: 'Format',
                                      value: displayBook.format ?? 'Digital',
                                      isDarkMode: isDarkMode,
                                    ),
                                    const SizedBox(height: 16),
                                    _buildDetailRow(
                                      icon: Icons.star,
                                      label: 'Rating',
                                      value:
                                          '${(displayBook.rating ?? 0.0).toStringAsFixed(1)}/5.0',
                                      isDarkMode: isDarkMode,
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 32),

                              // --- BAGIAN ULASAN REAL-TIME ---
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: isDarkMode
                                      ? const Color(0xFF2A2A2A)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: const Color(
                                      0xFFD4AF37,
                                    ).withOpacity(0.3),
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
                                            color: const Color(0xFFD4AF37),
                                            borderRadius: BorderRadius.circular(
                                              2,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          'Ulasan Pembaca',
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

                                    // STREAM BUILDER REVIEW
                                    displayBook.id.isEmpty
                                        ? const SizedBox()
                                        : StreamBuilder<List<ReviewModel>>(
                                            stream: _firestoreService
                                                .getBookReviewsStream(
                                                  displayBook.id,
                                                ),
                                            builder: (context, snapshot) {
                                              if (snapshot.connectionState ==
                                                  ConnectionState.waiting) {
                                                return const Center(
                                                  child:
                                                      CircularProgressIndicator(),
                                                );
                                              }
                                              if (!snapshot.hasData ||
                                                  snapshot.data!.isEmpty) {
                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        vertical: 20,
                                                      ),
                                                  child: Center(
                                                    child: Text(
                                                      "Belum ada ulasan. Jadilah yang pertama!",
                                                      style: TextStyle(
                                                        color: isDarkMode
                                                            ? Colors.grey
                                                            : Colors.black54,
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }

                                              final reviews = snapshot.data!;

                                              return ListView.separated(
                                                shrinkWrap: true,
                                                physics:
                                                    const NeverScrollableScrollPhysics(),
                                                itemCount: reviews.length,
                                                separatorBuilder: (ctx, i) =>
                                                    Divider(
                                                      color: Colors.grey
                                                          .withOpacity(0.2),
                                                    ),
                                                itemBuilder: (context, index) {
                                                  final review = reviews[index];

                                                  // Decode foto profil jika ada
                                                  Uint8List? userPhotoBytes;
                                                  if (review.photoUrl != null &&
                                                      review
                                                          .photoUrl!
                                                          .isNotEmpty) {
                                                    try {
                                                      userPhotoBytes =
                                                          base64Decode(
                                                            review.photoUrl!,
                                                          );
                                                    } catch (_) {}
                                                  }

                                                  return Padding(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          vertical: 8.0,
                                                        ),
                                                    child: Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        CircleAvatar(
                                                          backgroundColor:
                                                              Colors.grey[300],
                                                          backgroundImage:
                                                              userPhotoBytes !=
                                                                      null
                                                                  ? MemoryImage(
                                                                      userPhotoBytes,
                                                                    )
                                                                  : null,
                                                          child:
                                                              userPhotoBytes ==
                                                                      null
                                                                  ? const Icon(
                                                                      Icons.person,
                                                                      color: Colors
                                                                          .grey,
                                                                    )
                                                                  : null,
                                                        ),
                                                        const SizedBox(
                                                          width: 12,
                                                        ),
                                                        Expanded(
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Text(
                                                                    review
                                                                        .userName,
                                                                    style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color:
                                                                          isDarkMode
                                                                              ? Colors.white
                                                                              : Colors.black,
                                                                    ),
                                                                  ),
                                                                  Text(
                                                                    DateFormat(
                                                                      'dd MMM yyyy',
                                                                    ).format(
                                                                      review
                                                                          .timestamp,
                                                                    ),
                                                                    style: TextStyle(
                                                                      fontSize:
                                                                          10,
                                                                      color: Colors
                                                                          .grey,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              Row(
                                                                children: List.generate(5, (
                                                                  starIndex,
                                                                ) {
                                                                  return Icon(
                                                                    starIndex <
                                                                            review.rating
                                                                        ? Icons
                                                                            .star
                                                                        : Icons
                                                                            .star_border,
                                                                    size: 14,
                                                                    color: Colors
                                                                        .amber,
                                                                  );
                                                                }),
                                                              ),
                                                              const SizedBox(
                                                                height: 6,
                                                              ),
                                                              Text(
                                                                review
                                                                        .comment
                                                                        .isEmpty
                                                                    ? "Tidak ada komentar."
                                                                    : review
                                                                        .comment,
                                                                style: TextStyle(
                                                                  color:
                                                                      isDarkMode
                                                                          ? Colors
                                                                              .grey[300]
                                                                          : Colors
                                                                              .black87,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
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
                              _showDirectPurchaseModal(context, displayBook);
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
                            // Gunakan displayBook agar data yang masuk keranjang adalah data terbaru
                            _firestoreService.addToCart(displayBook);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Buku ditambahkan ke keranjang'),
                                duration: Duration(seconds: 2),
                              ),
                            );
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

  void _showShareOptions(BuildContext context, BookModel book) {
    final shareText =
        'Cek buku "${book.title}" oleh ${book.author}: https://tokonovel.com/book/${book.id}';
    final whatsappUrl = 'https://wa.me/?text=${Uri.encodeComponent(shareText)}';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Bagikan Buku',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildShareOption(
                    context,
                    icon: Icons.copy,
                    label: 'Salin Link',
                    onTap: () async {
                      await Clipboard.setData(ClipboardData(text: shareText));
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Link berhasil disalin')),
                      );
                    },
                  ),
                  _buildShareOption(
                    context,
                    icon: Icons.message,
                    label: 'WhatsApp',
                    onTap: () async {
                      if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
                        await launchUrl(Uri.parse(whatsappUrl));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('WhatsApp tidak tersedia'),
                          ),
                        );
                      }
                      Navigator.pop(context);
                    },
                  ),
                  _buildShareOption(
                    context,
                    icon: Icons.share,
                    label: 'Lainnya',
                    onTap: () async {
                      await Share.share(shareText);
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildShareOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFD4AF37), Color(0xFFFFD700)],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.black, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ],
      ),
    );
  }
}