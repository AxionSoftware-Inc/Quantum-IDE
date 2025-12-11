import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart'; // Clipboard uchun

class TerminalWidget extends StatefulWidget {
  const TerminalWidget({super.key});

  @override
  State<TerminalWidget> createState() => _TerminalWidgetState();
}

class _TerminalWidgetState extends State<TerminalWidget> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  // Terminal tarixi (Loglar)
  final List<TextSpan> _logs = [
    const TextSpan(text: "Quantum IDE Terminal v1.0\n", style: TextStyle(color: Colors.white54)),
    const TextSpan(text: "(c) 2025 Aether Systems. Yozing: 'pip install ...' yoki 'cls'\n\n", style: TextStyle(color: Colors.grey)),
  ];

  Process? _activeProcess; // Hozir ishlayotgan jarayon
  bool _isProcessing = false;

  // --- LOGIKA ---

  void _runCommand(String command) async {
    final cmd = command.trim();
    if (cmd.isEmpty) return;

    // 1. Tozalash komandasi (cls yoki clear)
    if (cmd == 'cls' || cmd == 'clear') {
      setState(() {
        _logs.clear();
        _logs.add(const TextSpan(text: "Terminal tozalandi.\n\n", style: TextStyle(color: Colors.grey)));
      });
      _controller.clear();
      // Fokusni qaytaramiz
      Future.delayed(Duration.zero, () => _focusNode.requestFocus());
      return;
    }

    setState(() {
      _logs.add(TextSpan(text: "C:\\User> $cmd\n", style: const TextStyle(color: Colors.yellowAccent)));
      _isProcessing = true;
    });
    _controller.clear();
    _scrollToBottom();

    try {
      // 2. Jarayonni boshlash
      // Windowsda 'cmd /c', Linux/Mac da 'bash -c' ishlatgan ma'qul, lekin 'run' da bu avtomatik
      // Bu yerda interactive emas, one-off command ishlatyapmiz
      _activeProcess = await Process.start('cmd', ['/c', cmd]);

      // Stdout (Oddiy natija)
      _activeProcess!.stdout.transform(utf8.decoder).listen((data) {
        if (mounted) {
          setState(() {
            _logs.add(TextSpan(text: data, style: const TextStyle(color: Colors.white70)));
          });
          _scrollToBottom();
        }
      });

      // Stderr (Xatoliklar)
      _activeProcess!.stderr.transform(utf8.decoder).listen((data) {
        if (mounted) {
          setState(() {
            _logs.add(TextSpan(text: data, style: const TextStyle(color: Colors.redAccent)));
          });
          _scrollToBottom();
        }
      });

      // Tugashini kutish
      await _activeProcess!.exitCode;

    } catch (e) {
      if (mounted) {
        setState(() {
          _logs.add(TextSpan(text: "Tizim xatosi: $e\n", style: const TextStyle(color: Colors.red)));
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _logs.add(const TextSpan(text: "\n"));
          _activeProcess = null;
        });
        _scrollToBottom();
        _focusNode.requestFocus();
      }
    }
  }

  void _stopProcess() {
    if (_activeProcess != null) {
      _activeProcess!.kill();
      setState(() {
        _logs.add(const TextSpan(text: "^C (To'xtatildi)\n", style: TextStyle(color: Colors.red)));
        _isProcessing = false;
      });
    }
  }

  void _clearTerminal() {
    setState(() {
      _logs.clear();
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 50), () {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1E1E1E),
      child: Column(
        children: [
          // 1. TOOLBAR (Qo'shimcha tugmalar)
          Container(
            height: 30,
            color: const Color(0xFF252526),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                const Text("CMD", style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
                const Spacer(),
                // STOP TUGMASI (Faqat jarayon ketayotganda chiqadi)
                if (_isProcessing)
                  IconButton(
                    icon: const Icon(Icons.stop_circle_outlined, size: 16, color: Colors.redAccent),
                    tooltip: "To'xtatish (Kill Process)",
                    padding: EdgeInsets.zero,
                    onPressed: _stopProcess,
                  ),
                const SizedBox(width: 10),
                // TOZALASH TUGMASI
                IconButton(
                  icon: const Icon(Icons.delete_sweep_outlined, size: 16, color: Colors.grey),
                  tooltip: "Tozalash (Clear)",
                  padding: EdgeInsets.zero,
                  onPressed: _clearTerminal,
                ),
              ],
            ),
          ),

          // 2. EKRAN (Output) - SelectionArea bilan o'ralgan (COPY ishlaydi)
          Expanded(
            child: SelectionArea( // <--- MUHIM: Bu nusxalashga ruxsat beradi
              child: GestureDetector(
                onTap: () {
                  // Bo'sh joy bosilganda fokus inputga o'tadi, lekin tanlash (selection) buzilmaydi
                  if (!_focusNode.hasFocus) _focusNode.requestFocus();
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  width: double.infinity,
                  color: const Color(0xFF1E1E1E), // Fon rangi
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: RichText(
                      text: TextSpan(
                        children: _logs,
                        style: GoogleFonts.robotoMono(fontSize: 13, height: 1.2),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 3. KIRITISH QATORI (Input)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: const BoxDecoration(
              color: Color(0xFF252526),
              border: Border(top: BorderSide(color: Colors.white10)),
            ),
            child: Row(
              children: [
                const Icon(Icons.chevron_right, color: Colors.greenAccent, size: 18),
                const SizedBox(width: 5),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    enabled: !_isProcessing,
                    style: GoogleFonts.robotoMono(color: Colors.white, fontSize: 13),
                    cursorColor: Colors.purpleAccent,

                    // Copy-Paste menyusini yoqish
                    enableInteractiveSelection: true,

                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "Buyruq...",
                      hintStyle: TextStyle(color: Colors.white24),
                      isDense: true,
                    ),
                    onSubmitted: _runCommand,
                  ),
                ),
                if (_isProcessing)
                  const SizedBox(
                    width: 15, height: 15,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.grey),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}