import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:tokonovel/utils/image_proxy.dart';
import 'package:tokonovel/services/firestore_service.dart';
import 'package:tokonovel/models/book_model.dart';
import 'package:tokonovel/theme.dart';

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final FirestoreService _firestoreService = FirestoreService();

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
                        color: Colors.black.withAlpha((0.1 * 255).round()),
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
                          Icons.shopping_cart,
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
                          'KERANJANG',
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
              SliverToBoxAdapter(
                child: StreamBuilder<List<BookModel>>(
                  stream: _firestoreService.getCartStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Text(
                            'Keranjang Anda kosong.',
                            style: TextStyle(
                              fontSize: 18,
                              color: isDarkMode
                                  ? Colors.grey[600]
                                  : Colors.grey[800],
                            ),
                          ),
                        ),
                      );
                    }

                    final cartItems = snapshot.data!;
                    double totalPrice = cartItems.fold(
                      0,
                      (sum, item) => sum + (item.price ?? 0),
                    );

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 7,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(24),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Keranjang Buku Anda',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: isDarkMode
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ),
                                    TextButton.icon(
                                      onPressed: () {
                                        _firestoreService.clearCart();
                                      },
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        color: Colors.red,
                                      ),
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
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                ),
                                itemCount: cartItems.length,
                                itemBuilder: (context, index) {
                                  final item = cartItems[index];
                                  return CartItemCard(
                                    item: item,
                                    isDarkMode: isDarkMode,
                                    onRemove: () =>
                                        _firestoreService.removeFromCart(item),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 350,
                          color: isDarkMode
                              ? const Color.fromARGB(255, 44, 43, 43)
                              : const Color(0xFFF5F5F5),
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Ringkasan Pesanan',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Subtotal',
                                    style: TextStyle(
                                      color: isDarkMode
                                          ? Colors.grey[400]
                                          : Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    'Rp ${totalPrice.toStringAsFixed(0)}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isDarkMode
                                          ? Colors.white70
                                          : Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Biaya Pengiriman',
                                    style: TextStyle(
                                      color: isDarkMode
                                          ? Colors.grey[400]
                                          : Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    'Rp 15.000',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isDarkMode
                                          ? Colors.white70
                                          : Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Divider(
                                color: isDarkMode
                                    ? Colors.grey[800]
                                    : Colors.grey[300],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Total',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: isDarkMode
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                  Text(
                                    'Rp ${(totalPrice + 15000).toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      color: Colors.amber,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 32),
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: () {
                                    _showQrCode(
                                      context,
                                      cartItems,
                                      totalPrice + 15000,
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.amber,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text(
                                    'Lanjutkan Pembayaran',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showQrCode(BuildContext context, List<BookModel> items, double total) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Scan Qr untuk Melakukan Pembayaran'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 250,
              height: 250,
              child: QrImageView(
                data: 'Payment for ${items.length} books, total: Rp $total',
                version: QrVersions.auto,
                size: 200.0,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Total Belanja: Rp ${total.toStringAsFixed(0)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Kembali ke Cart'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _generatePdf(items, total);
            },
            child: const Text('Cetak Struk'),
          ),
        ],
      ),
    );
  }

  Future<void> _generatePdf(List<BookModel> items, double total) async {
    final doc = pw.Document();
    final now = DateTime.now();

    doc.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Text(
                  'Struk Pembayaran',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                headers: ['Item', 'Harga'],
                data: items
                    .map(
                      (item) => [
                        item.title ?? '',
                        'Rp ${item.price?.toStringAsFixed(0)}',
                      ],
                    )
                    .toList(),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                cellAlignment: pw.Alignment.centerLeft,
                headerDecoration: const pw.BoxDecoration(
                  color: PdfColors.grey300,
                ),
                border: pw.TableBorder.all(),
              ),
              pw.SizedBox(height: 20),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [pw.Text('Biaya Pengiriman:'), pw.Text('Rp 15.000')],
              ),
              pw.Divider(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Total:',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text(
                    'Rp ${total.toStringAsFixed(0)}',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ],
              ),
              pw.SizedBox(height: 40),
              pw.Center(
                child: pw.Text(
                  'Terima kasih telah berbelanja!',
                  style: pw.TextStyle(font: pw.Font.helveticaBoldOblique()),
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Center(
                child: pw.Text(
                  'Tanggal: ${now.day}/${now.month}/${now.year}',
                  style: const pw.TextStyle(fontSize: 10),
                ),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
    );
  }
}

class CartItemCard extends StatelessWidget {
  final BookModel item;
  final VoidCallback onRemove;
  final bool isDarkMode;

  const CartItemCard({
    Key? key,
    required this.item,
    required this.onRemove,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
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
              coverProxy(item.imageUrl ?? ''),
              width: 80,
              height: 110,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 80,
                  height: 110,
                  color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                  child: Icon(
                    Icons.book,
                    size: 40,
                    color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
                  ),
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
                  item.title ?? '',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.author ?? '',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Rp ${item.price?.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber,
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
    );
  }
}
