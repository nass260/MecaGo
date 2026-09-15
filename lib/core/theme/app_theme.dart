// lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';

class AppColors {
  static const Color orange = Color(0xFFFF7A1A);
  static const Color orangeDark = Color(0xFFFF5A00);
  static const Color orangeLight = Color(0xFFFFB380);

  static const Color navy = Color(0xFF0A0F1C);
  static const Color navyLight = Color(0xFF1E293B);

  static const Color textSecondary = Color(0xFF64748B);
  static const Color textLight = Color(0xFF94A3B8);

  // ✅ FOND ORIGINAL (qui marchait)
  static const Color background = Color(0xFFF8FAFC);
  static const Color white = Colors.white;
  static const Color border = Color(0xFFE2E8F0);

  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFF0FDF4);

  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);

  static Color glassWhite = Colors.white.withOpacity(0.7);
  static Color glassBorder = Colors.white.withOpacity(0.3);
}

class AppShadows {
  static List<BoxShadow> card = [
    BoxShadow(
      color: const Color(0xFF0A0F1C).withOpacity(0.04),
      blurRadius: 20,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: const Color(0xFF0A0F1C).withOpacity(0.02),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> orangeButton = [
    BoxShadow(
      color: AppColors.orange.withOpacity(0.35),
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
  ];

  static List<BoxShadow> hero = [
    BoxShadow(
      color: const Color(0xFF0A0F1C).withOpacity(0.15),
      blurRadius: 30,
      offset: const Offset(0, 10),
    ),
  ];
}

class AppGradients {
  static const LinearGradient orange = LinearGradient(
    colors: [Color(0xFFFF7A1A), Color(0xFFFF5A00)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient navy = LinearGradient(
    colors: [Color(0xFF0A0F1C), Color(0xFF1E293B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}