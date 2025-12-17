import 'package:flutter/material.dart';
// Agar papka tuzilishi o'zgarmagan bo'lsa, bu import to'g'ri ishlashi kerak:
import '../../features/menu/top_menu_bar.dart';

class QuantumAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onNewFile;
  final VoidCallback onOpenFile;
  final VoidCallback onOpenFolder;
  final VoidCallback onSave;
  final VoidCallback onRun;        // Bu funksiya MainLayoutda Run yoki Stopni chaqiradi
  final VoidCallback onInstallDeps;

  final bool isLoading;
  final bool isRunning;            // <--- YANGI: Kod ishlayaptimi yo'qmi bilish uchun
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
    this.isRunning = false,        // Default qiymat
    this.activeFileName,
  });

  @override
  Size get preferredSize => const Size.fromHeight(40); // Sizning o'lchamingiz

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E),
        border: Border(bottom: BorderSide(color: Colors.white10)),
      ),
      child: Row(
        children: [
          // 1. LOGO VA NOM
          const Icon(Icons.code, color: Colors.purpleAccent, size: 18),
          const SizedBox(width: 8),
          const Text(
              "Quantum IDE",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white)
          ),

          const SizedBox(width: 20),
          Container(width: 1, height: 20, color: Colors.white10),
          const SizedBox(width: 10),

          // 2. MENYU (Sizning eski menyuingiz joyiga qaytdi)
          TopMenuBar(
            onNewFile: onNewFile,
            onOpenFile: onOpenFile,
            onOpenFolder: onOpenFolder,
            onSave: onSave,
            onRun: onRun,
            onInstallDeps: onInstallDeps,
          ),

          const Spacer(), // O'rtani bo'sh qoldiramiz

          // 3. FAYL NOMI (O'rtada yoki o'ngroqda)
          if (activeFileName != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                activeFileName!,
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ),

          const SizedBox(width: 10),

          // 4. RUN / STOP TUGMASI (YANGILANGAN MANTIQ)
          if (isLoading)
            const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(color: Colors.greenAccent, strokeWidth: 2)
            )
          else
            Container(
              height: 28, // Tugma balandligi
              decoration: BoxDecoration(
                color: isRunning
                    ? Colors.red.withOpacity(0.2)   // Ishlayotganda Qizil fon
                    : Colors.green.withOpacity(0.2), // Tinch holatda Yashil fon
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                    color: isRunning ? Colors.redAccent : Colors.greenAccent,
                    width: 1
                ),
              ),
              child: IconButton(
                padding: EdgeInsets.zero, // Iconni markazlashtirish uchun
                iconSize: 18,
                icon: Icon(
                    isRunning ? Icons.stop : Icons.play_arrow, // Icon almashadi
                    color: isRunning ? Colors.redAccent : Colors.greenAccent
                ),
                onPressed: onRun,
                tooltip: isRunning ? "Stop (Process Kill)" : "Run (F5)",
              ),
            ),

          const SizedBox(width: 10),
        ],
      ),
    );
  }
}