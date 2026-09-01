import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Un bouton premium qui s'écrase légèrement sous le doigt (-2%)
/// pour simuler une sensation mécanique et un retour utilisateur haut de gamme.
class PremiumButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color textColor;
  final bool isLoading;

  const PremiumButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor = AppColors.orange, // Orange officiel MecaGo por défaut
    this.textColor = Colors.white,
    this.isLoading = false,
  });

  @override
  State<PremiumButton> createState() => _PremiumButtonState();
}

class _PremiumButtonState extends State<PremiumButton> with SingleTickerProviderStateMixin {
  late double _scale;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Animation de pression rapide (150 ms) identique aux standards Apple
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      lowerBound: 0.0,
      upperBound: 0.02, // Réduction maximale de 2%
    )..addListener(() {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _scale = 1 - _controller.value;

    return GestureDetector(
      onTapDown: (_) => widget.isLoading ? null : _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.isLoading ? null : widget.onPressed,
      child: Transform.scale(
        scale: _scale,
        child: Container(
          width: double.infinity,
          height: 56, // Hauteur optimale pour l'ergonomie (Mains sales)
          decoration: BoxDecoration(
            color: widget.isLoading ? widget.backgroundColor.withOpacity(0.6) : widget.backgroundColor,
            borderRadius: BorderRadius.circular(24.0), // Arrondi harmonisé
            boxShadow: [
              // Ombre portée lumineuse sous le bouton
              BoxShadow(
                color: widget.backgroundColor.withOpacity(0.25),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: widget.isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    widget.text,
                    style: TextStyle(
                      color: widget.textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.2,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
