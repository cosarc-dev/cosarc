import 'package:flutter/material.dart';

/// ERP-derived Cosarc design tokens for the mobile app.
abstract final class CosarcColors {
  // Brand
  static const Color primary = Color(0xFFD7BB73);
  static const Color primaryLight = Color(0xFFF3DC9A);
  static const Color primaryMuted = Color(0x33D7BB73);
  static const Color rose = Color(0xFFDD3D71);
  static const Color accent = Color(0xFF42D888);

  // Surfaces — deep charcoal with warm undertone
  static const Color background = Color(0xFF040405);
  static const Color backgroundElevated = Color(0xFF080809);
  static const Color surface = Color(0xCC0C0C0E);
  static const Color surfaceElevated = Color(0xFF101012);
  static const Color surfaceHighlight = Color(0xFF161618);
  static const Color ink = Color(0xFF0A0A0B);

  // Text
  static const Color textPrimary = Color(0xFFF8F5EC);
  static const Color textSecondary = Color(0xB0F8F5EC);
  static const Color textTertiary = Color(0x66F8F5EC);
  static const Color textDisabled = Color(0x3DF8F5EC);

  // Borders & dividers
  static const Color border = Color(0x14FFFFFF);
  static const Color borderStrong = Color(0x21FFFFFF);
  static const Color divider = Color(0x12FFFFFF);

  // Semantic
  static const Color success = Color(0xFF42D888);
  static const Color warning = Color(0xFFFFAD66);
  static const Color error = Color(0xFFFF6B6B);
  static const Color info = Color(0xFF64A8FF);
  static const Color protein = Color(0xFF64A8FF);
  static const Color carbs = Color(0xFFFFAD66);
  static const Color fat = Color(0xFFB58CFF);

  static const Gradient appBackgroundGradient = RadialGradient(
    center: Alignment(-0.75, -1.1),
    radius: 1.5,
    colors: [
      Color(0x1AD7BB73),
      Color(0x00040405),
    ],
  );

  static const Gradient meshGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF0A0A0C),
      Color(0xFF040405),
      Color(0xFF0D0B08),
    ],
    stops: [0.0, 0.55, 1.0],
  );

  static const Gradient brandSweep = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryLight, primary],
  );

  static const Gradient roseSweep = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [rose, Color(0xFFC52D60)],
  );

  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.32),
          blurRadius: 36,
          offset: const Offset(0, 18),
        ),
      ];

  static List<BoxShadow> glow(Color color, [double opacity = 0.18]) => [
        BoxShadow(
          color: color.withOpacity(opacity),
          blurRadius: 28,
          offset: const Offset(0, 10),
        ),
      ];

  // Glass / frosted overlays
  static Color glassFill([double opacity = 0.055]) =>
      Colors.white.withOpacity(opacity);

  static Color glassBorder([double opacity = 0.12]) =>
      Colors.white.withOpacity(opacity);
}

/// Legacy aliases preserve imports across existing screens during migration.
const Color cosarcPink = CosarcColors.primary;
const Color cosarcDark = CosarcColors.background;
const Color cosarcSurface = CosarcColors.surfaceElevated;
const Color cosarcCard = CosarcColors.surfaceHighlight;
const Color cosarcAccent = CosarcColors.accent;
