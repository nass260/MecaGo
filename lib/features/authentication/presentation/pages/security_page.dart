import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/premium_card.dart';
import '../../../../core/widgets/premium_button.dart';
import '../../../../core/services/auth_service.dart'; // <-- 1. Importation du service d'authentification

class SecurityPage extends StatefulWidget {
  const SecurityPage({super.key});

  @override
  State<SecurityPage> createState() => _SecurityPageState();
}

class _SecurityPageState extends State<SecurityPage> {
  final AuthService _authService = const AuthService();
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

  /// Exécute la destruction asynchrone sur Firebase Auth et redirige vers l'entrée
  Future<void> _executeDeletionPipeline() async {
    setState(() {
      _isDeleting = true;
    });

    final bool success = await _authService.deleteUserAccount();

    if (mounted) {
      setState(() {
        _isDeleting = false;
      });

      if (success) {
        // Redirection radicale et sécurisée vers l'Onboarding de l'application
        context.go('/onboarding');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Une erreur est survenue lors de la suppression de votre compte."),
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
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Authentification biométrique', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.navy, fontSize: 15)),
                                  SizedBox(height: 2),
                                  Text('Utiliser Face ID / Touch ID pour l’accès', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                                ],
                              ),
                              Switch.adaptive(
                                value: _biometricAuth,
                                activeColor: AppColors.orange,
                                onChanged: (val) => setState(() => _biometricAuth = val),
                              ),
                            ],
                          ),
                          Divider(height: 24, color: Colors.grey.shade100),
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

                    // Section 2 : Bouton de suppression conforme à la réglementation App Store
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
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Supprimer définitivement le compte', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.red)),
                                    SizedBox(height: 2),
                                    Text('Effacer vos voitures et toutes vos données', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
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
