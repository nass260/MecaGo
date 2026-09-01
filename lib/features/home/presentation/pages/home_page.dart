import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              // 1. BARRE SUPÉRIEURE (Style Apple épuré)
              Row(
                mainAxisAlignment: MainAxisAlignment.between,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mon Tableau de Bord',
                        style: AppTheme.light.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Bonjour, Pro 🛠️',
                        style: AppTheme.light.textTheme.displayLarge?.copyWith(
                          fontSize: 26,
                        ),
                      ),
                    ],
                  ),
                  // Icône notification premium
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Icon(Icons.notifications_none_rounded, color: AppColors.navy),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // 2. CARTE PREMIUM : MECA GO SCORE™ (Élément clé V1)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    children: [
                      // Jauge circulaire de score
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          const SizedBox(
                            width: 74,
                            height: 74,
                            child: CircularProgressIndicator(
                              value: 0.85, // 85% de santé
                              strokeWidth: 8,
                              backgroundColor: AppColors.background,
                              valueColor: AlwaysStoppedAnimation<Color>(AppColors.success),
                            ),
                          ),
                          Text(
                            '85',
                            style: AppTheme.light.textTheme.headlineLarge?.copyWith(
                              fontSize: 22,
                              color: AppColors.navy,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 20),
                      // Infos du score
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'MecaGo Score™',
                              style: AppTheme.light.textTheme.headlineMedium?.copyWith(
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Votre véhicule est en excellent état général. Prochain entretien dans 4 500 km.',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // 3. ZONE SÉLECTION VÉHICULE (Simulation Tesla/Clio)
              Text(
                'Véhicule Actif',
                style: AppTheme.light.textTheme.headlineMedium?.copyWith(fontSize: 20),
              ),
              const SizedBox(height: 14),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.between,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Renault Clio 5',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.navy),
                              ),
                              SizedBox(height: 2),
                              Text(
                                '1.5 dCi - 95ch',
                                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                              ),
                            ],
                          ),
                          // Badge Plaque d'immatriculation
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, py: 6),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.navy, width: 1.5),
                            ),
                            child: const Text(
                              'AB-123-CD',
                              style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'monospace', color: AppColors.navy),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Zone image véhicule détourée
                      Container(
                        width: double.infinity,
                        height: 140,
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.directions_car_filled_rounded,
                            size: 80,
                            color: Color(0xFFCBD5E1),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
