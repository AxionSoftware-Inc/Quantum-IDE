import 'package:flutter/material.dart';

class TopMenuBar extends StatelessWidget {
  final VoidCallback onNewFile;
  final VoidCallback onOpenFile;
  final VoidCallback onOpenFolder;
  final VoidCallback onSave;
  final VoidCallback onRun;
  final VoidCallback onInstallDeps; // <--- BU YETISHMAYOTGAN EDI

  const TopMenuBar({
    super.key,
    required this.onNewFile,
    required this.onOpenFile,
    required this.onOpenFolder,
    required this.onSave,
    required this.onRun,
    required this.onInstallDeps, // <--- QO'SHDIK
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildMenuButton(context, "File", [
          _menuItem("New File", Icons.note_add_outlined, onNewFile),
          _menuItem("Open File...", Icons.file_open_outlined, onOpenFile),
          _menuItem("Open Folder...", Icons.folder_open_outlined, onOpenFolder),
          const PopupMenuDivider(),
          _menuItem("Save", Icons.save_outlined, onSave),
          const PopupMenuDivider(),
          _menuItem("Exit", Icons.exit_to_app, () {}),
        ]),
        _buildMenuButton(context, "Edit", [
          _menuItem("Undo", Icons.undo, () {}),
          _menuItem("Redo", Icons.redo, () {}),
        ]),
        _buildMenuButton(context, "Run", [
          _menuItem("Run Python Code", Icons.play_arrow, onRun),
        ]),
        _buildMenuButton(context, "Tools", [
          _menuItem("Install Libraries", Icons.download, onInstallDeps), // <--- ISHLATDIK
        ]),
        _buildMenuButton(context, "Help", [
          _menuItem("About", Icons.info_outline, () {}),
        ]),
      ],
    );
  }

  Widget _buildMenuButton(BuildContext context, String title, List<PopupMenuEntry> items) {
    return Theme(
      data: Theme.of(context).copyWith(
        popupMenuTheme: const PopupMenuThemeData(color: Color(0xFF252526)),
      ),
      child: PopupMenuButton(
        offset: const Offset(0, 30),
        itemBuilder: (context) => items,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(title, style: const TextStyle(fontSize: 13, color: Colors.white70)),
        ),
      ),
    );
  }

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