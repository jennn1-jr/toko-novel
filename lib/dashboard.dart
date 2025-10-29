import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tokonovel/book_detail_page.dart';
import 'package:tokonovel/about_page.dart';
import 'package:tokonovel/cart_page.dart';
import 'package:tokonovel/models/user_models.dart';
import 'package:tokonovel/profile_page.dart';
import 'package:tokonovel/services/firestore_service.dart';

// ===== MODEL Novel yang cocok dengan Firestore =====
class Novel {
  final String title;
  final String author;
  final String image;       // kita isi emoji / placeholder
  final double rating;      // rata-rata rating
  final int voters;         // total orang yang rating
  final String description; // sinopsis / deskripsi

  Novel({
    required this.title,
    required this.author,
    required this.image,
    required this.rating,
    required this.voters,
    required this.description,
  });

  // Factory: build Novel dari dokumen Firestore
  factory Novel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    // ambil list ratings dari Firestore
    final List<dynamic> ratingsList = (data['ratings'] ?? []) as List<dynamic>;

    // hitung total voters
    final voters = ratingsList.length;

    // hitung rata-rata rating
    double avgRating = 0.0;
    if (voters > 0) {
      double sum = 0.0;
      for (final r in ratingsList) {
        // r adalah Map { user_id, rating, created_at }
        if (r is Map && r['rating'] != null) {
          final val = r['rating'];
          if (val is num) sum += val.toDouble();
        }
      }
      avgRating = sum / voters;
    }

    // placeholder cover emoji biar UI kamu tetap lucu
    // kamu bisa nanti ganti jadi URL cover (imageUrl) dari Firestore kalau ada
    final placeholderEmoji = "📘";

    return Novel(
      title: data['title'] ?? 'Tanpa Judul',
      author: (data['author'] != null && data['author']['name'] != null)
          ? data['author']['name']
          : 'Unknown Author',
      image: placeholderEmoji,
      rating: avgRating,
      voters: voters,
      description: data['description'] ?? '',
    );
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedIndex = 0;

  // semua novel dari Firestore
  List<Novel> _allNovels = [];

  // novel yang ditampilkan setelah filter search
  List<Novel> _filteredNovels = [];

  // Firestore service instance untuk mendapatkan stream profile user
  final FirestoreService _firestoreService = FirestoreService();

  bool _loading = true;
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterNovels);
    _loadNovelsFromFirestore();
  }

  Future<void> _loadNovelsFromFirestore() async {
    try {
      // ambil semua dokumen di koleksi 'novels'
      final snap = await FirebaseFirestore.instance
          .collection('novels')
          .get(); // sekali fetch

      final novels = snap.docs.map((doc) {
        return Novel.fromFirestore(doc);
      }).toList();

      setState(() {
        _allNovels = novels;
        _filteredNovels = novels; // default tampil semua
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _errorMsg = e.toString();
        _loading = false;
      });
    }
  }

  void _filterNovels() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredNovels = _allNovels.where((novel) {
        return novel.title.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
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
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AboutUsPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // STATE HANDLING ATAS (loading / error)
    if (_loading) {
      return const Scaffold(
        backgroundColor: Color(0xFF1E1E1E),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFD4A574)),
        ),
      );
    }

    if (_errorMsg != null) {
      return Scaffold(
        backgroundColor: const Color(0xFF1E1E1E),
        body: Center(
          child: Text(
            'Gagal load data: $_errorMsg',
            style: const TextStyle(color: Colors.redAccent),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: CustomScrollView(
        slivers: [
          // =================== APP BAR ===================
          SliverAppBar(
            backgroundColor: Colors.black,
            pinned: true,
            expandedHeight: 0,
            toolbarHeight: 70,
            automaticallyImplyLeading: false,
            flexibleSpace: SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  children: [
                    // Logo + Brand
                    Row(
                      children: [
                        const Icon(Icons.menu_book,
                            color: Colors.white, size: 28),
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
                      child: TextField(
                        controller: _searchController,
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
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),

                    // User Profile Button
                    GestureDetector(
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfilePage()),
    );
  },
  child: Row(
    children: [
      // ===== CircleAvatar DIKEMBALIKAN DI SINI =====
      CircleAvatar(
        backgroundColor: const Color(0xFF2A2A2A),
        radius: 18,
        child: Icon(
          Icons.person,
          color: Colors.white,
          size: 20,
        ),
      ),
      // ===========================================
      const SizedBox(width: 8),
      // StreamBuilder untuk menampilkan nama (Kode ini sudah benar)
      StreamBuilder<UserProfile?>(
        stream: _firestoreService.getUserProfileStream(),
        builder: (context, snapshot) {
          // Handle state Menunggu (Waiting)
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text(
              FirebaseAuth.instance.currentUser?.email?.split('@')[0] ?? 'Loading...',
              style: TextStyle(color: Colors.white70, fontSize: 14),
              overflow: TextOverflow.ellipsis,
            );
          }

          // Handle jika ada Error
          if (snapshot.hasError) {
             return Text(
               'Error',
               style: TextStyle(color: Colors.red, fontSize: 14),
               overflow: TextOverflow.ellipsis,
             );
          }

          // Handle jika data Aktif dan Ada
          String displayName = 'User';
          if (snapshot.connectionState == ConnectionState.active && snapshot.hasData && snapshot.data != null) {
            displayName = snapshot.data!.name.isNotEmpty
                ? snapshot.data!.name
                : (FirebaseAuth.instance.currentUser?.email?.split('@')[0] ?? 'User');
          } else if (FirebaseAuth.instance.currentUser != null) {
             displayName = FirebaseAuth.instance.currentUser!.displayName ?? FirebaseAuth.instance.currentUser!.email?.split('@')[0] ?? 'User';
          }

          // Tampilkan nama yang sudah didapat
          return Text(
            displayName,
            style: TextStyle(color: Colors.white, fontSize: 14),
            overflow: TextOverflow.ellipsis,
          );
        },
      ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // =================== HERO SECTION ===================
          SliverToBoxAdapter(
            child: Container(
              height: 350,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF3A3A3A),
                    Color(0xFF2A2A2A),
                  ],
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
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 18,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () {
                        // nanti diarahkan ke Koleksi (index 1)
                        _onNavItemTapped(1);
                      },
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

          // =================== BEST SELLER SECTION ===================
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

                  // Grid/Row daftar novel dari Firestore (sudah terfilter)
                  Wrap(
                    alignment: WrapAlignment.center,
                    children: _filteredNovels
                        .map(
                          (novel) => _buildNovelCard(novel),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
          ),

          // =================== CATEGORIES SECTION ===================
          SliverToBoxAdapter(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
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

          // =================== PROMO SECTION (STATIC) ===================
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
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF2D5F3F),
                            Color(0xFF1A3D2A),
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

          const SliverToBoxAdapter(child: SizedBox(height: 60)),
        ],
      ),
    );
  }

  // =================== Helper Widgets ===================

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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                      style:
                          TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 12),

                    // Rating
                    Row(
                      children: [
                        ...List.generate(5, (index) {
                          // index: 0..4
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
                  side: const BorderSide(
                      color: Color(0xFFD4A574), width: 1.5),
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
                  style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600),
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
