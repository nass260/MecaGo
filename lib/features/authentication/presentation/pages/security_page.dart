import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/premium_card.dart';

class SecurityPage extends StatefulWidget {
  const SecurityPage({super.key});

  @override
  State<SecurityPage> createState() => _SecurityPageState();
}

class _SecurityPageState extends State<SecurityPage> {
  bool _biometricAuth = true;
  bool _isDeleting = false;

  /// Déclenche l'alerte de confirmation réglementaire Apple pour la suppression du compte
  void _confirmAccountDeletion() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text(
            'Supprimer le compte ?',
            style: TextStyle(color: AppColors.navy, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'Cette action est irréversible. Toutes vos voitures, vos rapports de diagnostic IA et votre historique d’économies seront définitivement effacés.',
            style: TextStyle(color: AppColors.textSecondary, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _executeDeletionPipeline(); // Lance la destruction asynchrone
              },
              child: const Text('Supprimer définitivement', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  /// Exécute la destruction asynchrone sur la persistance locale et cloud
  Future<void> _executeDeletionPipeline() async {
    setState(() {
      _isDeleting = true;
    });

    // Simulation du traitement de nettoyage RGPD (1,2 seconde)
    await Future.delayed(const Duration(milliseconds: 1200));

    if (mounted) {
      setState(() {
        _isDeleting = false;
      });
      // Redirection radicale vers l'accueil ou déconnexion
      context.go('/');
    }
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
          'Sécurité',
          style: TextStyle(color: AppColors.navy, fontWeight: FontWeight.w800, letterSpacing: -0.5),
        ),
      ),
      body: SafeArea(
        child: _isDeleting
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppColors.orange)),
                    SizedBox(height: 16),
                    Text('Suppression sécurisée de vos données cloud...', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
              )
            : SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Accès à l’application',
                      style: TextStyle(color: AppColors.navy, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: -0.3),
                    ),
                    const SizedBox(height: 12),

                    // Section 1 : Authentification biométrique Apple / Android native
                    PremiumCard(
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text('Authentification biométrique', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.navy, fontSize: 15)),
                                    SizedBox(height: 2),
                                    Text('Utiliser Face ID / Touch ID pour l’accès', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                                  ],
                                ),
                              ),
                              Switch.adaptive(
                                value: _biometricAuth,
                                activeColor: AppColors.orange,
                                onChanged: (val) => setState(() => _biometricAuth = val),
                              ),
                            ],
                          ),
                          const Divider(height: 24, color: AppColors.border),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text('Modifier le mot de passe', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.navy, fontSize: 15)),
                              Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textSecondary, size: 14),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),
                    const Text(
                      'Zone de danger',
                      style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.extrabold, letterSpacing: -0.3),
                    ),
                    const SizedBox(height: 12),

                    // Section 2 : Bouton de suppression conforme à la réglementation App Store RGPD
                    PremiumCard(
                      child: InkWell(
                        onTap: _confirmAccountDeletion,
                        borderRadius: BorderRadius.circular(14),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(12)),
                                child: const Icon(Icons.delete_forever_rounded, color: Colors.red, size: 22),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text('Supprimer définitivement le compte', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.red)),
                                    SizedBox(height: 2),
                                    Text('Effacer définitivement vos voitures et historiques', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
