import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tokonovel/services/firestore_service.dart';
import 'package:tokonovel/models/order_model.dart';
import 'package:tokonovel/models/book_model.dart'; // [PENTING] Import BookModel
import 'package:tokonovel/utils/image_proxy.dart'; // [PENTING] Import Image Proxy
import 'package:tokonovel/theme.dart';

// --- WIDGET RATING (Tetap dipertahankan) ---
class RatingWidget extends StatelessWidget {
  final String bookId;
  final String bookTitle;
  final FirestoreService firestoreService;

  const RatingWidget({
    Key? key,
    required this.bookId,
    required this.bookTitle,
    required this.firestoreService,
  }) : super(key: key);

  void _showRatingModal(BuildContext context) {
    final _commentController = TextEditingController();
    int _selectedRating = 5;

    final isDarkMode = backgroundColorNotifier.value == const Color(0xFF1A1A1A);
    final primaryGold = const Color(0xFFD4AF37);
    final surfaceColor = isDarkMode ? const Color(0xFF2A2A2A) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final inputFillColor = isDarkMode ? const Color(0xFF1F1F1F) : Colors.grey[50];

    final List<String> ratingLabels = [
      "Sangat Buruk", "Buruk", "Cukup", "Bagus", "Sempurna!"
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Container(
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                ),
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 20), decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(2))),
                    Text("Beri Ulasan", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                    const SizedBox(height: 4),
                    Text(bookTitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 14, color: primaryGold)),
                    const SizedBox(height: 24),
                    Text(ratingLabels[_selectedRating - 1], style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return GestureDetector(
                          onTap: () => setState(() => _selectedRating = index + 1),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Icon(index < _selectedRating ? Icons.star_rounded : Icons.star_outline_rounded, color: primaryGold, size: 36),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _commentController,
                      style: TextStyle(color: textColor),
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: "Tulis pengalamanmu...",
                        filled: true,
                        fillColor: inputFillColor,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: primaryGold, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        onPressed: () async {
                          Navigator.pop(context);
                          await firestoreService.submitReview(bookId: bookId, rating: _selectedRating, comment: _commentController.text.trim());
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Ulasan terkirim!"), backgroundColor: Colors.green));
                        },
                        child: const Text("Kirim", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int?>(
      stream: firestoreService.getUserRatingStream(bookId),
      builder: (context, snapshot) {
        final hasRated = snapshot.hasData && snapshot.data != null;
        final isDarkMode = backgroundColorNotifier.value == const Color(0xFF1A1A1A);
        final goldColor = const Color(0xFFD4AF37);

        return SizedBox(
          height: 32,
          child: OutlinedButton(
            onPressed: () => _showRatingModal(context),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: hasRated ? Colors.green : goldColor),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            child: Text(
              hasRated ? "Edit Ulasan" : "Beri Ulasan",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: hasRated ? Colors.green : goldColor,
              ),
            ),
          ),
        );
      },
    );
  }
}

// --- HALAMAN UTAMA ---
class UserOrderHistoryPage extends StatelessWidget {
  const UserOrderHistoryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final FirestoreService _firestoreService = FirestoreService();

    return ValueListenableBuilder<Color>(
      valueListenable: backgroundColorNotifier,
      builder: (context, backgroundColor, child) {
        final isDarkMode = backgroundColor == const Color(0xFF1A1A1A);
        final textColor = isDarkMode ? Colors.white : Colors.black87;
        final bgColor = isDarkMode ? const Color(0xFF121212) : const Color(0xFFF5F5F7);

        return Scaffold(
          backgroundColor: bgColor,
          appBar: AppBar(
            title: Text('Pesanan Saya', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
            backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: textColor),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: StreamBuilder<List<OrderModel>>(
            stream: _firestoreService.getUserOrdersStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37)));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return _buildEmptyState(isDarkMode);
              }

              final orders = snapshot.data!;
              return ListView.separated(
                padding: const EdgeInsets.all(16.0),
                itemCount: orders.length,
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  return _OrderCard(
                    order: orders[index],
                    isDarkMode: isDarkMode,
                    firestoreService: _firestoreService,
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_rounded, size: 80, color: isDarkMode ? Colors.grey[800] : Colors.grey[300]),
          const SizedBox(height: 16),
          Text("Belum ada pesanan", style: TextStyle(color: isDarkMode ? Colors.grey : Colors.grey[600])),
        ],
      ),
    );
  }
}

// --- KARTU PESANAN PREMIUM ---
class _OrderCard extends StatelessWidget {
  final OrderModel order;
  final bool isDarkMode;
  final FirestoreService firestoreService;

  const _OrderCard({
    Key? key,
    required this.order,
    required this.isDarkMode,
    required this.firestoreService,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final surfaceColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final subTextColor = isDarkMode ? Colors.grey[400] : Colors.grey[600];
    final goldColor = const Color(0xFFD4AF37);
    final borderColor = isDarkMode ? Colors.grey[800]! : Colors.grey[200]!;

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          // --- HEADER: Tanggal & Status ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.shopping_bag_outlined, size: 16, color: subTextColor),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('dd MMM yyyy, HH:mm').format(order.orderDate),
                      style: TextStyle(fontSize: 12, color: subTextColor),
                    ),
                  ],
                ),
                _buildStatusBadge(order.status),
              ],
            ),
          ),
          
          Divider(height: 1, color: borderColor),

          // --- BODY: Daftar Barang ---
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: order.items.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // [FIX] MENGAMBIL GAMBAR BUKU DARI DATABASE
                      StreamBuilder<BookModel?>(
                        stream: firestoreService.getBookStream(item.bookId),
                        builder: (context, snapshot) {
                          String imageUrl = '';
                          if (snapshot.hasData && snapshot.data != null) {
                            imageUrl = snapshot.data!.imageUrl;
                          }

                          return ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: SizedBox(
                              width: 50,
                              height: 70,
                              child: imageUrl.isNotEmpty
                                  ? Image.network(
                                      coverProxy(imageUrl),
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                                          child: Icon(Icons.broken_image, size: 20, color: subTextColor),
                                        );
                                      },
                                    )
                                  : Container(
                                      color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                                      child: snapshot.connectionState == ConnectionState.waiting
                                          ? Center(child: SizedBox(width: 15, height: 15, child: CircularProgressIndicator(strokeWidth: 2, color: goldColor)))
                                          : Icon(Icons.book, color: subTextColor),
                                    ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "${item.quantity} barang",
                              style: TextStyle(fontSize: 12, color: subTextColor),
                            ),
                          ],
                        ),
                      ),
                      // Harga Per Item & Tombol Ulasan jika completed
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (order.status == 'completed')
                            RatingWidget(
                              bookId: item.bookId,
                              bookTitle: item.title,
                              firestoreService: firestoreService,
                            ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),

          Divider(height: 1, color: borderColor),

          // --- FOOTER: Total & Info ---
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Total Pesanan", style: TextStyle(fontSize: 12, color: subTextColor)),
                    const SizedBox(height: 2),
                    Text(
                      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(order.totalAmount),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: goldColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String label;

    switch (status) {
      case 'paid':
        color = Colors.blue;
        label = "Dibayar";
        break;
      case 'packaging':
        color = Colors.orange;
        label = "Dikemas";
        break;
      case 'shipping':
        color = Colors.purple;
        label = "Dikirim";
        break;
      case 'completed':
        color = Colors.green;
        label = "Selesai";
        break;
      case 'cancelled':
        color = Colors.red;
        label = "Dibatalkan";
        break;
      default:
        color = Colors.grey;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.5), width: 0.5),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}