import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VisualizerWidget extends StatelessWidget {
  final Map<String, dynamic> data; // Masalan: {"00": 512, "11": 480}

  const VisualizerWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Center(
        child: Text(
          "Grafik chizish uchun ma'lumot yo'q.\nKodni ishga tushiring.",
          textAlign: TextAlign.center,
          style: GoogleFonts.robotoMono(color: Colors.white24),
        ),
      );
    }

    // 1. Ma'lumotlarni tayyorlash
    final List<String> keys = data.keys.toList();
    final List<int> values = data.values.map((e) => e as int).toList();
    // Eng katta qiymatni topamiz (Grafik shifti uchun)
    final int maxY = values.reduce((curr, next) => curr > next ? curr : next);

    return Container(
      padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
      color: const Color(0xFF1E1E1E),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY * 1.2, // Tepada ozgina joy qolsin

          // 2. Tepa va O'ng chiziqlarni olib tashlash
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: false), // Setkani o'chiramiz

          // 3. Pastki yozuvlar (00, 01, 10...)
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() < keys.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        keys[value.toInt()],
                        style: GoogleFonts.robotoMono(
                            color: Colors.white70,
                            fontWeight: FontWeight.bold,
                            fontSize: 10
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),

          // 4. Sichqoncha borganda chiqadigan ma'lumot (Tooltip)
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              // tooltipBgColor: Colors.deepPurple,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                String key = keys[group.x.toInt()];
                return BarTooltipItem(
                  '$key\n',
                  const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  children: [
                    TextSpan(
                      text: (rod.toY.toInt()).toString(),
                      style: const TextStyle(color: Colors.yellowAccent),
                    ),
                  ],
                );
              },
            ),
          ),

          // 5. Ustunlar (Bars)
          barGroups: List.generate(keys.length, (index) {
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: values[index].toDouble(),
                  color: const Color(0xFF6933FF), // Qiskit Purple rangi
                  width: 25,
                  borderRadius: BorderRadius.circular(4),
                  // Orqa fon (bo'sh joy)
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: maxY * 1.2,
                    color: Colors.white.withOpacity(0.05),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}