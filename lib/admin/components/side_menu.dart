import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tokonovel/admin/admin_theme.dart';
import 'package:tokonovel/controllers/admin_menu_controller.dart';
import 'package:tokonovel/login_register.dart'; // Import halaman login

class SideMenu extends StatelessWidget {
  const SideMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: primaryColor, // Menggunakan warna latar belakang utama dari tema
        child: ListView(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.white10)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.admin_panel_settings, color: accentColor, size: 64),
                  const SizedBox(height: 10),
                  Text(
                    "Admin Panel",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
                  ),
                ],
              ),
            ),
            DrawerListTile(
              title: "Dashboard",
              icon: Icons.dashboard,
              press: () => context.read<AdminMenuController>().selectMenu(AdminMenuItem.dashboard),
              item: AdminMenuItem.dashboard,
            ),
            DrawerListTile(
              title: "Kelola Novel",
              icon: Icons.book,
              press: () => context.read<AdminMenuController>().selectMenu(AdminMenuItem.manageNovels),
              item: AdminMenuItem.manageNovels,
            ),
            DrawerListTile(
              title: "Kelola Pesanan",
              icon: Icons.shopping_cart,
              press: () => context.read<AdminMenuController>().selectMenu(AdminMenuItem.manageOrders),
              item: AdminMenuItem.manageOrders,
            ),
            const Divider(color: Colors.white10, thickness: 1, indent: 20, endIndent: 20),
            ListTile(
              onTap: () {
                // Tambahkan logika logout di sini jika perlu
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                  (Route<dynamic> route) => false,
                );
              },
              leading: const Icon(Icons.logout, color: textColorMuted),
              title: const Text("Logout", style: TextStyle(color: textColorMuted)),
            ),
          ],
        ),
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
    required this.item,
  }) : super(key: key);

  final String title;
  final IconData icon;
  final VoidCallback press;
  final AdminMenuItem item;

  @override
  Widget build(BuildContext context) {
    final selectedItem = context.watch<AdminMenuController>().selectedItem;
    final isSelected = selectedItem == item;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? accentColor.withOpacity(0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(defaultBorderRadius),
      ),
      child: ListTile(
        onTap: press,
        leading: Icon(
          icon,
          color: isSelected ? accentColor : textColorMuted,
          size: 20,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? accentColor : textColorMuted,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        // Efek visual saat terpilih
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(defaultBorderRadius),
        ),
        trailing: isSelected
            ? Container(
                width: 5,
                height: 25,
                decoration: const BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                  ),
                ),
              )
            : null,
      ),
    );
  }
}
