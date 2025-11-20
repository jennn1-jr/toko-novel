import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tokonovel/admin/responsive.dart';
import 'package:tokonovel/controllers/admin_dashboard_controller.dart';

class OrderSummaryCards extends StatelessWidget {
  const OrderSummaryCards({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AdminDashboardController>();
    final size = MediaQuery.of(context).size;

    return Responsive(
      mobile: SummaryCardGridView(
        crossAxisCount: size.width < 650 ? 2 : 4,
        childAspectRatio: size.width < 650 ? 1.3 : 1,
      ),
      tablet: const SummaryCardGridView(),
      desktop: SummaryCardGridView(
        childAspectRatio: size.width < 1400 ? 1.1 : 1.4,
      ),
    );
  }
}

class SummaryCardGridView extends StatelessWidget {
  const SummaryCardGridView({
    Key? key,
    this.crossAxisCount = 4,
    this.childAspectRatio = 1,
  }) : super(key: key);

  final int crossAxisCount;
  final double childAspectRatio;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AdminDashboardController>();
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: childAspectRatio,
      children: [
        SummaryCard(
          title: "Total Pesanan",
          count: controller.totalOrders,
          icon: Icons.shopping_cart_rounded,
          color: Colors.blue,
        ),
        SummaryCard(
          title: "Perlu Dikemas",
          count: controller.packagingOrders,
          icon: Icons.inventory_2_rounded,
          color: Colors.orange,
        ),
        SummaryCard(
          title: "Dalam Pengiriman",
          count: controller.deliveryOrders,
          icon: Icons.local_shipping_rounded,
          color: Colors.purple,
        ),
        SummaryCard(
          title: "Selesai",
          count: controller.completedOrders,
          icon: Icons.check_circle_rounded,
          color: Colors.green,
        ),
      ],
    );
  }
}


class SummaryCard extends StatelessWidget {
  const SummaryCard({
    Key? key,
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
  }) : super(key: key);

  final String title;
  final int count;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "$count",
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 20, color: color),
              ),
            ],
          ),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          )
        ],
      ),
    );
  }
}
