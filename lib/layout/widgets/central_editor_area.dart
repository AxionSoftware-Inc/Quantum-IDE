import 'package:flutter/material.dart';
import 'package:code_text_field/code_text_field.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../features/editor/empty_state_widget.dart';
import '../../features/editor/tab_bar_widget.dart';
import '../../features/panel/bottom_panel.dart';

class CentralEditorArea extends StatelessWidget {
  final List<String> openFiles;
  final int activeTabIndex;
  final CodeController codeController;
  final Function(int) onTabSwitch;
  final Function(int) onTabClose;
  final VoidCallback onNewFile;
  final VoidCallback onOpenFile;

  // Terminal uchun
  final bool isBottomPanelVisible;
  final VoidCallback onToggleBottomPanel;
  final List<String> terminalLogs;
  final VoidCallback onClearTerminal;
  final Function(String) onRunCommand;

  const CentralEditorArea({
    super.key,
    required this.openFiles,
    required this.activeTabIndex,
    required this.codeController,
    required this.onTabSwitch,
    required this.onTabClose,
    required this.onNewFile,
    required this.onOpenFile,
    required this.isBottomPanelVisible,
    required this.onToggleBottomPanel,
    required this.terminalLogs,
    required this.onClearTerminal,
    required this.onRunCommand,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // A. EDITOR QISMI
        Expanded(
          flex: 7, // 70%
          child: openFiles.isEmpty
              ? EmptyStateWidget(onNewFile: onNewFile, onOpenFile: onOpenFile)
              : Column(
            children: [
              TabBarWidget(
                openFiles: openFiles,
                activeIndex: activeTabIndex,
                onTabSwitch: onTabSwitch,
                onTabClose: onTabClose,
              ),
              Expanded(
                child: CodeTheme(
                  data: CodeThemeData(styles: monokaiSublimeTheme),
                  child: CodeField(
                    controller: codeController,
                    textStyle: GoogleFonts.getFont('JetBrains Mono', fontSize: 15),
                    expands: true,
                  ),
                ),
              ),
            ],
          ),
        ),

        // B. PASTKI PANEL (TERMINAL)
        if (isBottomPanelVisible)
          SizedBox(
            height: 200,
            child: BottomPanel(
              onClose: onToggleBottomPanel,
              terminalLogs: terminalLogs,
              onClearTerminal: onClearTerminal,
              onCommand: onRunCommand,
            ),
          )
        else
        // Status Bar (Yopiq bo'lsa)
          InkWell(
            onTap: onToggleBottomPanel,
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
    );
  }
}