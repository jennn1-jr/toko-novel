
import 'dart:ui';
import 'package:flutter/material.dart';

void main() {
  runApp(const NovelKuApp());
}

class NovelKuApp extends StatelessWidget {
  const NovelKuApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NovelKu',
      theme: ThemeData(
        fontFamily: 'Poppins',
      ),
      debugShowCheckedModeBanner: false,
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    // Placeholder for login logic
    setState(() {
      if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
        _errorMessage = "Username dan password harus diisi";
      } else {
        _errorMessage = null;
        // Navigate to home or show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login berhasil!')),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomRight,
                end: Alignment.topLeft,
                colors: [Color(0xFF000000), Color(0xFFc19759)],
              ),
            ),
          ),
          // This would be the place to add a particle effect widget if desired
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20.0),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 400),
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 50),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20.0),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // SVG Logo Placeholder
                        SizedBox(
                          width: 70,
                          child: SvgPicture.string(
                            '''<svg role="img" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg" style="width: 100%; height: auto; fill: #ffffff;"><title>BookStack</title><path d="M.3013 17.6146c-.1299-.3387-.5228-1.5119-.1337-2.4314l9.8273 5.6738a.329.329 0 0 0 .3299 0L24 12.9616v2.3542l-13.8401 7.9906-9.8586-5.6918zM.1911 8.9628c-.2882.8769.0149 2.0581.1236 2.4261l9.8452 5.6841L24 9.0823V6.7275L10.3248 14.623a.329.329 0 0 1-.3299 0L.1911 8.9628zm13.1698-1.9361c-.1819.1113-.4394.0015-.4852-.2064l-.2805-1.1336-2.1254-.1752a.33.33 0 0 1-.1378-.6145l5.5782-3.2207-1.7021-.9826L.6979 8.4935l9.462 5.463 13.5104-7.8004-4.401-2.5407-5.9084 3.4113zm-.1821-1.7286.2321.938 5.1984-3.0014-2.0395-1.1775-4.994 2.8834 1.3099.108a.3302.3302 0 0 1 .2931.2495zM24 9.845l-13.6752 7.8954a.329.329 0 0 1-.3299 0L.1678 12.0667c-.3891.919.003 2.0914.1332 2.4311l9.8589 5.692L24 12.1993V9.845z"/></svg>''',
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 15),
                        RichText(
                          textAlign: TextAlign.center,
                          text: const TextSpan(
                            style: TextStyle(
                              fontSize: 48,
                              color: Colors.white,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w400,
                            ),
                            children: [
                              TextSpan(text: 'NOVEL'),
                              TextSpan(
                                text: 'KU',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF2d1f0a),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),
                        _buildTextField(
                          controller: _usernameController,
                          hintText: '*Username',
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _passwordController,
                          hintText: '*Password',
                          obscureText: _obscurePassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility : Icons.visibility_off,
                              color: Colors.white70,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFc19759),
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100),
                              ),
                            ),
                            child: const Text(
                              'Log In',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 19.2,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Belum punya akun? ',
                              style: TextStyle(color: Colors.white, fontSize: 14.4),
                            ),
                            GestureDetector(
                              onTap: () {
                                // Navigate to Register Page
                              },
                              child: const Text(
                                'Daftar',
                                style: TextStyle(
                                  color: Color(0xFFf2e6d0),
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                  fontSize: 14.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (_errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(color: Colors.red, fontSize: 14),
                              textAlign: TextAlign.center,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Color(0xFFddd)),
        contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        filled: true,
        fillColor: Colors.white.withOpacity(0.25),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.5), width: 1),
        ),
        suffixIcon: suffixIcon,
      ),
    );
  }
}

// You might need to add the flutter_svg package to your pubspec.yaml
// for the SVG to render.
// dependencies:
//   flutter_svg: ^1.0.3

// Placeholder for SvgPicture.string to avoid errors if flutter_svg is not installed
class SvgPicture {
  static Widget string(String data, {Color? color, double? width, double? height}) {
    return SizedBox(
      width: width,
      height: height,
      child: Icon(Icons.book, color: color, size: 50), // Placeholder Icon
    );
  }
}

class RegisterPage extends StatelessWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Daftar")),
      body: const Center(
        child: Text("Halaman Pendaftaran"),
      ),
    );
  }
}
