import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'output_parser.dart';
import 'file_service.dart';

class ExecutionResult {
  final String log;
  final Map<String, dynamic>? visualizationData;
  final bool isError;
  final bool isFinished;

  ExecutionResult({
    this.log = '',
    this.visualizationData,
    this.isError = false,
    this.isFinished = false,
  });
}

class ExecutionService {
  Process? _process;

  Stream<ExecutionResult> runPythonCode(String code) async* {
    try {
      // 1. Faylni saqlaymiz
      final tempFile = await FileService.saveCode(code, 'temp_run.py');

      // 2. Jarayonni boshlaymiz
      _process = await Process.start('python', ['-u', tempFile.path]);

      if (_process == null) {
        yield ExecutionResult(log: "Error: Python start olmadi!", isError: true);
        return;
      }

      // 3. STDOUT (Loglar va Vizualizatsiya) - XATO SHU YERDA EDI
      // LineSplitter() qo'shildi. Bu ma'lumotni qator-qator o'qiydi.
      // Bu bo'lmasa JSON yarmida uzilib qoladi va grafik chizilmaydi.
      await for (final line in _process!.stdout
          .transform(utf8.decoder)
          .transform(const LineSplitter())) {

        final parsed = OutputParser.parse(line);

        yield ExecutionResult(
            log: parsed.logOutput,
            visualizationData: parsed.visualizationData
        );
      }

      // 4. STDERR (Xatolar)
      await for (final line in _process!.stderr
          .transform(utf8.decoder)
          .transform(const LineSplitter())) {
        if (line.trim().isNotEmpty) {
          yield ExecutionResult(log: "Error: $line", isError: true);
        }
      }

      yield ExecutionResult(isFinished: true);
      _process = null;

    } catch (e) {
      yield ExecutionResult(log: "System Error: $e", isError: true);
    }
  }

  void stopExecution() {
    if (_process != null) {
      _process!.kill();
      _process = null;
    }
  }

  Stream<String> installDependencies() async* {
    final process = await Process.start('pip', ['install', 'qiskit', 'matplotlib', 'qiskit-aer', 'pylatexenc']);

    await for (final line in process.stdout
        .transform(utf8.decoder)
        .transform(const LineSplitter())) {
      yield line;
    }
  }
}