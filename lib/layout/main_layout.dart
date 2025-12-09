import 'dart:io';
import 'package:flutter/material.dart';
import 'package:code_text_field/code_text_field.dart';
import 'package:flutter/services.dart';
import 'package:highlight/languages/python.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';
import 'package:google_fonts/google_fonts.dart';
import '../features/editor/tab_bar_widget.dart';

// Importlar (Fayllaringiz joyida turibdi deb hisoblaymiz)
import '../features/activity_bar/activity_bar.dart';
import '../features/explorer/side_panel.dart';
import '../features/menu/top_menu_bar.dart';
import '../features/terminal/terminal_widget.dart';
import '../core/file_service.dart';
import '../core/python_service.dart';

import 'dart:convert'; // JSON uchun
import '../features/visualizer/visualizer_widget.dart'; // Yangi vidjet

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  // --- UI HOLATI (STATE) ---
  int _selectedSidebarIndex = 0;
  bool _isSidePanelVisible = true; // Panel ochiqmi yoki yopiq?
  String? _currentProjectPath;
  String? _activeFilePath;

  // --- TERMINAL HOLATI ---
  List<String> _terminalLogs = ["Quantum IDE v1.0 Ready."];
  List<String> _openFiles = [];
  int _activeTabIndex = -1;

  Map<String, dynamic> _chartData = {}; // Grafik uchun ma'lumot
  int _bottomTabIndex = 0; // 0=Terminal, 1=Visualizer

  // --- EDITOR HOLATI ---
  final CodeController _codeController = CodeController(
    text: '# Kvant loyihangizni shu yerda boshlang\nprint("Hello Quantum")',
    language: python,
  );

  bool _isLoading = false;

  // ------------------------------------------
  // 1. SIDEBAR LOGIKASI (VS Code Style)
  // ------------------------------------------
  void _onSidebarTap(int index) {
    setState(() {
      if (_selectedSidebarIndex == index) {
        // Agar o'sha tugma qayta bosilsa -> OCHISH/YOPISH
        _isSidePanelVisible = !_isSidePanelVisible;
      } else {
        // Boshqa tugma bosilsa -> O'tish va Ochish
        _selectedSidebarIndex = index;
        _isSidePanelVisible = true;
      }
    });
  }

  // ------------------------------------------
  // 2. FAYL TIZIMI LOGIKASI
  // ------------------------------------------
  void _openFolder() async {
    final path = await FileService.pickDirectory();
    if (path != null) {
      setState(() {
        _currentProjectPath = path;
        _selectedSidebarIndex = 0; // Fayllar bo'limiga o'tish
        _isSidePanelVisible = true; // Panelni ochish
        _addLog("Papka ochildi: $path");
      });
    }
  }

  void _openFileFromTree(String path) async {
    // 1. Fayl allaqachon ochiqmi?
    int existingIndex = _openFiles.indexOf(path);

    if (existingIndex != -1) {
      // Ha, ochiq ekan. O'sha tabga o'tamiz.
      _switchToTab(existingIndex);
    } else {
      // Yo'q, yangi ochamiz.
      setState(() {
        _openFiles.add(path);
        _activeTabIndex = _openFiles.length - 1; // Oxirgisiga o'tamiz
      });
      // Fayl mazmunini yuklaymiz
      _loadFileContent(path);
    }
  }

  // Yordamchi: Tabga o'tish va kodni yuklash
  void _switchToTab(int index) {
    setState(() {
      _activeTabIndex = index;
    });
    _loadFileContent(_openFiles[index]);
  }

  // Yordamchi: Diskdan o'qish
  void _loadFileContent(String path) async {
    File file = File(path);
    if (await file.exists()) {
      String content = await file.readAsString();
      setState(() {
        _codeController.text = content;
        // Fayl nomini tabda ko'rsatish uchun hech narsa qilish shart emas, _openFiles da bor
      });
    }
  }

  // YANGI: Tabni yopish
  void _closeTab(int index) {
    setState(() {
      _openFiles.removeAt(index);

      // Agar hamma tab yopilsa
      if (_openFiles.isEmpty) {
        _activeTabIndex = -1;
        _codeController.text = ""; // Editorni tozala
        return;
      }

      // Agar yopilgan tab aktiv bo'lsa yoki undan oldinda bo'lsa
      if (index <= _activeTabIndex) {
        // Aktiv tabni bitta orqaga suramiz (yoki 0 da qoldiramiz)
        _activeTabIndex = (_activeTabIndex - 1).clamp(0, _openFiles.length - 1);
        // Yangi aktiv faylni yuklaymiz
        _loadFileContent(_openFiles[_activeTabIndex]);
      }
    });
  }

  // ------------------------------------------
  // 3. RUN & TERMINAL LOGIKASI
  // ------------------------------------------
  void _addLog(String text) {
    if (text.trim().isEmpty) return;
    setState(() => _terminalLogs.add(text));
  }

  void _newFile() {
    setState(() {
      _codeController.text = ""; // Tozalash
      _activeFilePath = null; // Fayl yo'q
      _addLog("Yangi fayl yaratildi.");
    });
  }

  // Fayl ochish funksiyasi (Oldin yozgan edik, yana tekshirib oling)
  void _openFile() async {
    try {
      final result = await FileService.openFile();
      if (result != null) {
        setState(() {
          _codeController.text = result['content']!;
          _activeFilePath = result['path'];
          _addLog("Fayl ochildi: ${result['name']}");
        });
      }
    } catch (e) {
      _addLog("Xatolik: $e");
    }
  }

  // Save funksiyasi (Buni ham eslab qolaylik)
  void _saveFile() async {
    try {
      if (_activeFilePath == null) {
        final path = await FileService.saveFileAs(_codeController.text);
        if (path != null) {
          setState(() {
            _activeFilePath = path;
            _addLog("Saqlandi: $path");
          });
        }
      } else {
        await FileService.saveFile(_codeController.text, _activeFilePath!);
        _addLog("Fayl yangilandi!");
      }
    } catch (e) {
      _addLog("Saqlashda xato: $e");
    }
  }

  void _runCode() async {
    setState(() {
      _isLoading = true;
      _chartData = {}; // Eski grafikni tozalaymiz
    });

    _addLog("\n--- Run ---");

    try {
      final tempFile = await FileService.saveCode(_codeController.text, 'temp_run.py');
      final result = await PythonService.runScript(tempFile);

      if (result.error.isNotEmpty) {
        _addLog("Error: ${result.error}");
      }

      if (result.output.isNotEmpty) {
        // PARSING LOGIKASI:
        if (result.output.contains("__DATA__: ")) {
          // 1. JSON qismini ajratib olamiz
          final parts = result.output.split("__DATA__: ");
          final logPart = parts[0]; // Oddiy matn
          final jsonPart = parts[1].trim(); // JSON

          if (logPart.isNotEmpty) _addLog(logPart);

          try {
            // 2. JSON ni Map ga aylantiramiz
            final data = jsonDecode(jsonPart);
            setState(() {
              _chartData = data;
              _bottomTabIndex = 1; // Avtomatik Grafik tabiga o'tamiz!
            });
            _addLog("📊 Vizualizatsiya ma'lumotlari yuklandi.");
          } catch (e) {
            _addLog("JSON Xatosi: $e");
          }
        } else {
          // Oddiy matn bo'lsa
          _addLog(result.output);
        }
      }

    } catch (e) {
      _addLog("System Error: $e");
    } finally {
      setState(() => _isLoading = false);
      _addLog("----------------");
    }
  }

  void _runTerminalCommand(String command) async {
    _addLog("> $command");
    if (command.trim() == 'cls' || command.trim() == 'clear') {
      setState(() => _terminalLogs.clear());
      return;
    }
    final result = await PythonService.runCommand(command);
    if (result.output.isNotEmpty) _addLog(result.output);
    if (result.error.isNotEmpty) _addLog(result.error);
  }

  // ------------------------------------------
  // BUILD (LAYOUT)
  // ------------------------------------------
  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        // Ctrl + S (Macda Cmd + S) -> Saqlash
        const SingleActivator(LogicalKeyboardKey.keyS, control: true): _saveFile,
        const SingleActivator(LogicalKeyboardKey.keyS, meta: true): _saveFile, // Mac uchun

        // F5 -> Run
        const SingleActivator(LogicalKeyboardKey.f5): _runCode,

        // Ctrl + Enter -> Run (Qo'shimcha qulaylik)
        const SingleActivator(LogicalKeyboardKey.enter, control: true): _runCode,
        const SingleActivator(LogicalKeyboardKey.enter, meta: true): _runCode,
      },
      child: Scaffold(
        // TEPADAGI MENU VA RUN TUGMASI
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFF1E1E1E), // Asosiy fon
              border: Border(bottom: BorderSide(color: Colors.white10)), // Ingichka chiziq
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                // 1. Kichik Logo va Nom (BRANDING)
                const Icon(Icons.code, color: Colors.purpleAccent, size: 18),
                const SizedBox(width: 8),
                const Text("Quantum IDE", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white)),
      
                const SizedBox(width: 20), // Ajratuvchi
                Container(width: 1, height: 20, color: Colors.white10), // Vertikal chiziq
                const SizedBox(width: 10),
      
                // 2. MENU (File, Edit...)
                TopMenuBar(
                  onNewFile: _newFile,
                  onOpenFile: _openFile,
                  onOpenFolder: _openFolder,
                  onSave: _saveFile,
                  onRun: _runCode,
                ),
      
      
      
                const Spacer(),
      
                // 3. FAYL NOMI (Markazda)
                if (_activeFilePath != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _activeFilePath!.split(Platform.pathSeparator).last,
                      style: const TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                  ),
      
                const Spacer(),
      
      
      
                // 4. RUN TUGMASI (Yana ham chiroyli)
                IconButton(
                  icon: _isLoading
                      ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.greenAccent))
                      : const Icon(Icons.play_circle_fill, color: Colors.greenAccent, size: 28), // Dumaloq yashil tugma
                  onPressed: _isLoading ? null : _runCode,
                  tooltip: "Run (F5)",
                ),
              ],
            ),
          ),
        ),
      
        body: Row(
          children: [
            // 1. ACTIVITY BAR (Doim ko'rinadi)
            ActivityBar(
              selectedIndex: _selectedSidebarIndex,
              onIndexChanged: _onSidebarTap,
            ),
      
            // 2. SIDE PANEL (Ochiladigan/Yopiladigan)
            if (_isSidePanelVisible)
              Container(
                width: 250, // Qat'iy o'lcham
                decoration: const BoxDecoration(
                  border: Border(
                    right: BorderSide(color: Colors.white10),
                  ), // O'ng chiziq
                ),
                child: SidePanel(
                  selectedIndex: _selectedSidebarIndex,
                  projectPath: _currentProjectPath,
                  onOpenFolder: _openFolder,
                  onFileClick: _openFileFromTree,
                ),
              ),
      
            // 3. EDITOR VA TERMINAL (Qolgan joy)
            Expanded(
              child: Column(
                children: [
                  if (_openFiles.isNotEmpty)
                    TabBarWidget(
                      openFiles: _openFiles,
                      activeIndex: _activeTabIndex,
                      onTabSwitch: _switchToTab,
                      onTabClose: _closeTab,
                    )
                  else
      
                  // Agar tablar yo'q bo'lsa, shunchaki bo'sh joy yoki sarlavha
                    Container(
                      width: double.infinity,
                      color: const Color(0xFF1E1E1E),
                      padding: const EdgeInsets.all(8),
                      child: const Text("Fayl ochish uchun Explorer dan tanlang", style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ),
                  // A. KOD EDITOR
                  Expanded(
                    flex: 3,
                    child: CodeTheme(
                      data: CodeThemeData(styles: monokaiSublimeTheme),
                      child: CodeField(
                        controller: _codeController,
                        // Agar tablar yo'q bo'lsa, yozib bo'lmasin (readOnly)
                        readOnly: _activeTabIndex == -1,
                        textStyle: GoogleFonts.getFont('JetBrains Mono', fontSize: 15),
                        expands: true,
                      ),
                    ),
                  ),
      
                  const Divider(height: 1, color: Colors.white10),
      
                  // C. TERMINAL (Pastki qism)
                  SizedBox(
                    height: 220, // Balandligi fiks
                    child: TerminalWidget(
                      logs: _terminalLogs,
                      onClear: () => setState(() => _terminalLogs.clear()),
                      onCommandSubmitted: _runTerminalCommand,
                    ),
                  ),
                ],
              ),
            ),

            // ... Editor tugadi ...
            const Divider(height: 1, color: Colors.white10),

            // --- PASTKI PANELLAR (Terminal & Visualizer) ---
            Expanded(
              flex: 2, // Editordan kichikroq joy
              child: DefaultTabController(
                length: 2,
                initialIndex: _bottomTabIndex, // Avtomatik o'tish uchun
                child: Column(
                  children: [
                    // Tab Sarlavhalari
                    Container(
                      color: const Color(0xFF252526),
                      height: 35,
                      child: const TabBar(
                        isScrollable: true,
                        indicatorColor: Colors.purpleAccent,
                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.grey,
                        labelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        tabs: [
                          Tab(text: "TERMINAL"),
                          Tab(text: "VISUALIZER"),
                        ],
                      ),
                    ),

                    // Tab Ichlari
                    Expanded(
                      child: TabBarView(
                        children: [
                          // 1. TERMINAL
                          TerminalWidget(
                            logs: _terminalLogs,
                            onClear: () => setState(() => _terminalLogs.clear()),
                            onCommandSubmitted: _runTerminalCommand,
                          ),

                          // 2. VISUALIZER (Grafik)
                          VisualizerWidget(data: _chartData),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),


          ],
        ),
      ),
    );
  }
}
