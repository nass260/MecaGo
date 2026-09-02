import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/premium_card.dart';
import '../../../../core/widgets/premium_button.dart';

class TutorialCatalogPage extends StatelessWidget {
  const TutorialCatalogPage({super.key});

  static final List<TutorialItem> _tutorials = [
    TutorialItem(
      title: "Rotation des pneus",
      duration: "20 min",
      difficulty: "Débutant",
      savings: "40 €",
      icon: Icons.tire_repair_rounded,
      color: const Color(0xFF2563EB),
      progress: 1,
    ),
    TutorialItem(
      title: "Filtre d'habitacle",
      duration: "15 min",
      difficulty: "Débutant",
      savings: "35 €",
      icon: Icons.air_rounded,
      color: const Color(0xFF22C55E),
      progress: .75,
    ),
    TutorialItem(
      title: "Liquide lave-glace",
      duration: "5 min",
      difficulty: "Débutant",
      savings: "10 €",
      icon: Icons.water_drop_rounded,
      color: const Color(0xFF0EA5E9),
      progress: .45,
    ),
    TutorialItem(
      title: "Plaquettes de frein",
      duration: "60 min",
      difficulty: "Intermédiaire",
      savings: "180 €",
      icon: Icons.disc_full_rounded,
      color: const Color(0xFFFF6A00),
      progress: .25,
    ),
    TutorialItem(
      title: "Liquide de frein",
      duration: "40 min",
      difficulty: "Intermédiaire",
      savings: "70 €",
      icon: Icons.opacity_rounded,
      color: const Color(0xFF8B5CF6),
      progress: .15,
    ),
    TutorialItem(
      title: "Essuie-glaces",
      duration: "5 min",
      difficulty: "Débutant",
      savings: "25 €",
      icon: Icons.cleaning_services_rounded,
      color: const Color(0xFF14B8A6),
      progress: .90,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tutoriels"),
      ),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 10, 22, 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PremiumCard(
                      child: Padding(
                        padding: const EdgeInsets.all(22),
                        child: Row(
                          children: [
                            Container(
                              width: 74,
                              height: 74,
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(22),
                              ),
                              child: const Icon(
                                Icons.electric_car_rounded,
                                color: AppColors.orange,
                                size: 42,
                              ),
                            ),
                            const SizedBox(width: 18),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Tesla Model 3",
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.navy,
                                    ),
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    "Tutoriels adaptés à votre véhicule",
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 26),
                    const Text(
                      "Entretiens recommandés",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppColors.navy,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Sélectionnés automatiquement selon votre modèle.",
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              sliver: SliverList.separated(
                itemCount: _tutorials.length,
                separatorBuilder: (_, __) => const SizedBox(height: 18),
                itemBuilder: (_, index) {
                  final item = _tutorials[index];
                  return PremiumCard(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(28),
                      onTap: () {},
                      child: Padding(
                        padding: const EdgeInsets.all(22),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: item.color.withOpacity(.12),
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: Icon(
                                    item.icon,
                                    color: item.color,
                                    size: 30,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.title,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.navy,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: [
                                          _Tag(item.duration),
                                          _Tag(item.difficulty),
                                          _Tag("Économie ${item.savings}"),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 22),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: LinearProgressIndicator(
                                value: item.progress,
                                minHeight: 7,
                                backgroundColor: AppColors.border,
                                valueColor: AlwaysStoppedAnimation(item.color),
                              ),
                            ),
                            const SizedBox(height: 18),
                            PremiumButton(
                              text: "Ouvrir le tutoriel", // <-- CORRECTION ICI
                              onPressed: () {},
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: 30),
            ),
          ],
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

class TutorialItem {
  const TutorialItem({
    required this.title,
    required this.duration,
    required this.difficulty,
    required this.savings,
    required this.icon,
