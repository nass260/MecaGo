import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/premium_card.dart';
import '../../../../core/widgets/premium_button.dart';
import '../../../../core/services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final AuthService _authService = const AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Déclenche le processus de création de compte asynchrone sur Firebase Auth
  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus(); // Ferme le clavier virtuel

    setState(() {
      _isLoading = true;
    });

    final bool success = await _authService.registerUser(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      if (success) {
        // Redirection radicale de l'utilisateur vers le Tableau de Bord central après succès
        context.go('/');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Une erreur est survenue lors de la création de votre compte."),
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
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.navy),
          onPressed: () => context.go('/onboarding'),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppColors.orange), strokeWidth: 3.5),
                    SizedBox(height: 16),
                    Text('Création de votre profil de maintenance...', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
              )
            : SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'COMMENCER L’AVENTURE MECA GO',
                        style: TextStyle(color: AppColors.orange, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Créer votre compte',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.navy, letterSpacing: -0.6),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Rejoignez la communauté et commencez à scanner vos véhicules pour économiser dès aujourd’hui.',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.45, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 32),

                      // LE FORMULAIRE PREMIUM DE NIVEAU INDUSTRIEL (STYLE APPLE)
                      PremiumCard(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            // Champ Email
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              style: const TextStyle(color: AppColors.navy, fontWeight: FontWeight.w600, fontSize: 15),
                              decoration: const InputDecoration(
                                labelText: 'Adresse email',
                                labelStyle: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                                prefixIcon: Icon(Icons.email_outlined, color: AppColors.textSecondary),
                                border: InputBorder.none,
                              ),
                              validator: (value) => (value == null || !value.contains('@')) ? 'Veuillez entrer un email valide' : null,
                            ),
                            Divider(height: 16, color: AppColors.border.withOpacity(0.5)),
                            
                            // Champ Mot de passe
                            TextFormField(
                              controller: _passwordController,
                              obscureText: true,
                              style: const TextStyle(color: AppColors.navy, fontWeight: FontWeight.w600, fontSize: 15),
                              decoration: const InputDecoration(
                                labelText: 'Mot de passe',
                                labelStyle: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                                prefixIcon: Icon(Icons.lock_outline_rounded, color: AppColors.textSecondary),
                                border: InputBorder.none,
                              ),
                              validator: (value) => (value == null || value.length < 6) ? 'Mot de passe trop court (min 6 caractères)' : null,
                            ),
                            Divider(height: 16, color: AppColors.border.withOpacity(0.5)),

                            // Champ Confirmation du Mot de passe
                            TextFormField(
                              controller: _confirmPasswordController,
                              obscureText: true,
                              style: const TextStyle(color: AppColors.navy, fontWeight: FontWeight.w600, fontSize: 15),
                              decoration: const InputDecoration(
                                labelText: 'Confirmer le mot de passe',
                                labelStyle: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                                prefixIcon: Icon(Icons.lock_reset_rounded, color: AppColors.textSecondary),
                                border: InputBorder.none,
                              ),
                              validator: (value) => (value != _passwordController.text) ? 'Les mots de passe ne correspondent pas' : null,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),

                      // BOUTON DE SOUMISSION PREMIUM
                      PremiumButton(
                        text: 'Créer mon profil et démarrer',
                        onPressed: _handleRegister,
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // LIEN DE BASCULE VERS LA CONNEXION DIRECTE
                      Center(
                        child: TextButton(
                          onPressed: () => context.go('/login'),
                          child: RichText(
                            text: const TextSpan(
                              style: TextStyle(fontSize: 14, fontFamily: 'SF Pro Display'),
                              children: [
                                TextSpan(text: 'Déjà inscrit ? ', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                                TextSpan(text: 'Se connecter', style: TextStyle(color: AppColors.orange, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
