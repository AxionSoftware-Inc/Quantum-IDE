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
import '../features/activity_bar/right_activity_bar.dart';
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
  // --- STATE VARIABLES ---

  int _selectedSidebarIndex = 0;
  bool _isSidePanelVisible = true;
  bool _isBottomPanelVisible = true;
  bool _isRightPanelVisible = false;
  bool _isLoading = false;

  int _activeTabIndex = -1;
  String? _currentProjectPath;
  String? _activeFilePath;
  List<String> _openFiles = [];

  List<String> _terminalLogs = ["Quantum IDE v1.0 Ready."];
  Map<String, dynamic> _chartData = {};
  Key _vizKey = UniqueKey();

  late CodeController _codeController;

  @override
  void initState() {
    super.initState();
    // Boshlanishiga 5 Qubitli shablonni yuklaymiz
    _codeController = CodeController(
      text: _generateQubitCode(5), // Default: 5 Qubit
      language: python,
    );
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  // --- YANGI: QUBIT KOD GENERATORI (5 va 7 uchun) ---

  String _generateQubitCode(int qubits) {
    // Bu funksiya N-qubitli GHZ holatini (chigallashgan holat) yaratuvchi kod qaytaradi
    return '''
import numpy as np
from qiskit import QuantumCircuit, transpile
from qiskit_aer import AerSimulator
import matplotlib.pyplot as plt

# $qubits-Qubitli Tizimni Yaratish
n_qubits = $qubits
qc = QuantumCircuit(n_qubits)

# 1. Superpozitsiya (Hadamard gate)
qc.h(0)

# 2. Chigallashtirish (CNOT chain - GHZ State)
for i in range(n_qubits - 1):
    qc.cx(i, i+1)

# 3. O'lchash
qc.measure_all()

print(f"Running {n_qubits}-Qubit Simulation...")

# Simulyatsiya
simulator = AerSimulator()
compiled_circuit = transpile(qc, simulator)
result = simulator.run(compiled_circuit, shots=1024).result()
counts = result.get_counts()

print("Natijalar (Counts):", counts)
# IDE Vizualizatsiyasi uchun maxsus format (agar kerak bo'lsa)
# print("VISUALIZATION_DATA:", counts) 
''';
  }

  // Kodni almashtirish uchun yordamchi funksiya
  void _loadTemplate(int qubits) {
    bool confirm = true;
    // Agar kod yozilgan bo'lsa, ogohlantirish kerak (haqiqiy ilovada dialog chiqarish kerak)
    if (_codeController.text.isNotEmpty && _codeController.text.length > 50) {
      // confirm = await showDialog... (qisqartirildi)
    }

    if (confirm) {
      setState(() {
        _codeController.text = _generateQubitCode(qubits);
        _addLog("Template loaded: $qubits Qubit GHZ State");
      });
    }
  }

  // --- ASOSIY LOGIKA ---

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

  void _newFile() {
    setState(() {
      String newFileName = "Untitled-${_openFiles.length + 1}";
      _openFiles.add(newFileName);
      _activeTabIndex = _openFiles.length - 1;
      _codeController.text = "";
      _activeFilePath = null;
    });
  }

  void _openFile() async {
    final result = await FileService.openFile();
    if (result != null) _openFileFromTree(result['path']!);
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

  void _saveFile() async {
    if (_activeFilePath == null || _activeFilePath!.startsWith("Untitled-")) {
      final path = await FileService.saveFileAs(_codeController.text);
      if (path != null) {
        setState(() {
          _activeFilePath = path;
          _openFiles[_activeTabIndex] = path;
        });
      }
    } else {
      await FileService.saveFile(_codeController.text, _activeFilePath!);
    }
    _addLog("File saved.");
  }

  void _switchToTab(int index) {
    setState(() => _activeTabIndex = index);
    _loadFileContent(_openFiles[index]);
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

  void _toggleRightPanel() {
    setState(() => _isRightPanelVisible = !_isRightPanelVisible);
  }

  // --- RUN & TERMINAL ---

  void _addLog(String text) {
    if (text.trim().isEmpty) return;
    setState(() => _terminalLogs.add(text));
  }

  void _runCode() async {
    setState(() {
      _isBottomPanelVisible = true;
      _isLoading = true;
      _chartData = {};
      _vizKey = UniqueKey();
    });
    _addLog("\n--- Processing Quantum Circuit ---");

    try {
      final tempFile = await FileService.saveCode(_codeController.text, 'temp_run.py');
      final result = await PythonService.runScript(tempFile);

      if (result.error.isNotEmpty) _addLog("Error: ${result.error}");

      if (result.output.isNotEmpty) {
        final parsed = OutputParser.parse(result.output);
        if (parsed.logOutput.isNotEmpty) _addLog(parsed.logOutput);

        if (parsed.visualizationData != null) {
          setState(() {
            _chartData = parsed.visualizationData!;
            _isRightPanelVisible = true;
          });
          _addLog("📊 Vizualizatsiya (Histogramma) tayyor.");
        }
      }
    } catch (e) {
      _addLog("System Error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _installDependencies() async {
    _addLog("Installing Qiskit & Dependencies...");
    setState(() => _isBottomPanelVisible = true);
    await PythonService.runCommand("pip install qiskit matplotlib qiskit-aer pylatexenc");
    _addLog("Dependencies installed.");
  }

  void _runTerminalCommand(String cmd) async {
    // ... (Eski terminal logikasi bilan bir xil)
    _addLog("> $cmd");
    if (cmd == 'cls' || cmd == 'clear') {
      setState(() => _terminalLogs.clear());
      return;
    }
    final res = await PythonService.runCommand(cmd);
    if (res.output.isNotEmpty) _addLog(res.output);
  }

  // --- BUILD UI ---
  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyS, control: true): _saveFile,
        const SingleActivator(LogicalKeyboardKey.f5): _runCode,
      },
      child: Scaffold(
        appBar: QuantumAppBar(
          onNewFile: _newFile,
          onOpenFile: _openFile,
          onOpenFolder: _openFolder,
          onSave: _saveFile,
          onRun: _runCode,
          onInstallDeps: _installDependencies,
          isLoading: _isLoading,
          activeFileName: _activeFilePath?.split(Platform.pathSeparator).last,
          // Agar AppBar ga maxsus menyu qo'shish imkoni bo'lsa, buni ishlating:
          // actions: [
          //   IconButton(icon: Text("5Q"), onPressed: () => _loadTemplate(5)),
          //   IconButton(icon: Text("7Q"), onPressed: () => _loadTemplate(7)),
          // ]
        ),
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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

            // MARKAZIY QISM + QUBIT SWITCHER TUGMALARI
            Expanded(
              child: Stack(
                children: [
                  CentralEditorArea(
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

                  // QUBIT TANLASH UCHUN TEZKOR TUGMALAR (UI ustida)
                  Positioned(
                    top: 10,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          _qubitButton(5),
                          const SizedBox(width: 8),
                          _qubitButton(7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            if (_isRightPanelVisible)
              SizedBox(
                width: 400, // 7 qubitlik histogramma kengroq joy talab qilishi mumkin
                child: RightPanel(
                  key: _vizKey,
                  data: _chartData,
                  onClose: _toggleRightPanel,
                ),
              ),

            RightActivityBar(
              isPanelVisible: _isRightPanelVisible,
              onToggle: _toggleRightPanel,
            ),
          ],
        ),
      ),
    );
  }

  // Yordamchi tugma widgeti
  Widget _qubitButton(int n) {
    return TextButton(
      onPressed: () => _loadTemplate(n),
      style: TextButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.blueAccent.withOpacity(0.5),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      child: Text("$n-Qubit Example", style: const TextStyle(fontSize: 12)),
    );
  }
}