import 'dart:convert';

class ParsedData {
  final String logOutput; // Terminalga chiqadigan oddiy matn
  final Map<String, dynamic>? visualizationData; // Grafiklar uchun ma'lumot

  ParsedData({required this.logOutput, this.visualizationData});
}

class OutputParser {
  static const String _dataTag = "__DATA__: ";

  // Asosiy sehrgar funksiya
  static ParsedData parse(String rawOutput) {
    // 1. Agar ma'lumot signalini o'z ichiga olmasa -> Shunchaki matn
    if (!rawOutput.contains(_dataTag)) {
      return ParsedData(logOutput: rawOutput);
    }

    // 2. Matnni va JSONni ajratamiz
    try {
      final parts = rawOutput.split(_dataTag);
      final logPart = parts[0]; // "Hisoblash tugadi..." degan qism
      final jsonPart = parts[1].trim(); // JSON qismi

      // 3. JSONni o'qiymiz
      final Map<String, dynamic> rawJson = jsonDecode(jsonPart);

      // 4. Ma'lumotlarni standartlashtiramiz (Heatmap ishlashi uchun!)
      final processedData = _normalizeData(rawJson);

      return ParsedData(
          logOutput: logPart,
          visualizationData: processedData
      );

    } catch (e) {
      return ParsedData(
          logOutput: "$rawOutput\n\n[Parse Error]: JSON o'qishda xatolik: $e"
      );
    }
  }

  // Ma'lumot yetishmasa, to'ldirib qo'yadigan yordamchi
  static Map<String, dynamic> _normalizeData(Map<String, dynamic> data) {
    // Agar faqat histogram kelsa, uni o'z joyiga qo'yamiz
    if (!data.containsKey('histogram') && !data.containsKey('matrix')) {
      // Demak bu eski format {"00": 50}, uni histogram ichiga solamiz
      return {
        'histogram': data,
        'matrix': null, // Matritsa yo'q
        'bloch_image': null
      };
    }
    return data;
  }
}