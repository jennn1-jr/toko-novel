import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:tokonovel/admin/admin_theme.dart';
import 'package:tokonovel/models/order_model.dart';
import 'package:tokonovel/services/firestore_service.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();

    return SafeArea(
      child: SingleChildScrollView(
        primary: false,
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          children: [
            const SizedBox(height: defaultPadding),
            StreamBuilder<List<OrderModel>>(
              stream: firestoreService.getAllOrders(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: accentColor));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("Belum ada data pesanan.", style: TextStyle(color: textColorMuted)));
                }

                final orders = snapshot.data!;
                final int totalOrders = orders.length;
                final int pendingOrders = orders.where((o) => o.status == 'paid').length;
                final int packagingOrders = orders.where((o) => o.status == 'packaging').length;
                final int shippingOrders = orders.where((o) => o.status == 'shipping').length;
                final int completedOrders = orders.where((o) => o.status == 'completed').length;
                final int cancelledOrders = orders.where((o) => o.status == 'cancelled').length;

                return Column(
                  children: [
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 4,
                      crossAxisSpacing: defaultPadding,
                      mainAxisSpacing: defaultPadding,
                      childAspectRatio: 1.5,
                      children: [
                        _buildSummaryCard("Total Pesanan", totalOrders.toString(), Colors.blue, Icons.shopping_cart),
                        _buildSummaryCard("Pending", pendingOrders.toString(), warningColor, Icons.pending),
                        _buildSummaryCard("Dikemas", packagingOrders.toString(), infoColor, Icons.inventory_2),
                        _buildSummaryCard("Dikirim", shippingOrders.toString(), accentColor, Icons.local_shipping),
                        _buildSummaryCard("Selesai", completedOrders.toString(), successColor, Icons.check_circle),
                        _buildSummaryCard("Dibatalkan", cancelledOrders.toString(), dangerColor, Icons.cancel),
                      ],
                    ),
                    const SizedBox(height: defaultPadding),
                    Container(
                      padding: const EdgeInsets.all(defaultPadding),
                      decoration: BoxDecoration(
                        color: secondaryColor,
                        borderRadius: BorderRadius.circular(defaultBorderRadius),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Statistik Pesanan", style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.w600)),
                          const SizedBox(height: defaultPadding * 1.5),
                          SizedBox(
                            height: 250,
                            child: PieChart(
                              PieChartData(
                                sectionsSpace: 2,
                                centerSpaceRadius: 50,
                                sections: [
                                  _buildPieSection(pendingOrders.toDouble(), warningColor, "Pending"),
                                  _buildPieSection(packagingOrders.toDouble(), infoColor, "Dikemas"),
                                  _buildPieSection(shippingOrders.toDouble(), accentColor, "Dikirim"),
                                  _buildPieSection(completedOrders.toDouble(), successColor, "Selesai"),
                                  _buildPieSection(cancelledOrders.toDouble(), dangerColor, "Batal"),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: BorderRadius.circular(defaultBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
            ],
          ),
          Text(title, style: const TextStyle(fontSize: 14, color: textColorMuted, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  PieChartSectionData _buildPieSection(double value, Color color, String title) {
    final isZero = value == 0;
    return PieChartSectionData(
      color: color,
      value: value,
      title: isZero ? '' : '${value.toInt()}',
      radius: 60,
      titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
      showTitle: !isZero,
    );
  }
}