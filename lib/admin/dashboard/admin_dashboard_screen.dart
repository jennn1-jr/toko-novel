import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart'; // Pastikan package fl_chart sudah diinstall
import 'package:tokonovel/models/order_model.dart';
import 'package:tokonovel/services/firestore_service.dart';
import 'package:tokonovel/admin/dashboard/components/header.dart'; // Sesuaikan path import ini

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Header(title: "Dashboard Overview"),
            const SizedBox(height: 20),
            
            // STREAM BUILDER: Mengambil data pesanan secara Realtime
            StreamBuilder<List<OrderModel>>(
              stream: firestoreService.getAllOrders(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("Belum ada data pesanan"));
                }

                final orders = snapshot.data!;

                // --- LOGIKA PERHITUNGAN DATA LENGKAP ---
                final int totalOrders = orders.length;

                // 1. Pending (Belum Bayar / Baru)
                final int pendingCount = orders.where((o) => o.status == 'pending').length;

                // 2. Perlu Dikemas (Paid + Packaging)
                final int packagingCount = orders.where((o) => o.status == 'paid' || o.status == 'packaging').length;

                // 3. Dalam Pengiriman (Shipping + Delivered)
                final int shippingCount = orders.where((o) => o.status == 'shipping' || o.status == 'delivered').length;

                // 4. Selesai
                final int completedCount = orders.where((o) => o.status == 'completed').length;

                // 5. Batal
                final int cancelledCount = orders.where((o) => o.status == 'cancelled').length;

                return Column(
                  children: [
                    // --- GRID SUMMARY (Tetap 4 Kartu Utama agar rapi) ---
                    GridView.count(
                      crossAxisCount: 4,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      shrinkWrap: true,
                      childAspectRatio: 1.4,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildSummaryCard("Total Pesanan", totalOrders.toString(), Colors.blue, Icons.shopping_cart),
                        _buildSummaryCard("Perlu Dikemas", packagingCount.toString(), Colors.orange, Icons.inventory_2),
                        _buildSummaryCard("Dalam Pengiriman", shippingCount.toString(), Colors.purple, Icons.local_shipping),
                        _buildSummaryCard("Selesai", completedCount.toString(), Colors.green, Icons.check_circle),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // --- CHART STATISTIK (LENGKAP 5 WARNA) ---
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10)],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Statistik Pesanan Lengkap", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 32),
                          Row(
                            children: [
                              // CHART
                              Expanded(
                                flex: 2,
                                child: SizedBox(
                                  height: 250,
                                  child: PieChart(
                                    PieChartData(
                                      sectionsSpace: 2,
                                      centerSpaceRadius: 50,
                                      sections: [
                                        // Urutan warna searah jarum jam
                                        _buildPieSection(pendingCount.toDouble(), Colors.grey), 
                                        _buildPieSection(packagingCount.toDouble(), Colors.orange),
                                        _buildPieSection(shippingCount.toDouble(), Colors.purple),
                                        _buildPieSection(completedCount.toDouble(), Colors.green),
                                        _buildPieSection(cancelledCount.toDouble(), Colors.red), 
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              
                              // LEGEND (KETERANGAN)
                              const Expanded(
                                flex: 1,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _LegendItem(color: Colors.grey, text: "Pending"),
                                    SizedBox(height: 12),
                                    _LegendItem(color: Colors.orange, text: "Perlu Dikemas"),
                                    SizedBox(height: 12),
                                    _LegendItem(color: Colors.purple, text: "Sedang Dikirim"),
                                    SizedBox(height: 12),
                                    _LegendItem(color: Colors.green, text: "Selesai"),
                                    SizedBox(height: 12),
                                    _LegendItem(color: Colors.red, text: "Dibatalkan"),
                                  ],
                                ),
                              ),
                            ],
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

  // --- WIDGET HELPER CHART ---
  PieChartSectionData _buildPieSection(double value, Color color) {
    final isZero = value == 0;
    return PieChartSectionData(
      color: color,
      // Jika 0, beri nilai dummy 0.001 agar chart tidak error, tapi sembunyikan teksnya
      // Atau beri nilai 0 jika versi fl_chart mendukungnya (biasanya mendukung)
      value: value, 
      title: isZero ? '' : value.toInt().toString(), 
      radius: 60, // Ukuran ketebalan lingkaran
      titleStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      showTitle: !isZero, // Sembunyikan title jika 0
    );
  }

  // --- WIDGET HELPER KARTU ---
  Widget _buildSummaryCard(String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color),
              ),
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
          Text(title, style: TextStyle(fontSize: 14, color: Colors.grey[700], fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// --- WIDGET LEGEND (KETERANGAN) ---
class _LegendItem extends StatelessWidget {
  final Color color;
  final String text;

  const _LegendItem({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 8),
        Flexible(child: Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500))),
      ],
    );
  }
}