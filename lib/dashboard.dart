import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:tokonovel/book_detail_page.dart';
import 'package:tokonovel/about_page.dart';
import 'package:tokonovel/cart_page.dart';
import 'package:tokonovel/collection_page.dart';
import 'package:tokonovel/profile_page.dart';
import 'package:tokonovel/theme.dart';
import 'package:tokonovel/all_book_page.dart';
import 'package:tokonovel/debug_firestore_page.dart';
import 'package:tokonovel/models/book_model.dart';
import 'dart:convert';
import 'package:tokonovel/models/user_models.dart';
import 'package:tokonovel/services/firestore_service.dart';
import 'package:tokonovel/utils/image_proxy.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final ScrollController _scrollController = ScrollController();
  // Viewport fraction: seberapa lebar item buku terlihat
  final PageController _pageController = PageController(viewportFraction: 0.35);
  final TextEditingController _searchController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Timer? _autoScrollTimer;
  int _selectedIndex = 0;
  bool _isPaused = false;
  String _searchQuery = "";

  // [MODIFIKASI] Variabel untuk menyimpan stream yang aktif (Popular atau All)
  late Stream<List<BookModel>> _displayedBookStream;
  // [MODIFIKASI] Variabel untuk judul section
  String _sectionTitle = "Novel Best Seller";

  final List<Category> categories = [
    Category(name: "All", icon: Icons.apps),
    Category(name: "Romance", icon: Icons.favorite),
    Category(name: "Fiction", icon: Icons.auto_stories),
    Category(name: "Crime", icon: Icons.shield),
    Category(name: "Science", icon: Icons.science),
    Category(name: "Comedy", icon: Icons.emoji_emotions),
  ];

  @override
  void initState() {
    super.initState();
    // Awalnya tampilkan buku populer
    _displayedBookStream = getPopularBooksStream();

    _startAutoScroll();
    
    // Listener untuk mendeteksi ketikan pencarian
    _searchController.addListener(_onSearchChanged);
  }

  // [MODIFIKASI] Logika untuk menukar stream berdasarkan pencarian
  void _onSearchChanged() {
    final query = _searchController.text.trim().toLowerCase();
    
    // Cek apakah query berubah drastis (misal dari kosong ke ada isi, atau sebaliknya)
    // untuk menghindari rebuild stream berlebihan jika tidak perlu
    if (query.isNotEmpty && _searchQuery.isEmpty) {
       // User mulai mengetik -> Switch ke Semua Buku
       setState(() {
         _searchQuery = query;
         _sectionTitle = "Hasil Pencarian";
         _displayedBookStream = _firestoreService.getAllBooks(); 
       });
    } else if (query.isEmpty && _searchQuery.isNotEmpty) {
       // User menghapus search -> Balik ke Best Seller
       setState(() {
         _searchQuery = query;
         _sectionTitle = "Novel Best Seller";
         _displayedBookStream = getPopularBooksStream();
       });
    } else {
       // Hanya update query text untuk filtering
       setState(() {
         _searchQuery = query;
       });
    }
  }

  Stream<List<BookModel>> getPopularBooksStream() {
    final slugs = [
      'laskar-pelangi-edisi-50',
      'dilan-dia-adalah-dilanku-tahun-1990',
      'solo-leveling',
      'seporsi-mie-ayam-sebelum-mati',
      'the-lord-of-the-rings-kembalinya-sang-raja',
    ];

    return _db
        .collection('books')
        .where('slug', whereIn: slugs)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return BookModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      // [MODIFIKASI] Matikan auto-scroll jika sedang mencari (_searchQuery tidak kosong)
      if (!_isPaused && _pageController.hasClients && _searchQuery.isEmpty) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _scrollController.dispose();
    _pageController.dispose();
    _searchController.removeListener(_onSearchChanged); // Hapus listener
    _searchController.dispose();
    super.dispose();
  }

  void _onNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CollectionPage()),
      ).then((_) => setState(() => _selectedIndex = 0));
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CartPage()),
      ).then((_) => setState(() => _selectedIndex = 0));
    } else if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AboutUsPage()),
      ).then((_) => setState(() => _selectedIndex = 0));
    }
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
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
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
                     Image.asset(
                          'assets/images/logo.png', // Pastikan nama file sesuai
                          height: 200, // Atur tinggi logo sesuai keinginan
                          width: 200, // Atur lebar logo
                          fit: BoxFit.contain,
                        ),
                      const SizedBox(width: 12),
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Color(0xFFD4AF37), Color(0xFFFFD700)],
                        ).createShader(bounds),
                        child: const Text(
                          'NOVELKU',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 60),
                      Expanded(
                        child: Row(
                          children: [
                            _buildNavItem('Home', 0, isDarkMode),
                            _buildNavItem('Favorit', 1, isDarkMode),
                            _buildNavItem('Keranjang', 2, isDarkMode),
                            _buildNavItem('About', 3, isDarkMode),
                          ],
                        ),
                      ),
                      Container(
                        width: 280,
                        height: 45,
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? const Color(0xFF2A2A2A)
                              : const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: isDarkMode
                                ? Colors.grey[800]!
                                : Colors.grey[300]!,
                            width: 1,
                          ),
                        ),
                        child: TextField(
                          controller: _searchController,
                          style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Cari novel favorit Anda...',
                            hintStyle: TextStyle(
                              color: isDarkMode
                                  ? Colors.grey[500]
                                  : Colors.grey[600],
                              fontSize: 14,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            suffixIcon: Container(
                              margin: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFD4AF37),
                                    Color(0xFFFFD700),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(
                                Icons.search,
                                color: Colors.black,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 24),
                      StreamBuilder<UserProfile?>(
                        stream: _firestoreService.getUserProfileStream(),
                        builder: (context, snapshot) {
                          String displayName = 'User';
                          Uint8List? photoBytes;

                          if (snapshot.hasData && snapshot.data != null) {
                            final userProfile = snapshot.data!;
                            displayName = userProfile.name.isNotEmpty
                                ? userProfile.name
                                : 'User';
                            if (userProfile.photoUrl.isNotEmpty) {
                              try {
                                photoBytes = base64Decode(userProfile.photoUrl);
                              } catch (e) {
                                photoBytes = null;
                              }
                            }
                          }

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const ProfilePage()),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isDarkMode
                                    ? const Color(0xFF2A2A2A)
                                    : const Color(0xFFF5F5F5),
                                borderRadius: BorderRadius.circular(25),
                                border: Border.all(
                                  color: const Color(
                                    0xFFD4AF37,
                                  ).withAlpha((0.3 * 255).round()),
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFFD4AF37),
                                          Color(0xFFFFD700),
                                        ],
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: CircleAvatar(
                                      backgroundColor: isDarkMode
                                          ? const Color(0xFF2A2A2A)
                                          : Colors.white,
                                      radius: 16,
                                      backgroundImage: (photoBytes != null)
                                          ? MemoryImage(photoBytes)
                                          : null,
                                      child: (photoBytes != null)
                                          ? null
                                          : const Icon(
                                              Icons.person,
                                              color: Color(0xFFD4AF37),
                                              size: 18,
                                            ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    displayName,
                                    style: TextStyle(
                                      color: isDarkMode
                                          ? Colors.white
                                          : Colors.black,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? const Color(0xFF2A2A2A)
                              : const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFD4AF37).withAlpha(
                              (0.3 * 255).round(),
                            ),
                            width: 1.5,
                          ),
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.bug_report,
                            color: Color(0xFFD4AF37),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const DebugFirestorePage(),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? const Color(0xFF2A2A2A)
                              : const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFD4AF37).withAlpha(
                              (0.3 * 255).round(),
                            ),
                            width: 1.5,
                          ),
                        ),
                        child: IconButton(
                          icon: Icon(
                            isDarkMode ? Icons.light_mode : Icons.dark_mode,
                            color: const Color(0xFFD4AF37),
                          ),
                          onPressed: () {
                            setState(() {
                              backgroundColorNotifier.value = isDarkMode
                                  ? const Color(0xFFF5F5F5)
                                  : const Color(0xFF1A1A1A);
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                titleSpacing: 0,
              ),

              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 50,
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 60,
                    horizontal: 40,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDarkMode
                          ? [
                              const Color(0xFF1A1A1A),
                              const Color(0xFF2A2A2A),
                              const Color(0xFF1A1A1A),
                            ]
                          : [
                              const Color(0xFFFAFAFA),
                              const Color(0xFFFFFFFF),
                              const Color(0xFFF5F5F5),
                            ],
                    ),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: const Color(
                        0xFFD4AF37,
                      ).withAlpha((0.2 * 255).round()),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFD4AF37).withAlpha(
                          (0.1 * 255).round(),
                        ),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [
                            Color(0xFFD4AF37),
                            Color(0xFFFFD700),
                            Color(0xFFD4AF37),
                          ],
                        ).createShader(bounds),
                        child: const Text(
                          'Selamat Datang di NOVELKU',
                          style: TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 1,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Temukan ribuan novel menarik, dari best seller hingga digital original!',
                        style: TextStyle(
                          fontSize: 18,
                          color: isDarkMode
                              ? Colors.grey[400]
                              : Colors.grey[700],
                          height: 1.5,
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFD4AF37), Color(0xFFFFD700)],
                          ),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFD4AF37).withAlpha(
                                (0.4 * 255).round(),
                              ),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AllBooksPage(
                                  selectedCategorySlug: 'buku/semua',
                                  selectedGenreId: null,
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 48,
                              vertical: 18,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Jelajahi Semua Novel',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(
                                Icons.arrow_forward,
                                color: Color.fromARGB(255, 0, 0, 0),
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(40, 40, 40, 24),
                  child: Row(
                    children: [
                      Container(
                        width: 5,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFD4AF37), Color(0xFFFFD700)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(width: 16),
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Color(0xFFD4AF37), Color(0xFFFFD700)],
                        ).createShader(bounds),
                        child: Text(
                          _sectionTitle, // [MODIFIKASI] Gunakan Judul Variabel
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(
                        Icons.local_fire_department,
                        color: Color(0xFFD4AF37),
                        size: 32,
                      ),
                    ],
                  ),
                ),
              ),

              // --- STREAM BUILDER UNTUK BOOKS (INFINITE REAL-TIME) ---
              SliverToBoxAdapter(
                child: MouseRegion(
                  onEnter: (_) => setState(() => _isPaused = true),
                  onExit: (_) => setState(() => _isPaused = false),
                  child: SizedBox(
                    height: 500,
                    child: StreamBuilder<List<BookModel>>(
                      // [MODIFIKASI] Gunakan stream dinamis (Popular atau All)
                      stream: _displayedBookStream, 
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFFD4AF37),
                            ),
                          );
                        }

                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return Center(
                            child: Text(
                              'Tidak ada buku tersedia',
                              style: TextStyle(
                                color: isDarkMode
                                    ? Colors.white60
                                    : Colors.black54,
                                fontSize: 16,
                              ),
                            ),
                          );
                        }

                        final allBooks = snapshot.data!;
                        // Filter buku
                        final filteredBooks = _searchQuery.isEmpty
                            ? allBooks
                            : allBooks.where((book) {
                                return book.title.toLowerCase().contains(
                                          _searchQuery,
                                        ) ||
                                    book.author.toLowerCase().contains(
                                          _searchQuery,
                                        );
                              }).toList();

                        if (filteredBooks.isEmpty) {
                          return Center(
                            child: Text(
                              'Buku tidak ditemukan',
                              style: TextStyle(
                                color: isDarkMode
                                    ? Colors.white60
                                    : Colors.black54,
                                fontSize: 16,
                              ),
                            ),
                          );
                        }

