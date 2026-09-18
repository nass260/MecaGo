import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/premium_card.dart';

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              // 1. EN-TÊTE ÉPURÉ (Style Apple)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'VOTRE IMPACT FINANCIER',
                        style: TextStyle(
                          color: AppColors.orange,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Statistiques',
                        style: TextStyle(
                          color: AppColors.navy,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // 2. LE CHIFFRE CLÉ : LE GRAND COMPTEUR D'ÉCONOMIES CORRIGÉ VIA SIZEDBOX
              PremiumCard(
                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Économies totales réalisées',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '485,00 €',
                        style: TextStyle(
                          color: AppColors.success,
                          fontSize: 42,
                          fontWeight: FontWeight.extrabold,
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.success.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              '▲ +12%',
                              style: TextStyle(color: AppColors.success, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'par rapport au mois dernier',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // 3. RÉPARTITION DES PROFITS PAR INTERVENTION
              const Text(
                'Détail par catégorie',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.navy),
              ),
              const SizedBox(height: 14),

              _buildStatItem(
                category: 'Filtres & Air',
                savedAmount: '65,00 €',
                percentage: 0.15,
                icon: '💨',
              ),
              _buildStatItem(
                category: 'Freinage',
                savedAmount: '240,00 €',
                percentage: 0.55,
                icon: '🧪',
              ),
              _buildStatItem(
                category: 'Électricité & Batterie',
                savedAmount: '180,00 €',
                percentage: 0.30,
                icon: '⚡',
              ),

              const SizedBox(height: 20),

              // 4. MESSAGE MOTIVANT : L'IMPACT CO2 NETTOYÉ DE SON EFFET DE FLOU
              PremiumCard(
                child: Row(
                  children: [
                    const Text('🌱', style: TextStyle(fontSize: 24)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Éco-Entretien',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.navy),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'En prolongeant la durée de vie de vos pièces, vous réduisez l’empreinte carbone de votre Tesla de 14%.',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required String category,
    required String savedAmount,
    required double percentage,
    required String icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14.0),
      child: PremiumCard(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(icon, style: const TextStyle(fontSize: 18)),
                    const SizedBox(width: 12),
                    Text(category, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.navy)),
                  ],
                ),
                Text(savedAmount, style: const TextStyle(fontWeight: FontWeight.extrabold, fontSize: 15, color: AppColors.navy)),
              ],
            ),
            const SizedBox(height: 12),
            Stack(
              children: [
                Container(
                  height: 6,
                  width: double.infinity,
                  decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(3)),
                ),
                FractionallySizedBox(
                  widthFactor: percentage,
                  child: Container(
                    height: 6,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.orange, Colors.amber],
                      ),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
