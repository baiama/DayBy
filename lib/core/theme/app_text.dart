import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Text styles from the «typography» frame plus the fonts used on screens.
abstract final class AppText {
  static TextStyle logo(Color color) =>
      GoogleFonts.inter(fontSize: 48, fontWeight: FontWeight.w700, color: color);

  static TextStyle h1(Color color) => GoogleFonts.figtree(
      fontSize: 32, height: 1, fontWeight: FontWeight.w800, color: color);
  static TextStyle h2(Color color) => GoogleFonts.figtree(
      fontSize: 24, height: 1, fontWeight: FontWeight.w800, color: color);
  static TextStyle h3(Color color) => GoogleFonts.figtree(
      fontSize: 20, height: 0.9, fontWeight: FontWeight.w800, color: color);

  static TextStyle label(Color color) => GoogleFonts.figtree(
      fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w700, color: color);
  static TextStyle body(Color color) =>
      GoogleFonts.figtree(fontSize: 14, color: color);
  static TextStyle caption(Color color) =>
      GoogleFonts.figtree(fontSize: 10, height: 2, color: color);

  /// Farro: buttons and section titles.
  static TextStyle button(Color color) => GoogleFonts.farro(
      fontSize: 13,
      height: 18 / 13,
      fontWeight: FontWeight.w700,
      letterSpacing: 1,
      color: color);
  static TextStyle section(Color color) => GoogleFonts.farro(
      fontSize: 24,
      height: 18 / 24,
      fontWeight: FontWeight.w700,
      letterSpacing: 1,
      color: color);

  /// JetBrains Mono: links, nav labels, small hints.
  static TextStyle mono(Color color,
          {double size = 12, FontWeight weight = FontWeight.w400}) =>
      GoogleFonts.jetBrainsMono(fontSize: size, fontWeight: weight, color: color);

  /// Inter Medium 16: profile and settings rows.
  static TextStyle setting(Color color) => GoogleFonts.inter(
      fontSize: 16, fontWeight: FontWeight.w500, letterSpacing: 0.8, color: color);
}
