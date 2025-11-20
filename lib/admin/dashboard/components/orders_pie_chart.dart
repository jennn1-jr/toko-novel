import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:tokonovel/controllers/admin_dashboard_controller.dart';

class OrdersPieChart extends StatelessWidget {
  const OrdersPieChart({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AdminDashboardController>();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Statistik Pesanan",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: SfCircularChart(
              legend: const Legend(isVisible: true, overflowMode: LegendItemOverflowMode.wrap),
              series: <CircularSeries<ChartData, String>>[
                PieSeries<ChartData, String>(
                  dataSource: controller.pieChartData,
                  xValueMapper: (ChartData data, _) => data.x,
                  yValueMapper: (ChartData data, _) => data.y,
                  pointColorMapper: (ChartData data, _) => data.color,
                  dataLabelMapper: (ChartData data, _) => '${data.y.toInt()}',
                  dataLabelSettings: const DataLabelSettings(
                    isVisible: true,
                    textStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
