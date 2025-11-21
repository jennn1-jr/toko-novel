import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'package:tokonovel/models/book_model.dart';
import 'package:tokonovel/models/order_model.dart';
import 'package:tokonovel/models/user_models.dart';
import 'package:tokonovel/services/firestore_service.dart';
import 'package:tokonovel/utils/image_proxy.dart';
import 'package:tokonovel/theme.dart';
import 'package:tokonovel/user_order_history_page.dart';

class CheckoutPage extends StatefulWidget {
  final List<BookModel> items;
  final Map<String, int> quantities;
  final double subTotal;
  final double shippingCost;
  final double serviceFee;
  final double totalAmount;

  const CheckoutPage({
    Key? key,
    required this.items,
    required this.quantities,
    required this.subTotal,
    required this.shippingCost,
    required this.serviceFee,
    required this.totalAmount,
  }) : super(key: key);

  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final FirestoreService _firestoreService = FirestoreService();
  String _selectedPaymentMethod = 'QRIS';
  bool _isLoading = false;
  UserProfile? _userProfile;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final profile = await _firestoreService.getUserProfile();
    setState(() {
      _userProfile = profile;
    });
  }

  String formatRupiah(num amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }

  Future<void> _placeOrder() async {
    if (_userProfile == null || _userProfile!.address.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Alamat pengiriman belum diisi!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final List<OrderItem> orderItems = widget.items.map((book) {
      int qty = widget.quantities[book.id] ?? 1;
      return OrderItem(
        bookId: book.id,
        title: book.title ?? 'Unknown',
        price: (book.price ?? 0).toDouble(),
        quantity: qty,
      );
    }).toList();

    final OrderModel newOrder = OrderModel(
      userId: _firestoreService.getCurrentUserId()!,
      items: orderItems,
      totalAmount: widget.totalAmount,
      shippingAddress: _userProfile!.address,
      orderDate: DateTime.now(),
      status: 'paid',
    );

    try {
      await _firestoreService.createOrder(newOrder);
      for (var item in widget.items) {
        await _firestoreService.removeFromCart(item);
      }

      if (!mounted) return;

      if (_selectedPaymentMethod == 'QRIS') {
        _showQRISDialog();
      } else {
        _showGeneralSuccessDialog();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal membuat pesanan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // --- NAVIGASI KE RIWAYAT ---
  void _navigateToHistory() {
    // Menggunakan pushReplacement agar user tidak bisa kembali ke halaman checkout (karena sudah selesai)
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const UserOrderHistoryPage()),
    );
  }

  // --- DIALOG QRIS ---
  void _showQRISDialog() {
    String formattedTotal = formatRupiah(widget.totalAmount);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        title: const Text(
          'Scan QRIS',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(10),
              child: Center(
                child: QrImageView(
                  data: 'PAYMENT-ID-${widget.totalAmount}',
                  version: QrVersions.auto,
                  size: 200.0,
                  backgroundColor: Colors.white,
                  gapless: false,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Total: $formattedTotal',
              style: const TextStyle(
                color: Colors.amber,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Silakan scan untuk membayar',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
        actions: [
          // TOMBOL KE HOME
          TextButton(
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: const Text("Ke Home", style: TextStyle(color: Colors.grey)),
          ),
          // TOMBOL LIHAT PESANAN (RIWAYAT)
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Tutup dialog
              _navigateToHistory(); // Pindah ke Riwayat
            },
            child: const Text(
              "Lihat Pesanan",
              style: TextStyle(color: Colors.white),
            ),
          ),
          // TOMBOL CETAK & LANJUT
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
            onPressed: () async {
              Navigator.pop(context); // Tutup dialog dulu
              await _generatePdf(); // Cetak
              if (mounted) {
                _navigateToHistory(); // Setelah cetak, pindah ke Riwayat
              }
            },
            icon: const Icon(Icons.print, color: Colors.black, size: 18),
            label: const Text(
              "Cetak & Selesai",
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  // --- DIALOG SUKSES UMUM ---
  void _showGeneralSuccessDialog() {
    bool isCOD = _selectedPaymentMethod == 'Cash on Delivery (COD)';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            const Icon(Icons.check_circle, color: Colors.green, size: 80),
            const SizedBox(height: 16),
            const Text(
              "Pesanan Berhasil!",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isCOD
                  ? "Silakan siapkan uang pas saat kurir datang."
                  : "Silakan lakukan transfer sesuai nominal.",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 12),
            Text(
              formatRupiah(widget.totalAmount),
              style: const TextStyle(
                color: Colors.amber,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: const Text("Ke Home", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _navigateToHistory();
            },
            child: const Text(
              "Lihat Pesanan",
              style: TextStyle(color: Colors.white),
            ),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
            onPressed: () async {
              Navigator.pop(context);
              await _generatePdf();
              if (mounted) {
                _navigateToHistory();
              }
            },
            icon: const Icon(Icons.print, color: Colors.black, size: 18),
            label: const Text(
              "Cetak & Selesai",
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _generatePdf() async {
    final doc = pw.Document();
    final now = DateTime.now();
    final formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(now);

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(10),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Center(
                  child: pw.Text(
                    'TOKO NOVEL',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                pw.Center(
                  child: pw.Text(
                    'Struk Pembayaran',
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                ),
                pw.Divider(),

                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Tanggal:', style: const pw.TextStyle(fontSize: 8)),
                    pw.Text(
                      formattedDate,
                      style: const pw.TextStyle(fontSize: 8),
                    ),
                  ],
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Metode:', style: const pw.TextStyle(fontSize: 8)),
                    pw.Text(
                      _selectedPaymentMethod,
                      style: pw.TextStyle(
                        fontSize: 8,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                pw.Divider(),

                ...widget.items.map((item) {
                  int qty = widget.quantities[item.id] ?? 1;
                  return pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        item.title ?? '',
                        style: const pw.TextStyle(fontSize: 8),
                      ),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            '$qty x ${formatRupiah(item.price ?? 0)}',
                            style: const pw.TextStyle(fontSize: 8),
                          ),
                          pw.Text(
                            formatRupiah((item.price ?? 0) * qty),
                            style: const pw.TextStyle(fontSize: 8),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 4),
                    ],
                  );
                }).toList(),

                pw.Divider(),

                _pdfRow('Subtotal', widget.subTotal),
                _pdfRow('Ongkir', widget.shippingCost),
                _pdfRow('Layanan', widget.serviceFee),

                pw.Divider(borderStyle: pw.BorderStyle.dashed),

                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'TOTAL',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    pw.Text(
                      formatRupiah(widget.totalAmount),
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),

                pw.SizedBox(height: 20),
                pw.Center(
                  child: pw.Text(
                    'Terima Kasih!',
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
      name: 'Struk_TokoNovel_${now.millisecondsSinceEpoch}',
    );
  }

  pw.Widget _pdfRow(String label, double value) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label, style: const pw.TextStyle(fontSize: 8)),
        pw.Text(formatRupiah(value), style: const pw.TextStyle(fontSize: 8)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Color>(
      valueListenable: backgroundColorNotifier,
      builder: (context, backgroundColor, child) {
        final isDarkMode = backgroundColor == const Color(0xFF1A1A1A);
        final cardColor = isDarkMode ? const Color(0xFF2A2A2A) : Colors.white;
        final textColor = isDarkMode ? Colors.white : Colors.black;

        return Scaffold(
          backgroundColor: backgroundColor,
          appBar: AppBar(
            title: Text(
              "CHECKOUT",
              style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
            ),
            backgroundColor: isDarkMode ? Colors.black : Colors.white,
            iconTheme: IconThemeData(color: textColor),
            elevation: 0,
          ),
          body: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.amber),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionTitle("Alamat Pengiriman", isDarkMode),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.2),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  color: Colors.amber[700],
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _userProfile?.name ?? 'Pelanggan',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _userProfile?.address.isNotEmpty == true
                                  ? _userProfile!.address
                                  : "Alamat belum diatur. Silakan atur di profil.",
                              style: TextStyle(
                                color: isDarkMode
                                    ? Colors.grey[400]
                                    : Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      _sectionTitle("Daftar Buku", isDarkMode),
                      const SizedBox(height: 8),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: widget.items.length,
                        itemBuilder: (context, index) {
                          final item = widget.items[index];
                          final qty = widget.quantities[item.id] ?? 1;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    coverProxy(item.imageUrl ?? ''),
                                    width: 50,
                                    height: 70,
                                    fit: BoxFit.cover,
                                    errorBuilder: (ctx, err, stack) =>
                                        Container(
                                          width: 50,
                                          height: 70,
                                          color: Colors.grey,
                                        ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.title ?? '',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: textColor,
                                        ),
                                      ),
                                      Text(
                                        "${qty} x ${formatRupiah(item.price ?? 0)}",
                                        style: TextStyle(
                                          color: Colors.grey[500],
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  formatRupiah((item.price ?? 0) * qty),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.amber,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 24),

                      _sectionTitle("Metode Pembayaran", isDarkMode),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            _paymentOption("QRIS", isDarkMode),
                            Divider(
                              height: 1,
                              color: Colors.grey.withOpacity(0.1),
                            ),
                            _paymentOption("Transfer Bank", isDarkMode),
                            Divider(
                              height: 1,
                              color: Colors.grey.withOpacity(0.1),
                            ),
                            _paymentOption(
                              "Cash on Delivery (COD)",
                              isDarkMode,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      _sectionTitle("Rincian Pembayaran", isDarkMode),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            _summaryRow(
                              "Subtotal untuk Produk",
                              widget.subTotal,
                              isDarkMode,
                            ),
                            const SizedBox(height: 8),
                            _summaryRow(
                              "Biaya Pengiriman",
                              widget.shippingCost,
                              isDarkMode,
                            ),
                            const SizedBox(height: 8),
                            _summaryRow(
                              "Biaya Layanan",
                              widget.serviceFee,
                              isDarkMode,
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Divider(),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Total Pembayaran",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                ),
                                Text(
                                  formatRupiah(widget.totalAmount),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.amber,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),

          bottomNavigationBar: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Total Tagihan",
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                      Text(
                        formatRupiah(widget.totalAmount),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: 150,
                    height: 45,
                    child: ElevatedButton(
                      onPressed: _placeOrder,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        "Bayar Sekarang",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
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

  Widget _sectionTitle(String title, bool isDarkMode) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: isDarkMode ? Colors.grey[300] : Colors.black87,
      ),
    );
  }

  Widget _paymentOption(String name, bool isDarkMode) {
    return RadioListTile<String>(
      value: name,
      groupValue: _selectedPaymentMethod,
      activeColor: Colors.amber,
      title: Text(
        name,
        style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
      ),
      onChanged: (value) {
        setState(() {
          _selectedPaymentMethod = value!;
        });
      },
    );
  }

  Widget _summaryRow(String label, double value, bool isDarkMode) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
        Text(
          formatRupiah(value),
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
      ],
    );
  }
}
