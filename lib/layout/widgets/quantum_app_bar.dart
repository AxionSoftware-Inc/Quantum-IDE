import 'package:flutter/material.dart';
import '../../features/menu/top_menu_bar.dart';

class QuantumAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onNewFile;
  final VoidCallback onOpenFile;
  final VoidCallback onOpenFolder;
  final VoidCallback onSave;
  final VoidCallback onRun;
  final VoidCallback onInstallDeps;
  final bool isLoading;
  final String? activeFileName;

  const QuantumAppBar({
    super.key,
    required this.onNewFile,
    required this.onOpenFile,
    required this.onOpenFolder,
    required this.onSave,
    required this.onRun,
    required this.onInstallDeps,
    required this.isLoading,
    this.activeFileName,
  });

  @override
  Size get preferredSize => const Size.fromHeight(40);

  @override
  Widget build(BuildContext context) {
    return Container(
      // ❌ ESKI XATO JOYI: color: const Color(0xFF1E1E1E), <-- BU YERDAN OLIB TASHLANG

      padding: const EdgeInsets.symmetric(horizontal: 10),

      // ✅ TO'G'RI JOYI:
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E), // <--- Rangni decoration ICHIGA yozish kerak
        border: Border(bottom: BorderSide(color: Colors.white10)),
      ),

      child: Row(
        children: [
          const Icon(Icons.code, color: Colors.purpleAccent, size: 18),
          const SizedBox(width: 8),
          const Text("Quantum IDE", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white)),

          const SizedBox(width: 20),
          Container(width: 1, height: 20, color: Colors.white10),
          const SizedBox(width: 10),

          // MENU
          TopMenuBar(
            onNewFile: onNewFile,
            onOpenFile: onOpenFile,
            onOpenFolder: onOpenFolder,
            onSave: onSave,
            onRun: onRun,
            onInstallDeps: onInstallDeps,
          ),

          const SizedBox(width: 20),

          // RUN TUGMASI
          IconButton(
            icon: isLoading
                ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(color: Colors.greenAccent, strokeWidth: 2))
                : const Icon(Icons.play_circle_fill, color: Colors.greenAccent),
            onPressed: isLoading ? null : onRun,
            tooltip: "Run (F5)",
          ),

          const Spacer(),

          // FAYL NOMI
          if (activeFileName != null)
            Text(activeFileName!, style: const TextStyle(color: Colors.white54, fontSize: 12)),

          const Spacer(),
        ],
      ),
    );
  }
}