// Tentukan apakah sedang mode cari
                        final bool isSearching = _searchQuery.isNotEmpty;

                        return PageView.builder(
                          controller: _pageController,
                          
                          // [PERBAIKAN UTAMA]
                          // Jika sedang mencari, batasi jumlah item sesuai hasil (jangan infinite/null)
                          // Jika tidak mencari (mode Best Seller), biarkan null (infinite scroll)
                          itemCount: isSearching ? filteredBooks.length : null,
                          
                          onPageChanged: (index) {
                            // Update index hanya jika perlu
                          },
                          
                          itemBuilder: (context, index) {
                            // [PERBAIKAN UTAMA]
                            // Jika searching, ambil index langsung (0, 1, 2...)
                            // Jika infinite, gunakan modulo (%) agar berulang
                            final bookIndex = isSearching ? index : index % filteredBooks.length;
                            final book = filteredBooks[bookIndex];

                            return AnimatedBuilder(
                              animation: _pageController,
                              builder: (context, child) {
                                double value = 1.0;
                                if (_pageController.position.haveDimensions) {
                                  value = _pageController.page! - index;
                                  value = (1 - (value.abs() * 0.25)).clamp(
                                    0.85,
                                    1.0,
                                  );
                                }
                                return Center(
                                  child: Transform.scale(
                                    scale: value,
                                    child: Opacity(
                                      opacity: value,
                                      child: child,
                                    ),
                                  ),
                                );
                              },
                              child: BookCard(
                                book: book,
                                isDarkMode: isDarkMode,
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(40, 40, 40, 24),
                  child: Row(
                    children: [
                      Container(
                        width: 5,
                        height: 35,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFD4AF37), Color(0xFFFFD700)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(width: 16),
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Color(0xFFD4AF37), Color(0xFFFFD700)],
                        ).createShader(bounds),
                        child: const Text(
                          'Kategori',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        return CategoryCard(
                          category: categories[index],
                          isDarkMode: isDarkMode,
                        );
                      },
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Container(
                    padding: const EdgeInsets.all(48),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF1B5E20),
                          Color(0xFF2E7D32),
                          Color(0xFF388E3C),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1B5E20).withAlpha(
                            (0.4 * 255).round(),
                          ),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(
                              (0.2 * 255).round(),
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.local_offer,
                            size: 56,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Promo Special',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [
                              Color(0xFFFFD700),
                              Color(0xFFD4AF37),
                              Color(0xFFFFD700),
                            ],
                          ).createShader(bounds),
                          child: const Text(
                            'Diskon Hingga 50%',
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Novel Terpilih',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white70,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 28),
                        Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFD4AF37), Color(0xFFFFD700)],
                            ),
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFD4AF37).withAlpha(
                                  (0.5 * 255).round(),
                                ),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 48,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Beli Sekarang',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.black,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(
                                  Icons.shopping_cart,
                                  color: Colors.black,
                                  size: 20,
                                ),
                              ],
                            ),
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
      },
    );
  }

  Widget _buildNavItem(String title, int index, bool isDarkMode) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onNavItemTapped(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFFD4AF37), Color(0xFFFFD700)],
                )
              : null,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected
                ? Colors.black
                : (isDarkMode ? Colors.white : Colors.black87),
            fontSize: 15,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}

