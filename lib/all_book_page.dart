import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/book_model.dart';
import '../models/genre_model.dart';
import 'package:tokonovel/book_detail_page.dart';
import 'package:tokonovel/theme.dart';
import 'package:tokonovel/utils/image_proxy.dart';

class AllBooksPage extends StatefulWidget {
  /// Kalau [selectedGenreId] null/empty -> tampilkan semua genre di bawah [selectedCategorySlug].
  /// Contoh kategori:
  /// - 'buku/komik' (Light Novel)
  /// - 'buku/fiksi-sastra' (Novel)
  final String selectedCategorySlug;
  final String? selectedGenreId;
  final String? initialSearch;

  const AllBooksPage({
    super.key,
    required this.selectedCategorySlug,
    this.selectedGenreId,
    this.initialSearch,
  });

  @override
  State<AllBooksPage> createState() => _AllBooksPageState();
}

class _AllBooksPageState extends State<AllBooksPage> {
  final _db = FirebaseFirestore.instance;
  final _scroll = ScrollController();
  final _searchCtl = TextEditingController();

  final int _pageSize = 20;

  List<BookModel> _items = [];
  DocumentSnapshot<BookModel>? _lastDoc;
  bool _loading = false;
  bool _loadingMore = false;
  bool _hasMore = true;

  List<GenreModel> _categoryGenres = []; // genre ids untuk kategori aktif
  String? _activeGenreId; // bisa null = All
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _activeGenreId = (widget.selectedGenreId?.isNotEmpty == true)
        ? widget.selectedGenreId
        : null;
    _searchQuery = (widget.initialSearch ?? '').trim().toLowerCase();
    _searchCtl.text = widget.initialSearch ?? '';

