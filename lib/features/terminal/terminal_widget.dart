import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TerminalWidget extends StatefulWidget {
  final List<String> logs; // Tarix (Output + Input)
  final Function(String) onCommandSubmitted; // Buyruq yozilganda
  final VoidCallback onClear;

  const TerminalWidget({
    super.key,
    required this.logs,
    required this.onCommandSubmitted,
    required this.onClear,
  });

  @override
  State<TerminalWidget> createState() => _TerminalWidgetState();
}

class _TerminalWidgetState extends State<TerminalWidget> {
  final TextEditingController _cmdController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode(); // Avtomatik fokus uchun

  @override
  void didUpdateWidget(TerminalWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Yangi yozuv qo'shilganda pastga tushirish
    if (widget.logs.length != oldWidget.logs.length) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      });
    }
  }

  void _submit() {
    final text = _cmdController.text.trim();
    if (text.isNotEmpty) {
      widget.onCommandSubmitted(text); // MainLayoutga jo'natamiz
      _cmdController.clear();
      // Fokusni qaytaramiz (ketma-ket yozish uchun)
      Future.delayed(const Duration(milliseconds: 50), () {
        _focusNode.requestFocus();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E),
        border: Border(top: BorderSide(color: Colors.white10)),
      ),
      child: Column(
        children: [
          // SARLAVHA
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            color: const Color(0xFF252526),
            child: Row(
              children: [
                const Text("TERMINAL", style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
                const Spacer(),
                InkWell(onTap: widget.onClear, child: const Icon(Icons.block, size: 16, color: Colors.grey)),
              ],
            ),
          ),

          // TARIX (OUTPUTLAR)
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(10),
              itemCount: widget.logs.length,
              itemBuilder: (context, index) {
                return SelectableText(
                  widget.logs[index],
                  style: GoogleFonts.robotoMono(color: Colors.white70, fontSize: 13),
                );
              },
            ),
          ),

          // INPUT (Yozish joyi)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Colors.white10)),
            ),
            child: Row(
              children: [
                const Icon(Icons.chevron_right, color: Colors.greenAccent, size: 18),
                const SizedBox(width: 5),
                Expanded(
                  child: TextField(
                    controller: _cmdController,
                    focusNode: _focusNode,
                    style: GoogleFonts.robotoMono(color: Colors.white, fontSize: 14),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "Buyruq yozing (masalan: pip list)",
                      hintStyle: TextStyle(color: Colors.white24),
                      isDense: true,
                    ),
                    onSubmitted: (_) => _submit(), // Enter bosilganda
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}