import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'cosarc_colors.dart';

/// Editorial typography — Instrument Serif for display, Plus Jakarta Sans for UI.
abstract final class CosarcTypography {
  static TextStyle _serif({
    required double size,
    required FontWeight weight,
    double letterSpacing = 0,
    double height = 1.1,
    Color? color,
  }) =>
      GoogleFonts.instrumentSerif(
        fontSize: size,
        fontWeight: weight,
        letterSpacing: letterSpacing,
        height: height,
        color: color ?? CosarcColors.textPrimary,
      );

  static TextStyle _sans({
    required double size,
    required FontWeight weight,
    double letterSpacing = 0,
    double height = 1.4,
    Color? color,
  }) =>
      GoogleFonts.plusJakartaSans(
        fontSize: size,
        fontWeight: weight,
        letterSpacing: letterSpacing,
        height: height,
        color: color ?? CosarcColors.textSecondary,
      );

  static TextStyle display(BuildContext context, {Color? color}) => _serif(
        size: 44,
        weight: FontWeight.w400,
        letterSpacing: -0.8,
        height: 1.02,
        color: color,
      );

  static TextStyle headline(BuildContext context, {Color? color}) => _serif(
        size: 30,
        weight: FontWeight.w400,
        letterSpacing: -0.5,
        height: 1.12,
        color: color,
      );

  static TextStyle title(BuildContext context, {Color? color}) => _sans(
        size: 18,
        weight: FontWeight.w600,
        letterSpacing: -0.2,
        height: 1.3,
        color: color ?? CosarcColors.textPrimary,
      );

  static TextStyle body(BuildContext context, {Color? color}) => _sans(
        size: 15,
        weight: FontWeight.w400,
        height: 1.55,
        color: color,
      );

  static TextStyle caption(BuildContext context, {Color? color}) => _sans(
        size: 13,
        weight: FontWeight.w500,
        height: 1.45,
        color: color,
      );

  static TextStyle overline(String text, {Color? color}) => _sans(
        size: 10,
        weight: FontWeight.w700,
        letterSpacing: 2.0,
        height: 1.2,
        color: color ?? CosarcColors.textTertiary,
      );

  static TextStyle metric(String value, {Color? color}) => _sans(
        size: 38,
        weight: FontWeight.w800,
        letterSpacing: -1.4,
        height: 1,
        color: color ?? CosarcColors.textPrimary,
      );

  static TextStyle brandMark({double size = 28}) => _serif(
        size: size,
        weight: FontWeight.w400,
        letterSpacing: 4.0,
        height: 1,
        color: CosarcColors.textPrimary,
      );
}
