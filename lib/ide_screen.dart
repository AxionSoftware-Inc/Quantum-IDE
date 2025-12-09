import 'dart:io';
import 'package:code_text_field/code_text_field.dart';
import 'package:flutter/material.dart';
import 'package:code_text_field/code_text_field.dart';
import 'package:highlight/languages/python.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quantum_ide/core/file_service.dart';
import 'package:quantum_ide/core/python_service.dart';

class IdeScreen extends StatefulWidget {
  const IdeScreen({super.key});

  @override
  State<IdeScreen> createState() => _IdeScreenState();
}

class _IdeScreenState extends State<IdeScreen> {
  CodeController? _codeController;
  String _output = "Terminal tayyor.\nKod yozing va 'Run' tugmasini bosing.";
  String? _currentFilePath;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _codeController = CodeController(
      text: 'print("Salom, Quantum!")\nprint(100 * 5)',
      language: python,
    );
  }

  // --- 1. OCHISH ---
  Future<void> openFile() async {
    try {
      final result = await FileService.openFile();
      if (result != null) {
        setState(() {
          _codeController!.text = result['content']!;
          _currentFilePath = result['path'];
          _output = "Fayl yuklandi: ${result['name']}";
        });
      }
    } catch (e) {
      setState(() => _output = "Fayl ochishda xato: $e");
    }
  }

  // --- 2. SAQLASH ---
  Future<void> saveFile() async {
    try {
      if (_currentFilePath == null) {
        final path = await FileService.saveFileAs(_codeController!.text);
        if (path != null) {
          setState(() {
            _currentFilePath = path;
            _output = "Yangi fayl saqlandi: $path";
          });
        }
      } else {
        await FileService.saveFile(_codeController!.text, _currentFilePath!);
        setState(() => _output = "Fayl yangilandi!");
      }
    } catch (e) {
      setState(() => _output = "Saqlashda xato: $e");
    }
  }

  // --- 3. YURGIZISH (RUN) ---
  Future<void> runPythonCode() async {
    setState(() {
      _isLoading = true;
      _output = "Kompilyatsiya ketmoqda...";
    });

    try {
      // 1. Kodni vaqtincha faylga yozamiz (Core papkasidagi funksiya)
      final tempFile = await FileService.saveCode(_codeController!.text, 'temp_script.py');

      // 2. Pythonni ishga tushiramiz
      final result = await PythonService.runScript(tempFile);

      setState(() {
        _output = result.isEmpty ? "[Dastur ishlamadi yoki hech narsa chop etmadi]" : result;
      });

    } catch (e) {
      setState(() => _output = "Kritik Xato: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --- TEPA QISM (APPBAR) ---
      appBar: AppBar(
        title: Text(
          _currentFilePath ?? "Nomsiz Loyiha",
          style: GoogleFonts.robotoMono(fontSize: 14),
        ),
        backgroundColor: const Color(0xFF252526),
        elevation: 0,
        actions: [
          _buildActionButton(Icons.folder_open, "Ochish", openFile),
          _buildActionButton(Icons.save, "Saqlash", saveFile),
          const SizedBox(width: 20),
          // RUN TUGMASI
          Container(
            margin: const EdgeInsets.only(right: 10),
            child: IconButton(
              icon: _isLoading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.play_arrow, color: Colors.greenAccent, size: 32),
              onPressed: _isLoading ? null : runPythonCode,
              tooltip: "Ishga tushirish (Run)",
            ),
          ),
        ],
      ),

      // --- ASOSIY QISM (BODY) ---
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch, // Hamma ustunlar to'liq balandlikda bo'ladi
        children: [

          // 1. CHAP: FAYLLAR (Qizil chegara yo'q, chiroyli kulrang)
          Container(
            width: 250, // Qat'iy o'lcham (uchib ketmasligi uchun)
            color: const Color(0xFF1E1E1E),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  width: double.infinity,
                  color: const Color(0xFF252526),
                  child: const Text("LOYIHA FAYLLARI", style: TextStyle(color: Colors.grey, fontSize: 12)),
                ),
                const Expanded(
                  child: Center(child: Text("Fayllar ro'yxati\n(Tez orada...)", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey))),
                ),
              ],
            ),
          ),

          // 2. O'RTA: KOD EDITOR
          Expanded(
            flex: 2, // Ekranning katta qismini egallaydi
            child: CodeTheme(
              data: CodeThemeData(styles: monokaiSublimeTheme),
              child: CodeField(
                controller: _codeController!,
                textStyle: GoogleFonts.getFont('JetBrains Mono', fontSize: 16),
                expands: true, // Editor butun bo'sh joyni egallaydi
                wrap: false,
              ),
            ),
          ),

          // 3. O'NG: TERMINAL
          Container(
            width: 300, // Qat'iy o'lcham
            color: const Color(0xFF1E1E1E),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Terminal sarlavhasi
                Container(
                  padding: const EdgeInsets.all(10),
                  color: const Color(0xFF252526),
                  child: const Text("TERMINAL / NATIJA", style: TextStyle(color: Colors.grey, fontSize: 12)),
                ),
                // Natija matni
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    color: Colors.black, // Terminal qora bo'lishi kerak
                    child: SingleChildScrollView(
                      child: SelectableText( // Matnni nusxalab olish uchun
                        _output,
                        style: GoogleFonts.robotoMono(color: Colors.white70, fontSize: 14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Kichik yordamchi vidjet (Tugmalar uchun)
  Widget _buildActionButton(IconData icon, String tooltip, VoidCallback onPressed) {
    return IconButton(
      icon: Icon(icon, color: Colors.white70),
      tooltip: tooltip,
      onPressed: _isLoading ? null : onPressed,
    );
  }
}