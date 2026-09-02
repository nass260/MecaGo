import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class SocialLoginButton extends StatelessWidget {
  const SocialLoginButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.backgroundColor = Colors.white,
    this.foregroundColor = AppColors.navy,
  });

  // Constructeur spécifique pour le bouton Apple (Noir Premium)
  factory SocialLoginButton.apple({
    required VoidCallback onPressed,
  }) {
    return SocialLoginButton(
      icon: Icons.apple,
      label: "Continuer avec Apple",
      backgroundColor: AppColors.navy,
      foregroundColor: Colors.white,
      onPressed: onPressed,
    );
  }

  // Constructeur spécifique pour le bouton Google (Blanc Épuré)
  factory SocialLoginButton.google({
    required VoidCallback onPressed,
  }) {
    return SocialLoginButton(
      icon: Icons.g_mobiledata_rounded,
      label: "Continuer avec Google",
      onPressed: onPressed,
    );
  }

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20), // Coins arrondis style iOS
            side: backgroundColor == Colors.white
                ? const BorderSide(color: AppColors.border, width: 1.5)
                : BorderSide.none,
          ),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 26),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
