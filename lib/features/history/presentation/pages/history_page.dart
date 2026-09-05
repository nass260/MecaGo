import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/premium_card.dart';
import '../managers/history_notifier.dart'; // <-- 1. Importation du gestionnaire d'état

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  // Initialisation locale du contrôleur connecté du Sprint 4
  final HistoryNotifier _notifier = HistoryNotifier();

  @override
  void initState() {
    super.initState();
    // Déclenche l'extraction asynchrone et le calcul des gains dès l'ouverture de l'onglet
    _notifier.loadMaintenanceHistory();
  }

  @override
  Widget build(BuildContext context) {
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
      // 2. Utilisation d'un AnimatedBuilder pour rafraîchir dynamiquement l'interface
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _notifier,
          builder: (context, _) {
            // Affichage d'un indicateur de chargement premium pendant l'agrégation SQLite
            if (_notifier.isLoading) {
              return const Center(
                child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppColors.orange)),
              );
            }

            // Gestion de l'état d'erreur ou d'historique vide
            if (_notifier.errorMessage != null || _notifier.historyItems.isEmpty) {
              return Center(
                child: Text(
                  _notifier.errorMessage ?? "Aucune intervention consignée pour le moment.",
                  style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                ),
              );
            }

            final historyItems = _notifier.historyItems;

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Section 1 : En-tête de synthèse dynamique des gains financiers
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                    child: PremiumCard(
                      padding: const EdgeInsets.all(22),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildSummaryStat(
                            label: "Économies", 
                            value: "${_notifier.totalSavings} €", // Somme calculée en temps réel
                            color: AppColors.success
                          ),
                          Container(width: 1, height: 44, color: AppColors.border),
                          _buildSummaryStat(
                            label: "Interventions", 
                            value: "${historyItems.length}", 
                            color: AppColors.navy
                          ),
                          Container(width: 1, height: 44, color: AppColors.border),
                          _buildSummaryStat(
                            label: "Année", 
                            value: "2026", 
                            color: AppColors.orange
                          ),
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

                // Section 2 : Liste chronologique défilante dynamique
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
                            // Conteneur d'icône d'intervention dynamique
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: AppColors.orange.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(
                                IconData(item.iconCodePoint, fontFamily: 'MaterialIcons'), 
                                color: AppColors.orange, 
                                size: 24
                              ),
                            ),
                            const SizedBox(width: 16),
                            
                            // Textes descriptifs réels extraits de SQLite
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

                            // Badge de statut "Validé" et montant d'économie réel
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
                                  '${item.savings} €',
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
            );
          },
        ),
      ),
    );
  }

  // Widget interne de rendu de synthèse des compteurs
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
