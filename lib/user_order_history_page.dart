import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tokonovel/services/firestore_service.dart';
import 'package:tokonovel/models/order_model.dart';
import 'package:tokonovel/theme.dart';

// --- WIDGET RATING MODERN (BOTTOM SHEET) ---
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

    // Ambil warna background saat ini untuk menentukan Dark/Light Mode
    final currentColor = backgroundColorNotifier.value;
    final isDarkMode = currentColor == const Color(0xFF1A1A1A);
    
    // Warna Tema
    final primaryGold = const Color(0xFFD4AF37);
    final surfaceColor = isDarkMode ? const Color(0xFF2A2A2A) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final hintColor = isDarkMode ? Colors.grey[500] : Colors.grey[400];
    final inputFillColor = isDarkMode ? const Color(0xFF1F1F1F) : Colors.grey[50];

    // Label rating dinamis
    final List<String> ratingLabels = [
      "Sangat Buruk",
      "Buruk",
      "Cukup",
      "Bagus",
      "Sempurna!"
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Supaya keyboard tidak menutupi input
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle Bar (Garis kecil di atas)
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),

                    // Judul
                    Text(
                      "Beri Ulasan",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      bookTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        color: primaryGold,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Bintang Rating
                    Center(
                      child: Column(
                        children: [
                          Text(
                            ratingLabels[_selectedRating - 1],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(5, (index) {
                              return GestureDetector(
                                onTap: () => setState(() => _selectedRating = index + 1),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  child: Icon(
                                    index < _selectedRating
                                        ? Icons.star_rounded
                                        : Icons.star_outline_rounded,
                                    color: primaryGold,
                                    size: 42,
                                  ),
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Input Text Area
                    Text(
                      "Bagaimana pendapatmu?",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: textColor,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _commentController,
                      style: TextStyle(color: textColor),
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: "Ceritakan pengalamanmu membaca buku ini...",
                        hintStyle: TextStyle(color: hintColor, fontSize: 13),
                        filled: true,
                        fillColor: inputFillColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: primaryGold, width: 1.5),
                        ),
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Tombol Kirim
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryGold,
                          foregroundColor: Colors.black,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          Navigator.pop(context);
                          try {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Mengirim ulasan...")),
                            );

                            await firestoreService.submitReview(
                              bookId: bookId,
                              rating: _selectedRating,
                              comment: _commentController.text.trim(),
                            );

                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Terima kasih! Ulasan berhasil dikirim."),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Gagal: $e"), backgroundColor: Colors.red),
                            );
                          }
                        },
                        child: const Text(
                          "Kirim Ulasan",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
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
    // Stream builder untuk cek status rating user
    return StreamBuilder<int?>(
      stream: firestoreService.getUserRatingStream(bookId),
      builder: (context, snapshot) {
        final hasRated = snapshot.hasData && snapshot.data != null;
        
        final isDarkMode = backgroundColorNotifier.value == const Color(0xFF1A1A1A);
        final btnColor = isDarkMode ? const Color(0xFF2A2A2A) : Colors.grey[100];
        final borderColor = isDarkMode ? Colors.grey[700]! : Colors.grey[300]!;
        final goldColor = const Color(0xFFD4AF37);

        return InkWell(
          onTap: () => _showRatingModal(context),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: hasRated ? goldColor.withOpacity(0.1) : btnColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: hasRated ? goldColor : borderColor,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  hasRated ? Icons.star : Icons.rate_review_outlined, 
                  size: 16, 
                  color: hasRated ? goldColor : (isDarkMode ? Colors.white70 : Colors.black54)
                ),
                const SizedBox(width: 6),
                Text(
                  hasRated ? "Edit Ulasan" : "Beri Ulasan",
                  style: TextStyle(
                    fontSize: 12, 
                    fontWeight: FontWeight.w600,
                    color: hasRated ? goldColor : (isDarkMode ? Colors.white : Colors.black87)
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// --- HALAMAN RIWAYAT PESANAN ---
class UserOrderHistoryPage extends StatelessWidget {
  const UserOrderHistoryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final FirestoreService _firestoreService = FirestoreService();

    return ValueListenableBuilder<Color>(
      valueListenable: backgroundColorNotifier,
      builder: (context, backgroundColor, child) {
        final isDarkMode = backgroundColor == const Color(0xFF1A1A1A);
        final Color textColor = isDarkMode ? Colors.white : Colors.black87;
        final Color secondaryTextColor = isDarkMode ? Colors.grey[400]! : Colors.grey[700]!;
        final Color cardColor = isDarkMode ? const Color(0xFF2A2A2A) : Colors.white;
        final Color primaryColor = const Color(0xFFD4AF37);

        return Scaffold(
          backgroundColor: backgroundColor,
          appBar: AppBar(
            title: Text('Riwayat Pesanan Saya', style: TextStyle(color: textColor)),
            backgroundColor: backgroundColor,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: primaryColor),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: StreamBuilder<List<OrderModel>>(
            stream: _firestoreService.getUserOrdersStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator(color: primaryColor));
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: secondaryTextColor)));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Text(
                    'Anda belum memiliki pesanan.',
                    style: TextStyle(fontSize: 18, color: secondaryTextColor),
                  ),
                );
              }

              final orders = snapshot.data!;
              return ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  return Card(
                    color: cardColor,
                    margin: const EdgeInsets.only(bottom: 16.0),
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header Pesanan
                          Text(
                            'ID Pesanan: ${order.id ?? 'N/A'}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tanggal: ${DateFormat('dd MMMM yyyy, HH:mm').format(order.orderDate)}',
                            style: TextStyle(color: secondaryTextColor),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Total: Rp ${order.totalAmount.toStringAsFixed(0)}',
                            style: TextStyle(color: textColor),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Status: ${order.status}',
                            style: TextStyle(
                              color: _getStatusColor(order.status),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Alamat
                          Text(
                            'Alamat Pengiriman:',
                            style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
                          ),
                          Text(
                            order.shippingAddress,
                            style: TextStyle(color: secondaryTextColor),
                          ),
                          const SizedBox(height: 16),
                          
                          // List Item Buku
                          ...order.items.map((item) => Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            '${item.title} x${item.quantity}',
                                            style: TextStyle(color: secondaryTextColor),
                                          ),
                                        ),
                                        Text(
                                          'Rp ${item.price.toStringAsFixed(0)}',
                                          style: TextStyle(color: secondaryTextColor),
                                        ),
                                      ],
                                    ),
                                    // Tampilkan tombol Rating HANYA JIKA status == completed
                                    if (order.status == 'completed')
                                      Padding(
                                        padding: const EdgeInsets.only(top: 8.0),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            RatingWidget(
                                              bookId: item.bookId,
                                              bookTitle: item.title,
                                              firestoreService: _firestoreService,
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              )),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'paid':
        return Colors.blue;
      case 'packaging':
        return Colors.orange;
      case 'shipping':
        return Colors.green;
      case 'completed':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }
}