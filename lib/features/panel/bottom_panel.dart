import 'package:flutter/material.dart';
import '../terminal/terminal_widget.dart';

class BottomPanel extends StatelessWidget {
  final VoidCallback onClose;
  final List<String> terminalLogs;
  final VoidCallback onClearTerminal;
  final Function(String) onCommand;

  const BottomPanel({
    super.key,
    required this.onClose,
    required this.terminalLogs,
    required this.onClearTerminal,
    required this.onCommand,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Divider(height: 1, color: Colors.white10),
        // Sarlavha
        Container(
          height: 28,
          color: const Color(0xFF252526),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              const Text("TERMINAL", style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
              const Spacer(),
              InkWell(onTap: onClose, child: const Icon(Icons.close, size: 16, color: Colors.grey)),
            ],
          ),
        ),
        // Terminal
        Expanded(
          child: TerminalWidget(
            logs: terminalLogs,
            onClear: onClearTerminal,
            onCommandSubmitted: onCommand,
          ),
        ),
      ],
    );
  }
}