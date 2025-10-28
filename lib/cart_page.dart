import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Keranjang Buku',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        primaryColor: Colors.amber,
      ),
      home: const CartPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class CartItem {
  final String title;
  final String author;
  final String price;
  final String imageUrl;
  int quantity;

  CartItem({
    required this.title,
    required this.author,
    required this.price,
    required this.imageUrl,
    this.quantity = 1,
  });
}

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<CartItem> cartItems = [
    CartItem(
      title: 'Lintang Kemukus',
      author: 'Ahmad Tohari',
      price: 'Rp 85.000',
      imageUrl: 'https://images.unsplash.com/photo-1544947950-fa07a98d237f?w=400',
    ),
    CartItem(
      title: 'Pulang',
      author: 'Tere Liye',
      price: 'Rp 95.000',
      imageUrl: 'https://images.unsplash.com/photo-1512820790803-83ca734da794?w=400',
    ),
    CartItem(
      title: 'Bumi',
      author: 'Tere Liye',
      price: 'Rp 78.000',
      imageUrl: 'https://images.unsplash.com/photo-1589998059171-988d887df646?w=400',
    ),
    CartItem(
      title: 'Dilan 1990',
      author: 'Pidi Baiq',
      price: 'Rp 89.000',
      imageUrl: 'https://images.unsplash.com/photo-1543002588-bfa74002ed7e?w=400',
    ),
  ];

  double getTotalPrice() {
    double total = 0;
    for (var item in cartItems) {
      String priceStr = item.price.replaceAll('Rp ', '').replaceAll('.', '');
      total += double.parse(priceStr) * item.quantity;
    }
    return total;
  }

  void removeItem(int index) {
    setState(() {
      cartItems.removeAt(index);
    });
  }

  void updateQuantity(int index, int delta) {
    setState(() {
      cartItems[index].quantity += delta;
      if (cartItems[index].quantity < 1) {
        cartItems[index].quantity = 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'SMART',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cart Items Section
          Expanded(
            flex: 7,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Keranjang Buku Anda',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            cartItems.clear();
                          });
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
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      return CartItemCard(
                        item: cartItems[index],
                        onRemove: () => removeItem(index),
                        onQuantityChanged: (delta) => updateQuantity(index, delta),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          
          // Summary Section
          Container(
            width: 350,
            color: const Color(0xFF1A1A1A),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ringkasan Pesanan',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Subtotal',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    Text(
                      'Rp ${getTotalPrice().toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'Biaya Pengiriman',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    Text(
                      'Rp 15.000',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(color: Colors.grey),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Rp ${(getTotalPrice() + 15000).toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
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
                    onPressed: () {},
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
      ),
    );
  }
}

class CartItemCard extends StatelessWidget {
  final CartItem item;
  final VoidCallback onRemove;
  final Function(int) onQuantityChanged;

  const CartItemCard({
    Key? key,
    required this.item,
    required this.onRemove,
    required this.onQuantityChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Book Cover
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              item.imageUrl,
              width: 80,
              height: 110,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 80,
                  height: 110,
                  color: Colors.grey[800],
                  child: const Icon(Icons.book, size: 40, color: Colors.grey),
                );
              },
            ),
          ),
          const SizedBox(width: 16),
          
          // Book Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.author,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[400],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item.price,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber,
                  ),
                ),
              ],
            ),
          ),
          
          // Quantity Controls
          Row(
            children: [
              IconButton(
                onPressed: () => onQuantityChanged(-1),
                icon: const Icon(Icons.remove_circle_outline, color: Colors.grey),
                iconSize: 24,
              ),
              Text(
                '${item.quantity}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              IconButton(
                onPressed: () => onQuantityChanged(1),
                icon: const Icon(Icons.add_circle_outline, color: Colors.amber),
                iconSize: 24,
              ),
            ],
          ),
          
          // Remove Button
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
