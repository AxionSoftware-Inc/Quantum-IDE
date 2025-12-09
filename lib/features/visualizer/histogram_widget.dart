import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HistogramWidget extends StatelessWidget {
  final Map<String, dynamic> data;

  const HistogramWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    // 1. DATA PROCESSING (Ma'lumotni tayyorlash)
    List<MapEntry<String, int>> sortedEntries = data.entries
        .map((e) => MapEntry(e.key, e.value as int))
        .toList();

    // Saralash (Kattasi boshiga)
    sortedEntries.sort((a, b) => b.value.compareTo(a.value));

    // Limit: 15 ta ustun
    const int limit = 15;
    List<MapEntry<String, int>> displayData = [];
    int othersCount = 0;

    if (sortedEntries.length > limit) {
      displayData = sortedEntries.sublist(0, limit);
      for (var i = limit; i < sortedEntries.length; i++) {
        othersCount += sortedEntries[i].value;
      }
      if (othersCount > 0) {
        displayData.add(MapEntry("Others", othersCount));
      }
    } else {
      displayData = sortedEntries;
    }

    final int maxY = displayData.isEmpty ? 0 : displayData.map((e) => e.value).reduce((a, b) => a > b ? a : b);

    if (maxY == 0) return const Center(child: Text("Natija 0 ga teng"));

    // 2. CHART CHIZISH
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY * 1.2,
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(color: Colors.white10, strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 35,
              getTitlesWidget: (value, meta) => Text(
                  value.toInt().toString(),
                  style: const TextStyle(color: Colors.grey, fontSize: 10)
              ),
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                int index = value.toInt();
                if (index < displayData.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Transform.rotate(
                      angle: -0.5,
                      child: Text(
                        displayData[index].key,
                        style: GoogleFonts.robotoMono(
                            color: displayData[index].key == "Others" ? Colors.grey : Colors.white70,
                            fontWeight: FontWeight.bold,
                            fontSize: 10
                        ),
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => const Color(0xFF2D2D2D),
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              String key = displayData[group.x.toInt()].key;
              return BarTooltipItem(
                '$key\n',
                const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                children: [
                  TextSpan(
                    text: "${rod.toY.toInt()} times",
                    style: const TextStyle(color: Colors.purpleAccent),
                  ),
                ],
              );
            },
          ),
        ),
        barGroups: List.generate(displayData.length, (index) {
          bool isOthers = displayData[index].key == "Others";
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: displayData[index].value.toDouble(),
                color: isOthers ? Colors.grey[700] : const Color(0xFF6933FF),
                width: 16,
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4)),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: maxY * 1.2,
                  color: Colors.white.withOpacity(0.02),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}