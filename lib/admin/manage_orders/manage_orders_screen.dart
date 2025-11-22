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
  
  // Default filter: Tampilkan Semua
  String _selectedFilter = 'Semua';

  // Daftar Status untuk Dropdown (Update Data)
  final List<String> _orderStatuses = [
    'pending',
    'paid',
    'packaging',
    'shipping',
    'delivered',
    'completed',
    'cancelled'
  ];

  // Daftar Kategori untuk Tab Filter (Atas)
  final List<String> _filterOptions = [
    'Semua',
    'paid',
    'pending',
    'packaging',
    'shipping',
    'completed',
    'cancelled'
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        primary: false,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Kelola Pesanan",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20.0),

            // --- 1. BAGIAN FILTER KATEGORI (BARU) ---
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _filterOptions.map((status) {
                  final bool isSelected = _selectedFilter == status;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(
                        _getDisplayStatus(status), // Nama yang user-friendly
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: _getStatusColor(status), // Warna sesuai status
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected ? Colors.transparent : Colors.grey.shade300,
                        ),
                      ),
                      onSelected: (bool selected) {
                        if (selected) {
                          setState(() {
                            _selectedFilter = status;
                          });
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            
            const SizedBox(height: 16.0),

            // --- 2. TABEL DATA ---
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

                final allOrders = snapshot.data!;

                // --- LOGIKA FILTER DATA ---
                // Jika pilih 'Semua', tampilkan semua. Jika tidak, filter berdasarkan status.
                // Khusus untuk filter 'shipping', kita gabungkan dengan 'delivered' agar muncul di tab yang sama
                final filteredOrders = allOrders.where((order) {
                  if (_selectedFilter == 'Semua') return true;
                  if (_selectedFilter == 'shipping') {
                    return order.status == 'shipping' || order.status == 'delivered';
                  }
                  return order.status == _selectedFilter;
                }).toList();

                if (filteredOrders.isEmpty) {
                  return Container(
                    height: 200,
                    alignment: Alignment.center,
                    child: Text("Tidak ada pesanan dengan status '${_getDisplayStatus(_selectedFilter)}'"),
                  );
                }

                return Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        horizontalMargin: 12,
                        columnSpacing: 20.0,
                        columns: const [
                          DataColumn(label: Text('ID', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Tanggal', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Total', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Alamat', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Aksi', style: TextStyle(fontWeight: FontWeight.bold))),
                        ],
                        rows: List.generate(
                          filteredOrders.length,
                          (index) => orderDataRow(filteredOrders[index]),
                        ),
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
    String formatRupiah(double amount) {
      return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(amount);
    }

    String currentStatus = _orderStatuses.contains(order.status) ? order.status : 'pending';

    return DataRow(
      cells: [
        DataCell(Text(
          (order.id ?? 'N/A').substring(0, 6).toUpperCase(), 
          style: const TextStyle(fontWeight: FontWeight.w500)
        )),
        DataCell(Text(DateFormat('dd/MM HH:mm').format(order.orderDate))),
        DataCell(Text(
          formatRupiah(order.totalAmount),
          style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
        )),
        DataCell(SizedBox(
          width: 120,
          child: Text(
            order.shippingAddress,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            style: const TextStyle(fontSize: 12),
          ),
        )),
        DataCell(Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getStatusColor(currentStatus).withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _getStatusColor(currentStatus)),
          ),
          child: Text(
            currentStatus.toUpperCase(),
            style: TextStyle(color: _getStatusColor(currentStatus), fontWeight: FontWeight.bold, fontSize: 10),
          ),
        )),
        DataCell(
          DropdownButton<String>(
            value: currentStatus,
            underline: const SizedBox(),
            icon: const Icon(Icons.edit, size: 16, color: Colors.grey),
            style: const TextStyle(color: Colors.black, fontSize: 13),
            onChanged: (String? newValue) {
              if (newValue != null && order.id != null) {
                _firestoreService.updateOrderStatus(order.id!, newValue);
              }
            },
            items: _orderStatuses.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value.toUpperCase()),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // Helper: Nama Status yang enak dibaca
String _getDisplayStatus(String status) {
    switch (status) {
      case 'Semua': return 'Semua';
      case 'pending': return 'Pending'; 
      case 'paid': return 'Dibayar';
      case 'packaging': return 'Dikemas';
      case 'shipping': return 'Dikirim';
      case 'completed': return 'Selesai';
      case 'cancelled': return 'Batal';
      default: return status;
    }
  }

  // Helper: Warna Status
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Semua': return Colors.grey[800]!;
      case 'paid': return Colors.blue;
      case 'pending': return Colors.grey;
      case 'packaging': return Colors.orange;
      case 'shipping': return Colors.purple;
      case 'delivered': return Colors.purpleAccent;
      case 'completed': return Colors.green;
      case 'cancelled': return Colors.red;
      default: return Colors.grey;
    }
  }
}