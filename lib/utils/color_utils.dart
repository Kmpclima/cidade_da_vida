import 'package:flutter/material.dart';

Color? stringToColor(String? hexColor) {
  if (hexColor == null || hexColor.isEmpty) return null;
  hexColor = hexColor.toUpperCase().replaceAll("#", "");
  if (hexColor.length == 6) {
    hexColor = "FF$hexColor"; // Adiciona opacidade se não tiver
  }
  return Color(int.parse(hexColor, radix: 16));
}