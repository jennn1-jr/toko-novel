import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tokonovel/services/firestore_service.dart';
import 'package:tokonovel/models/order_model.dart';
import 'package:tokonovel/theme.dart';
import 'package:tokonovel/models/book_model.dart';

class RatingWidget extends StatefulWidget {
  final String bookId;
  final FirestoreService firestoreService;

  const RatingWidget({Key? key, required this.bookId, required this.firestoreService}) : super(key: key);

  @override
  _RatingWidgetState createState() => _RatingWidgetState();
}

class _RatingWidgetState extends State<RatingWidget> {
  int? _currentRating;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int?>(
      stream: widget.firestoreService.getUserRatingStream(widget.bookId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }
        _currentRating = snapshot.data;
        return Row(
          children: List.generate(5, (index) {
            return IconButton(
              icon: Icon(
                index < (_currentRating ?? 0) ? Icons.star : Icons.star_border,
                color: Colors.amber,
              ),
              onPressed: () async {
                final newRating = index + 1;
                try {
                  await widget.firestoreService.rateBook(widget.bookId, newRating);
                  setState(() {
                    _currentRating = newRating;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Rating berhasil disimpan')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Gagal menyimpan rating: $e')),
                  );
                }
              },
            );
          }),
        );
      },
    );
  }
}

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
                          Text(
                            'Alamat Pengiriman:',
                            style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
                          ),
                          Text(
                            order.shippingAddress,
                            style: TextStyle(color: secondaryTextColor),
                          ),
                          const SizedBox(height: 16),
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
                                    if (order.status == 'completed')
                                      Padding(
                                        padding: const EdgeInsets.only(top: 8.0),
                                        child: Row(
                                          children: [
                                            Text(
                                              'Beri Rating:',
                                              style: TextStyle(color: textColor, fontSize: 14),
                                            ),
                                            const SizedBox(width: 8),
                                            RatingWidget(
                                              bookId: item.bookId,
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
      case 'pending':
        return Colors.orange;
      case 'packaging':
        return Colors.blue;
      case 'shipping':
        return Colors.green;
      case 'completed':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }
}