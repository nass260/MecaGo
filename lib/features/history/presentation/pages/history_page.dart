import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/premium_card.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  static const List<HistoryItem> _history = [
    HistoryItem(
      title: "Remplacement filtre d'habitacle HEPA",
      date: "18 août 2026",
      mileage: "42 150 km",
      savings: "35 €",
      icon: Icons.air_rounded,
      color: Color(0xFF22C55E),
    ),
    HistoryItem(
      title: "Rotation des pneus",
      date: "02 juillet 2026",
      mileage: "39 800 km",
      savings: "40 €",
      icon: Icons.tire_repair_rounded,
      color: Color(0xFF2563EB),
    ),
    HistoryItem(
      title: "Remplissage liquide lave-glace",
      date: "12 mai 2026",
      mileage: "37 100 km",
      savings: "10 €",
      icon: Icons.water_drop_rounded,
      color: Color(0xFF0EA5E9),
    ),
    HistoryItem(
      title: "Contrôle pression des pneus",
      date: "28 mars 2026",
      mileage: "34 600 km",
      savings: "15 €",
      icon: Icons.speed_rounded,
      color: Color(0xFF8B5CF6),
    ),
    HistoryItem(
      title: "Nettoyage des caméras Autopilot",
      date: "09 février 2026",
      mileage: "32 900 km",
      savings: "25 €",
      icon: Icons.camera_alt_rounded,
      color: Color(0xFFFF6A00),
    ),
  ];

  int get _totalSavings =>
      _history.fold(0, (sum, item) => sum + item.savingsValue);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Historique"),
      ),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 12, 22, 24),
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
                                size: 42,
                                color: AppColors.orange,
                              ),
                            ),
                            const SizedBox(width: 18),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Tesla Model 3",
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.navy,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    "${_history.length} interventions enregistrées",
                                    style: const TextStyle(
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

                    const SizedBox(height: 24),

                    PremiumCard(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _SummaryItem(
                              label: "Économies",
                              value: "$_totalSavings €",
                              color: AppColors.success,
                            ),
                            Container(
                              width: 1,
                              height: 48,
                              color: AppColors.border,
                            ),
                            const _SummaryItem(
                              label: "Score",
                              value: "98",
                              color: AppColors.orange,
                            ),
                            Container(
                              width: 1,
                              height: 48,
                              color: AppColors.border,
                            ),
                            const _SummaryItem(
                              label: "Année",
                              value: "2026",
                              color: AppColors.blue,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    const Text(
                      "Dernières interventions",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppColors.navy,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      "Historique chronologique de votre Tesla Model 3.",
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
                itemCount: _history.length,
                separatorBuilder: (_, __) => const SizedBox(height: 18),
                itemBuilder: (_, index) {
                  final item = _history[index];

                  return PremiumCard(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(28),
                      onTap: () {},
                      child: Padding(
                        padding: const EdgeInsets.all(22),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 58,
                              height: 58,
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.title,
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.navy,
                                      height: 1.25,
                                    ),
                                  ),

                                  const SizedBox(height: 8),

                                  Text(
                                    item.date,
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),

                                  const SizedBox(height: 4),

                                  Text(
                                    item.mileage,
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 10),

                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 7,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.success.withOpacity(.12),
                                    borderRadius: BorderRadius.circular(30),
