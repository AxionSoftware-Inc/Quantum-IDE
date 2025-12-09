import 'package:flutter/material.dart';

class RightActivityBar extends StatelessWidget {
  final bool isPanelVisible;
  final VoidCallback onToggle;

  const RightActivityBar({
    super.key,
    required this.isPanelVisible,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50, // Ingichka ustun
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E), // Yoki sal to'qroq rang
        border: Border(left: BorderSide(color: Colors.white10)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          // Vizualizatsiya Tugmasi
          Tooltip(
            message: "Visualization Dashboard",
            child: InkWell(
              onTap: onToggle,
              child: Container(
                width: 40,
                height: 40,
                decoration: isPanelVisible
                    ? BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  border: const Border(right: BorderSide(color: Colors.purpleAccent, width: 2)), // O'ngda chiziq
                )
                    : null,
                child: Icon(
                    Icons.space_dashboard_outlined,
                    color: isPanelVisible ? Colors.purpleAccent : Colors.grey,
                    size: 24
                ),
              ),
            ),
          ),
          // Kelajakda yana tugmalar qo'shish mumkin (masalan, AI Chat, Documentation)
          const Spacer(),
        ],
      ),
    );
  }
}