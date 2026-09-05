import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/premium_card.dart';
import '../../../../core/widgets/premium_button.dart';
import '../managers/reminders_notifier.dart'; // <-- Écoute du contrôleur de télémétrie

class MaintenanceReminderPage extends StatefulWidget {
  const MaintenanceReminderPage({super.key});

  @override
  State<MaintenanceReminderPage> createState() => _MaintenanceReminderPageState();
}

class _MaintenanceReminderPageState extends State<MaintenanceReminderPage> {
  final RemindersNotifier _notifier = RemindersNotifier();

  @override
  void initState() {
    super.initState();
    // Déclenche l'extraction et le calcul de l'usure spécifique du véhicule ID 1 (Tesla ou Clio lue)
    _notifier.loadVehicleReminders(1);
  }

  @override
  Widget build(BuildContext context) {
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
          'Rappels intelligents',
          style: TextStyle(color: AppColors.navy, fontWeight: FontWeight.w800, letterSpacing: -0.5),
        ),
      ),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _notifier,
          builder: (context, _) {
            // Rendu de chargement iOS Style pendant le calcul de dégradation algorithmique
            if (_notifier.isLoading) {
              return const Center(
                child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppColors.orange)),
              );
            }

            if (_notifier.errorMessage != null || _notifier.reminders.isEmpty) {
              return Center(
                child: Text(
                  _notifier.errorMessage ?? "Aucun rappel configuré pour ce véhicule.",
                  style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                ),
              );
            }

            final reminders = _notifier.reminders;

            return Column(
              children: [
                // 1. CARTE DE SYNTHÈSE CRITIQUE SPÉCIFIQUE
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                  child: PremiumCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.analytics_rounded, color: AppColors.orange, size: 26),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Analyse de Télémétrie',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.navy),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'Santé générale de maintenance estimée',
                          style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w500, fontSize: 13),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: const [
                            Text('76', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: AppColors.navy, fontFamily: 'monospace')),
                            SizedBox(width: 2),
                            Padding(
                              padding: EdgeInsets.only(bottom: 6),
                              child: Text('/100', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold, fontSize: 14)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: const LinearProgressIndicator(
                            value: 0.76,
                            minHeight: 8,
                            backgroundColor: AppColors.border,
                            valueColor: AlwaysStoppedAnimation(AppColors.orange),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // 2. LISTE CHRONOLOGIQUE DES COMPOSANTS ET USURES LIÉS AU MODÈLE
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    itemCount: reminders.length,
                    physics: const BouncingScrollPhysics(),
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final item = reminders[index];
                      final Color statusColor = Color(item.colorValue);

                      return PremiumCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    item.title,
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.navy, letterSpacing: -0.3),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: statusColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '${item.remaining}% restant',
                                    style: TextStyle(color: statusColor, fontWeight: FontWeight.extrabold, fontSize: 11),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.subtitle,
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: item.remaining / 100,
                                minHeight: 7,
                                backgroundColor: AppColors.border,
                                valueColor: AlwaysStoppedAnimation(statusColor),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Icon(Icons.speed_rounded, size: 16, color: AppColors.textSecondary),
                                const SizedBox(width: 6),
                                Text(
                                  item.mileage,
                                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                
                // 3. BOUTON D'ACTION PROGRAMMÉ
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: PremiumButton(
                    text: 'Synchroniser le kilométrage',
                    onPressed: () {},
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
