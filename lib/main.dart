import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'controllers/admin_dashboard_controller.dart';
import 'controllers/admin_menu_controller.dart';
import 'firebase_options.dart';
import 'login_register.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => AdminMenuController(),
        ),
        ChangeNotifierProvider(
          create: (context) => AdminDashboardController(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NovelKu',
      theme: ThemeData(primarySwatch: Colors.brown, fontFamily: 'Poppins'),
      debugShowCheckedModeBanner: false,
      home: const LoginPage(),
    );
  }
}
