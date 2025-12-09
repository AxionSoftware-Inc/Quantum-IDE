import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

class FileService {

  // 1. Faylni OCHISH (Open)
  static Future<Map<String, String>?> openFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any, // O'ZGARISH: Hamma fayllarni ochsin
      // allowedExtensions: ['py', 'txt'], // BU QATORNI O'CHIRIB TASHLANG
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      String content = await file.readAsString();
      return {
        'path': file.path,      // Fayl manzili (keyin saqlash uchun kerak)
        'content': content,     // Kodning o'zi
        'name': result.files.single.name, // Fayl nomi (Tabga yozish uchun)
      };
    }
    return null; // Agar foydalanuvchi "Cancel" bossa
  }

  // 2. Faylni SAQLASH (Save As)
  static Future<String?> saveFileAs(String content) async {
    // Qayerga saqlashni so'raymiz
    String? outputFile = await FilePicker.platform.saveFile(
      dialogTitle: 'Kodni saqlash',
      fileName: 'quantum_script.py',
    );

    if (outputFile != null) {
      File file = File(outputFile);
      await file.writeAsString(content);
      return outputFile; // Saqlangan joyini qaytaramiz
    }
    return null;
  }

  static Future<String?> pickDirectory() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    return selectedDirectory;
  }

  static Future<void> saveFile(String content, String path) async {
    File file = File(path);
    await file.writeAsString(content);
  }

  static Future<File> saveCode(String content, String filename) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$filename');
    return await file.writeAsString(content);
  }
}