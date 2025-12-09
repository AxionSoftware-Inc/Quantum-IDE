import 'package:process_run/shell.dart';
import 'dart:io';

import 'launcher_script.dart';

// Javob uchun maxsus quti
class RunResult {
  final String output;
  final String error;

  RunResult({required this.output, required this.error});

  bool get hasError => error.isNotEmpty;
}

class PythonService {
  static Future<RunResult> runScript(File userCodeFile) async {
    var shell = Shell(throwOnError: false);

    try {
      final dir = userCodeFile.parent;
      final launcherFile = File('${dir.path}/ide_launcher.py');
      await launcherFile.writeAsString(LauncherScript.content);
      var result = await shell.run('python "${launcherFile.path}" "${userCodeFile.path}"');

      final processResult = result.first;
      return RunResult(output: processResult.outText, error: processResult.errText);

    } catch (e) {
      return RunResult(output: "", error: "Run Error: $e");
    }
  }

  static Future<RunResult> runCommand(String command) async {
    var shell = Shell(throwOnError: false);
    try {
      // Buyruqni yurgizamiz
      var result = await shell.run(command);
      final processResult = result.first;

      return RunResult(
        output: processResult.outText,
        error: processResult.errText,
      );
    } catch (e) {
      return RunResult(output: "", error: "Xatolik: $e");
    }
  }
}