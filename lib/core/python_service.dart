import 'dart:io';
import 'package:process_run/shell.dart';
import 'embedded_scripts.dart';

class RunResult {
  final String output;
  final String error;
  RunResult({required this.output, required this.error});
}

class PythonService {

  static Future<RunResult> runScript(File userCodeFile) async {
    var shell = Shell(throwOnError: false);

    try {
      final dir = userCodeFile.parent.path;

      // 1. Foydalanuvchi kodini o'qiymiz
      String userCode = await userCodeFile.readAsString();

      // 2. Bizning "Header" kodimiz bilan birlashtiramiz
      // Header + 2 ta enter + User Code
      String finalCode = "${EmbeddedScripts.headerCode}\n\n$userCode";

      // 3. Yangi vaqtincha fayl yaratamiz (final_run.py)
      final runFile = File('$dir/final_run.py');
      await runFile.writeAsString(finalCode);

      // 4. O'sha birlashgan faylni yurgizamiz
      // Endi hech qanday argument yoki launcher kerak emas!
      var result = await shell.run('python "${runFile.path}"');

      final processResult = result.first;

      return RunResult(
        output: processResult.outText,
        error: processResult.errText,
      );

    } catch (e) {
      return RunResult(output: "", error: "Run Error: $e");
    }
  }

  static Future<RunResult> runCommand(String command) async {
    var shell = Shell(throwOnError: false);
    try {
      var result = await shell.run(command);
      return RunResult(output: result.first.outText, error: result.first.errText);
    } catch (e) {
      return RunResult(output: "", error: "$e");
    }
  }
}