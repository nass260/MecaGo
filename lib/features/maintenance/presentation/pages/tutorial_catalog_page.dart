import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/premium_card.dart';

class TutorialCatalogPage extends StatelessWidget {
  const TutorialCatalogPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Liste des entretiens disponibles (Universels pour le parc automobile)
    final interventions = [
      const _MaintenanceCardItem(
        title: "Filtre d'habitacle HEPA",
        duration: "15 min",
        difficulty: "Facile",
        savings: "35 €",
        icon: Icons.air_rounded,
        tag: "Recommandé",
        tagColor: AppColors.orange,
      ),
      const _MaintenanceCardItem(
        title: "Rotation des pneumatiques",
        duration: "30 min",
        difficulty: "Intermédiaire",
        savings: "40 €",
        icon: Icons.tire_repair_rounded,
        tag: "À faire",
        tagColor: Colors.amber,
      ),
      const _MaintenanceCardItem(
        title: "Liquide de lave-glace",
        duration: "5 min",
        difficulty: "Très facile",
        savings: "10 €",
        icon: Icons.water_drop_rounded,
        tag: "À jour",
        tagColor: AppColors.success,
      ),
      const _MaintenanceCardItem(
        title: "Contrôle des plaquettes",
        duration: "20 min",
        difficulty: "Intermédiaire",
        savings: "50 €",
        icon: Icons.disc_full_rounded,
        tag: "Conseillé",
        tagColor: Colors.blue,
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.navy),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Guide d’entretien',
          style: TextStyle(
            color: AppColors.navy,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bandeau d'en-tête du catalogue
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'INTERVENTIONS DISPONIBLES',
                    style: TextStyle(color: AppColors.orange, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Prenez soin de votre véhicule',
                    style: TextStyle(color: AppColors.navy, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: -0.6),
                  ),
                ],
              ),
            ),

            // Liste défilante des fiches d'entretien de luxe
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                itemCount: interventions.length,
                physics: const BouncingScrollPhysics(),
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final item = interventions[index];
                  return PremiumCard(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(24),
                      onTap: () => context.push('/tutorial-detail'), // Ouvre le guide en 8 étapes
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            // Icône technique enveloppée
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(item.icon, color: AppColors.orange, size: 24),
                            ),
                            const SizedBox(width: 16),
                            
                            // Informations textuelles
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        item.tag,
                                        style: TextStyle(color: item.tagColor, fontSize: 11, fontWeight: FontWeight.extrabold, letterSpacing: 0.2),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item.title,
                                    style: const TextStyle(color: AppColors.navy, fontSize: 17, fontWeight: FontWeight.bold, letterSpacing: -0.3),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '⏱️ ${item.duration}  •  📊 ${item.difficulty}',
                                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ),
                            
                            // Badge d'Économie Réalisée Style AUTODOC Premium
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  item.savings,
                                  style: const TextStyle(color: AppColors.success, fontSize: 20, fontWeight: FontWeight.w900, fontFamily: 'monospace'),
                                ),
                                const Text(
                                  'd’économie',
                                  style: TextStyle(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
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
}

// Classe de transfert d'informations interne
class _MaintenanceCardItem {
  final String title;
  final String duration;
  final String difficulty;
  final String savings;
  final IconData icon;
  final String tag;
  final Color tagColor;

  const _MaintenanceCardItem({
    required this.title,
    required this.duration,
    required this.difficulty,
    required this.savings,
    required this.icon,
    required this.tag,
    required this.tagColor,
  });
}
