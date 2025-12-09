import 'package:process_run/shell.dart';
import 'dart:io';

// Javob uchun maxsus quti
class RunResult {
  final String output;
  final String error;

  RunResult({required this.output, required this.error});

  bool get hasError => error.isNotEmpty;
}

class PythonService {
  static Future<RunResult> runScript(File scriptFile) async {
    var shell = Shell(throwOnError: false); // Xato bo'lsa ham dastur to'xtamasin

    try {
      // Dasturni yurgizamiz
      var result = await shell.run('python "${scriptFile.path}"');

      // process_run ro'yxat qaytaradi, bizga birinchisi kerak
      final processResult = result.first;

      return RunResult(
        output: processResult.outText,
        error: processResult.errText,
      );
    } catch (e) {
      return RunResult(output: "", error: "Tizim xatosi: $e");
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