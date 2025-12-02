import 'package:flutter/material.dart';
import 'package:tokonovel/admin/admin_theme.dart';
import 'package:tokonovel/admin/responsive.dart';
import 'package:provider/provider.dart';
import 'package:tokonovel/controllers/admin_menu_controller.dart';

class AdminHeader extends StatelessWidget {
  final String title;

  const AdminHeader({
    Key? key,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: BorderRadius.circular(defaultBorderRadius),
      ),
      child: Row(
        children: [
          if (!Responsive.isDesktop(context))
            IconButton(
              icon: const Icon(Icons.menu, color: textColorMuted),
              onPressed: context.read<AdminMenuController>().controlMenu,
            ),
          if (!Responsive.isMobile(context))
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          if (!Responsive.isMobile(context))
            Spacer(flex: Responsive.isDesktop(context) ? 2 : 1),

          // Profile Card
          const ProfileCard()
        ],
      ),
    );
  }
}

class ProfileCard extends StatelessWidget {
  const ProfileCard({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: defaultPadding),
      padding: const EdgeInsets.symmetric(
        horizontal: defaultPadding,
        vertical: defaultPadding / 2,
      ),
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        border: Border.all(color: Colors.white10),
      ),
    );
  }
}