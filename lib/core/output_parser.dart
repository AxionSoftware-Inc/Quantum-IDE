import 'dart:convert';

class ParsedData {
  final String logOutput;
  final Map<String, dynamic>? visualizationData;

  ParsedData({required this.logOutput, this.visualizationData});
}

class OutputParser {
  static const String _tag = "__DATA__:";

  static ParsedData parse(String text) {
    if (!text.contains(_tag)) {
      return ParsedData(logOutput: text);
    }

    String cleanLog = text;
    final Map<String, dynamic> mergedData = {};

    // Matn ichidan barcha __DATA__ larni qidiramiz
    int startIndex = 0;
    while (true) {
      // 1. __DATA__: ni topamiz
      final tagIndex = text.indexOf(_tag, startIndex);
      if (tagIndex == -1) break;

      // 2. JSON boshlanadigan joyni topamiz ('{' belgisi)
      final jsonStartIndex = text.indexOf('{', tagIndex);
      if (jsonStartIndex == -1) {
        startIndex = tagIndex + 1;
        continue;
      }

      // 3. JSONning tugashini topish (Qavslarni sanash orqali)
      // Bu juda muhim, chunki JSON ichida ham qavslar bo'lishi mumkin
      int braceCount = 0;
      int jsonEndIndex = -1;

      for (int i = jsonStartIndex; i < text.length; i++) {
        if (text[i] == '{') braceCount++;
        else if (text[i] == '}') braceCount--;

        if (braceCount == 0) {
          jsonEndIndex = i + 1; // Tugadi
          break;
        }
      }

      if (jsonEndIndex != -1) {
        // 4. JSONni qirqib olamiz va o'qiymiz
        try {
          final jsonString = text.substring(jsonStartIndex, jsonEndIndex);
          final data = jsonDecode(jsonString) as Map<String, dynamic>;

          // Ma'lumotlarni birlashtiramiz
          mergedData.addAll(data);

          // Logdan bu qismni o'chiramiz (terminalni toza saqlash uchun)
          cleanLog = cleanLog.replaceFirst(text.substring(tagIndex, jsonEndIndex), "[DATA RECEIVED]");
        } catch (e) {
          print("JSON Parse Error: $e");
        }
        // Keyingisini qidirish uchun
        startIndex = jsonEndIndex;
      } else {
        startIndex = tagIndex + 1;
      }
    }

    // 5. Ma'lumotlarni normalizatsiya qilish
    final finalData = _normalizeData(mergedData);

    return ParsedData(
      logOutput: cleanLog.trim(), // Ortiqcha bo'shliqlarsiz log
      visualizationData: finalData.isNotEmpty ? finalData : null,
    );
  }

  static Map<String, dynamic> _normalizeData(Map<String, dynamic> data) {
    if (data.isEmpty) return {};
    bool isStandard = data.containsKey('histogram') ||
        data.containsKey('matrix') ||
        data.containsKey('circuit_image') ||
        data.containsKey('bloch_image');
    if (!isStandard) {
      return {'histogram': data, 'matrix': null};
    }
    return data;
  }
}