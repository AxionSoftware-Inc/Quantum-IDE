import 'dart:io';
import 'package:flutter/material.dart';

class TabBarWidget extends StatelessWidget {
  final List<String> openFiles;       // Ochilgan fayllar yo'li
  final int activeIndex;              // Hozir qaysi biri ochiq?
  final Function(int) onTabSwitch;    // Tab bosilganda
  final Function(int) onTabClose;     // X bosilganda

  const TabBarWidget({
    super.key,
    required this.openFiles,
    required this.activeIndex,
    required this.onTabSwitch,
    required this.onTabClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 35, // Tablar balandligi
      width: double.infinity,
      color: const Color(0xFF1E1E1E), // Asosiy fon
      child: ListView.builder(
        scrollDirection: Axis.horizontal, // Yonma-yon
        itemCount: openFiles.length,
        itemBuilder: (context, index) {
          final path = openFiles[index];
          final filename = path.split(Platform.pathSeparator).last;
          final isActive = index == activeIndex;

          return InkWell(
            onTap: () => onTabSwitch(index),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              // Aktiv tabning tepasida chiziq va foni ochroq bo'ladi
              decoration: BoxDecoration(
                color: isActive ? const Color(0xFF252526) : Colors.transparent,
                border: isActive
                    ? const Border(top: BorderSide(color: Colors.purpleAccent, width: 2))
                    : const Border(right: BorderSide(color: Colors.white10)),
              ),
              child: Row(
                children: [
                  // Fayl ikonchasi (Kichkina)
                  Icon(
                    filename.endsWith('.py') ? Icons.code : Icons.description,
                    size: 14,
                    color: isActive ? Colors.purpleAccent : Colors.grey,
                  ),
                  const SizedBox(width: 8),

                  // Fayl nomi
                  Text(
                    filename,
                    style: TextStyle(
                      color: isActive ? Colors.white : Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Yopish (X) tugmasi - Faqat sichqoncha borganda chiqsa zo'r bo'lardi,
                  // lekin hozircha doim chiqarib turamiz.
                  InkWell(
                    onTap: () => onTabClose(index),
                    borderRadius: BorderRadius.circular(10),
                    child: const Padding(
                      padding: EdgeInsets.all(2.0),
                      child: Icon(Icons.close, size: 14, color: Colors.white54),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}