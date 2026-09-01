import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Une carte haut de gamme respectant le design minimaliste Apple.
/// Elle intègre des micro-ombres superposées et un contour de lumière.
class PremiumCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double blur;

  const PremiumCard({
    super.key,
    required this.child,
    this.padding,
    this.blur = 10.0, // Intensité du flou de fond (Glassmorphism)
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28.0), // Arrondi strict du cahier des charges
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding ?? const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.92), // Translucide pour le flou
            borderRadius: BorderRadius.circular(28.0),
            
            // CONTOUR DE LUMIÈRE (Bordure sub-pixel premium style iOS)
            border: Border.all(
              color: Colors.white.withOpacity(0.6),
              width: 1.0,
            ),
            
            // SUPERPOSITION D'OMBRES COMPLEXES (Méthode UI haut de gamme)
            boxShadow: [
              // 1. L'ombre large et vaporeuse pour décoller la carte du fond
              BoxShadow(
                color: const Color(0xFF111827).withOpacity(0.02),
                blurRadius: 30,
                offset: const Offset(0, 16),
              ),
              // 2. L'ombre de contact fine pour marquer la structure
              BoxShadow(
                color: const Color(0xFF111827).withOpacity(0.01),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
