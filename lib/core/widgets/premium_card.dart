// lib/core/widgets/premium_card.dart
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PremiumCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final bool glass;

  const PremiumCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.color,
    this.glass = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? (glass ? AppColors.glassWhite : Colors.white),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: glass
              ? AppColors.glassBorder
              : AppColors.border.withOpacity(0.5),
          width: 1.5,
        ),
        boxShadow: AppShadows.card,
      ),
      child: child,
    );
  }
}