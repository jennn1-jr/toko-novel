import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
// 1. TAMBAHKAN IMPOR THEME ANDA
// Sesuaikan path-nya jika perlu, misalnya 'package:tokonovel/theme.dart'
import 'theme.dart';

void main() {
  runApp(const MyApp());
}

// MyApp ini mungkin hanya untuk tes, 
// pastikan main.dart utama Anda yang dipakai
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Di aplikasi aslinya, Anda mungkin ingin membungkus MaterialApp ini
    // dengan ValueListenableBuilder juga untuk mengganti tema (dark/light)
    return MaterialApp(
      title: 'Tentang Kami',
      theme: AppThemes.darkTheme, // Ambil dari theme.dart
      home: const AboutUsPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class TeamMember {
  final String name;
  final String role;
  final String imageUrl;
  final String instagram;
  final String github;
  final String description;

  TeamMember({
    required this.name,
    required this.role,
    required this.imageUrl,
    required this.instagram,
    required this.github,
    this.description = '',
  });
}

class AboutUsPage extends StatefulWidget {
  const AboutUsPage({Key? key}) : super(key: key);

  @override
  State<AboutUsPage> createState() => _AboutUsPageState();
}

class _AboutUsPageState extends State<AboutUsPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<TeamMember> teamMembers = [
      TeamMember(
        name: 'Jenar Aditiya Bagaskara',
        role: 'Team Leader',
        imageUrl: 'https://avatars.githubusercontent.com/u/200600912?v=4',
        instagram: '@jenar_aditiya',
        github: 'https://github.com/jennn1-jr',
        description: 'Memimpin tim dengan visi yang jelas',
      ),
      TeamMember(
        name: 'Ello Adrian Hariadi',
        role: 'Backend Developer',
        imageUrl: 'https://avatars.githubusercontent.com/u/144525698?v=4',
        instagram: '@elloadrian',
        github: 'https://github.com/Driannnn',
        description: 'Fullstack Developer Pemula',
      ),
      TeamMember(
        name: 'Izora Elverda',
        role: 'Frontend Developer',
        imageUrl: 'https://avatars.githubusercontent.com/u/208224160?v=4',
        instagram: '@elverdaputri',
        github: 'https://github.com/Elverda',
        description: 'Spesialis UI/UX dan Frontend',
      ),
      TeamMember(
        name: 'Muhammad Dwi Saputri',
        role: 'Mobile Developer',
        imageUrl: 'https://avatars.githubusercontent.com/u/200634165?v=4',
        instagram: '@aartup__',
        github: 'https://github.com/POKSI77',
        description: 'NEWBIE Flutter Developer',
      ),
      TeamMember(
        name: 'Muhammad Dzacky M.Y',
        role: 'Quality Assurance',
        imageUrl: 'https://avatars.githubusercontent.com/u/207881192?v=4',
        instagram: '@mflofeee',
        github: 'https://github.com/LofeYN',
        description: 'Memastikan kualitas produk',
      ),
    ];

    // 2. GUNAKAN VALUELISTENABLEBUILDER
    // Ini adalah langkah kunci untuk "mendengarkan" perubahan tema
    return ValueListenableBuilder<Color>(
      valueListenable: backgroundColorNotifier,
      builder: (context, backgroundColor, child) {
        // 3. TENTUKAN MODE SAAT INI
        // Kita gunakan warna dari theme.dart sebagai acuan mode gelap
        final isDarkMode = backgroundColor == const Color(0xFF1A1A1A);

        return Scaffold(
          // 4. GANTI WARNA STATIS MENJADI DINAMIS
          backgroundColor: isDarkMode ? const Color(0xFF0F0F0F) : Colors.white,
          body: CustomScrollView(
            slivers: [
              // App Bar dengan Gradient
              SliverAppBar(
                expandedHeight: 120,
                floating: false,
                pinned: true,
                elevation: 0,
                backgroundColor: Colors.transparent,
                flexibleSpace: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.amber.withOpacity(0.8),
                        Colors.orange.withOpacity(0.6),
                        // 4. GANTI WARNA STATIS MENJADI DINAMIS
                        isDarkMode ? const Color(0xFF0F0F0F) : Colors.white,
                      ],
                    ),
                  ),
                  child: FlexibleSpaceBar(
                    centerTitle: true,
                    title: const Text(
                      'TENTANG KAMI',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                        shadows: [
                          Shadow(
                            color: Colors.black45,
                            offset: Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                leading: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_back,
                        color: Colors.white, size: 20),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),

              // Content
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),

                        // Hero Section
                        // 5. KIRIM STATUS isDarkMode KE WIDGET BAWAHAN
                        _buildHeroSection(isDarkMode),

                        const SizedBox(height: 40),

                        // Stats Section
                        // 5. KIRIM STATUS isDarkMode KE WIDGET BAWAHAN
                        _buildStatsSection(isDarkMode),

                        const SizedBox(height: 60),

                        // Team Section Header
                        // 5. KIRIM STATUS isDarkMode KE WIDGET BAWAHAN
                        _buildSectionHeader('TIM KAMI', Icons.group, isDarkMode),

                        const SizedBox(height: 30),

                        // Team Grid
                        LayoutBuilder(
                          builder: (context, constraints) {
                            return Wrap(
                              spacing: 20,
                              runSpacing: 30,
                              alignment: WrapAlignment.center,
                              children: teamMembers.asMap().entries.map((entry) {
                                final index = entry.key;
                                final member = entry.value;
                                return TweenAnimationBuilder<double>(
                                  duration:
                                  Duration(milliseconds: 500 + (index * 100)),
                                  tween: Tween(begin: 0.0, end: 1.0),
                                  curve: Curves.easeOutBack,
                                  builder: (context, value, child) {
                                    return Transform.scale(
                                      scale: value,
                                      child: Opacity(
                                        opacity: value,
                                        child: SizedBox(
                                          width: constraints.maxWidth > 800
                                              ? (constraints.maxWidth - 60) / 3
                                              : constraints.maxWidth > 500
                                              ? (constraints.maxWidth - 40) / 2
                                              : constraints.maxWidth,
                                          // 5. KIRIM STATUS isDarkMode KE WIDGET BAWAHAN
                                          child: TeamMemberCard(
                                            member: member,
                                            isDarkMode: isDarkMode,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              }).toList(),
                            );
                          },
                        ),

                        const SizedBox(height: 60),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 6. TAMBAHKAN PARAMETER isDarkMode
  Widget _buildHeroSection(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.amber.withOpacity(0.1),
            Colors.orange.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.amber.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.amber, Colors.orange],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.amber.withOpacity(0.5),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              Icons.rocket_launch,
              size: 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),

          // Title
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Colors.amber, Colors.orange],
            ).createShader(bounds),
            child: const Text(
              'INOVASI & KOLABORASI',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white, // Teks ini tetap putih karena di-mask
                letterSpacing: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),

          // Description
          Text(
            'Kami adalah kelompok mahasiswa yang berdedikasi untuk menciptakan solusi inovatif dalam dunia digital. Dengan latar belakang yang beragam dan semangat kolaborasi yang kuat, kami berkomitmen untuk menghadirkan produk berkualitas tinggi yang dapat memberikan dampak positif bagi masyarakat.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              // 4. GANTI WARNA STATIS MENJADI DINAMIS
              color: isDarkMode ? Colors.grey[400] : Colors.black54,
              height: 1.8,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  // 6. TAMBAHKAN PARAMETER isDarkMode
  Widget _buildStatsSection(bool isDarkMode) {
    // Menggunakan Wrap agar responsif di layar kecil
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 20,
      runSpacing: 20,
      children: [
        // 5. KIRIM STATUS isDarkMode KE WIDGET BAWAHAN
        _buildStatCard('5+', 'Anggota Tim', Icons.people, isDarkMode),
        _buildStatCard('10+', 'Proyek', Icons.work, isDarkMode),
        _buildStatCard('100%', 'Dedikasi', Icons.favorite, isDarkMode),
      ],
    );
  }

  // 6. TAMBAHKAN PARAMETER isDarkMode
  Widget _buildStatCard(
      String number, String label, IconData icon, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        // 4. GANTI WARNA STATIS MENJADI DINAMIS
        color: isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.amber.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            // 4. GANTI WARNA STATIS MENJADI DINAMIS
            color: isDarkMode
                ? Colors.amber.withOpacity(0.1)
                : Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.amber, size: 28),
          const SizedBox(height: 8),
          Text(
            number,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              // 4. GANTI WARNA STATIS MENJADI DINAMIS
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              // 4. GANTI WARNA STATIS MENJADI DINAMIS
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  // 6. TAMBAHKAN PARAMETER isDarkMode
  Widget _buildSectionHeader(String title, IconData icon, bool isDarkMode) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.amber, Colors.orange],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            // 4. GANTI WARNA STATIS MENJADI DINAMIS
            color: isDarkMode ? Colors.white : Colors.black87,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }
}

// ==================================================================
// KODE YANG DIPERBARUI (IKON + FUNGSI KLIK)
// ==================================================================

class TeamMemberCard extends StatefulWidget {
  final TeamMember member;
  // 7. TAMBAHKAN isDarkMode DI SINI
  final bool isDarkMode;

  const TeamMemberCard({
    Key? key,
    required this.member,
    required this.isDarkMode, // 8. TAMBAHKAN DI CONSTRUCTOR
  }) : super(key: key);

  @override
  State<TeamMemberCard> createState() => _TeamMemberCardState();
}

class _TeamMemberCardState extends State<TeamMemberCard> {
  bool _isHovered = false;

  // Fungsi untuk membuka URL
  Future<void> _launchSocialUrl(String url) async {
    String fullUrl = url;
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      fullUrl = 'https://$url';
    }

    final Uri uri = Uri.parse(fullUrl);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tidak bisa membuka link: $fullUrl')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        transform: Matrix4.identity()
          ..translate(0.0, _isHovered ? -10.0 : 0.0),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              // 9. GANTI WARNA STATIS MENJADI DINAMIS
              colors: _isHovered
                  ? [
                widget.isDarkMode
                    ? const Color(0xFF2A2A2A)
                    : Colors.grey[100]!,
                widget.isDarkMode
                    ? const Color(0xFF1F1F1F)
                    : Colors.grey[50]!,
              ]
                  : [
                widget.isDarkMode
                    ? const Color(0xFF1F1F1F)
                    : Colors.white,
                widget.isDarkMode
                    ? const Color(0xFF1A1A1A)
                    : Colors.white70,
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              // 9. GANTI WARNA STATIS MENJADI DINAMIS
              color: _isHovered
                  ? Colors.amber.withOpacity(0.5)
                  : widget.isDarkMode
                  ? Colors.grey.withOpacity(0.2)
                  : Colors.grey.withOpacity(0.4),
              width: _isHovered ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                // 9. GANTI WARNA STATIS MENJADI DINAMIS
                color: _isHovered
                    ? Colors.amber.withOpacity(0.2)
                    : widget.isDarkMode
                    ? Colors.black.withOpacity(0.3)
                    : Colors.grey.withOpacity(0.2),
                blurRadius: _isHovered ? 20 : 10,
                offset: Offset(0, _isHovered ? 8 : 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Profile Image with Glow Effect
              Stack(
                alignment: Alignment.center,
                children: [
                  if (_isHovered)
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.amber.withOpacity(0.6),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                    ),
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Colors.amber, Colors.orange],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.amber.withOpacity(0.3),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(3),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        // 9. GANTI WARNA STATIS MENJADI DINAMIS
                        color: widget.isDarkMode
                            ? Colors.grey[800]
                            : Colors.grey[200],
                      ),
                      child: ClipOval(
                        child: Image.network(
                          widget.member.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              // 9. GANTI WARNA STATIS MENJADI DINAMIS
                              color: widget.isDarkMode
                                  ? Colors.grey[800]
                                  : Colors.grey[200],
                              child: Icon(
                                Icons.person,
                                size: 45,
                                // 9. GANTI WARNA STATIS MENJADI DINAMIS
                                color: widget.isDarkMode
                                    ? Colors.grey
                                    : Colors.grey[600],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  // Badge untuk Leader
                  if (widget.member.role.contains('Leader'))
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.amber, Colors.orange],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.amber.withOpacity(0.5),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.star,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),

              // Name with Gradient
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  // 9. GANTI WARNA STATIS MENJADI DINAMIS
                  colors: _isHovered
                      ? [Colors.amber, Colors.orange]
                      : [
                    widget.isDarkMode ? Colors.white : Colors.black87,
                    widget.isDarkMode ? Colors.white : Colors.black87
                  ],
                ).createShader(bounds),
                child: Text(
                  widget.member.name,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // Teks ini tetap putih karena di-mask
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 8),

              // Role Badge
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.amber.withOpacity(0.2),
                      Colors.orange.withOpacity(0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.amber.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  widget.member.role,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.amber,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              if (widget.member.description.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  widget.member.description,
                  style: TextStyle(
                    fontSize: 12,
                    // 9. GANTI WARNA STATIS MENJADI DINAMIS
                    color:
                    widget.isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              const SizedBox(height: 20),

              // Social Icons with Animation
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSocialButton(
                    icon: FontAwesomeIcons.instagram,
                    color: Colors.pink,
                    onTap: () {
                      String username =
                      widget.member.instagram.replaceAll('@', '');
                      _launchSocialUrl('instagram.com/$username');
                    },
                  ),
                  const SizedBox(width: 16),
                  _buildSocialButton(
                    icon: FontAwesomeIcons.github,
                    color: Colors.purple,
                    onTap: () {
                      String githubUrl = widget.member.github;
                      if (githubUrl.startsWith('https://') ||
                          githubUrl.startsWith('http://')) {
                        _launchSocialUrl(githubUrl);
                      } else {
                        _launchSocialUrl('github.com/$githubUrl');
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.2),
              color.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          size: 18,
          color: color,
        ),
      ),
    );
  }
}

