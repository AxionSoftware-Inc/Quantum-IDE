import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../terminal/terminal_widget.dart';

class BottomPanel extends StatefulWidget {
  final VoidCallback onClose;
  final List<String> terminalLogs; // Output loglari
  final VoidCallback onClearTerminal; // Outputni tozalash
  // onCommand endi kerak emas, chunki Terminal mustaqil ishlaydi

  const BottomPanel({
    super.key,
    required this.onClose,
    required this.terminalLogs,
    required this.onClearTerminal,
    required Function(String) onCommand, // Eski kod buzilmasligi uchun qoldiramiz
  });

  @override
  State<BottomPanel> createState() => _BottomPanelState();
}

class _BottomPanelState extends State<BottomPanel> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _logScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this); // Output, Terminal, Problems
  }

  // Loglar yangilansa pastga tushamiz
  @override
  void didUpdateWidget(BottomPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.terminalLogs.length != oldWidget.terminalLogs.length) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_logScrollController.hasClients) {
          _logScrollController.jumpTo(_logScrollController.position.maxScrollExtent);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Divider(height: 1, color: Colors.white10),

        // --- 1. TAB HEADER (VS Code Style) ---
        Container(
          height: 35,
          color: const Color(0xFF252526),
          child: Row(
            children: [
              // Tablar
              Expanded(
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  indicatorColor: Colors.purpleAccent,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.grey,
                  labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  tabs: const [
                    Tab(text: "OUTPUT"),   // Bizning Python Natijalarimiz
                    Tab(text: "TERMINAL"), // Haqiqiy CMD
                    Tab(text: "PROBLEMS"), // Kelajak uchun
                  ],
                ),
              ),

              // Tozalash tugmasi (Faqat Output uchun)
              IconButton(
                icon: const Icon(Icons.block, size: 16, color: Colors.grey),
                tooltip: "Clear Output",
                onPressed: widget.onClearTerminal,
              ),
              // Yopish tugmasi
              IconButton(
                icon: const Icon(Icons.close, size: 16, color: Colors.grey),
                tooltip: "Close Panel",
                onPressed: widget.onClose,
              ),
            ],
          ),
        ),

        // --- 2. TAB CONTENT ---
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // 1-TAB: OUTPUT (Python loglari)
              Container(
                color: const Color(0xFF1E1E1E),
                child: ListView.builder(
                  controller: _logScrollController,
                  padding: const EdgeInsets.all(8),
                  itemCount: widget.terminalLogs.length,
                  itemBuilder: (context, index) {
                    return SelectableText(
                      widget.terminalLogs[index],
                      style: GoogleFonts.robotoMono(color: Colors.white70, fontSize: 13),
                    );
                  },
                ),
              ),

              // 2-TAB: TERMINAL (Real xterm)
              const TerminalWidget(),

              // 3-TAB: PROBLEMS (Hozircha bo'sh)
              const Center(child: Text("No problems detected", style: TextStyle(color: Colors.grey))),
            ],
          ),
        ),
      ],
    );
  }
}