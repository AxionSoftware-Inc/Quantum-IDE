import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Yangi fayllarni ulaymiz
import 'histogram_widget.dart';
import 'matrix_widget.dart';

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
          // HEADER
          Text("SIMULATION RESULTS", style: GoogleFonts.robotoMono(color: Colors.grey, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),

          // 1. GISTOGRAMMA (Histogram)
          _buildCard("Probabilities (Histogram)", AspectRatio(
            aspectRatio: 1.5,
            // Agar histogram ma'lumoti bo'lsa, widgetni chaqiramiz
            child: data.containsKey('histogram')
                ? HistogramWidget(data: data['histogram'])
                : HistogramWidget(data: data), // Eski format uchun fallback
          )),

          // 2. MATRITSA (Density Matrix)
          if (data.containsKey('matrix'))
            _buildCard("Density Matrix (Heatmap)", SizedBox(
              height: 350, // Kvadratga yaqin joy ajratamiz
              child: MatrixWidget(data: data['matrix']),
            )),

          // 3. BLOCH SFERA (Rasm)
          if (data.containsKey('bloch_image'))
            _buildCard("Bloch Sphere", _buildImage(data['bloch_image'])),

          // 4. SXEMA (Circuit) - Kelajak uchun
          if (data.containsKey('circuit_image'))
            _buildCard("Quantum Circuit", _buildImage(data['circuit_image'])),
        ],
      ),
    );
  }

  Widget _buildCard(String title, Widget content) {
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.white10)),
            ),
            child: Row(
              children: [
                const Icon(Icons.analytics_outlined, size: 16, color: Colors.purpleAccent),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: content,
          ),
        ],
      ),
    );
  }

  Widget _buildImage(String? base64String) {
    if (base64String == null || base64String.isEmpty) return const SizedBox.shrink();
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Image.memory(base64Decode(base64String), fit: BoxFit.contain),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.auto_awesome_mosaic, size: 60, color: Colors.white10),
          const SizedBox(height: 10),
          Text("No Visualization Data", style: GoogleFonts.robotoMono(color: Colors.white24)),
        ],
      ),
    );
  }
}