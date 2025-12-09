import 'dart:io';
import 'package:flutter/material.dart';
import 'package:code_text_field/code_text_field.dart';
import 'package:flutter/services.dart';
import 'package:highlight/languages/python.dart';
import 'dart:convert';

// CORE
import '../core/output_parser.dart';
import '../core/file_service.dart';
import '../core/python_service.dart';

// FEATURES
import '../features/activity_bar/left_activity_bar.dart';
import '../features/activity_bar/right_activity_bar.dart'; // <--- YANGI
import '../features/explorer/side_panel.dart';
import '../features/panel/right_panel.dart';

// WIDGETS
import 'widgets/quantum_app_bar.dart';
import 'widgets/central_editor_area.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  // STATE
  int _selectedSidebarIndex = 0;
  bool _isSidePanelVisible = true;
  bool _isBottomPanelVisible = true;
  bool _isRightPanelVisible = false; // Boshida yopiq

  String? _currentProjectPath;
  String? _activeFilePath;

  List<String> _terminalLogs = ["Quantum IDE v1.0 Ready."];
  List<String> _openFiles = [];
  int _activeTabIndex = -1;
  Map<String, dynamic> _chartData = {};
  bool _isLoading = false;

  final CodeController _codeController = CodeController(
    text: '# Start Quantum Coding\nprint("Hello Quantum")',
    language: python,
  );

  // --- FUNKSIYALAR ---
  void _installDependencies() async {
    _addLog("Installing libs...");
    setState(() => _isBottomPanelVisible = true);
    await PythonService.runCommand("pip install qiskit matplotlib qiskit-aer pylatexenc");
    _addLog("Done.");
  }

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

  // O'ng panelni ochish/yopish (Endi RightActivityBar dan chaqiriladi)
  void _toggleRightPanel() {
    setState(() {
      _isRightPanelVisible = !_isRightPanelVisible;
    });
  }

  void _openFolder() async {
    final path = await FileService.pickDirectory();
    if (path != null) {
      setState(() {
        _currentProjectPath = path;
        _selectedSidebarIndex = 0;
        _isSidePanelVisible = true;
        _addLog("Folder: $path");
      });
    }
  }

  void _openFileFromTree(String path) {
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

  void _openFile() async {
    try {
      final result = await FileService.openFile();
      if (result != null) _openFileFromTree(result['path']!);
    } catch (e) {
      _addLog("Error: $e");
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

  void _newFile() {
    setState(() {
      String newFileName = "Untitled-${_openFiles.length + 1}";
      _openFiles.add(newFileName);
      _activeTabIndex = _openFiles.length - 1;
      _codeController.text = "";
      _activeFilePath = null;
      _addLog("New file created.");
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
            _addLog("Saved: $path");
          });
        }
      } else {
        await FileService.saveFile(_codeController.text, _activeFilePath!);
        _addLog("Saved.");
      }
    } catch (e) {
      _addLog("Error: $e");
    }
  }

  void _addLog(String text) {
    if (text.trim().isEmpty) return;
    setState(() => _terminalLogs.add(text));
  }

  void _runCode() async {
    setState(() {
      _isBottomPanelVisible = true;
      _isLoading = true;
      _chartData = {};
    });
    _addLog("\n--- Running ---");

    try {
      final tempFile = await FileService.saveCode(_codeController.text, 'temp_run.py');
      final result = await PythonService.runScript(tempFile);

      if (result.error.isNotEmpty) _addLog("Err: ${result.error}");

      if (result.output.isNotEmpty) {
        final parsed = OutputParser.parse(result.output);
        if (parsed.logOutput.isNotEmpty) _addLog(parsed.logOutput);

        if (parsed.visualizationData != null) {
          setState(() {
            _chartData = parsed.visualizationData!;
            _isRightPanelVisible = true; // Avtomatik ochish
          });
          _addLog("📊 Vizualizatsiya yangilandi.");
        }
      }
    } catch (e) {
      _addLog("Sys Error: $e");
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

  // --- UI BUILD ---
  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyS, control: true): _saveFile,
        const SingleActivator(LogicalKeyboardKey.f5): _runCode,
        const SingleActivator(LogicalKeyboardKey.keyN, control: true): _newFile,
      },
      child: Scaffold(
        // 1. TEPADAGI PANEL (Endi o'ng tugmasiz)
        appBar: QuantumAppBar(
          onNewFile: _newFile,
          onOpenFile: _openFile,
          onOpenFolder: _openFolder,
          onSave: _saveFile,
          onRun: _runCode,
          onInstallDeps: _installDependencies,
          isLoading: _isLoading,
          activeFileName: _activeFilePath?.split(Platform.pathSeparator).last,
        ),

        // 2. ASOSIY EKRAN (4 USTUN)
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // A. CHAP USTUN
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

            // B. O'RTA USTUN
            Expanded(
              child: CentralEditorArea(
                openFiles: _openFiles,
                activeTabIndex: _activeTabIndex,
                codeController: _codeController,
                onTabSwitch: _switchToTab,
                onTabClose: _closeTab,
                onNewFile: _newFile,
                onOpenFile: _openFile,
                isBottomPanelVisible: _isBottomPanelVisible,
                onToggleBottomPanel: () => setState(() => _isBottomPanelVisible = !_isBottomPanelVisible),
                terminalLogs: _terminalLogs,
                onClearTerminal: () => setState(() => _terminalLogs.clear()),
                onRunCommand: _runTerminalCommand,
              ),
            ),

            // C. O'NG PANEL (Vizualizatsiya)
            if (_isRightPanelVisible)
              RightPanel(
                data: _chartData,
                onClose: _toggleRightPanel,
              ),

            // D. O'NG USTUN (YANGI!)
            RightActivityBar(
              isPanelVisible: _isRightPanelVisible,
              onToggle: _toggleRightPanel,
            ),
          ],
        ),
      ),
    );
  }
}