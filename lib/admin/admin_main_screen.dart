import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tokonovel/admin/admin_theme.dart';
import 'package:tokonovel/admin/dashboard/admin_dashboard_screen.dart';
import 'package:tokonovel/admin/manage_novels/manage_novels_screen.dart';
import 'package:tokonovel/admin/manage_orders/manage_orders_screen.dart';
import 'package:tokonovel/controllers/admin_menu_controller.dart';
import 'components/side_menu.dart';
import 'responsive.dart';
import 'components/admin_header.dart'; // Import header baru

class AdminMainScreen extends StatelessWidget {
  const AdminMainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Terapkan tema kustom di sini
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: lightThemeData, // Tema terang
      darkTheme: darkThemeData, // Tema gelap
      themeMode: themeNotifier.value, // Gunakan notifier untuk mode tema
      home: const AdminScaffold(),
    );
  }
}

class AdminScaffold extends StatelessWidget {
  const AdminScaffold({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: context.read<AdminMenuController>().scaffoldKey,
      drawer: const SideMenu(),
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (Responsive.isDesktop(context))
              const Expanded(
                child: SideMenu(),
              ),
            const Expanded(
              flex: 5,
              child: AdminContent(),
            ),
          ],
        ),
      ),
    );
  }
}

class AdminContent extends StatelessWidget {
  const AdminContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final selectedMenuItem = context.watch<AdminMenuController>().selectedItem;
    String title = "Dashboard"; // Judul default
    Widget content;

    switch (selectedMenuItem) {
      case AdminMenuItem.dashboard:
        title = "Dashboard";
        content = const AdminDashboardScreen();
        break;
      case AdminMenuItem.manageNovels:
        title = "Kelola Novel";
        content = const ManageNovelsScreen();
        break;
      case AdminMenuItem.manageOrders:
        title = "Kelola Pesanan";
        content = const ManageOrdersScreen();
        break;
      case AdminMenuItem.profile:
        title = "Profil Admin";
        content = const Center(child: Text("Halaman Profil Admin", style: TextStyle(color: textColor)));
        break;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(defaultPadding),
      child: Column(
        children: [
          AdminHeader(title: title),
          const SizedBox(height: defaultPadding),
          content,
        ],
      ),
    );
  }
}
