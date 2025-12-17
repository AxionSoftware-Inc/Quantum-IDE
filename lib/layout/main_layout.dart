import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// CONTROLLER (Miya)
import '../controllers/ide_controller.dart';

// FEATURES
import '../features/activity_bar/left_activity_bar.dart';
import '../features/activity_bar/right_activity_bar.dart';
import '../features/explorer/side_panel.dart';
import '../features/panel/right_panel.dart';
import '../features/search/search_panel.dart';
import '../features/extensions/extensions_panel.dart';

// WIDGETS
import 'widgets/quantum_app_bar.dart';
import 'widgets/central_editor_area.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  // Controller yaratamiz
  final IDEController _controller = IDEController();

  @override
  void initState() {
    super.initState();
    // Controllerni o'zgarishini eshitib turamiz va UI ni yangilaymiz
    _controller.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Yordamchi UI funksiya
  Widget _buildSidePanelContent() {
    switch (_controller.selectedSidebarIndex) {
      case 0: return SidePanel(
        selectedIndex: 0,
        projectPath: _controller.currentProjectPath,
        onOpenFolder: _controller.openFolder,
        onFileClick: _controller.openFileFromTree,
      );
      case 1: return SearchPanel(
        projectPath: _controller.currentProjectPath,
        onResultClick: _controller.openFileFromTree,
      );
      case 2: return const Center(child: Text("Git (Soon)", style: TextStyle(color: Colors.white30)));
      case 3: return const ExtensionsPanel();
      default: return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Shortcuts ham controllerni ishlatadi
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyS, control: true): _controller.saveFile,
        const SingleActivator(LogicalKeyboardKey.f5): _controller.runCode,
      },
      child: Scaffold(
        appBar: QuantumAppBar(
          onNewFile: _controller.newFile,
          onOpenFile: () async {
            // FileService controllerni ichida, shuning uchun bu yerda oddiy chaqirish qiyinroq bo'lsa
            // Controllerni ichida openFile() metodini o'zgartirib to'g'irlab qo'ydim
            // Lekin FileService UI blok qilishi mumkin, shuning uchun controllerda async qildik
          },
          // Kichik fix: AppBar callbacklari void talab qiladi, shuning uchun wrapper
          // Lekin controller metodlari mos tushadi
          onOpenFolder: _controller.openFolder,
          onSave: _controller.saveFile,
          onRun: _controller.isRunning ? _controller.stopCode : _controller.runCode,
          onInstallDeps: _controller.installDependencies,
          isLoading: _controller.isLoading,
          isRunning: _controller.isRunning,
          activeFileName: _controller.activeFilePath?.split(Platform.pathSeparator).last,
        ),

        body: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // LEFT BAR
            ActivityBar(
              selectedIndex: _controller.selectedSidebarIndex,
              onIndexChanged: _controller.toggleSidebar,
            ),

            // SIDE PANEL
            if (_controller.isSidePanelVisible)
              SizedBox(width: 250, child: _buildSidePanelContent()),

            // CENTER AREA
            Expanded(
              child: Stack(
                children: [
                  CentralEditorArea(
                    openFiles: _controller.openFiles,
                    activeTabIndex: _controller.activeTabIndex,
                    codeController: _controller.codeController,
                    onTabSwitch: _controller.switchToTab,
                    onTabClose: _controller.closeTab,
                    onNewFile: _controller.newFile,
                    onOpenFile: () {}, // Controllerda bor
                    isBottomPanelVisible: _controller.isBottomPanelVisible,
                    onToggleBottomPanel: _controller.toggleBottomPanel,
                    terminalLogs: _controller.terminalLogs,
                    onClearTerminal: _controller.clearLogs,
                    onRunCommand: _controller.runTerminalCommand,
                  ),

                  // QUBIT BUTTONS
                  Positioned(
                    top: 10, right: 20,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        children: [
                          _qubitBtn(5), const SizedBox(width: 8), _qubitBtn(7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // RIGHT PANEL
            if (_controller.isRightPanelVisible)
              SizedBox(
                width: 400,
                child: RightPanel(
                  key: _controller.vizKey,
                  data: _controller.chartData,
                  onClose: () => setState(() => _controller.isRightPanelVisible = false),
                ),
              ),

            // RIGHT BAR
            RightActivityBar(
              isPanelVisible: _controller.isRightPanelVisible,
              onToggle: _controller.toggleRightPanel,
            ),
          ],
        ),
      ),
    );
  }

  Widget _qubitBtn(int n) {
    return TextButton(
      onPressed: () => _controller.loadTemplate(n),
      style: TextButton.styleFrom(foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 12)),
      child: Text("$n-Qubit", style: const TextStyle(fontSize: 12)),
    );
  }
}