    _scroll.addListener(_onScroll);
    _bootstrap();
  }

  @override
  void dispose() {
    _scroll.dispose();
    _searchCtl.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    setState(() => _loading = true);
    try {
      // 1) Ambil genres di bawah kategori
      Query<GenreModel> query = GenreRef.col(_db);

      if (widget.selectedCategorySlug == 'buku/semua') {
        // Fetch ALL genres from both komik and fiksi-sastra
        query = query
            .where('slug', isGreaterThanOrEqualTo: 'buku/')
            .where('slug', isLessThan: 'buku/\uf8ff')
            .orderBy('slug');
      } else {
        // Fetch genres under specific category
        query = query
            .where('slug', isGreaterThanOrEqualTo: widget.selectedCategorySlug)
            .where('slug', isLessThan: '${widget.selectedCategorySlug}\uf8ff')
            .orderBy('slug');
      }

      final gSnap = await query.get();
      _categoryGenres = gSnap.docs.map((d) => d.data()).toList();
      print(
        'DEBUG: Loaded ${_categoryGenres.length} genres for slug: ${widget.selectedCategorySlug}',
      );
      for (var g in _categoryGenres) {
        print('  - Genre: id=${g.id}, name=${g.name}, slug=${g.slug}');
      }

      // 2) Load page pertama
      _items.clear();
      _lastDoc = null;
      _hasMore = true;
      await _loadNextPage();
    } catch (e) {
      print('ERROR in _bootstrap: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading genres: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadNextPage() async {
    if (!_hasMore) return;
    if (_loadingMore) return;
    setState(() => _loadingMore = true);

    try {
      // Strategy: Fetch all books and filter client-side to avoid complex Firestore indexes
      Query<BookModel> q = BookRef.col(_db);

      // Build list of genre IDs to filter
      List<String> genreIdsToFilter = [];

      if ((_activeGenreId ?? '').isNotEmpty) {
        // Filter by specific genre
        genreIdsToFilter = [_activeGenreId!];
        print('DEBUG: Filtering by genre_id: $_activeGenreId');
      } else {
        // Get all genre IDs from current category
        genreIdsToFilter = _categoryGenres.map((g) => g.id).toList();
        print('DEBUG: Category genres IDs: $genreIdsToFilter');
      }

      if (genreIdsToFilter.isEmpty) {
        print('DEBUG: No genres found for category. Stopping pagination.');
        _hasMore = false;
        return;
      }

      // Query: Get books (orderBy title, limit per page)
      // We'll filter by genre_id client-side to avoid needing composite indexes
      Query<BookModel> baseQuery = q.orderBy('title').limit(_pageSize * 3);

      if (_lastDoc != null) {
        baseQuery = baseQuery.startAfterDocument(_lastDoc!);
      }

      final snap = await baseQuery.get();

      if (snap.docs.isEmpty) {
        print('DEBUG: No more books available');
        _hasMore = false;
      } else {
        // Filter docs by genre_id on client side
        final allFetched = snap.docs.map((d) => d.data()).toList();

        // Client-side filter: only keep books with matching genre_id
        final filtered = allFetched
            .where((b) => genreIdsToFilter.contains(b.genreId))
            .toList();

        print(
          'DEBUG: Fetched ${allFetched.length} books, ${filtered.length} after genre filter',
        );

        if (filtered.isEmpty) {
          // No books found for this genre in this batch
          print('DEBUG: No books matching genres in this batch');
          _lastDoc = snap.docs.last;
          // Continue to next batch
        } else {
          _lastDoc = snap.docs.last;

          // Apply search filter
          final searchFiltered = _applySearch(filtered);
          print('DEBUG: Books after search filter: ${searchFiltered.length}');

          _items.addAll(searchFiltered);
        }

        // Check if we should continue pagination
        if (snap.docs.length < (_pageSize * 3)) {
          _hasMore = false;
        }
      }
    } catch (e) {
      print('ERROR in _loadNextPage: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading books: $e')));
      }
      _hasMore = false;
    } finally {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  List<BookModel> _getFilteredItems() {
    // Filter by search query
    if (_searchQuery.isEmpty) return _items;
    return _items.where((b) {
      final t = b.title.toLowerCase();
      final a = b.author.toLowerCase();
      return t.contains(_searchQuery) || a.contains(_searchQuery);
    }).toList();
  }

  List<BookModel> _applySearch(List<BookModel> list) {
    if (_searchQuery.isEmpty) return list;
    return list.where((b) {
      final t = b.title.toLowerCase();
      final a = b.author.toLowerCase();
      return t.contains(_searchQuery) || a.contains(_searchQuery);
    }).toList();
  }

  void _onScroll() {
    if (!_scroll.hasClients || _loadingMore || !_hasMore) return;
    final threshold =
        _scroll.position.maxScrollExtent - 400; // 400px sebelum akhir
    if (_scroll.position.pixels >= threshold) {
      _loadNextPage();
    }
  }

  Future<void> _onRefresh() async {
    setState(() {
      _items.clear();
      _lastDoc = null;
      _hasMore = true;
    });
    await _loadNextPage();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Color>(
      valueListenable: backgroundColorNotifier,
      builder: (_, bg, __) {
        final isDark = bg == const Color(0xFF1A1A1A);
        return Scaffold(
          backgroundColor: bg,
          appBar: AppBar(
            backgroundColor: isDark ? Colors.black : Colors.white,
            elevation: 0.5,
            titleSpacing: 0,
            title: Row(
              children: [
                const SizedBox(width: 16),
                Text(
                  _activeGenreId?.isNotEmpty == true
                      ? 'Semua Buku (Genre)'
                      : (widget.selectedCategorySlug == 'buku/semua'
                            ? 'Semua Buku'
                            : (widget.selectedCategorySlug == 'buku/komik'
                                  ? 'Semua Light Novel'
                                  : 'Semua Novel')),
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            actions: [
              SizedBox(
                width: 260,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 12,
                  ),
                  child: TextField(
                    controller: _searchCtl,
                    onChanged: (v) {
                      setState(() => _searchQuery = v.trim().toLowerCase());
                      print('DEBUG: Search query updated to: "$_searchQuery"');
                    },
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Cari judul/penulis...',
                      hintStyle: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Color(0xFFD4AF37),
                      ),
                      filled: true,
                      fillColor: isDark
                          ? const Color(0xFF2A2A2A)
                          : const Color(0xFFF5F5F5),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 0,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: _loading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _onRefresh,
                  child: CustomScrollView(
                    controller: _scroll,
                    slivers: [
                      // Info bar kategori + dropdown genre
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: _CategoryGenreBar(
                            isDark: isDark,
                            categorySlug: widget.selectedCategorySlug,
                            categoryGenres: _categoryGenres,
                            activeGenreId: _activeGenreId,
                            onGenreChanged: (newId) async {
                              setState(() {
                                _activeGenreId = newId;
                                _items.clear();
                                _lastDoc = null;
                                _hasMore = true;
                              });
                              await _loadNextPage();
                            },
                          ),
                        ),
                      ),

                      // Grid buku atau empty state
                      if (_items.isEmpty && !_loading && !_loadingMore)
                        SliverToBoxAdapter(
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 80),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.library_books,
                                    size: 80,
                                    color: isDark
                                        ? Colors.white30
                                        : Colors.black26,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Belum ada buku',
                                    style: TextStyle(
                                      color: isDark
                                          ? Colors.white60
                                          : Colors.black54,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Silakan cek kembali nanti',
                                    style: TextStyle(
                                      color: isDark
                                          ? Colors.white38
                                          : Colors.black38,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      else
                        SliverPadding(
                          padding: const EdgeInsets.all(16),
                          sliver: SliverGrid(
                            delegate: SliverChildBuilderDelegate((context, i) {
                              final filtered = _getFilteredItems();
                              if (i >= filtered.length)
                                return const SizedBox.shrink();
                              final b = filtered[i];
                              final imageUrl = coverProxy(
                                b.imageUrl,
                                w: 480,
                                h: 720,
                              );
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const BookDetailPage(),
                                    ),
                                  );
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: isDark
                                        ? const Color(0xFF1E1E1E)
                                        : Colors.white,
                                    border: Border.all(
                                      color: const Color(
                                        0xFFD4AF37,
                                      ).withAlpha((0.3 * 255).round()),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: ClipRRect(
                                          borderRadius:
                                              const BorderRadius.vertical(
                                                top: Radius.circular(12),
                                              ),
                                          child: imageUrl.isEmpty
                                              ? Container(
                                                  color: Colors.grey[900],
                                                  child: const Center(
                                                    child: Icon(
                                                      Icons.bookmark,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                )
                                              : Image.network(
                                                  imageUrl,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (_, __, ___) =>
                                                      Container(
                                                        color: Colors.grey[900],
                                                        child: const Center(
                                                          child: Icon(
                                                            Icons.bookmark,
                                                            color: Colors.grey,
                                                          ),
                                                        ),
                                                      ),
                                                  loadingBuilder:
                                                      (
                                                        context,
                                                        child,
                                                        loadingProgress,
                                                      ) {
                                                        if (loadingProgress ==
                                                            null) {
                                                          return child;
                                                        }
                                                        return Container(
                                                          color:
                                                              Colors.grey[850],
                                                          child: const Center(
                                                            child: Icon(
                                                              Icons.image,
                                                              color:
                                                                  Colors.grey,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              b.title,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: isDark
                                                    ? Colors.white
                                                    : Colors.black,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              b.author,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color: isDark
                                                    ? Colors.grey[400]
                                                    : Colors.grey[600],
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }, childCount: _getFilteredItems().length),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 5,
                                  mainAxisSpacing: 16,
                                  crossAxisSpacing: 16,
                                  childAspectRatio: 0.62,
                                ),
                          ),
                        ),

                      // Loading more & footer
                      if (_items.isNotEmpty || _loadingMore)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            child: Column(
                              children: [
                                if (_loadingMore)
                                  const CircularProgressIndicator(),
                                if (!_hasMore && _items.isNotEmpty)
                                  Text(
                                    'Sudah semua 🎉',
                                    style: TextStyle(
                                      color: isDark
                                          ? Colors.white60
                                          : Colors.black54,
                                    ),
                                  ),
                                const SizedBox(height: 16),
                              ],
                            ),
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

// ================== Widgets Kecil ==================

class _CategoryGenreBar extends StatelessWidget {
  final bool isDark;
  final String categorySlug;
  final List<GenreModel> categoryGenres;
  final String? activeGenreId;
  final ValueChanged<String?> onGenreChanged;

  const _CategoryGenreBar({
    required this.isDark,
    required this.categorySlug,
    required this.categoryGenres,
    required this.activeGenreId,
    required this.onGenreChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isKomik = categorySlug == 'buku/komik';
    return Row(
      children: [
        _ChipTag(
          label: categorySlug == 'buku/semua'
              ? 'Semua'
              : (isKomik ? 'Light Novel' : 'Novel'),
          isDark: isDark,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 42,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String?>(
                value: activeGenreId ?? '',
                isExpanded: true,
                dropdownColor: isDark ? const Color(0xFF2A2A2A) : Colors.white,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontSize: 14,
                ),
                items: [
                  DropdownMenuItem(
                    value: '',
                    child: Text(
                      'Semua Genre',
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                  ...categoryGenres.map(
                    (g) => DropdownMenuItem(
                      value: g.id,
                      child: Text(
                        g.name,
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
                onChanged: (v) => onGenreChanged((v ?? '').isEmpty ? null : v),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ChipTag extends StatelessWidget {
  final String label;
  final bool isDark;
  const _ChipTag({required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFD4AF37), Color(0xFFFFD700)],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(50),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// _BookTile removed - grid items are inline for better search filtering support
