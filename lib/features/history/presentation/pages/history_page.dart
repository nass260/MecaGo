import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/premium_card.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Liste chronologique universelle des réparations (Toutes Marques Europe)
    final historyItems = [
      const _HistoryItem(
        title: "Remplacement filtre d'habitacle HEPA",
        date: "18 août 2026",
        mileage: "42 150 km",
        savings: "35 €",
        icon: Icons.air_rounded,
        color: AppColors.success,
      ),
      const _HistoryItem(
        title: "Rotation des pneumatiques",
        date: "02 juillet 2026",
        mileage: "39 800 km",
        savings: "40 €",
        icon: Icons.tire_repair_rounded,
        color: AppColors.orange,
      ),
      const _HistoryItem(
        title: "Remplissage liquide lave-glace",
        date: "12 mai 2026",
        mileage: "37 100 km",
        savings: "10 €",
        icon: Icons.water_drop_rounded,
        color: Colors.blue,
      ),
      const _HistoryItem(
        title: "Contrôle pression des pneus",
        date: "28 mars 2026",
        mileage: "34 600 km",
        savings: "15 €",
        icon: Icons.speed_rounded,
        color: Colors.purple,
      ),
      const _HistoryItem(
        title: "Nettoyage capteurs d'assistance",
        date: "09 février 2026",
        mileage: "32 900 km",
        savings: "25 €",
        icon: Icons.center_focus_strong_rounded,
        color: AppColors.navy,
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Historique',
          style: TextStyle(color: AppColors.navy, fontWeight: FontWeight.w800, letterSpacing: -0.5),
        ),
      ),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Section 1 : En-tête de synthèse des gains financiers
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: PremiumCard(
                  padding: const EdgeInsets.all(22),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSummaryStat(label: "Économies", value: "125 €", color: AppColors.success),
                      Container(width: 1, height: 44, color: AppColors.border),
                      _buildSummaryStat(label: "Interventions", value: "${historyItems.length}", color: AppColors.navy),
                      Container(width: 1, height: 44, color: AppColors.border),
                      _buildSummaryStat(label: "Année", value: "2026", color: AppColors.orange),
                    ],
                  ),
                ),
              ),
            ),

            // Titre de section liste
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: const Text(
                  'Toutes les interventions',
                  style: TextStyle(color: AppColors.navy, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: -0.3),
                ),
              ),
            ),

            // Section 2 : Liste chronologique défilante
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              sliver: SliverList.separated(
                itemCount: historyItems.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final item = historyItems[index];

                  return PremiumCard(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Conteneur d'icône d'intervention
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: item.color.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(item.icon, color: item.color, size: 24),
                        ),
                        const SizedBox(width: 16),
                        
                        // Textes descriptifs de l'historique
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                style: const TextStyle(color: AppColors.navy, fontSize: 16, fontWeight: FontWeight.bold, height: 1.25),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${item.date}  •  ${item.mileage}',
                                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Badge de statut "Validé" et montant économisé constructeur
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.success.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                "Validé",
                                style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 11),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              item.savings,
                              style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.w900, fontSize: 17, fontFamily: 'monospace'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget interne pour l'affichage de synthèse des compteurs
  static Widget _buildSummaryStat({required String label, required String value, required Color color}) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.w900, fontFamily: 'monospace'),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}

class _HistoryItem {
  final String title;
  final String date;
  final String mileage;
  final String savings;
  final IconData icon;
  final Color color;

  const _HistoryItem({
    required this.title,
    required this.date,
    required this.mileage,
    required this.savings,
    required this.icon,
    required this.color,
  });
}
