import 'dart:io';
import 'package:flutter/material.dart';

class SidePanel extends StatefulWidget {
  final int selectedIndex;
  final String? projectPath;
  final VoidCallback onOpenFolder;
  final Function(String) onFileClick;

  const SidePanel({
    super.key,
    required this.selectedIndex,
    required this.projectPath,
    required this.onOpenFolder,
    required this.onFileClick,
  });

  @override
  State<SidePanel> createState() => _SidePanelState();
}

class _SidePanelState extends State<SidePanel> {
  List<FileSystemEntity> _files = [];

  @override
  void didUpdateWidget(covariant SidePanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.projectPath != oldWidget.projectPath) {
      _loadFiles();
    }
  }

  void _loadFiles() {
    if (widget.projectPath == null) return;
    final dir = Directory(widget.projectPath!);
    if (dir.existsSync()) {
      setState(() {
        _files = dir.listSync()
          ..sort((a, b) => a.path.compareTo(b.path)); // Alifbo bo'yicha
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Agar Explorer tanlanmagan bo'lsa (boshqa tablar uchun)
    if (widget.selectedIndex != 0) {
      return Container(color: const Color(0xFF1E1E1E));
    }

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E), // Panel foni
        border: Border(
          right: BorderSide(color: Colors.white10, width: 1), // <--- MANA SHU CHEGARA AJRATIB TURADI
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. HEADER (Sarlavha - Bitta bo'lishi kerak)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            color: const Color(0xFF252526),
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("EXPLORER", style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
                if (widget.projectPath != null)
                  const Icon(Icons.more_horiz, size: 16, color: Colors.white30),
              ],
            ),
          ),

          // 2. FAYLLAR RO'YXATI
          Expanded(
            child: widget.projectPath == null
                ? Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.folder_open, size: 16),
                label: const Text("Open Folder"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                ),
                onPressed: widget.onOpenFolder,
              ),
            )
                : ListView.builder(
              itemCount: _files.length,
              // FAYLLAR ORASINI ZICH QILISH SIRI SHU YERDA:
              padding: EdgeInsets.zero,
              itemExtent: 28, // Har bir qator balandligi (juda ixcham)
              itemBuilder: (context, index) {
                final file = _files[index];
                final name = file.path.split(Platform.pathSeparator).last;
                final isFile = FileSystemEntity.isFileSync(file.path);

                return InkWell(
                  onTap: () {
                    if (isFile) widget.onFileClick(file.path);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      children: [
                        Icon(
                          isFile ? Icons.description_outlined : Icons.folder,
                          size: 16,
                          color: isFile ? Colors.lightBlueAccent : Colors.amber,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            name,
                            style: const TextStyle(color: Colors.white70, fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}