import 'package:flutter/material.dart';
import 'package:tokonovel/models/order_model.dart';
import 'package:tokonovel/services/firestore_service.dart';

class ChartData {
  ChartData(this.x, this.y, [this.color]);
  final String x;
  final double y;
  final Color? color;
}

class AdminDashboardController extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<ChartData> _pieChartData = [];
  List<ChartData> get pieChartData => _pieChartData;

  int _totalOrders = 0;
  int get totalOrders => _totalOrders;

  int _packagingOrders = 0;
  int get packagingOrders => _packagingOrders;

  int _deliveryOrders = 0;
  int get deliveryOrders => _deliveryOrders;

  int _completedOrders = 0;
  int get completedOrders => _completedOrders;

  AdminDashboardController() {
    _fetchData();
  }

  void _fetchData() {
    _firestoreService.getAllOrders().listen((orders) {
      _totalOrders = orders.length;
      _packagingOrders = orders.where((order) => order.status == 'packaging').length;
      _deliveryOrders = orders.where((order) => order.status == 'shipping').length;
      _completedOrders = orders.where((order) => order.status == 'completed').length;

      _pieChartData = [
        ChartData('Selesai', _completedOrders.toDouble(), Colors.green),
        ChartData('Dikirim', _deliveryOrders.toDouble(), Colors.blue),
        ChartData('Dikemas', _packagingOrders.toDouble(), Colors.orange),
      ];

      notifyListeners();
    });
  }
}
