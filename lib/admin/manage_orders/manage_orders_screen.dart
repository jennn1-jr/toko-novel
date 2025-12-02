import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tokonovel/admin/admin_theme.dart';
import 'package:tokonovel/models/order_model.dart';
import 'package:tokonovel/services/firestore_service.dart';

class ManageOrdersScreen extends StatelessWidget {
  const ManageOrdersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();

    return Container(
      padding: const EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: BorderRadius.circular(defaultBorderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Semua Pesanan",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: defaultPadding),
          StreamBuilder<List<OrderModel>>(
            stream: firestoreService.getAllOrders(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: accentColor));
              }
              if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}", style: const TextStyle(color: dangerColor)));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text("Belum ada pesanan.", style: TextStyle(color: textColorMuted)));
              }

              final orders = snapshot.data!;
              return SizedBox(
                width: double.infinity,
                child: DataTable(
                  columnSpacing: defaultPadding,
                  columns: const [
                    DataColumn(label: Text("Order ID", style: TextStyle(color: textColorMuted))),
                    DataColumn(label: Text("Tanggal", style: TextStyle(color: textColorMuted))),
                    DataColumn(label: Text("Total", style: TextStyle(color: textColorMuted))),
                    DataColumn(label: Text("Status", style: TextStyle(color: textColorMuted))),
                    DataColumn(label: Text("Aksi", style: TextStyle(color: textColorMuted))),
                  ],
                  rows: orders.map((order) => _buildOrderRow(context, order, firestoreService)).toList(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  DataRow _buildOrderRow(BuildContext context, OrderModel order, FirestoreService service) {
    return DataRow(
      cells: [
        DataCell(Text(order.id?.substring(0, 8) ?? '(no id)', style: const TextStyle(color: textColor))),
        DataCell(Text(DateFormat('dd MMM yyyy').format(order.orderDate), style: const TextStyle(color: textColorMuted))),
        DataCell(Text("Rp${NumberFormat('#,##0').format(order.totalAmount)}", style: const TextStyle(color: textColor, fontWeight: FontWeight.w600))),
        DataCell(_buildStatusChip(order.status)),
        DataCell(
          PopupMenuButton<String>(
            onSelected: (String newStatus) {
              if (order.id != null) {
                service.updateOrderStatus(order.id!, newStatus);
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              _buildPopupMenuItem("packaging", "Kemas Pesanan", Icons.inventory_2),
              _buildPopupMenuItem("shipping", "Kirim Pesanan", Icons.local_shipping),
              _buildPopupMenuItem("completed", "Selesaikan Pesanan", Icons.check_circle),
              _buildPopupMenuItem("cancelled", "Batalkan Pesanan", Icons.cancel),
            ],
            icon: const Icon(Icons.more_vert, color: textColorMuted),
            color: primaryColor,
          ),
        ),
      ],
    );
  }

  PopupMenuItem<String> _buildPopupMenuItem(String value, String text, IconData icon) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(icon, color: _getStatusColor(value), size: 20),
          const SizedBox(width: 10),
          Text(text, style: const TextStyle(color: textColor)),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    final Color color = _getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'paid':
        return warningColor;
      case 'packaging':
        return infoColor;
      case 'shipping':
        return accentColor;
      case 'completed':
        return successColor;
      case 'cancelled':
        return dangerColor;
      default:
        return Colors.grey;
    }
  }
}