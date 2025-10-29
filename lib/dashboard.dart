<<<<<<< HEAD
// 1. TAMBAHKAN SEMUA IMPORT YANG DIBUTUHKAN DI SINI
import 'package:flutter/material.dart';
import 'package:tokonovel/about_page.dart'; // Pastikan path ini benar
import 'package:tokonovel/book_detail_page.dart'; // Pastikan path ini benar
import 'package:tokonovel/cart_page.dart'; // Pastikan path ini benar
=======
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tokonovel/book_detail_page.dart';
import 'package:tokonovel/about_page.dart';
import 'package:tokonovel/cart_page.dart';
import 'package:tokonovel/cart_page.dart';
import 'package:tokonovel/profile_page.dart'; // Import the CartPage
>>>>>>> 7f2187507c7f3b068b8a69f103f5454ea687128e


// 2. PINDAHKAN ATAU DEFINISIKAN ULANG CLASS NOVEL DI FILE INI
class Novel {
  final String title;
  final String author;
  final String image;
  final double rating;
  final int voters;
  final String description;

  Novel({
    required this.title,
    required this.author,
    required this.image,
    required this.rating,
    required this.voters,
    required this.description,
  });
}

// 3. KODE DASHBOARD PAGE ANDA (TIDAK PERLU DIUBAH, HANYA PASTE ULANG)
class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedIndex = 0;

  // Daftar novel asli yang tidak akan berubah
  final List<Novel> bestSellers = [
    Novel(
      title: "Harry Potter and the Sorcerer's Stone",
      author: "J. K. Rowling",
      image: "🧙",
      rating: 4.8,
      voters: 2967,
      description:
          "Masuki dunia sihir penuh petualangan dan misteri bersama Harry Potter di novel fantasi legendaris karya J.K. Rowling ini.",
    ),
    Novel(
      title: "Solo Leveling",
      author: "Chugong",
      image: "⚔️",
      rating: 4.9,
      voters: 1594,
      description:
          "Petualangan Sung Jin-Woo naik level dari terkemah menjadi terkuat dalam dunia penuh monster dan gerbang misterius.",
    ),
    Novel(
      title: "Laskar Pelangi",
      author: "Andrea Hirata",
      image: "🌈",
      rating: 4.7,
      voters: 1987,
      description:
          "Kisah inspiratif anak-anak Belitong yang penuh semangat, mimpi besar, dan perjuangan menghadapi keterbatasan pendidikan.",
    ),
  ];

  // Daftar novel yang akan ditampilkan di UI (hasil filter)
  List<Novel> _filteredNovels = [];

  @override
  void initState() {
    super.initState();
    // Saat halaman pertama kali dibuka, tampilkan semua novel
    _filteredNovels = bestSellers;
    // Tambahkan listener untuk mendeteksi perubahan teks pada search bar
    _searchController.addListener(_filterNovels);
  }

  // Fungsi untuk memfilter novel berdasarkan input pencarian
  void _filterNovels() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredNovels = bestSellers.where((novel) {
        // Cek apakah judul novel mengandung teks yang dicari (case-insensitive)
        return novel.title.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    // Hapus listener untuk mencegah memory leak
    _searchController.removeListener(_filterNovels);
    _searchController.dispose();
    super.dispose();
  }

  void _onNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CartPage()),
      );
    } else if (index == 3) {
      // 'About' is at index 3
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AboutUsPage()),
      );
    }
  }

 @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xFFF5F5F5),
    body: CustomScrollView(
      slivers: [
        SliverAppBar(
          backgroundColor: Colors.black, // Pastikan ada background color atau styling lain
          pinned: true,
          expandedHeight: 0, // Sesuaikan jika perlu
          toolbarHeight: 70,
          automaticallyImplyLeading: false, // Menghilangkan tombol back default
          flexibleSpace: SafeArea(
            child: Padding(
              // ===== PERBAIKAN DI SINI =====
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), // Tambahkan parameter padding
              // =============================
              child: Row(
                children: [
                  // ... (Logo) ...
                  Row(
                    children: [
                      Icon(Icons.menu_book, color: Colors.white, size: 28),
                      const SizedBox(width: 8),
                      const Text(
                        'NOVELKU',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 40),

                  // Navigation Menu
                  Expanded(
                    child: Row(
                      children: [
                        _buildNavItem('Home', 0),
                        _buildNavItem('Koleksi', 1),
                        _buildNavItem('Keranjang', 2),
                        _buildNavItem('About', 3),
                      ],
                    ),
                  ),

                  // Search Bar
                  Container(
                    width: 250,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A2A2A),
                      borderRadius: BorderRadius.circular(20),
                    ),
<<<<<<< HEAD

                    // Search Bar
                    Container(
                      width: 250,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A2A2A),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: TextField(
                        controller: _searchController, // Controller sudah ada
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Cari novel...',
                          hintStyle: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          suffixIcon: Icon(
                            Icons.search,
                            color: Colors.grey[500],
                            size: 20,
                          ),
=======
                    child: TextField(
                      controller: _searchController, // Pastikan _searchController didefinisikan di state
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Cari novel...',
                        hintStyle: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10, // Sesuaikan padding vertikal agar teks di tengah
                        ),
                        suffixIcon: Icon(
                          Icons.search,
                          color: Colors.grey[500],
                          size: 20,
>>>>>>> 7f2187507c7f3b068b8a69f103f5454ea687128e
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),

                  // User Profile (buat jadi GestureDetector)
                  GestureDetector( // Dibungkus GestureDetector
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ProfilePage()), // Navigasi ke ProfilePage
                      );
                    },
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: const Color(0xFF2A2A2A),
                          radius: 18,
                          child: Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Ambil nama user dari FirebaseAuth atau Firestore jika perlu
                        // Untuk sementara:
                        Text(
                          FirebaseAuth.instance.currentUser?.displayName ??
                          FirebaseAuth.instance.currentUser?.email?.split('@')[0] ?? // Ambil bagian sebelum @ jika display name null
                          'User',
                          style: TextStyle(color: Colors.white, fontSize: 14),
                          overflow: TextOverflow.ellipsis, // Cegah nama terlalu panjang
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

          // Hero Section
          SliverToBoxAdapter(
            child: Container(
              height: 350,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [const Color(0xFF3A3A3A), const Color(0xFF2A2A2A)],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Selamat Datang di NOVELKU',
                      style: TextStyle(
                        color: Color(0xFFD4A574),
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Temukan ribuan novel menarik, dari best seller hingga digital original!',
                      style: TextStyle(color: Colors.grey[400], fontSize: 18),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD4A574),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 48,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: const Text(
                        'Jelajahi Koleksi',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Best Seller Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                children: [
                  const Text(
                    'Novel Best Seller',
                    style: TextStyle(
                      color: Color(0xFFD4A574),
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Novel Cards
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    // *** PERUBAHAN DI SINI ***
                    // Tampilkan novel dari _filteredNovels, bukan bestSellers
                    children: _filteredNovels
                        .map((novel) => Flexible(child: _buildNovelCard(novel)))
                        .toList(),
                  ),
                ],
              ),
            ),
          ),

          // Categories Section (Sisa kode sama)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildCategoryItem(Icons.book, 'Romance'),
                      _buildCategoryItem(Icons.auto_stories, 'Komedi'),
                      _buildCategoryItem(Icons.psychology, 'Fantasi'),
                      _buildCategoryItem(Icons.people, 'Drama'),
                      _buildCategoryItem(Icons.eco, 'Edukasi'),
                      _buildCategoryItem(Icons.history_edu, 'Biografi'),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Special Promo Section (Sisa kode sama)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Book Image
                    Container(
                      width: 140,
                      height: 200,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFF2D5F3F),
                            const Color(0xFF1A3D2A),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('🌙', style: TextStyle(fontSize: 60)),
                            SizedBox(height: 8),
                            Text(
                              'Laskar\nPelangi',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 32),

                    // Promo Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD4A574),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Promo Spesial',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Diskon Hingga 50%',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Novel Terbaik!',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Text(
                                'Rp 250.000',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Rp 125.000',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFD4A574),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFD4A574),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'Beli Sekarang',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Footer Spacing
          const SliverToBoxAdapter(child: SizedBox(height: 60)),
        ],
      ),
    );
  }

  // Helper Widgets (tidak ada perubahan di sini)
  Widget _buildNavItem(String title, int index) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        _onNavItemTapped(index);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? const Color(0xFFD4A574) : Colors.white,
            fontSize: 15,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildNovelCard(Novel novel) {
    return Container(
      width: 320,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Book Cover
              Container(
                width: 100,
                height: 140,
                decoration: BoxDecoration(
                  color: const Color(0xFFD4A574),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    novel.image,
                    style: const TextStyle(fontSize: 60),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Book Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      novel.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'by ${novel.author}',
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 12),

                    // Rating
                    Row(
                      children: [
                        ...List.generate(5, (index) {
                          if (index < novel.rating.floor()) {
                            return const Icon(
                              Icons.star,
                              color: Color(0xFFD4A574),
                              size: 16,
                            );
                          } else if (index < novel.rating) {
                            return const Icon(
                              Icons.star_half,
                              color: Color(0xFFD4A574),
                              size: 16,
                            );
                          } else {
                            return Icon(
                              Icons.star_border,
                              color: Colors.grey[400],
                              size: 16,
                            );
                          }
                        }),
                        const SizedBox(width: 8),
                        Text(
                          '(${novel.voters} voters)',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Description
          Text(
            novel.description,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[700],
              height: 1.5,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 20),

          // Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _buildActionIcon(
                    Icons.favorite_border,
                    const Color(0xFFD4A574),
                  ),
                  const SizedBox(width: 12),
                  _buildActionIcon(
                    Icons.shopping_cart_outlined,
                    const Color(0xFFD4A574),
                  ),
                  const SizedBox(width: 12),
                  _buildActionIcon(
                    Icons.share_outlined,
                    const Color(0xFFD4A574),
                  ),
                ],
              ),
              OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BookDetailPage(),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFD4A574), width: 1.5),
                  foregroundColor: const Color(0xFFD4A574),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'See The Book',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionIcon(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }

  Widget _buildCategoryItem(IconData icon, String label) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: const Color(0xFFD4A574),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 32),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}