import 'package:flutter/material.dart';

class TopMenuBar extends StatelessWidget {
  // Bizga kerak bo'lgan buyruqlar
  final VoidCallback onNewFile;
  final VoidCallback onOpenFile;
  final VoidCallback onOpenFolder;
  final VoidCallback onSave;
  final VoidCallback onRun;
  final VoidCallback onInstallDeps;


  const TopMenuBar({
    super.key,
    required this.onNewFile,
    required this.onOpenFile,
    required this.onOpenFolder,
    required this.onSave,
    required this.onRun,
    required this.onInstallDeps,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // 1. FILE MENU
        _buildMenuButton(
            context,
            "File",
            [
              _menuItem("New File", Icons.note_add_outlined, onNewFile),
              _menuItem("Open File...", Icons.file_open_outlined, onOpenFile),
              _menuItem("Open Folder...", Icons.folder_open_outlined, onOpenFolder),
              const PopupMenuDivider(), // Chiziq
              _menuItem("Save", Icons.save_outlined, onSave),
              const PopupMenuDivider(),
              _menuItem("Exit", Icons.exit_to_app, () {}), // Hozircha bo'sh
            ]
        ),

        // 2. EDIT MENU (Hozircha shunchaki ko'rinish uchun)
        _buildMenuButton(
            context,
            "Edit",
            [
              _menuItem("Undo", Icons.undo, () {}),
              _menuItem("Redo", Icons.redo, () {}),
              const PopupMenuDivider(),
              _menuItem("Cut", Icons.content_cut, () {}),
              _menuItem("Copy", Icons.content_copy, () {}),
              _menuItem("Paste", Icons.content_paste, () {}),
            ]
        ),

        // 3. RUN MENU
        _buildMenuButton(
            context,
            "Run",
            [
              _menuItem("Run Python Code", Icons.play_arrow, onRun),
              _menuItem("Debug", Icons.bug_report, () {}),
            ]
        ),

        _buildMenuButton(
            context,
            "Help",
            [
              _menuItem("About Quantum IDE", Icons.info_outline, () {}),
            ]
        ),

        _buildMenuButton(
            context,
            "Tools",
            [
              _menuItem("Install Qiskit & Matplotlib", Icons.download, () {
                // Bu funksiyani MainLayout dan olib kelasiz
                onInstallDeps();
              }),
            ]
        ),
      ],
    );
  }

  // Menyu tugmasini yasovchi
  Widget _buildMenuButton(BuildContext context, String title, List<PopupMenuEntry> items) {
    return Theme(
      data: Theme.of(context).copyWith(
        popupMenuTheme: const PopupMenuThemeData(color: Color(0xFF252526)), // Menyu foni
      ),
      child: PopupMenuButton(
        offset: const Offset(0, 30), // Tugmadan sal pastroqda ochilsin
        itemBuilder: (context) => items,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(title, style: const TextStyle(fontSize: 13, color: Colors.white70)),
        ),
      ),
    );
  }

  // Menyu ichidagi har bir qator
  PopupMenuItem _menuItem(String title, IconData icon, VoidCallback onTap) {
    return PopupMenuItem(
      height: 35,
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 10),
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 13)),
        ],
      ),
    );
  }
}