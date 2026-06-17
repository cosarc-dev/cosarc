import 'package:flutter/material.dart';

/// COSARC brand palette — matches the Premium Gym ERP web dashboard.
abstract final class CosarcColors {
  static const Color gold = Color(0xFFC9A962);
  static const Color goldLight = Color(0xFFE5D4A1);
  static const Color goldDark = Color(0xFF9A7B3C);
  static const Color goldMuted = Color(0xFF8B7355);

  static const Color black = Color(0xFF000000);
  static const Color charcoal = Color(0xFF0A0A0A);
  static const Color background = Color(0xFF0C0C0C);
  static const Color surface = Color(0xFF121212);
  static const Color card = Color(0xFF1A1A1A);
  static const Color border = Color(0xFF2A2A2A);
  static const Color inputFill = Color(0xFF161616);

  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xB3FFFFFF);
  static const Color textMuted = Color(0x66FFFFFF);

  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFE53935);
  static const Color info = Color(0xFF42A5F5);

  /// Legacy alias — all accent usage now maps to gold.
  static const Color accent = gold;
}
