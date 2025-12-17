import 'dart:io';
import 'package:flutter/material.dart';
import 'package:code_text_field/code_text_field.dart';
import 'package:highlight/languages/python.dart';

// SERVICES
import '../core/file_service.dart';
import '../core/python_service.dart';
import '../core/execution_service.dart';
import '../utils/template_generator.dart';

class IDEController extends ChangeNotifier {
  // --- STATE VARIABLES (O'zgaruvchilar) ---
  final ExecutionService _executor = ExecutionService();
  late CodeController codeController;

  // UI Status
  int selectedSidebarIndex = 0;
  bool isSidePanelVisible = true;
  bool isBottomPanelVisible = true;
  bool isRightPanelVisible = false;
  bool isLoading = false;
  bool isRunning = false;

  // Data
  List<String> terminalLogs = ["Quantum IDE v1.0 Ready."];
  Map<String, dynamic> chartData = {};
  Key vizKey = UniqueKey();

  // File System
  String? currentProjectPath;
  String? activeFilePath;
  int activeTabIndex = -1;
  List<String> openFiles = [];

  // --- INIT & DISPOSE ---
  IDEController() {
    codeController = CodeController(
      text: TemplateGenerator.generateGHZState(5),
      language: python,
    );
  }

  @override
  void dispose() {
    codeController.dispose();
    _executor.stopExecution();
    super.dispose();
  }

  // --- ACTIONS (Funksiyalar) ---

  void toggleSidebar(int index) {
    if (selectedSidebarIndex == index) {
      isSidePanelVisible = !isSidePanelVisible;
    } else {
      selectedSidebarIndex = index;
      isSidePanelVisible = true;
    }
    notifyListeners(); // UI ga "Yangilan!" deb buyruq beradi
  }

  void toggleRightPanel() {
    isRightPanelVisible = !isRightPanelVisible;
    notifyListeners();
  }

  void toggleBottomPanel() {
    isBottomPanelVisible = !isBottomPanelVisible;
    notifyListeners();
  }

  // --- RUN & STOP ---

  void runCode() {
    if (isRunning) return;

    isRunning = true;
    isBottomPanelVisible = true;
    chartData = {};
    vizKey = UniqueKey();
    addLog("\n--- 🚀 Running Quantum Circuit ---");
    notifyListeners();

    _executor.runPythonCode(codeController.text).listen(
          (result) {
        if (result.log.isNotEmpty) addLog(result.log);

        if (result.visualizationData != null) {
          chartData = result.visualizationData!;
          isRightPanelVisible = true;
          addLog("📊 Visualization Updated.");
        }

        if (result.isFinished) {
          isRunning = false;
          addLog("--- ✅ Execution Finished ---");
        }
        notifyListeners();
      },
      onError: (e) {
        isRunning = false;
        addLog("Critical Error: $e");
        notifyListeners();
      },
    );
  }

  void stopCode() {
    _executor.stopExecution();
    isRunning = false;
    addLog("\n🛑 Execution Stopped by User.");
    notifyListeners();
  }

  void installDependencies() {
    isLoading = true;
    addLog("Installing Qiskit...");
    notifyListeners();

    _executor.installDependencies().listen(
          (log) {
        addLog(log);
        notifyListeners();
      },
      onDone: () {
        isLoading = false;
        addLog("Installation Complete.");
        notifyListeners();
      },
    );
  }

  // --- FILE SYSTEM ---

  void openFolder() async {
    final path = await FileService.pickDirectory();
    if (path != null) {
      currentProjectPath = path;
      selectedSidebarIndex = 0;
      isSidePanelVisible = true;
      addLog("Folder: $path");
      notifyListeners();
    }
  }

  void newFile() {
    String newFileName = "Untitled-${openFiles.length + 1}";
    openFiles.add(newFileName);
    activeTabIndex = openFiles.length - 1;
    codeController.text = "";
    activeFilePath = null;
    notifyListeners();
  }

  void openFileFromTree(String path) async {
    int existingIndex = openFiles.indexOf(path);
    if (existingIndex != -1) {
      activeTabIndex = existingIndex;
    } else {
      openFiles.add(path);
      activeTabIndex = openFiles.length - 1;
    }
    await _loadFileContent(path);
    notifyListeners();
  }

  Future<void> _loadFileContent(String path) async {
    if (path.startsWith("Untitled-")) return;
    File file = File(path);
    if (await file.exists()) {
      String content = await file.readAsString();
      codeController.text = content;
      activeFilePath = path;
    }
  }

  void saveFile() async {
    if (activeFilePath == null || activeFilePath!.startsWith("Untitled-")) {
      final path = await FileService.saveFileAs(codeController.text);
      if (path != null) {
        activeFilePath = path;
        openFiles[activeTabIndex] = path;
        addLog("Saved: $path");
      }
    } else {
      await FileService.saveFile(codeController.text, activeFilePath!);
      addLog("File Saved.");
    }
    notifyListeners();
  }

  void closeTab(int index) {
    openFiles.removeAt(index);
    if (openFiles.isEmpty) {
      activeTabIndex = -1;
      codeController.text = "";
    } else if (index <= activeTabIndex) {
      activeTabIndex = (activeTabIndex - 1).clamp(0, openFiles.length - 1);
      _loadFileContent(openFiles[activeTabIndex]);
    }
    notifyListeners();
  }

  void switchToTab(int index) {
    activeTabIndex = index;
    _loadFileContent(openFiles[index]);
    notifyListeners();
  }

  // --- UTILS ---

  void loadTemplate(int qubits) {
    codeController.text = TemplateGenerator.generateGHZState(qubits);
    addLog("Template loaded: $qubits Qubit GHZ");
    notifyListeners();
  }

  void addLog(String text) {
    if (text.trim().isEmpty) return;
    terminalLogs.add(text);
    // Agar log juda ko'payib ketsa tozalash mumkin
    if (terminalLogs.length > 500) terminalLogs.removeAt(0);
    notifyListeners();
  }

  void clearLogs() {
    terminalLogs.clear();
    notifyListeners();
  }

  void runTerminalCommand(String cmd) async {
    addLog("> $cmd");
    if (cmd == 'cls' || cmd == 'clear') {
      clearLogs();
      return;
    }
    final res = await PythonService.runCommand(cmd);
    if (res.output.isNotEmpty) addLog(res.output);
    notifyListeners();
  }
}