import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class QuarterlySavingsChart extends StatelessWidget {
  final Map<String, double> quarterlyData;

  const QuarterlySavingsChart({
    super.key,
    required this.quarterlyData,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Recherche de la valeur maximale pour calculer des proportions visuelles équilibrées
    double maxSavings = 1.0;
    quarterlyData.forEach((_, value) {
      if (value > maxSavings) maxSavings = value;
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: quarterlyData.entries.map((entry) {
        final String quarterName = entry.key;
        final double savingsValue = entry.value;
        
        // Calcul du ratio de remplissage de la jauge (entre 0.0 et 1.0)
        final double fillRatio = savingsValue / maxSavings;

        return Padding(
          padding: const EdgeInsets.only(bottom: 14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    quarterName,
                    style: const TextStyle(color: AppColors.navy, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${savingsValue.toStringAsFixed(0)} €',
                    style: const TextStyle(color: AppColors.success, fontSize: 13, fontWeight: FontWeight.black, fontFamily: 'monospace'),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Stack(
                children: [
                  // Fond de la jauge
                  Container(
                    width: double.infinity,
                    height: 10,
                    decoration: BoxDecoration(
                      color: AppColors.border.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  // Barre de progression proportionnelle animée
                  FractionallySizedBox(
                    widthFactor: fillRatio == 0 ? 0.02 : fillRatio,
                    child: Container(
                      height: 10,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.success, Color(0xFF34D399)],
                        ),
                        borderRadius: BorderRadius.circular(5),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.success.withOpacity(0.15),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
