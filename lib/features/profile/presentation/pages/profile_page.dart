import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/premium_card.dart';
import '../../../../core/widgets/premium_button.dart';
import '../../../authentication/presentation/managers/subscription_notifier.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final SubscriptionNotifier _subscriptionNotifier = SubscriptionNotifier();
  bool _pushNotificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    // Synchronisation automatique de l'état de facturation de l'utilisateur
    _subscriptionNotifier.syncSubscriptionStatus("alex_user_id");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Mon Profil',
          style: TextStyle(color: AppColors.navy, fontWeight: FontWeight.w900, fontSize: 20, letterSpacing: -0.5),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
      ),
      body: AnimatedBuilder(
        animation: _subscriptionNotifier,
        builder: (context, _) {
          final isPremium = _subscriptionNotifier.isPremiumActive;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                // 1. CARTE COMPTE UTILISATEUR AVEC INSIGNE COURONNE DYNAMIQUE
                PremiumCard(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 68,
                            height: 68,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                              gradient: const LinearGradient(colors: [Color(0xFF1E293B), Color(0xFF0F172A)]),
                            ),
                            child: const Center(
                              child: Text('AX', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                            ),
                          ),
                          if (isPremium)
                            const Positioned(
                              top: -12,
                              right: -4,
                              child: Text('👑', style: TextStyle(fontSize: 22)),
                            ),
                        ],
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Alexandre Martin', style: TextStyle(color: AppColors.navy, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: -0.3)),
                            const SizedBox(height: 2),
                            Text('alex.martin@email.com', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: isPremium ? const Color(0xFFFFF7ED) : AppColors.border.withOpacity(0.4),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                isPremium ? 'Membre Premium 👑' : 'Compte Standard Free',
                                style: TextStyle(color: isPremium ? AppColors.orange : AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                const Text('Réglages de l’application', style: TextStyle(color: AppColors.navy, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: -0.3)),
                const SizedBox(height: 12),

                // 2. BOUTON SWITCH POUR ACTIVER/DÉSACTIVER LES PUSH NOTIFICATIONS DU SPRINT 9
                PremiumCard(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Rappels d’entretien prédictifs', style: TextStyle(color: AppColors.navy, fontWeight: FontWeight.bold, fontSize: 15)),
                    subtitle: const Text('Recevoir une alerte push locale avant l’usure critique des pièces.', style: TextStyle(fontSize: 12, height: 1.3)),
                    activeColor: AppColors.orange,
                    value: _pushNotificationsEnabled,
                    onChanged: (bool value) {
                      setState(() {
                        _pushNotificationsEnabled = value;
                      });
                    },
                  ),
                ),

                const SizedBox(height: 20),

                // 3. ENCADRÉ DE PROMOTION COMMERCIALE OU BOUTON DE RESTAURATION EXIGÉ PAR APPLE
                if (!isPremium) ...[
                  PremiumCard(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Débloquez tout le potentiel', style: TextStyle(color: AppColors.navy, fontSize: 16, fontWeight: FontWeight.w900)),
                        const SizedBox(height: 4),
                        const Text('Accédez aux diagnostics IA illimités et aux fiches équipementiers en vous abonnant.', style: TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.35)),
                        const SizedBox(height: 16),
                        PremiumButton(
                          text: 'Découvrir MecaGo Premium',
                          onPressed: () => context.push('/paywall'),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  PremiumCard(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('Gestion de l’abonnement', style: TextStyle(color: AppColors.navy, fontWeight: FontWeight.bold, fontSize: 15)),
                            SizedBox(height: 2),
                            Text('Facturation gérée par l’App Store', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                          ],
                        ),
                        TextButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Restauration des licences effectuée.')),
                            );
                          },
                          child: const Text('Restaurer', style: TextStyle(color: AppColors.orange, fontWeight: FontWeight.bold, fontSize: 14)),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

