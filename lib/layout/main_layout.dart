import 'dart:io';
import 'package:flutter/material.dart';
import 'package:code_text_field/code_text_field.dart';
import 'package:flutter/services.dart';
import 'package:highlight/languages/python.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';

// Importlar
import '../core/output_parser.dart';
import '../features/activity_bar/activity_bar.dart';
import '../features/editor/empty_state_widget.dart';
import '../features/explorer/side_panel.dart';
import '../features/menu/top_menu_bar.dart';
import '../features/editor/tab_bar_widget.dart';
import '../features/panel/bottom_panel.dart';
import '../features/panel/right_panel.dart'; // <--- YANGI IMPORT
import '../core/file_service.dart';
import '../core/python_service.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  // --- UI STATE ---
  int _selectedSidebarIndex = 0;
  bool _isSidePanelVisible = true;
  bool _isBottomPanelVisible = true;
  bool _isRightPanelVisible = false; // <--- YANGI: O'ng panel holati

  String? _currentProjectPath;
  String? _activeFilePath;

  List<String> _terminalLogs = ["Quantum IDE v1.0 Ready."];
  List<String> _openFiles = [];
  int _activeTabIndex = -1;
  Map<String, dynamic> _chartData = {};
  bool _isLoading = false;

  final CodeController _codeController = CodeController(
    text: '# Start Quantum Coding\nprint("Hello")',
    language: python,
  );

  void _installDependencies() async {
    _addLog("--- Kutubxonalar o'rnatilmoqda (Internet kerak)... ---");
    _isBottomPanelVisible = true; // Terminalni ochamiz

    // Asxron tarzda ishlaydi
    await PythonService.runCommand("pip install qiskit matplotlib qiskit-aer pylatexenc");

    _addLog("--- O'rnatish tugadi. ---");
  }

  // --- LOGIKA ---
  void _onSidebarTap(int index) {
    setState(() {
      if (_selectedSidebarIndex == index) {
        _isSidePanelVisible = !_isSidePanelVisible;
      } else {
        _selectedSidebarIndex = index;
        _isSidePanelVisible = true;
      }
    });
  }

  void _openFolder() async {
    final path = await FileService.pickDirectory();
    if (path != null) {
      setState(() {
        _currentProjectPath = path;
        _selectedSidebarIndex = 0;
        _isSidePanelVisible = true;
        _addLog("Papka: $path");
      });
    }
  }

  void _openFileFromTree(String path) async {
    int existingIndex = _openFiles.indexOf(path);
    if (existingIndex != -1) {
      _switchToTab(existingIndex);
    } else {
      setState(() {
        _openFiles.add(path);
        _activeTabIndex = _openFiles.length - 1;
      });
      _loadFileContent(path);
    }
  }

  void _switchToTab(int index) {
    setState(() => _activeTabIndex = index);
    _loadFileContent(_openFiles[index]);
  }

  void _loadFileContent(String path) async {
    if (path.startsWith("Untitled-")) return;
    File file = File(path);
    if (await file.exists()) {
      String content = await file.readAsString();
      setState(() {
        _codeController.text = content;
        _activeFilePath = path;
      });
    }
  }

  void _closeTab(int index) {
    setState(() {
      _openFiles.removeAt(index);
      if (_openFiles.isEmpty) {
        _activeTabIndex = -1;
        _codeController.text = "";
        return;
      }
      if (index <= _activeTabIndex) {
        _activeTabIndex = (_activeTabIndex - 1).clamp(0, _openFiles.length - 1);
        _loadFileContent(_openFiles[_activeTabIndex]);
      }
    });
  }

  void _addLog(String text) {
    if (text.trim().isEmpty) return;
    setState(() => _terminalLogs.add(text));
  }

  void _newFile() {
    setState(() {
      String newFileName = "Untitled-${_openFiles.length + 1}";
      _openFiles.add(newFileName);
      _activeTabIndex = _openFiles.length - 1;
      _codeController.text = "";
      _activeFilePath = null;
      _addLog("Yangi fayl yaratildi.");
    });
  }

  void _saveFile() async {
    try {
      if (_activeFilePath == null || _activeFilePath!.startsWith("Untitled-")) {
        final path = await FileService.saveFileAs(_codeController.text);
        if (path != null) {
          setState(() {
            _activeFilePath = path;
            _openFiles[_activeTabIndex] = path;
            _addLog("Saqlandi: $path");
          });
        }
      } else {
        await FileService.saveFile(_codeController.text, _activeFilePath!);
        _addLog("Yangilandi!");
      }
    } catch (e) {
      _addLog("Saqlashda xato: $e");
    }
  }

  // --- RUN LOGIKASI (O'ZGARTIRILDI) ---
  void _runCode() async {
    setState(() {
      _isBottomPanelVisible = true;
      _isLoading = true;
      _chartData = {}; // Eskisini tozalaymiz
    });

    _addLog("\n--- Running ---");

    try {
      final tempFile = await FileService.saveCode(_codeController.text, 'temp_run.py');
      final result = await PythonService.runScript(tempFile);

      // Xatolik bo'lsa chiqaramiz
      if (result.error.isNotEmpty) {
        _addLog("Error: ${result.error}");
      }

      if (result.output.isNotEmpty) {
        // --- YANGI: PARSERNI ISHLATAMIZ ---
        final parsed = OutputParser.parse(result.output);

        // 1. Oddiy loglarni terminalga chiqaramiz
        if (parsed.logOutput.isNotEmpty) {
          _addLog(parsed.logOutput);
        }

        // 2. Vizualizatsiya ma'lumoti bormi?
        if (parsed.visualizationData != null) {
          setState(() {
            _chartData = parsed.visualizationData!;
            _isRightPanelVisible = true; // O'ng panelni ochamiz
          });
          _addLog("📊 Vizualizatsiya yangilandi.");
        }
      }

    } catch (e) {
      _addLog("System Error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _runTerminalCommand(String command) async {
    _addLog("> $command");
    if (command == 'cls' || command == 'clear') {
      setState(() => _terminalLogs.clear());
      return;
    }
    final result = await PythonService.runCommand(command);
    if (result.output.isNotEmpty) _addLog(result.output);
    if (result.error.isNotEmpty) _addLog(result.error);
  }

  // --- UI BUILD (3 USTUN) ---
  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyS, control: true): _saveFile,
        const SingleActivator(LogicalKeyboardKey.f5): _runCode,
        const SingleActivator(LogicalKeyboardKey.keyN, control: true): _newFile,
      },
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: Container(
            color: const Color(0xFF1E1E1E),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                const Icon(Icons.code, color: Colors.purpleAccent, size: 18),
                const SizedBox(width: 8),
                const Text("Quantum IDE", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white)),
                const SizedBox(width: 20),
                TopMenuBar(
                  onNewFile: _newFile,
                  onOpenFile: () async {
                    final res = await FileService.openFile();
                    if(res != null) _openFileFromTree(res['path']!);
                  },
                  onOpenFolder: _openFolder,
                  onSave: _saveFile,
                  onRun: _runCode, onInstallDeps: () {  },
                ),
                const Spacer(),
                IconButton(
                  icon: _isLoading
                      ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(color: Colors.greenAccent, strokeWidth: 2))
                      : const Icon(Icons.play_circle_fill, color: Colors.greenAccent),
                  onPressed: _runCode,
                  tooltip: "Run (F5)",
                ),
              ],
            ),
          ),
        ),

        // ASOSIY ROW (3 USTUN)
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. CHAP USTUN (Sidebar + Explorer)
            ActivityBar(selectedIndex: _selectedSidebarIndex, onIndexChanged: _onSidebarTap),

            if (_isSidePanelVisible)
              SizedBox(
                width: 250,
                child: SidePanel(
                  selectedIndex: _selectedSidebarIndex,
                  projectPath: _currentProjectPath,
                  onOpenFolder: _openFolder,
                  onFileClick: _openFileFromTree,
                ),
              ),

            // 2. O'RTA USTUN (Editor + Terminal) - EXPANDED
            Expanded(
              child: Column(
                children: [
                  // Editor qismi
                  Expanded(
                    flex: 7,
                    child: _openFiles.isEmpty
                        ? EmptyStateWidget(
                      onNewFile: _newFile,
                      onOpenFile: () async {
                        final res = await FileService.openFile();
                        if(res != null) _openFileFromTree(res['path']!);
                      },
                    )
                        : Column(
                      children: [
                        TabBarWidget(
                          openFiles: _openFiles,
                          activeIndex: _activeTabIndex,
                          onTabSwitch: _switchToTab,
                          onTabClose: _closeTab,
                        ),
                        Expanded(
                          child: CodeTheme(
                            data: CodeThemeData(styles: monokaiSublimeTheme),
                            child: CodeField(
                              controller: _codeController,
                              readOnly: false,
                              textStyle: GoogleFonts.getFont('JetBrains Mono', fontSize: 15),
                              expands: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Pastki Terminal
                  if (_isBottomPanelVisible)
                    SizedBox(
                      height: 200,
                      child: BottomPanel(
                        onClose: () => setState(() => _isBottomPanelVisible = false),
                        terminalLogs: _terminalLogs,
                        onClearTerminal: () => setState(() => _terminalLogs.clear()),
                        onCommand: _runTerminalCommand,
                      ),
                    )
                  else
                  // Status Bar (Yopiq bo'lsa)
                    InkWell(
                      onTap: () => setState(() => _isBottomPanelVisible = true),
                      child: Container(
                        height: 24,
                        color: const Color(0xFF007ACC),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: const Row(
                          children: [
                            Icon(Icons.keyboard_arrow_up, size: 14, color: Colors.white),
                            SizedBox(width: 5),
                            Text("Open Terminal", style: TextStyle(color: Colors.white, fontSize: 11)),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // 3. O'NG USTUN (Vizualizatsiya) - QOTIRILGAN
            if (_isRightPanelVisible)
              RightPanel(
                data: _chartData,
                onClose: () => setState(() => _isRightPanelVisible = false),
              ),
          ],
        ),
      ),
    );
  }
}