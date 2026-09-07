import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/premium_card.dart';
import '../../../../core/widgets/premium_button.dart';
import '../managers/subscription_notifier.dart';

class PaywallPage extends StatefulWidget {
  const PaywallPage({super.key});

  @override
  State<PaywallPage> createState() => _PaywallPageState();
}

class _PaywallPageState extends State<PaywallPage> {
  final SubscriptionNotifier _subscriptionNotifier = SubscriptionNotifier();

  /// Déclenche l'achat in-app de l'abonnement mensuel et gère le retour
  Future<void> _triggerSubscriptionPurchase() async {
    final bool success = await _subscriptionNotifier.executePremiumPurchase();
    
    if (mounted) {
      if (success) {
        // Achat validé : on ferme l'écran et on félicite l'utilisateur
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("👑 Félicitations ! Votre accès MecaGo Premium est activé."),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        // Échec du paiement
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_subscriptionNotifier.billingErrorMessage ?? "Transaction annulée."),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppColors.navy, size: 28),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _subscriptionNotifier,
          builder: (context, _) {
            if (_subscriptionNotifier.isProcessing) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppColors.orange), strokeWidth: 3.5),
                    SizedBox(height: 18),
                    Text('Communication sécurisée avec l’App Store...', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
              );
            }

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ACCÈS ILLIMITÉ D’EXCELLENCE',
                    style: TextStyle(color: AppColors.orange, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Passez à la vitesse supérieure',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.navy, letterSpacing: -0.6),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Prenez le contrôle total de l’entretien de vos véhicules et économisez des centaines d’euros chaque année.',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.45, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 28),

                  // LISTE DES ARGUMENTS COMMERCIAUX DE PRESTIGE
                  _buildFeatureBullet(icon: "🧠", title: "Diagnostic IA illimité", desc: "Identifiez instantanément l’origine de n’importe quelle panne ou sifflement mécanique."),
                  _buildFeatureBullet(icon: "📋", title: "Fiches techniques constructeurs", desc: "Accédez aux couples de serrage, viscosités d’huiles et dimensions d'origine."),
                  _buildFeatureBullet(icon: "🔔", title: "Rappels kilométriques prédictifs", desc: "Anticipez l’usure de vos pièces VALEO ou PURFLUX avant le Contrôle Technique."),

                  const SizedBox(height: 24),

                  // CARTE DE TARIFICATION PREMIUM CHIRURGICALE
                  PremiumCard(
                    padding: const EdgeInsets.all(22),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(color: const Color(0xFFFFF7ED), borderRadius: BorderRadius.circular(16)),
                          child: const Center(child: Text("👑", style: TextStyle(fontSize: 22))),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text('Formule Mensuelle', style: TextStyle(fontWeight: FontWeight.extrabold, fontSize: 17, color: AppColors.navy)),
                              SizedBox(height: 2),
                              Text('Sans engagement — Annulable en 1 clic', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('4,99 €', style: TextStyle(color: AppColors.navy, fontSize: 24, fontWeight: FontWeight.w900, fontFamily: 'monospace')),
                            Text('/mois', style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // GRAND BOUTON DE FACTURATION ÉLASTIQUE
                  PremiumButton(
                    text: 'Activer mon accès Premium',
                    onPressed: _triggerSubscriptionPurchase,
                  ),

                  const SizedBox(height: 18),
                  const Center(
                    child: Text(
                      'Période d’essai de 7 jours incluse. Prélèvement automatique mensuel via l’App Store. Restauration des achats disponible.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 11, height: 1.4, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  static Widget _buildFeatureBullet({required String icon, required String title, required String desc}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.navy)),
                const SizedBox(height: 3),
                Text(desc, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
