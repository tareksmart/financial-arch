import 'package:flutter/material.dart';

class AppColorsDark {
  AppColorsDark._();

  // ─── Brand (same hues, kept as brand identity) ────────────
  static const Color primary       = Color(0xFF1A237E);
  static const Color primaryDark   = Color(0xFF000666);
  static const Color primaryLight  = Color(0xFF3949AB);

  // ─── Dark Surfaces (derived from primary navy hue) ────────
  static const Color background            = Color(0xFF0D0F1A); // deepest bg
  static const Color surface               = Color(0xFF131629); // cards, sheets
  static const Color surfaceContainerLow   = Color(0xFF1A1E30); // input fills
  static const Color surfaceContainerLowest= Color(0xFF0D0F1A); // modal overlay bg
  static const Color surfaceContainerHigh  = Color(0xFF1E2133); // dividers, borders
  static const Color surfaceBright         = Color(0xFF252840); // highlighted surface

  // ─── On-Primary ───────────────────────────────────────────
  static const Color onPrimary      = Color(0xFFE8EAF6); // text/icons on primary btn
  static const Color primaryContainer     = Color(0xFF1A237E); // tonal container
  static const Color onPrimaryContainer   = Color(0xFFDEE0FF); // text inside it

  // ─── Secondary (dark-adapted) ─────────────────────────────
  static const Color secondary      = Color(0xFF9FA8DA); // adapted from #625B71
  static const Color secondaryLight = Color(0xFF454870); // adapted from #CAC7DE
  static const Color secondaryDark  = Color(0xFF6B6F9E); // adapted from #49454E
  static const Color onSecondary    = Color(0xFF1A1C3A);
  static const Color secondaryContainer   = Color(0xFF1E2040);
  static const Color onSecondaryContainer = Color(0xFFDEE0FF);

  // ─── Tertiary (dark-adapted) ──────────────────────────────
  static const Color tertiary       = Color(0xFFEFB8C8); // kept (good on dark)
  static const Color tertiaryLight  = Color(0xFF4A2D38); // inverted container
  static const Color onTertiary     = Color(0xFF2D1620);
  static const Color tertiaryContainer    = Color(0xFF3A1F2C);
  static const Color onTertiaryContainer  = Color(0xFFFFD8E6);

  // ─── Semantic Colors (lightened for dark bg contrast) ─────
  static const Color success          = Color(0xFF81C784); // 4CAF50 → lighter
  static const Color onSuccess        = Color(0xFF0A2E0C);
  static const Color successContainer = Color(0xFF1B3A1C);

  static const Color error            = Color(0xFFEF9A9A); // BA1A1A → lighter
  static const Color onError          = Color(0xFF3A0909);
  static const Color errorContainer   = Color(0xFF3A1010);

  static const Color warning          = Color(0xFFFFD54F); // FFC107 → lighter
  static const Color onWarning        = Color(0xFF2E2000);
  static const Color warningContainer = Color(0xFF3A2E00);

  static const Color info             = Color(0xFF64B5F6); // 2196F3 → lighter
  static const Color onInfo           = Color(0xFF0A1F3A);
  static const Color infoContainer    = Color(0xFF0D2A4A);

  // ─── Text Colors ──────────────────────────────────────────
  static const Color onSurface        = Color(0xFFC5CAE9); // adapted from #191C1E
  static const Color onSurfaceVariant = Color(0xFF7986A8); // adapted from #454652
  static const Color outlineVariant   = Color(0xFF2A3050); // adapted from #C6C5D4
  static const Color outline          = Color(0xFF3D4270);

  // ─── Utility ──────────────────────────────────────────────
  static const Color transparent = Colors.transparent;
  static const Color white       = Color(0xFFFFFFFF);
  static const Color black       = Color(0xFF000000);
  static const Color scrim       = Color(0x80000000);
}