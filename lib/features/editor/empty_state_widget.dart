import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EmptyStateWidget extends StatelessWidget {
  final VoidCallback onNewFile;
  final VoidCallback onOpenFile;

  const EmptyStateWidget({
    super.key,
    required this.onNewFile,
    required this.onOpenFile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1E1E1E),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 1. LOGO (Katta va xira)
            Icon(
              Icons.rocket_launch_outlined, // Yoki kvant belgisi
              size: 100,
              color: Colors.white.withOpacity(0.05),
            ),
            const SizedBox(height: 20),

            Text(
              "Quantum IDE",
              style: GoogleFonts.jetBrainsMono(
                  color: Colors.white24,
                  fontSize: 24,
                  fontWeight: FontWeight.bold
              ),
            ),
            const SizedBox(height: 40),

            // 2. TEZKOR TUGMALAR (Shortcuts)
            _buildShortcut(Icons.note_add_outlined, "New File", "Ctrl + N", onNewFile),
            _buildShortcut(Icons.folder_open_outlined, "Open File", "Ctrl + O", onOpenFile),
            _buildShortcut(Icons.play_arrow_outlined, "Run Code", "F5", () {}),

            const SizedBox(height: 20),
            // Qo'shimcha yozuv
            const Text(
              "Start by opening a file or creating a new one.",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShortcut(IconData icon, String label, String keyCombo, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 300,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        margin: const EdgeInsets.only(bottom: 10),
        child: Row(
          children: [
            Icon(icon, color: Colors.purpleAccent, size: 20),
            const SizedBox(width: 15),
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(keyCombo, style: const TextStyle(color: Colors.grey, fontSize: 11)),
            ),
          ],
        ),
      ),
    );
  }
}