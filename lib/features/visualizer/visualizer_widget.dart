import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'histogram_widget.dart';
import 'matrix_widget.dart';

class VisualizerWidget extends StatelessWidget {
  final Map<String, dynamic> data;

  const VisualizerWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    // Endi "data.isEmpty" bo'lsa ham Widget chizamiz (faqat bo'shini)

    return Container(
      color: const Color(0xFF1E1E1E),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text("VISUALIZATION TOOLS", style: GoogleFonts.robotoMono(color: Colors.grey, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),

          // 1. SXEMA (CIRCUIT)
          _buildSection(
            title: "Quantum Circuit",
            icon: Icons.schema_outlined, // Yoki memory
            content: data.containsKey('circuit_image')
                ? _buildImage(data['circuit_image'])
                : _buildPlaceholder("Sxema chizilmagan"),
          ),

          // 2. GISTOGRAMMA (Histogram)
          _buildSection(
            title: "Probabilities",
            icon: Icons.bar_chart,
            content: data.containsKey('histogram')
                ? AspectRatio(aspectRatio: 1.5, child: HistogramWidget(data: data.containsKey('histogram') ? data['histogram'] : data))
                : _buildPlaceholder("Natijalar yo'q"),
          ),

          // 3. MATRITSA (Density Matrix)
          _buildSection(
            title: "Density Matrix",
            icon: Icons.grid_on,
            content: data.containsKey('matrix')
                ? SizedBox(height: 350, child: MatrixWidget(data: data['matrix']))
                : _buildPlaceholder("Matritsa hisoblanmagan"),
          ),

          // 4. BLOCH SPHERE
          _buildSection(
            title: "Bloch Sphere",
            icon: Icons.public,
            content: data.containsKey('bloch_image')
                ? _buildImage(data['bloch_image'])
                : _buildPlaceholder("Sfera chizilmagan"),
          ),
        ],
      ),
    );
  }

  // Chiroyli Karta Qolipi
  Widget _buildSection({required String title, required IconData icon, required Widget content}) {
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
          // Karta sarlavhasi
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
          // Karta ichi
          Padding(
            padding: const EdgeInsets.all(12),
            child: content,
          ),
        ],
      ),
    );
  }

  // BO'SH HOLAT (SKELET)
  Widget _buildPlaceholder(String message) {
    return Container(
      height: 100,
      width: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.code_off, color: Colors.white10),
          const SizedBox(height: 5),
          Text(message, style: const TextStyle(color: Colors.white24, fontSize: 12)),
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
}