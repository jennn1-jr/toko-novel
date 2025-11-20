import 'package:flutter/material.dart';

enum AdminMenuItem {
  dashboard,
  manageNovels,
  manageOrders,
  profile,
}

class AdminMenuController extends ChangeNotifier {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  GlobalKey<ScaffoldState> get scaffoldKey => _scaffoldKey;

  AdminMenuItem _selectedItem = AdminMenuItem.dashboard;

  AdminMenuItem get selectedItem => _selectedItem;

  void selectMenu(AdminMenuItem item) {
    if (_selectedItem != item) {
      _selectedItem = item;
      notifyListeners();
    }
  }

  void controlMenu() {
    if (!_scaffoldKey.currentState!.isDrawerOpen) {
      _scaffoldKey.currentState!.openDrawer();
    }
  }
}