class BookCard extends StatelessWidget {
  final BookModel book;
  final bool isDarkMode;

  const BookCard({Key? key, required this.book, required this.isDarkMode})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkMode
              ? [const Color(0xFF2A2A2A), const Color(0xFF1F1F1F)]
              : [Colors.white, const Color(0xFFFAFAFA)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFD4AF37).withAlpha((0.3 * 255).round()),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.2 * 255).round()),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: Image.network(
                      coverProxy(book.imageUrl, w: 480, h: 600),
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
                            child: CircularProgressIndicator(
                              color: Color(0xFFD4AF37),
                            ),
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
                            child: Icon(
                              Icons.book,
                              size: 60,
                              color: Colors.white54,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFD4AF37), Color(0xFFFFD700)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(
                              (0.3 * 255).round(),
                            ),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, color: Colors.black, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            (book.rating ?? 0.0).toStringAsFixed(1),
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black,
                        letterSpacing: 0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      book.author,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        letterSpacing: 0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Icon(Icons.people, color: Colors.grey[500], size: 14),
                        const SizedBox(width: 6),
                        Text(
                          book.voters ?? '0',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFD4AF37), Color(0xFFFFD700)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFD4AF37).withAlpha(
                              (0.4 * 255).round(),
                            ),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BookDetailPage(book: book),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Lihat Detail',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                letterSpacing: 0.3,
                              ),
                            ),
                            SizedBox(width: 6),
                            Icon(
                              Icons.arrow_forward,
                              color: Color.fromARGB(255, 0, 0, 0),
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Category {
  final String name;
  final IconData icon;

  Category({required this.name, required this.icon});
}

// Helper function to map category name to Firestore category slug
String _getCategorySlug(String categoryName) {
  switch (categoryName) {
    case 'All':
      return 'buku/semua'; 
    case 'Romance':
      return 'buku/romance';
    case 'Fiction':
      return 'buku/fiksi-sastra'; 
    case 'Crime':
      return 'buku/crime';
    case 'Science':
      return 'buku/sains';
    case 'Comedy':
      return 'buku/komedi';
    default:
      return 'buku/semua';
  }
}

class CategoryCard extends StatelessWidget {
  final Category category;
  final bool isDarkMode;

  const CategoryCard({
    Key? key,
    required this.category,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 130,
      margin: const EdgeInsets.only(right: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkMode
              ? [const Color(0xFF2A2A2A), const Color(0xFF1F1F1F)]
              : [Colors.white, const Color(0xFFFAFAFA)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFD4AF37).withAlpha((0.3 * 255).round()),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.1 * 255).round()),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            if (category.name == 'All') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AllBooksPage(
                    selectedCategorySlug: 'buku/semua',
                    selectedGenreId: null,
                  ),
                ),
              );
            } else {
              final slug = _getCategorySlug(category.name);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AllBooksPage(
                    selectedCategorySlug: slug,
                    selectedGenreId: null,
                  ),
                ),
              );
            }
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFD4AF37), Color(0xFFFFD700)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFD4AF37).withAlpha((0.3 * 255).round()),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(category.icon, color: Colors.black, size: 28),
              ),
              const SizedBox(height: 12),
              Text(
                category.name,
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}