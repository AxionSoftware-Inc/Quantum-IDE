import 'package:flutter/material.dart';
import '../visualizer/visualizer_widget.dart';

class RightPanel extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onClose;

  const RightPanel({
    super.key,
    required this.data,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400, // Kengroq joy (Grafiklar sig'ishi uchun)
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E),
        border: Border(left: BorderSide(color: Colors.white10)),
      ),
      child: Column(
        children: [
          // SARLAVHA
          Container(
            height: 35,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            color: const Color(0xFF252526),
            child: Row(
              children: [
                const Text("VISUALIZATION", style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                const Spacer(),
                InkWell(
                  onTap: onClose,
                  child: const Icon(Icons.close, size: 16, color: Colors.grey),
                ),
              ],
            ),
          ),

          // ASOSIY VIZUALIZATOR
          Expanded(
            child: VisualizerWidget(data: data),
          ),
        ],
      ),
    );
  }
}