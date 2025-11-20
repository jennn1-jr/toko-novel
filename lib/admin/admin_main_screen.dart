import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tokonovel/admin/dashboard/admin_dashboard_screen.dart';
import 'package:tokonovel/admin/manage_novels/manage_novels_screen.dart';
import 'package:tokonovel/admin/manage_orders/manage_orders_screen.dart';
import 'package:tokonovel/controllers/admin_menu_controller.dart';
import 'components/side_menu.dart';
import 'responsive.dart';

class AdminMainScreen extends StatelessWidget {
  const AdminMainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: context.read<AdminMenuController>().scaffoldKey,
      drawer: const SideMenu(),
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // We want this side menu only for large screen
            if (Responsive.isDesktop(context))
              const Expanded(
                // default flex = 1
                // and it takes 1/6 part of the screen
                child: SideMenu(),
              ),
            const Expanded(
              // It takes 5/6 part of the screen
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
    // Watch for changes in the menu controller
    final selectedMenuItem = context.watch<AdminMenuController>().selectedItem;

    // Return the screen based on the selected item
    switch (selectedMenuItem) {
      case AdminMenuItem.dashboard:
        return const AdminDashboardScreen();
      case AdminMenuItem.manageNovels:
        return const ManageNovelsScreen();
      case AdminMenuItem.manageOrders:
        return const ManageOrdersScreen();
      case AdminMenuItem.profile:
        return const Center(child: Text("Halaman Profil Admin")); // Placeholder
      default:
        return const AdminDashboardScreen();
    }
  }
}