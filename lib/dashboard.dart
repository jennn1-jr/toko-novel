import 'package:firebase_auth/firebase_auth.dart';
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

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final ScrollController _scrollController = ScrollController();
  final PageController _pageController = PageController(viewportFraction: 0.35);
  final TextEditingController _searchController = TextEditingController();
  Timer? _autoScrollTimer;
  int _currentPage = 0;
  int _selectedIndex = 0;
  bool _isPaused = false;
  String _userName = "User"; // Default name

  final List<BookModel> _allBooks = [
    BookModel(
      id: '1',
      genreId: '1',
      slug: 'harry-potter',
      title: "Harry Potter",
      author: "by J. K. Rowling",
      rating: 5.0,
      voters: "2,987 voters",
      description:
          "Masuki dunia sihir penuh petualangan dan misteri bersama Harry Potter.",
      imageUrl: "assets/images/harry_potter.png",
    ),
    BookModel(
      id: '2',
      genreId: '2',
      slug: 'solo-leveling',
      title: "Solo Leveling",
      author: "by Chugong",
      rating: 4.9,
      voters: "1,594 voters",
      description: "Petualangan Sung Jin-Woo dari terlemah menjadi terkuat.",
      imageUrl: "assets/images/solo_leveling.png",
    ),
    BookModel(
      id: '3',
      genreId: '3',
      slug: 'laskar-pelangi',
      title: "Laskar Pelangi",
      author: "by Andrea Hirata",
      rating: 4.8,
      voters: "1,987 voters",
      description: "Kisah inspiratif anak-anak Belitong yang penuh semangat.",
      imageUrl: "assets/images/laskar_pelangi.png",
    ),
    BookModel(
      id: '4',
      genreId: '1',
      slug: 'the-lord-of-the-rings',
      title: "The Lord of the Rings",
      author: "by J.R.R. Tolkien",
      rating: 5.0,
      voters: "3,421 voters",
      description:
          "Epik fantasi legendaris tentang perjalanan heroik menghancurkan cincin.",
      imageUrl: "assets/images/lotr.png",
    ),
    BookModel(
      id: '5',
      genreId: '4',
      slug: 'dilan-1990',
      title: "Dilan 1990",
      author: "by Pidi Baiq",
      rating: 4.7,
      voters: "2,156 voters",
      description: "Kisah romansa manis di era 90-an yang penuh kenangan.",
      imageUrl: "assets/images/dilan.png",
    ),
    BookModel(
      id: '6',
      genreId: '3',
      slug: 'bumi-manusia',
      title: "Bumi Manusia",
      author: "by Pramoedya Ananta Toer",
      rating: 4.9,
      voters: "2,541 voters",
      description:
          "Kisah Minke di tengah pusaran perubahan sosial dan politik Hindia Belanda.",
      imageUrl: "assets/images/bumi_manusia.png",
    ),
    BookModel(
      id: '7',
      genreId: '3',
      slug: 'cantik-itu-luka',
      title: "Cantik Itu Luka",
      author: "by Eka Kurniawan",
      rating: 4.8,
      voters: "1,890 voters",
      description:
          "Kisah tragis dan magis seorang wanita dan kutukan kecantikannya.",
      imageUrl: "assets/images/cantik_itu_luka.png",
    ),
    BookModel(
      id: '8',
      genreId: '3',
      slug: 'negeri-5-menara',
      title: "Negeri 5 Menara",
      author: "by Ahmad Fuadi",
      rating: 4.7,
      voters: "2,333 voters",
      description:
          "Perjuangan enam santri dari berbagai daerah untuk meraih mimpi mereka.",
      imageUrl: "assets/images/negeri_5_menara.png",
    ),
    BookModel(
      id: '9',
      genreId: '4',
      slug: 'perahu-kertas',
      title: "Perahu Kertas",
      author: "by Dee Lestari",
      rating: 4.6,
      voters: "1,988 voters",
      description:
          "Kisah tentang takdir, cinta, dan impian yang terjalin rumit.",
      imageUrl: "assets/images/perahu_kertas.png",
    ),
    BookModel(
      id: '10',
      genreId: '3',
      slug: 'ronggeng-dukuh-paruk',
      title: "Ronggeng Dukuh Paruk",
      author: "by Ahmad Tohari",
      rating: 4.8,
      voters: "1,560 voters",
      description: "Tragedi seorang penari ronggeng di tengah gejolak politik.",
      imageUrl: "assets/images/ronggeng.png",
    ),
  ];

  List<BookModel> _filteredBooks = []; // List to hold filtered books

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
    _filteredBooks = List.from(
      _allBooks,
    ); // Initialize filtered books with all books
    _startAutoScroll();
    _loadUserName();
    _searchController.addListener(
      _filterBooks,
    ); // Add listener for search input
  }

  void _loadUserName() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null &&
        user.displayName != null &&
        user.displayName!.isNotEmpty) {
      setState(() {
        _userName = user.displayName!;
      });
    }
  }

  void _filterBooks() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredBooks = List.from(_allBooks);
      } else {
        _filteredBooks = _allBooks.where((book) {
          return book.title.toLowerCase().contains(query) ||
              book.author.toLowerCase().contains(query);
        }).toList();
      }
      // Reset page controller if filtered list changes significantly
      if (_pageController.hasClients) {
        _pageController.jumpToPage(0);
      }
      _currentPage = 0;
    });
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!_isPaused &&
          _pageController.hasClients &&
          _filteredBooks.isNotEmpty) {
        int prevPage = _currentPage - 1;
        if (prevPage < 0) {
          prevPage = _filteredBooks.length - 1;
        }
        _pageController.animateToPage(
          prevPage,
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
    _searchController.removeListener(_filterBooks); // Remove listener
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
      );
    } else if (index == 2) {
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
                        color: Colors.black.withAlpha(
                          (0.1 * 255).round(),
                        ), // Replaced withOpacity
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
                          Icons.menu_book,
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
                            _buildNavItem('Koleksi', 1, isDarkMode),
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
                      GestureDetector(
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ProfilePage(),
                            ),
                          );
                          _loadUserName(); // Refresh name when returning from ProfilePage
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
                              color: const Color(0xFFD4AF37).withAlpha(
                                (0.3 * 255).round(),
                              ), // Replaced withOpacity
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
                                  child: const Icon(
                                    Icons.person,
                                    color: Color(0xFFD4AF37),
                                    size: 18,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                _userName, // Display the dynamic user name
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
                            ), // Replaced withOpacity
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
                            ), // Replaced withOpacity
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
                      color: const Color(0xFFD4AF37).withAlpha(
                        (0.2 * 255).round(),
                      ), // Replaced withOpacity
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFD4AF37).withAlpha(
                          (0.1 * 255).round(),
                        ), // Replaced withOpacity
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
                              ), // Replaced withOpacity
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            // Navigate to AllBooksPage showing all novels
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
                                'Jelajahi Koleksi',
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
                        child: const Text(
                          'Novel Best Seller',
                          style: TextStyle(
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

              SliverToBoxAdapter(
                child: MouseRegion(
                  onEnter: (_) => setState(() => _isPaused = true),
                  onExit: (_) => setState(() => _isPaused = false),
                  child: SizedBox(
                    height: 500,
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() => _currentPage = index);
                      },
                      itemCount: _filteredBooks.length, // Use filtered books
                      itemBuilder: (context, index) {
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
                                child: Opacity(opacity: value, child: child),
                              ),
                            );
                          },
                          child: BookCard(
                            book: _filteredBooks[index],
                            isDarkMode: isDarkMode,
                          ), // Use filtered books
                        );
                      },
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _filteredBooks.length, // Use filtered books
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        height: 10,
                        width: _currentPage == index ? 30 : 10,
                        decoration: BoxDecoration(
                          gradient: _currentPage == index
                              ? const LinearGradient(
                                  colors: [
                                    Color(0xFFD4AF37),
                                    Color(0xFFFFD700),
                                  ],
                                )
                              : null,
                          color: _currentPage == index
                              ? null
                              : Colors.grey[600],
                          borderRadius: BorderRadius.circular(5),
                          boxShadow: _currentPage == index
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFFD4AF37).withAlpha(
                                      (0.5 * 255).round(),
                                    ), // Replaced withOpacity
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                      ),
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
                          ), // Replaced withOpacity
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
                            ), // Replaced withOpacity
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
                                ), // Replaced withOpacity
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
          color: const Color(0xFFD4AF37).withAlpha(
            (0.3 * 255).round(),
          ), // Replaced withOpacity
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(
              (0.2 * 255).round(),
            ), // Replaced withOpacity
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
                    child: Image.asset(
                      book.imageUrl,
                      fit: BoxFit.cover,
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
                            ), // Replaced withOpacity
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
                            book.rating.toString(),
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
                          book.voters ?? '',
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
                            ), // Replaced withOpacity
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
                              builder: (context) => const BookDetailPage(),
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
                              color: Colors.black,
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
      return 'buku/semua'; // All books
    case 'Romance':
      return 'buku/romance';
    case 'Fiction':
      return 'buku/fiksi-sastra'; // Novel
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
          color: const Color(0xFFD4AF37).withAlpha(
            (0.3 * 255).round(),
          ), // Replaced withOpacity
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(
              (0.1 * 255).round(),
            ), // Replaced withOpacity
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
            // Navigate to AllBooksPage when category is tapped
            if (category.name == 'All') {
              // For "All" category, show all novels from both komik and fiksi-sastra
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
              // For other categories, navigate with appropriate slug
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
                      color: const Color(0xFFD4AF37).withAlpha(
                        (0.3 * 255).round(),
                      ), // Replaced withOpacity
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