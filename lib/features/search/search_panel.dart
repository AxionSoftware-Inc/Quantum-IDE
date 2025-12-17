import 'dart:io';
import 'package:flutter/material.dart';

class SearchPanel extends StatefulWidget {
  final String? projectPath;
  final Function(String path) onResultClick;

  const SearchPanel({
    super.key,
    required this.projectPath,
    required this.onResultClick,
  });

  @override
  State<SearchPanel> createState() => _SearchPanelState();
}

class _SearchPanelState extends State<SearchPanel> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> _results = [];
  bool _isSearching = false;

  void _performSearch(String query) async {
    if (widget.projectPath == null || query.isEmpty) return;

    setState(() {
      _isSearching = true;
      _results = [];
    });

    final dir = Directory(widget.projectPath!);
    if (!await dir.exists()) return;

    // Oddiy qidiruv algoritmi (Faqat matnli fayllar uchun)
    try {
      await for (final entity in dir.list(recursive: true, followLinks: false)) {
        if (entity is File) {
          try {
            // Binary fayllarni o'qimaslik uchun oddiy tekshiruv (yoki try-catch)
            if (entity.path.contains('.git') || entity.path.endsWith('.png')) continue;

            final lines = await entity.readAsLines();
            for (int i = 0; i < lines.length; i++) {
              if (lines[i].toLowerCase().contains(query.toLowerCase())) {
                setState(() {
                  _results.add({
                    'file': entity.path.split(Platform.pathSeparator).last,
                    'path': entity.path,
                    'line': i + 1,
                    'content': lines[i].trim(),
                  });
                });
              }
            }
          } catch (e) {
            // O'qib bo'lmaydigan fayllarni tashlab ketamiz
          }
        }
      }
    } catch (e) {
      print("Search Error: $e");
    } finally {
      setState(() => _isSearching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1E1E1E),
      decoration: const BoxDecoration(
        border: Border(right: BorderSide(color: Colors.white10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            color: const Color(0xFF252526),
            width: double.infinity,
            child: const Text("SEARCH", style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
          ),

          // INPUT
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _controller,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                hintText: "Search in files...",
                hintStyle: const TextStyle(color: Colors.white30),
                filled: true,
                fillColor: const Color(0xFF3C3C3C),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(0), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search, color: Colors.white70, size: 18),
                  onPressed: () => _performSearch(_controller.text),
                ),
              ),
              onSubmitted: _performSearch,
            ),
          ),

          // LOADING
          if (_isSearching)
            const LinearProgressIndicator(backgroundColor: Colors.transparent, color: Colors.blueAccent),

          // RESULTS
          Expanded(
            child: ListView.builder(
              itemCount: _results.length,
              itemBuilder: (context, index) {
                final item = _results[index];
                return InkWell(
                  onTap: () => widget.onResultClick(item['path']),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.insert_drive_file, size: 12, color: Colors.white30),
                            const SizedBox(width: 5),
                            Text(item['file'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                            const SizedBox(width: 5),
                            Text(":${item['line']}", style: const TextStyle(color: Colors.greenAccent, fontSize: 11)),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 18.0),
                          child: Text(
                            item['content'],
                            style: const TextStyle(color: Colors.white54, fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Divider(color: Colors.white10, height: 8),
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