import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:tokonovel/login_register.dart'; // Import Login Page
import '../../controllers/admin_menu_controller.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.menu_book_rounded, size: 40),
                SizedBox(height: 8),
                Text("Toko Novel Admin"),
              ],
            ),
          ),
          DrawerListTile(
            title: "Dashboard",
            icon: Icons.dashboard_rounded,
            press: () {
              context.read<AdminMenuController>().selectMenu(AdminMenuItem.dashboard);
            },
            isSelected: context.watch<AdminMenuController>().selectedItem == AdminMenuItem.dashboard,
          ),
          DrawerListTile(
            title: "Kelola Novel",
            icon: Icons.book_rounded,
            press: () {
              context.read<AdminMenuController>().selectMenu(AdminMenuItem.manageNovels);
            },
            isSelected: context.watch<AdminMenuController>().selectedItem == AdminMenuItem.manageNovels,
          ),
          DrawerListTile(
            title: "Kelola Pesanan",
            icon: Icons.receipt_long_rounded,
            press: () {
              context.read<AdminMenuController>().selectMenu(AdminMenuItem.manageOrders);
            },
            isSelected: context.watch<AdminMenuController>().selectedItem == AdminMenuItem.manageOrders,
          ),
          // Tambahkan item menu lain di sini
          DrawerListTile(
            title: "Logout",
            icon: Icons.logout,
            press: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (Route<dynamic> route) => false,
                );
              }
            },
            isSelected: false, // Logout should not be "selected"
          ),
        ],
      ),
    );
  }
}

class DrawerListTile extends StatelessWidget {
  const DrawerListTile({
    Key? key,
    required this.title,
    required this.icon,
    required this.press,
    required this.isSelected,
  }) : super(key: key);

  final String title;
  final IconData icon;
  final VoidCallback press;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: press,
      horizontalTitleGap: 0.0,
      selected: isSelected,
      selectedTileColor: Colors.brown.withOpacity(0.2),
      leading: Icon(
        icon,
        color: isSelected ? Colors.brown : Colors.black54,
        size: 18,
      ),
      title: Text(
        title,
        style: TextStyle(color: isSelected ? Colors.brown : Colors.black54),
      ),
    );
  }
}
