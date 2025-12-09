import 'package:flutter/material.dart';
import 'file_tree_widget.dart'; // Fayl daraxtini shu yerga chaqiramiz

class SidePanel extends StatelessWidget {
  final int selectedIndex;
  final String? projectPath;
  final VoidCallback onOpenFolder; // Papka ochish tugmasi uchun
  final Function(String) onFileClick;

  const SidePanel({
    super.key,
    required this.selectedIndex,
    this.projectPath,
    required this.onOpenFolder,
    required this.onFileClick,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250, // Qat'iy o'lcham
      color: const Color(0xFF252526),
      child: Column(
        children: [
          // Sarlavha (EXPLORER, SEARCH...)
          Container(
            height: 35,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            alignment: Alignment.centerLeft,
            color: const Color(0xFF1E1E1E), // Biroz to'qroq
            child: Text(
                _getTitle(selectedIndex),
                style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)
            ),
          ),

          // O'zgaruvchan qism
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  String _getTitle(int index) {
    switch (index) {
      case 0: return "EXPLORER";
      case 1: return "SEARCH";
      case 2: return "QUANTUM DEVICES";
      case 3: return "SETTINGS";
      default: return "";
    }
  }

  Widget _buildContent() {
    // 0-TAB: Fayllar
    if (selectedIndex == 0) {
      if (projectPath == null) {
        // Agar papka tanlanmagan bo'lsa -> Tugma ko'rsatamiz
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Loyiha ochilmagan", style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: onOpenFolder,
                child: const Text("Papka Ochish"),
              )
            ],
          ),
        );
      }
      // Agar papka bor bo'lsa -> Daraxtni ko'rsatamiz
      return FileTreeWidget(
          rootPath: projectPath!,
          onFileClick: onFileClick
      );
    }

    // 1-TAB: Qidiruv (Hozircha bo'sh)
    if (selectedIndex == 1) {
      return const Center(child: Text("Qidiruv tez orada...", style: TextStyle(color: Colors.grey)));
    }

    // Boshqalar
    return const Center(child: Text("Bo'lim topilmadi", style: TextStyle(color: Colors.grey)));
  }
}