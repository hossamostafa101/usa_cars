import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// --- DIBRAH / دَبْرَة brand palette (no greens) ---
const kOlive       = Color(0xFF585B61); // primary
const kOliveDark   = Color(0xFF842FAE);
const kOliveLight  = Color(0xFF7B7D85);
const kSage        = Color(0xFFF6F3F1); // background
const kCharcoal    = Color(0xFF292929); // text on light
const kOutline     = Color(0xFFB7BBC0); // borders
const kSurfaceLite = Colors.white;
const kSurfaceDark = Color(0xFF181517);
const kBgDark      = Color(0xFF0E110F);

ThemeData _buildTheme(Brightness brightness) {
  final isLight = brightness == Brightness.light;

  // Explicit ColorScheme (no fromSeed → no accidental greens)
  final scheme = ColorScheme(
    brightness: brightness,
    primary: kOlive,
    onPrimary: Colors.white,
    primaryContainer: const Color(0xFFD8DDD8),
    onPrimaryContainer: kCharcoal,

    secondary: kOliveLight,
    onSecondary: Colors.white,
    secondaryContainer: const Color(0xFFC9D0C8),
    onSecondaryContainer: kCharcoal,

    tertiary: kOliveDark,
    onTertiary: Colors.white,
    tertiaryContainer: const Color(0xFFD3D9D3),
    onTertiaryContainer: kCharcoal,

    error: const Color(0xFFBA1A1A),
    onError: Colors.white,

    background: isLight ? kSage : kBgDark,
    onBackground: isLight ? kCharcoal : Colors.white,

    surface: isLight ? kSurfaceLite : kSurfaceDark,
    onSurface: isLight ? kCharcoal : Colors.white,

    surfaceVariant: isLight ? const Color(0xFFE9EEE8) : const Color(0xFF1E211E),
    onSurfaceVariant: isLight ? kCharcoal.withOpacity(.72) : Colors.white70,

    outline: kOutline,
    shadow: Colors.black.withOpacity(.25),
    scrim: Colors.black,
    inverseSurface: isLight ? kSurfaceDark : kSurfaceLite,
    onInverseSurface: isLight ? Colors.white : kCharcoal,
    inversePrimary: kOliveLight,
  );

  final textTheme = GoogleFonts.cairoTextTheme().apply(
    bodyColor: scheme.onSurface,
    displayColor: scheme.onSurface,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: scheme.background,
    cardColor: scheme.surface,

    // Global font
    fontFamily: GoogleFonts.cairo().fontFamily,
    textTheme: textTheme,

    appBarTheme: AppBarTheme(
      backgroundColor: isLight ? kSurfaceLite : const Color(0xFF121412),
      foregroundColor: scheme.onSurface,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.cairo(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: scheme.onSurface,
      ),
      iconTheme: IconThemeData(color: scheme.onSurface),
    ),

    iconTheme: IconThemeData(color: scheme.primary),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.cairo(fontWeight: FontWeight.w800),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: scheme.primary,
        side: BorderSide(color: scheme.primary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.cairo(fontWeight: FontWeight.w700),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: isLight ? kSurfaceLite : const Color(0xFF1A1D1B),
      hintStyle: TextStyle(color: isLight ? Colors.black45 : Colors.white60),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: isLight ? const Color(0x14000000) : Colors.white12),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: isLight ? const Color(0x14000000) : Colors.white12),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: scheme.primary, width: 1.6),
      ),
    ),

    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      selectedItemColor: scheme.primary,
      unselectedItemColor: isLight ? Colors.black54 : Colors.white70,
      backgroundColor: Colors.transparent,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: GoogleFonts.cairo(fontWeight: FontWeight.w800, fontSize: 11),
      unselectedLabelStyle: GoogleFonts.cairo(fontWeight: FontWeight.w600, fontSize: 11),
    ),

    switchTheme: SwitchThemeData(
      thumbColor: WidgetStatePropertyAll(scheme.primary),
      trackColor: WidgetStatePropertyAll(scheme.primary.withOpacity(.35)),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStatePropertyAll(scheme.primary),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    ),

    dividerTheme: DividerThemeData(
      color: isLight ? const Color(0x1F000000) : Colors.white12,
      thickness: 1,
    ),
  );
}

final ThemeData lightModeTheme = _buildTheme(Brightness.light);
final ThemeData darkModeTheme  = _buildTheme(Brightness.dark);
