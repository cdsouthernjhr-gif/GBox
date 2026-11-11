import 'dart:io';

import 'package:flutter/material.dart';

import '../../data/repositories/settings_repository.dart';

/// Extra colours used by GAMEBOX widgets.
@immutable
class GameboxPalette extends ThemeExtension<GameboxPalette> {
  const GameboxPalette({
    required this.background,
    required this.surface,
    required this.card,
    required this.focus,
    required this.accent,
    required this.success,
    required this.warning,
    required this.danger,
    required this.muted,
    this.wallpaperImage,
  });

  /// Custom wallpaper (local file), drawn under a dark overlay.
  final String? wallpaperImage;

  /// Background for full screens: wallpaper image if set, else gradient.
  BoxDecoration get decoration => BoxDecoration(
        gradient: background,
        image: wallpaperImage == null
            ? null
            : DecorationImage(
                image: ResizeImage(FileImage(File(wallpaperImage!)), width: 1280),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(Colors.black.withValues(alpha: 0.55), BlendMode.darken),
              ),
      );

  final Gradient background;
  final Color surface;
  final Color card;
  final Color focus;
  final Color accent;
  final Color success;
  final Color warning;
  final Color danger;
  final Color muted;

  @override
  GameboxPalette copyWith({Gradient? background}) => GameboxPalette(
        wallpaperImage: wallpaperImage,
        background: background ?? this.background,
        surface: surface,
        card: card,
        focus: focus,
        accent: accent,
        success: success,
        warning: warning,
        danger: danger,
        muted: muted,
      );

  @override
  GameboxPalette lerp(GameboxPalette? other, double t) => t < 0.5 ? this : other ?? this;

  static GameboxPalette of(BuildContext context) =>
      Theme.of(context).extension<GameboxPalette>()!;
}

/// Built-in backgrounds for the Custom Wallpaper theme. Lightweight gradients
/// (no large bitmaps) to stay friendly to 2 GB devices.
const List<(String, List<Color>)> wallpaperPresets = [
  ('Nebula', [Color(0xFF1A0B3D), Color(0xFF07131F), Color(0xFF00343F)]),
  ('Sunset Arcade', [Color(0xFF3B0A2A), Color(0xFF1B0B2E), Color(0xFF3D1E00)]),
  ('Deep Ocean', [Color(0xFF001B33), Color(0xFF00121F), Color(0xFF002B2B)]),
  ('Forest Night', [Color(0xFF0D2214), Color(0xFF07120B), Color(0xFF1F2A0A)]),
];

/// Accent colours offered in Settings (null = theme default).
const accentChoices = <int?>[
  null, 0xFF7C4DFF, 0xFF00BFA5, 0xFFFF2E88, 0xFFFF9100, 0xFF2979FF, 0xFF00C853, 0xFFFFD600, 0xFFE53935,
];

ThemeData buildTheme(AppThemeId id, {int wallpaperPreset = 0, int? accentColor, String? wallpaperImage}) {
  final (seed0, bg, surface, card, focus, accent0) = switch (id) {
    AppThemeId.darkGaming => (
        const Color(0xFF7C4DFF),
        const Color(0xFF0B0E17),
        const Color(0xFF121726),
        const Color(0xFF1A2035),
        const Color(0xFF00E5FF),
        const Color(0xFF7C4DFF),
      ),
    AppThemeId.retroArcade => (
        const Color(0xFFFF2E88),
        const Color(0xFF14061F),
        const Color(0xFF1E0B2E),
        const Color(0xFF2A1140),
        const Color(0xFFFFE600),
        const Color(0xFFFF2E88),
      ),
    AppThemeId.minimal => (
        const Color(0xFF9E9E9E),
        const Color(0xFF111111),
        const Color(0xFF181818),
        const Color(0xFF222222),
        const Color(0xFFFFFFFF),
        const Color(0xFFBDBDBD),
      ),
    AppThemeId.wallpaper => (
        const Color(0xFF00BFA5),
        const Color(0xFF0B0E17),
        const Color(0xCC121726),
        const Color(0xCC1A2035),
        const Color(0xFF64FFDA),
        const Color(0xFF00BFA5),
      ),
  };
  final accent = accentColor == null ? accent0 : Color(accentColor);
  final seed = accentColor == null ? seed0 : Color(accentColor);

  final Gradient background = switch (id) {
    AppThemeId.wallpaper => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: wallpaperPresets[wallpaperPreset.clamp(0, wallpaperPresets.length - 1)].$2,
      ),
    AppThemeId.retroArcade => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF14061F), Color(0xFF250B3A)],
      ),
    _ => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [bg, Color.lerp(bg, seed, 0.12)!],
      ),
  };

  final scheme = ColorScheme.fromSeed(
    seedColor: seed,
    brightness: Brightness.dark,
    surface: surface,
    primary: accent,
    secondary: focus,
  );

  // Sizes are in logical pixels; a 1080p TV at xhdpi is ~960x540 logical,
  // so these read comfortably from a sofa.
  const text = TextTheme(
    displaySmall: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, letterSpacing: 1.5),
    headlineSmall: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
    titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
    titleMedium: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
    bodyLarge: TextStyle(fontSize: 14),
    bodyMedium: TextStyle(fontSize: 13),
    labelLarge: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 0.8),
    bodySmall: TextStyle(fontSize: 11.5),
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: scheme,
    scaffoldBackgroundColor: bg,
    textTheme: text.apply(bodyColor: Colors.white, displayColor: Colors.white),
    focusColor: focus.withValues(alpha: 0.25),
    visualDensity: VisualDensity.standard,
    cardTheme: CardThemeData(color: card, elevation: 0, margin: EdgeInsets.zero),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? focus : Colors.white70),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: card,
      contentTextStyle: const TextStyle(color: Colors.white, fontSize: 14),
      behavior: SnackBarBehavior.floating,
    ),
    extensions: [
      GameboxPalette(
        background: background,
        surface: surface,
        card: card,
        focus: focus,
        accent: accent,
        success: const Color(0xFF00E676),
        warning: const Color(0xFFFFC400),
        danger: const Color(0xFFFF5252),
        muted: Colors.white60,
        wallpaperImage: id == AppThemeId.wallpaper ? wallpaperImage : null,
      ),
    ],
  );
}
