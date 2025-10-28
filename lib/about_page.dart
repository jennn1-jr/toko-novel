import 'package:flutter/material.dart';

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
        scaffoldBackgroundColor: const Color(0xFF1A1A1A),
        primaryColor: Colors.amber,
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

  TeamMember({
    required this.name,
    required this.role,
    required this.imageUrl,
    required this.instagram,
    required this.github,
  });
}

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<TeamMember> teamMembers = [
      TeamMember(
        name: 'Arifin Muftie',
        role: 'Leader',
        imageUrl: 'https://i.pravatar.cc/150?img=1',
        instagram: '@arifmuftie',
        github: 'arifmuftie',
      ),
      TeamMember(
        name: 'Dimas Yoga',
        role: 'Anggota',
        imageUrl: 'https://i.pravatar.cc/150?img=2',
        instagram: '@dimsyog',
        github: 'dimsyog',
      ),
      TeamMember(
        name: 'Yoga Pratama',
        role: 'Anggota',
        imageUrl: 'https://i.pravatar.cc/150?img=3',
        instagram: '@yogaprtma',
        github: 'yogaprtma',
      ),
      TeamMember(
        name: 'Farhan Kurnia',
        role: 'Anggota',
        imageUrl: 'https://i.pravatar.cc/150?img=4',
        instagram: '@farhankrn',
        github: 'farhankrn',
      ),
      TeamMember(
        name: 'Dr. Nanik Suciati',
        role: 'Dosen Pembimbing',
        imageUrl: 'https://i.pravatar.cc/150?img=5',
        instagram: '@naniksuciati',
        github: 'naniksuciati',
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'TENTANG KAMI',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              const Text(
                'TENTANG KAMI',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 24),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Kami adalah kelompok mahasiswa yang berdedikasi untuk menciptakan solusi inovatif dalam dunia digital. Dengan latar belakang yang beragam dan semangat kolaborasi yang kuat, kami berkomitmen untuk menghadirkan produk berkualitas tinggi yang dapat memberikan dampak positif bagi masyarakat.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    height: 1.6,
                  ),
                ),
              ),
              const SizedBox(height: 50),
              
              // Team Grid
              LayoutBuilder(
                builder: (context, constraints) {
                  return Wrap(
                    spacing: 20,
                    runSpacing: 30,
                    alignment: WrapAlignment.center,
                    children: teamMembers.map((member) {
                      return SizedBox(
                        width: constraints.maxWidth > 800 
                          ? (constraints.maxWidth - 60) / 3
                          : constraints.maxWidth > 500
                            ? (constraints.maxWidth - 40) / 2
                            : constraints.maxWidth - 40,
                        child: TeamMemberCard(member: member),
                      );
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}

class TeamMemberCard extends StatelessWidget {
  final TeamMember member;

  const TeamMemberCard({Key? key, required this.member}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Profile Image
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.amber,
                width: 2,
              ),
            ),
            child: ClipOval(
              child: Image.network(
                member.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[800],
                    child: const Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.grey,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Name
          Text(
            member.name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          
          // Role
          Text(
            member.role,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[400],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          
          // Social Icons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    border: Border.all(
                      color: Colors.grey.withOpacity(0.3),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    size: 16,
                    color: Colors.grey,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              InkWell(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    border: Border.all(
                      color: Colors.grey.withOpacity(0.3),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.code,
                    size: 16,
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
