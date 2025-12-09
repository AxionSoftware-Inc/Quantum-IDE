import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'histogram_widget.dart';
import 'matrix_widget.dart';

// ... importlar ...

class VisualizerWidget extends StatelessWidget {
  final Map<String, dynamic> data;

  const VisualizerWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return _buildEmptyState();

    return Container(
      color: const Color(0xFF1E1E1E),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text("SIMULATION REPORT", style: GoogleFonts.robotoMono(color: Colors.grey, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),

          // 1. SXEMA
          if (data.containsKey('circuit_image'))
            _buildSection(
                title: "Quantum Circuit",
                icon: Icons.schema_outlined,
                content: _buildImage(data['circuit_image']),
                // Agar width/depth kabi info bo'lsa shu yerga yoziladi
                info: data['circuit_info']
            ),

          // 2. GISTOGRAMMA
          if (data.containsKey('histogram') || data.containsKey('counts'))
            _buildSection(
              title: "Probabilities",
              icon: Icons.bar_chart,
              content: AspectRatio(
                  aspectRatio: 1.5,
                  child: HistogramWidget(data: data.containsKey('histogram') ? data['histogram'] : data)
              ),
              info: _generateHistogramStats(data.containsKey('histogram') ? data['histogram'] : data),
            ),

          // 3. MATRITSA
          if (data.containsKey('matrix'))
            _buildSection(
              title: "Density Matrix",
              icon: Icons.grid_on,
              content: SizedBox(
                  height: 350,
                  child: MatrixWidget(data: data['matrix'])
              ),
              info: "Matritsa o'lchami va tozaligi (Purity) haqida ma'lumot shu yerda bo'ladi.",
            ),

          // 4. BLOCH SPHERE
          if (data.containsKey('bloch_image'))
            _buildSection(
              title: "Bloch Sphere",
              icon: Icons.public,
              content: _buildImage(data['bloch_image']),
            ),
        ],
      ),
    );
  }

  // YANGILANGAN KARTA DIZAYNI
  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget content,
    String? info, // <--- YANGI: Qo'shimcha ma'lumot matni
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF252526),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sarlavha
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.white10)),
            ),
            child: Row(
              children: [
                Icon(icon, size: 16, color: Colors.purpleAccent),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
              ],
            ),
          ),

          // Asosiy Grafik
          Padding(
            padding: const EdgeInsets.all(12),
            child: content,
          ),

          // INFO QISMI (Agar bor bo'lsa)
          if (info != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: Colors.black12, // Sal to'qroq fon
                border: Border(top: BorderSide(color: Colors.white10)),
              ),
              child: Text(
                info,
                style: GoogleFonts.robotoMono(color: Colors.grey, fontSize: 11),
              ),
            ),
        ],
      ),
    );
  }

  // Yordamchi: Gistogramma statistikasini hisoblash
  String _generateHistogramStats(Map<String, dynamic> counts) {
    int totalShots = 0;
    String maxState = "";
    int maxVal = -1;

    counts.forEach((key, value) {
      int val = value as int;
      totalShots += val;
      if (val > maxVal) {
        maxVal = val;
        maxState = key;
      }
    });

    return "Total Shots: $totalShots  |  Most Probable: |$maxState> (${((maxVal/totalShots)*100).toStringAsFixed(1)}%)";
  }

  // ... (Qolgan _buildImage va _buildEmptyState funksiyalari o'zgarishsiz) ...
  Widget _buildImage(String? base64String) {
    if (base64String == null || base64String.isEmpty) return const SizedBox.shrink();
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Image.memory(base64Decode(base64String), fit: BoxFit.contain),
    );
  }

  Widget _buildEmptyState() {
    return Center(child: Text("No Data", style: TextStyle(color: Colors.white)));
  }
}