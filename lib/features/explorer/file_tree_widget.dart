import 'dart:io';
import 'package:flutter/material.dart';

class FileTreeWidget extends StatelessWidget {
  final String rootPath;
  final Function(String path) onFileClick;

  const FileTreeWidget({
    super.key,
    required this.rootPath,
    required this.onFileClick
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF252526),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(10),
            child: Text("EXPLORER", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          ),
          Expanded(
            // Boshlang'ich nuqtadan boshlab daraxtni quramiz
            child: SingleChildScrollView(
              child: _buildNode(Directory(rootPath)),
            ),
          ),
        ],
      ),
    );
  }

  // 🔥 REKURSIV FUNKSIYA: Papka ichini ochib beradi
  Widget _buildNode(FileSystemEntity entity) {
    final name = entity.path.split(Platform.pathSeparator).last;

    // Yashirin fayllarni (.git, .idea) ko'rsatmaymiz
    if (name.startsWith('.')) return const SizedBox.shrink();

    // 1. Agar PAPKA bo'lsa -> ExpansionTile (Ochiladigan quti)
    if (entity is Directory) {
      List<FileSystemEntity> children = [];
      try {
        children = entity.listSync()
          ..sort((a, b) => a.path.compareTo(b.path)); // Tartiblaymiz
      } catch (e) {
        // Ruxsat yo'q papkalar bo'lsa, indamaymiz
      }

      return Theme(
        data: ThemeData.dark().copyWith(dividerColor: Colors.transparent), // Chiziqlarni yo'qotish
        child: ExpansionTile(
          leading: const Icon(Icons.folder, color: Colors.amber, size: 16),
          title: Text(name, style: const TextStyle(color: Colors.white70, fontSize: 13)),
          childrenPadding: const EdgeInsets.only(left: 15), // Ichkariga surish (Indent)
          children: children.map((child) => _buildNode(child)).toList(), // <--- O'ZINI QAYTA CHAQUERYAPTI
        ),
      );
    }

    // 2. Agar FAYL bo'lsa -> ListTile (Bosiladigan yozuv)
    if (entity is File) {
      // Faqat bizga kerakli fayllarni ko'rsatamiz
      if (!name.endsWith('.py') && !name.endsWith('.txt') && !name.endsWith('.md')) {
        return const SizedBox.shrink();
      }

      return ListTile(
        leading: const Icon(Icons.description_outlined, color: Colors.blueAccent, size: 16),
        title: Text(name, style: const TextStyle(color: Colors.white60, fontSize: 13)),
        dense: true,
        visualDensity: VisualDensity.compact,
        contentPadding: const EdgeInsets.symmetric(horizontal: 5),
        onTap: () => onFileClick(entity.path),
      );
    }

    return const SizedBox.shrink();
  }
}