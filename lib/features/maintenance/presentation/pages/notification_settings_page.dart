import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/premium_card.dart';
import '../../../../core/widgets/premium_button.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() => _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  bool _wearAlerts = true;
  bool _technicalControl = true;
  bool _savingsAlerts = false;
  bool _weeklySummary = true;

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
          'Notifications',
          style: TextStyle(
            color: AppColors.navy,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Alertes de maintenance',
                      style: TextStyle(
                        color: AppColors.navy,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Configurez la manière dont MecaGo vous alerte sur l’état et l’usure de votre véhicule.',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Section 1 : Alertes d'usures (Huile, Filtres, Courroie, Disques...)
                    PremiumCard(
                      child: Column(
                        children: [
                          _buildSwitchRow(
                            icon: Icons.error_outline_rounded,
                            title: 'Usure critique de pièce',
                            subtitle: 'Alerte immédiate sous les 20% d’efficacité (Alerte Orange)',
                            value: _wearAlerts,
                            onChanged: (val) => setState(() => _wearAlerts = val),
                          ),
                          Divider(height: 24, color: Colors.grey.shade100),
                          _buildSwitchRow(
                            icon: Icons.calendar_today_rounded,
                            title: 'Échéances réglementaires',
                            subtitle: 'Contrôle technique SIV et révisions constructeurs',
                            value: _technicalControl,
                            onChanged: (val) => setState(() => _technicalControl = val),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),
                    const Text(
                      'Communauté & Économies',
                      style: TextStyle(
                        color: AppColors.navy,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Section 2 : Gestion des économies réalisées (Remplacements DIY)
                    PremiumCard(
                      child: Column(
                        children: [
                          _buildSwitchRow(
                            icon: Icons.monetization_on_outlined,
                            title: 'Rapports d’économies',
                            subtitle: 'Notification lors d’un gain validé sur le MecaGo Score™',
                            value: _savingsAlerts,
                            onChanged: (val) => setState(() => _savingsAlerts = val),
                          ),
                          Divider(height: 24, color: Colors.grey.shade100),
                          _buildSwitchRow(
                            icon: Icons.insights_rounded,
                            title: 'Résumé hebdomadaire',
                            subtitle: 'Bilan de santé global de votre garage chaque lundi',
                            value: _weeklySummary,
                            onChanged: (val) => setState(() => _weeklySummary = val),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: PremiumButton(
                text: 'Enregistrer les préférences',
                onPressed: () {
                  Navigator.of(context).pop(); 
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.navy, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(color: AppColors.navy, fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
            ],
          ),
        ),
        Switch.adaptive(
          value: value,
          activeColor: AppColors.orange,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
