import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tokonovel/services/firestore_service.dart';
import 'package:tokonovel/models/order_model.dart';

class ManageOrdersScreen extends StatefulWidget {
  const ManageOrdersScreen({Key? key}) : super(key: key);

  @override
  State<ManageOrdersScreen> createState() => _ManageOrdersScreenState();
}

class _ManageOrdersScreenState extends State<ManageOrdersScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        primary: false,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  "Kelola Pesanan",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            StreamBuilder<List<OrderModel>>(
              stream: _firestoreService.getAllOrders(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Tidak ada pesanan.'));
                }

                final orders = snapshot.data!;
                return Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor, // Use cardColor for better theme integration
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: DataTable(
                      horizontalMargin: 0,
                      columnSpacing: 16.0,
                      columns: const [
                        DataColumn(label: Text('ID Pesanan')),
                        DataColumn(label: Text('User ID')),
                        DataColumn(label: Text('Tanggal')),
                        DataColumn(label: Text('Total')),
                        DataColumn(label: Text('Alamat')),
                        DataColumn(label: Text('Status')),
                        DataColumn(label: Text('Aksi')),
                      ],
                      rows: List.generate(
                        orders.length,
                        (index) => orderDataRow(orders[index]),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  DataRow orderDataRow(OrderModel order) {
    return DataRow(
      cells: [
        DataCell(Text(order.id ?? 'N/A')),
        DataCell(Text(order.userId)),
        DataCell(Text(DateFormat('dd MMM yyyy').format(order.orderDate))),
        DataCell(Text('Rp ${order.totalAmount.toStringAsFixed(0)}')),
        DataCell(Text(order.shippingAddress)),
        DataCell(Text(order.status)),
        DataCell(
          DropdownButton<String>(
            value: order.status,
            onChanged: (String? newValue) {
              if (newValue != null) {
                _firestoreService.updateOrderStatus(order.id!, newValue);
              }
            },
            items: <String>['pending', 'packaging', 'shipping', 'completed']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}