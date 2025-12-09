import 'package:flutter/material.dart';

class MatrixWidget extends StatelessWidget {
  final dynamic data;

  const MatrixWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final Map<String, double> matrixData = {};
    int gridSize = 0;

    // 1. MA'LUMOTNI PARSING QILISH (Xavfsiz)
    try {
      final rawMap = data as Map<String, dynamic>;
      rawMap.forEach((key, value) {
        if (key.contains(',')) {
          // Raqamni double ga o'tkazamiz (Python int yuborsa ham ishlashi uchun)
          double intensity = (value as num).toDouble();
          matrixData[key] = intensity;

          // Matritsa o'lchamini aniqlaymiz
          final parts = key.split(',');
          int row = int.parse(parts[0]);
          int col = int.parse(parts[1]);

          if (row + 1 > gridSize) gridSize = row + 1;
          if (col + 1 > gridSize) gridSize = col + 1;
        }
      });
    } catch (e) {
      return Center(child: Text("Error: $e", style: const TextStyle(color: Colors.red)));
    }

    // 2. LIMIT TEKSHIRUVI (64x64 dan katta bo'lsa chizmaymiz)
    if (gridSize > 64) {
      return Center(
        child: Text(
          "Matritsa juda katta ($gridSize x $gridSize).\nFaqat Gistogrammani ko'ring.",
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.orangeAccent),
        ),
      );
    }

    if (matrixData.isEmpty) return const Center(child: Text("Matritsa bo'sh", style: TextStyle(color: Colors.grey)));

    // 3. INTERAKTIV CHIZISH (Zoom va Pan)
    return ClipRect(
      child: InteractiveViewer(
        boundaryMargin: EdgeInsets.zero, // Bo'sh joy qoldirmaymiz
        minScale: 1.0, // Kichraytirish mumkin emas
        maxScale: 20.0, // 20 barobar kattalashtirish mumkin (Raqamlar ko'rinishi uchun)
        panEnabled: true, // Surish mumkin
        child: Center(
          child: AspectRatio(
            aspectRatio: 1, // Kvadrat shakl
            child: CustomPaint(
              painter: MatrixPainter(data: matrixData, gridSize: gridSize),
            ),
          ),
        ),
      ),
    );
  }
}

// --- RASSOM KLASSI (GPU da chizadi) ---
class MatrixPainter extends CustomPainter {
  final Map<String, double> data;
  final int gridSize;

  MatrixPainter({required this.data, required this.gridSize});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..style = PaintingStyle.fill;

    // Xato chiqmasligi uchun kamida 1 deb olamiz
    final int safeGridSize = gridSize > 0 ? gridSize : 1;
    final double cellSize = size.width / safeGridSize;

    // 1. Orqa fon (Qora)
    paint.color = Colors.black;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // 2. Katakchalarni chizish
    data.forEach((key, intensity) {
      final parts = key.split(',');
      int row = int.parse(parts[0]);
      int col = int.parse(parts[1]);

      // Rang intensivligi (0.0 dan 1.0 gacha)
      final double safeIntensity = intensity.clamp(0.0, 1.0);

      // RANG TANLASH: Qoradan -> Havorangga (Cyan) qarab
      paint.color = Color.lerp(
          Colors.black,
          Colors.cyanAccent,
          safeIntensity
      )!;

      // Katakni chizamiz (ozgina oraliq 'padding' bilan)
      canvas.drawRect(
          Rect.fromLTWH(
              col * cellSize,
              row * cellSize,
              cellSize,
              cellSize
          ),
          paint
      );

      // --- RAQAMLARNI YOZISH (DINAMIK) ---
      // Agar katakcha ekranda yetarlicha katta ko'rinsa (12 pikseldan katta), raqam yozamiz
      if (cellSize > 12) {
        // Shrift o'lchamini katakchaga moslaymiz (30% joy olsin)
        double fontSize = cellSize * 0.3;
        // Lekin juda kichkina bo'lib ketmasin (min 8)
        if (fontSize < 8) fontSize = 8;

        // Raqamni faqat 20 dan katta bo'lganda chizamiz (ko'zga ko'rinishi uchun)
        if (cellSize > 20) {
          _drawText(
              canvas,
              safeIntensity.toStringAsFixed(2), // 0.95 kabi
              col * cellSize + cellSize / 2,
              row * cellSize + cellSize / 2,
              fontSize
          );
        }
      }
    });

    // 3. Panjara (Setka) chizish - Faqat kataklar katta bo'lsa
    if (cellSize > 5) {
      paint.color = Colors.white.withOpacity(0.1);
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = 1;

      for (int i = 0; i <= safeGridSize; i++) {
        double pos = i * cellSize;
        canvas.drawLine(Offset(pos, 0), Offset(pos, size.height), paint);
        canvas.drawLine(Offset(0, pos), Offset(size.width, pos), paint);
      }
    }
  }

  // Matn chizuvchi yordamchi funksiya
  void _drawText(Canvas canvas, String text, double x, double y, double fontSize) {
    // Agar raqam 0.00 bo'lsa, yozib o'tirmaymiz (shovqinni kamaytirish uchun)
    if (text == "0.00") return;

    final textStyle = TextStyle(
        color: Colors.black, // Ochiq rangli fonda qora yozuv
        fontSize: fontSize,
        fontWeight: FontWeight.bold
    );

    final textSpan = TextSpan(text: text, style: textStyle);
    final textPainter = TextPainter(text: textSpan, textDirection: TextDirection.ltr);

    textPainter.layout();
    textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, y - textPainter.height / 2)
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}