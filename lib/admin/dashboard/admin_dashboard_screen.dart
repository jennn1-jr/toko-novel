import 'package:flutter/material.dart';
import 'components/header.dart';
import 'components/order_summary_cards.dart';
import 'components/orders_pie_chart.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Header(title: "Dashboard"),
            SizedBox(height: 16),
            OrderSummaryCards(),
            SizedBox(height: 16),
            OrdersPieChart(),
          ],
        ),
      ),
    );
  }
}


