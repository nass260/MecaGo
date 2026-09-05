import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/premium_card.dart';
import '../../../../core/widgets/premium_button.dart';
import '../../history/presentation/managers/history_notifier.dart'; // <-- Écoute des gains calculés

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Liaison asynchrone avec les données de l'historique de maintenance SQLite
  final HistoryNotifier _historyNotifier = HistoryNotifier();

  @override
  void initState() {
    super.initState();
    _historyNotifier.loadMaintenanceHistory();
  }

  @override
  Widget build(BuildContext context) {
    const int mecaGoScore = 85;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Mon Profil',
          style: TextStyle(
            color: AppColors.navy,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _historyNotifier,
          builder: (context, _) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                  // 1. BADGE PREMIUM DÉGRADÉ HISTORIQUE MECA GO STYLE
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF6A00), Color(0xFFFFA64D)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF6A00).withOpacity(0.25),
                          blurRadius: 28,
                          offset: const Offset(0, 12),
                        ),
                      ],
                      border: Border.all(color: Colors.white.withOpacity(0.45)),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 30),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'MecaGo Premium 👑',
                                style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 14),
                        Text(
                          'Accès illimité aux tutoriels constructeurs, rapports d’usure et diagnostic intelligent.',
                          style: TextStyle(color: Colors.white, height: 1.45, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  const Text(
                    'Votre activité',
                    style: TextStyle(color: AppColors.navy, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: -0.3),
                  ),
                  const SizedBox(height: 14),

                  // 2. DOUBLE COMPTEUR D'ACTIVITÉ CONNECTÉ AUX LOGS
                  Row(
                    children: [
                      Expanded(
                        child: PremiumCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.emoji_events_rounded, color: AppColors.orange, size: 30),
                              const SizedBox(height: 14),
                              const Text('MecaGo Score™', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                              const SizedBox(height: 6),
                              const Text('$mecaGoScore', style: TextStyle(color: AppColors.navy, fontSize: 32, fontWeight: FontWeight.w800)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: PremiumCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.savings_rounded, color: AppColors.success, size: 30),
                              const SizedBox(height: 14),
                              const Text('Économies', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                              const SizedBox(height: 6),
                              Text(
                                '${_historyNotifier.totalSavings} €', // Sommation automatique réelle lue en base
                                style: const TextStyle(color: AppColors.navy, fontSize: 28, fontWeight: FontWeight.w800),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  const Text(
                    'Réglages',
                    style: TextStyle(color: AppColors.navy, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: -0.3),
                  ),
                  const SizedBox(height: 14),

                  // 3. MENU INTERACTIF CONNECTÉ AU GO_ROUTER CENTRAL DE PRODUCTION
                  PremiumCard(
                    child: Column(
                      children: [
                        _ProfileTile(
                          icon: Icons.garage_rounded,
                          title: 'Mon Garage',
                          subtitle: 'Gérer vos véhicules enregistrés',
                          onTap: () => context.push('/garage'), // Redirection Garage
                        ),
                        Divider(height: 24, color: Colors.grey.shade100),
                        _ProfileTile(
                          icon: Icons.shield_rounded,
                          title: 'Sécurité',
                          subtitle: 'Connexion et confidentialité des données',
                          onTap: () => context.push('/security'), // Redirection Sécurité
                        ),
                        Divider(height: 24, color: Colors.grey.shade100),
                        _ProfileTile(
                          icon: Icons.notifications_rounded,
                          title: 'Notifications',
                          subtitle: 'Rappels et alertes de maintenance',
                          onTap: () => context.push('/notifications'), // Redirection Alertes Push
                        ),
                        Divider(height: 24, color: Colors.grey.shade100),
                        _ProfileTile(
                          icon: Icons.settings_rounded,
                          title: 'Réglages généraux',
                          subtitle: 'Unités métriques et données légales',
                          onTap: () => context.push('/settings'), // Redirection Réglages Généraux
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 4. ACTION DE GESTION ADMINISTRATIVE BASSE
                  PremiumButton(
                    text: 'Gérer mon abonnement',
                    onPressed: () {},
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ProfileTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: AppColors.navy, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.navy)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textSecondary, size: 14),
