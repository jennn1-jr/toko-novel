import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:tokonovel/checkout_page.dart';

import 'package:tokonovel/utils/image_proxy.dart';
import 'package:tokonovel/services/firestore_service.dart';
import 'package:tokonovel/models/book_model.dart';
import 'package:tokonovel/models/order_model.dart';
import 'package:tokonovel/models/user_models.dart';
import 'package:tokonovel/theme.dart';

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final FirestoreService _firestoreService = FirestoreService();
  late Stream<List<BookModel>> _cartStream;

  final Map<String, int> _quantities = {};
  final Set<String> _selectedItemIds = {};

  @override
  void initState() {
    super.initState();
    _cartStream = _firestoreService.getCartStream();
  }

  String formatRupiah(num amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }

  void _updateQuantity(BookModel item, int change) {
    int currentQty = _quantities[item.id] ?? 1;
    int newQty = currentQty + change;

    if (newQty < 1) {
      _showDeleteConfirmation(item);
    } else {
      setState(() {
        _quantities[item.id] = newQty;
        if (change > 0) {
          _selectedItemIds.add(item.id);
        }
      });
    }
  }

  void _toggleSelection(String itemId) {
    setState(() {
      if (_selectedItemIds.contains(itemId)) {
        _selectedItemIds.remove(itemId);
      } else {
        _selectedItemIds.add(itemId);
      }
    });
  }

  void _toggleSelectAll(List<BookModel> allItems) {
    setState(() {
      if (_selectedItemIds.length == allItems.length) {
        _selectedItemIds.clear();
      } else {
        _selectedItemIds.clear();
        for (var item in allItems) {
          _selectedItemIds.add(item.id);
        }
      }
    });
  }

  Future<void> _showDeleteConfirmation(BookModel item) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2A2A2A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text(
            "Hapus Buku?",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Text(
            "Yakin ingin membuang '${item.title}' dari keranjang?",
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Batal", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _firestoreService.removeFromCart(item);
                setState(() {
                  _quantities.remove(item.id);
                  _selectedItemIds.remove(item.id);
                });
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("Hapus", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmClearCart() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2A2A2A),
          title: const Text(
            "Kosongkan Keranjang?",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            "Semua buku akan dihapus. Lanjutkan?",
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Batal", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _firestoreService.clearCart();
                setState(() {
                  _quantities.clear();
                  _selectedItemIds.clear();
                });
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text(
                "Hapus Semua",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _processCheckout(
    List<BookModel> allItems,
    double totalAmount,
  ) async {
    final selectedItemsList = allItems
        .where((item) => _selectedItemIds.contains(item.id))
        .toList();

    if (selectedItemsList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih minimal satu buku!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final UserProfile? userProfile = await _firestoreService.getUserProfile();
    if (userProfile == null || userProfile.address.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mohon lengkapi alamat pengiriman di profil.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    double subTotal = 0;
    int totalBooksCount = 0;

    for (var item in selectedItemsList) {
      int qty = _quantities[item.id] ?? 1;
      subTotal += (item.price ?? 0) * qty;
      totalBooksCount += qty;
    }

    double shippingCost = 0;
    double serviceFee = 0;

    if (totalBooksCount > 0) {
      serviceFee = totalBooksCount * 2000.0;
      if (subTotal >= 300000) {
        shippingCost = 0;
      } else {
        shippingCost = 10000;
      }
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckoutPage(
          items: selectedItemsList,
          quantities: _quantities,
          subTotal: subTotal,
          shippingCost: shippingCost,
          serviceFee: serviceFee,
          totalAmount: totalAmount,
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDarkMode, BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 100,
            color: isDarkMode ? Colors.grey[800] : Colors.grey[300],
          ),
          const SizedBox(height: 24),
          Text(
            "Keranjangmu Masih Kosong",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Sepertinya kamu belum menambahkan novel apapun.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.search, color: Colors.black),
            label: const Text(
              "Mulai Belanja",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
        ],
      ),
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
              SliverAppBar(
                backgroundColor: isDarkMode ? Colors.black : Colors.white,
                elevation: 0,
                pinned: true,
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
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                titleSpacing: 0,
              ),

              SliverToBoxAdapter(
                child: StreamBuilder<List<BookModel>>(
                  stream: _cartStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting)
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(50.0),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    if (!snapshot.hasData || snapshot.data!.isEmpty)
                      return _buildEmptyState(isDarkMode, context);

                    final cartItems = snapshot.data!;

                    double subTotal = 0;
                    int totalBooksCount = 0;

                    for (var item in cartItems) {
                      if (!_quantities.containsKey(item.id))
                        _quantities[item.id] = 1;
                      if (_selectedItemIds.contains(item.id)) {
                        int qty = _quantities[item.id]!;
                        subTotal += (item.price ?? 0) * qty;
                        totalBooksCount += qty;
                      }
                    }

                    double shippingCost = 0;
                    double serviceFee = 0;

                    if (totalBooksCount > 0) {
                      serviceFee = totalBooksCount * 2000.0;
                      if (subTotal >= 300000) {
                        shippingCost = 0;
                      } else {
                        shippingCost = 10000;
                      }
                    }

                    double grandTotal = subTotal + shippingCost + serviceFee;
                    bool isAllSelected =
                        cartItems.isNotEmpty &&
                        _selectedItemIds.length == cartItems.length;

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 7,
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 16,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Checkbox(
                                          value: isAllSelected,
                                          activeColor: Colors.amber,
                                          checkColor: Colors.black,
                                          onChanged: (val) =>
                                              _toggleSelectAll(cartItems),
                                          side: BorderSide(
                                            color: isDarkMode
                                                ? Colors.grey
                                                : Colors.black,
                                          ),
                                        ),
                                        Text(
                                          'Pilih Semua (${cartItems.length})',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: isDarkMode
                                                ? Colors.white
                                                : Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                    TextButton.icon(
                                      onPressed: () => _confirmClearCart(),
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
                                physics: const NeverScrollableScrollPhysics(),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                ),
                                itemCount: cartItems.length,
                                itemBuilder: (context, index) {
                                  final item = cartItems[index];
                                  return CartItemCard(
                                    key: ValueKey(item.id),
                                    item: item,
                                    quantity: _quantities[item.id] ?? 1,
                                    isSelected: _selectedItemIds.contains(
                                      item.id,
                                    ),
                                    isDarkMode: isDarkMode,
                                    onToggleSelect: (val) =>
                                        _toggleSelection(item.id),
                                    onRemove: () =>
                                        _showDeleteConfirmation(item),
                                    onIncrement: () => _updateQuantity(item, 1),
                                    onDecrement: () =>
                                        _updateQuantity(item, -1),
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
                              _buildSummaryRow(
                                'Item Terpilih',
                                '$totalBooksCount Buku',
                                isDarkMode,
                              ),
                              const SizedBox(height: 12),
                              _buildSummaryRow(
                                'Subtotal',
                                formatRupiah(subTotal),
                                isDarkMode,
                              ),
                              const SizedBox(height: 12),
                              _buildSummaryRow(
                                'Biaya Pengiriman',
                                formatRupiah(shippingCost),
                                isDarkMode,
                              ),

                              // --- TAMBAHAN: BIAYA LAYANAN ---
                              const SizedBox(height: 12),
                              _buildSummaryRow(
                                'Biaya Layanan',
                                formatRupiah(serviceFee),
                                isDarkMode,
                              ),

                              // ------------------------------
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
                                    formatRupiah(grandTotal),
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
                                  onPressed: totalBooksCount > 0
                                      ? () => _processCheckout(
                                          cartItems,
                                          grandTotal,
                                        )
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.amber,
                                    disabledBackgroundColor: Colors.grey,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text(
                                    'Checkout ($totalBooksCount)',
                                    style: const TextStyle(
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

  Widget _buildSummaryRow(String label, String value, bool isDarkMode) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            color: isDarkMode ? Colors.white70 : Colors.black87,
          ),
        ),
      ],
    );
  }

  // (Functions _showQrCode and _generatePdf kept same as before)
  void _showQrCode(BuildContext context, List<BookModel> items, double total) {
    String formattedTotal = formatRupiah(total);
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
                data: 'Total: $formattedTotal',
                version: QrVersions.auto,
                size: 200.0,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Total Bayar: $formattedTotal',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tutup'),
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
    String formattedTotal = formatRupiah(total);
    doc.addPage(
      pw.Page(
        build: (pw.Context context) =>
            pw.Center(child: pw.Text("Struk $formattedTotal")),
      ),
    );
    await Printing.layoutPdf(onLayout: (format) => doc.save());
  }
}

// --- WIDGET KARTU ITEM (SUDAH FIX) ---
class CartItemCard extends StatefulWidget {
  final BookModel item;
  final int quantity;
  final bool isSelected;
  final bool isDarkMode;
  final ValueChanged<bool?> onToggleSelect;
  final VoidCallback onRemove;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const CartItemCard({
    Key? key,
    required this.item,
    required this.quantity,
    required this.isSelected,
    required this.isDarkMode,
    required this.onToggleSelect,
    required this.onRemove,
    required this.onIncrement,
    required this.onDecrement,
  }) : super(key: key);

  @override
  State<CartItemCard> createState() => _CartItemCardState();
}

class _CartItemCardState extends State<CartItemCard> {
  late String _fixedImageUrl;

  @override
  void initState() {
    super.initState();
    _fixedImageUrl = coverProxy(widget.item.imageUrl);
  }

  @override
  void didUpdateWidget(covariant CartItemCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.item.imageUrl != oldWidget.item.imageUrl) {
      _fixedImageUrl = coverProxy(widget.item.imageUrl);
    }
  }

  String formatRupiah(num amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final textColor = widget.isDarkMode ? Colors.white : Colors.black;
    final subTextColor = widget.isDarkMode
        ? Colors.grey[400]
        : Colors.grey[600];
    final cardColor = widget.isDarkMode
        ? const Color(0xFF2A2A2A)
        : Colors.white;

    int unitPrice = widget.item.price ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Checkbox(
            value: widget.isSelected,
            activeColor: Colors.amber,
            checkColor: Colors.black,
            onChanged: widget.onToggleSelect,
            side: BorderSide(
              color: widget.isDarkMode ? Colors.grey : Colors.black54,
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: _fixedImageUrl,
              width: 80,
              height: 110,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(color: Colors.grey),
              errorWidget: (context, url, error) => const Icon(Icons.book),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: SizedBox(
              height: 110,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.item.title ?? '',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.item.author ?? '',
                              style: TextStyle(
                                fontSize: 13,
                                color: subTextColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                        Text(
                          formatRupiah(unitPrice),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        height: 30,
                        decoration: BoxDecoration(
                          color: widget.isDarkMode
                              ? Colors.black45
                              : Colors.grey[100],
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: widget.isDarkMode
                                ? Colors.grey[700]!
                                : Colors.grey[300]!,
                          ),
                        ),
                        child: Row(
                          children: [
                            _iconBtn(Icons.remove, widget.onDecrement),
                            Container(
                              constraints: const BoxConstraints(minWidth: 24),
                              alignment: Alignment.center,
                              child: Text(
                                '${widget.quantity}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            _iconBtn(Icons.add, widget.onIncrement),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      InkWell(
                        onTap: widget.onRemove,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
          child: Icon(icon, size: 16, color: Colors.amber),
        ),
      ),
    );
  }
}
