import 'package:flutter/material.dart';

class ActivityBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onIndexChanged;

  const ActivityBar({
    super.key,
    required this.selectedIndex,
    required this.onIndexChanged,
  });

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> items = [
      {'icon': Icons.file_copy_outlined, 'tooltip': 'Explorer'},
      {'icon': Icons.search, 'tooltip': 'Search'},
      {'icon': Icons.hub_outlined, 'tooltip': 'Quantum Devices'}, // Ikonka o'zgardi
      {'icon': Icons.bug_report_outlined, 'tooltip': 'Debug'},
      {'icon': Icons.extension_outlined, 'tooltip': 'Extensions'},
    ];

    return Container(
      width: 60, // Biroz kengaytirdik (zamonaviy ko'rinish uchun)
      decoration: const BoxDecoration(
        // 1. GRADIENT FON (Qoradan to'q ko'kka)
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1E1E1E), // Tepa qismi (Editor bilan bir xil)
            Color(0xFF0F0F1A), // Pastki qismi (Biroz ko'kish qora)
          ],
        ),
        border: Border(right: BorderSide(color: Colors.white10)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 15),
          // LOGO O'RNIGA (Vaqtincha)
          const Icon(Icons.blur_on, color: Colors.purpleAccent, size: 32),
          const SizedBox(height: 20),

          ...List.generate(items.length, (index) {
            return _buildIconButton(
              icon: items[index]['icon'],
              tooltip: items[index]['tooltip'],
              index: index,
            );
          }),

          const Spacer(),
          _buildIconButton(
              icon: Icons.settings_outlined,
              tooltip: 'Settings',
              index: 99
          ),
          const SizedBox(height: 15),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required String tooltip,
    required int index
  }) {
    bool isActive = selectedIndex == index;

    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: () => onIndexChanged(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 50,
          height: 50,
          margin: const EdgeInsets.symmetric(vertical: 5),
          decoration: isActive
              ? BoxDecoration(
            // 2. AKTIV TUGMA UCHUN NEON EFFEKT
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10), // Yumaloq burchak
              border: Border.all(color: Colors.white10),
              boxShadow: [
                BoxShadow(
                  color: Colors.purpleAccent.withOpacity(0.2),
                  blurRadius: 10,
                  spreadRadius: 1,
                )
              ]
          )
              : null,
          child: Icon(
            icon,
            // Aktiv bo'lsa oppoq, bo'lmasa xira
            color: isActive ? Colors.white : Colors.grey[600],
            size: 26,
          ),
        ),
      ),
    );
  }
}