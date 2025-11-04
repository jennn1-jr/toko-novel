import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart'; 

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tentang Kami',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F0F0F),
        primaryColor: Colors.amber,
        fontFamily: 'Poppins',
      ),
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
        imageUrl: 'https://i.pravatar.cc/150?img=1',
        instagram: '@jenar_aditiya',
        github: 'https://github.com/jennn1-jr',
        description: 'Memimpin tim dengan visi yang jelas',
      ),
      TeamMember(
        name: 'Ello Adrian Hariyadi',
        role: 'Frontend Developer',
        imageUrl: 'https://i.pravatar.cc/150?img=2',
        instagram: '@dimsyog',
        github: 'dimsyog',
        description: 'Fullstack',
      ),
      TeamMember(
        name: 'Izora Elverda',
        role: 'Backend Developer',
        imageUrl: 'https://i.pravatar.cc/150?img=3',
        instagram: '@yogaprtma',
        github: 'yogaprtma',
        description: 'Spesialis UI/UX dan Frontend',
      ),
      TeamMember(
        name: 'Muhammad Dwi Saputri',
        role: 'Mobile Developer',
        imageUrl: 'https://i.pravatar.cc/150?img=4',
        instagram: '@farhankrn',
        github: 'farhankrn',
        description: 'KING AI',
      ),
      TeamMember(
        name: 'Muhammad Dzacky M.Y',
        role: 'Quality Assurance',
        imageUrl: 'https://i.pravatar.cc/150?img=5',
        instagram: '@naniksuciati',
        github: 'naniksuciati',
        description: 'Memastikan kualitas produk',
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
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
                    const Color(0xFF0F0F0F),
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
                child:
                    const Icon(Icons.arrow_back, color: Colors.white, size: 20),
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
                    _buildHeroSection(),

                    const SizedBox(height: 40),

                    // Stats Section
                    _buildStatsSection(),

                    const SizedBox(height: 60),

                    // Team Section Header
                    _buildSectionHeader('TIM KAMI', Icons.group),

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
                                      child: TeamMemberCard(member: member),
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
  }

  Widget _buildHeroSection() {
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
                color: Colors.white,
                letterSpacing: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),

          // Description
          const Text(
            'Kami adalah kelompok mahasiswa yang berdedikasi untuk menciptakan solusi inovatif dalam dunia digital. Dengan latar belakang yang beragam dan semangat kolaborasi yang kuat, kami berkomitmen untuk menghadirkan produk berkualitas tinggi yang dapat memberikan dampak positif bagi masyarakat.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey,
              height: 1.8,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatCard('5+', 'Anggota Tim', Icons.people),
        _buildStatCard('10+', 'Proyek', Icons.work),
        _buildStatCard('100%', 'Dedikasi', Icons.favorite),
      ],
    );
  }

  Widget _buildStatCard(String number, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.amber.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.1),
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
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
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
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
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

  const TeamMemberCard({Key? key, required this.member}) : super(key: key);

  @override
  State<TeamMemberCard> createState() => _TeamMemberCardState();
}

class _TeamMemberCardState extends State<TeamMemberCard> {
  bool _isHovered = false;

  // Fungsi untuk membuka URL
  Future<void> _launchSocialUrl(String url) async {
    // Kita tambahkan prefix https:// jika belum ada
    String fullUrl = url;
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      fullUrl = 'https://$url';
    }
    
    final Uri uri = Uri.parse(fullUrl);
    
    // Gunakan mode externalApplication agar membuka di browser/aplikasi
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      // Tampilkan pesan error jika gagal membuka link
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
              colors: _isHovered
                  ? [
                      const Color(0xFF2A2A2A),
                      const Color(0xFF1F1F1F),
                    ]
                  : [
                      const Color(0xFF1F1F1F),
                      const Color(0xFF1A1A1A),
                    ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _isHovered
                  ? Colors.amber.withOpacity(0.5)
                  : Colors.grey.withOpacity(0.2),
              width: _isHovered ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: _isHovered
                    ? Colors.amber.withOpacity(0.2)
                    : Colors.black.withOpacity(0.3),
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
                        color: Colors.grey[800],
                      ),
                      child: ClipOval(
                        child: Image.network(
                          widget.member.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[800],
                              child: const Icon(
                                Icons.person,
                                size: 45,
                                color: Colors.grey,
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
                  colors: _isHovered
                      ? [Colors.amber, Colors.orange]
                      : [Colors.white, Colors.white],
                ).createShader(bounds),
                child: Text(
                  widget.member.name,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
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
                    color: Colors.grey[400],
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
                      // Ambil username dari data member dan buat URL
                      String username = widget.member.instagram.replaceAll('@', '');
                      _launchSocialUrl('instagram.com/$username');
                    },
                  ),
                  const SizedBox(width: 16),
                  _buildSocialButton(
                    icon: FontAwesomeIcons.github,
                    color: Colors.purple,
                    onTap: () {
                      // Ambil username dari data member dan buat URL
                      String username = widget.member.github;
                      _launchSocialUrl('github.com/$username');
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
      onTap: onTap, // onTap sekarang memanggil fungsi _launchSocialUrl
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