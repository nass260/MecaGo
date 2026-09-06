import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/premium_card.dart';
import '../../../../core/widgets/premium_button.dart';
import '../managers/auth_notifier.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthNotifier _authNotifier = AuthNotifier();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Déclenche le pipeline de vérification de session asynchrone auprès de Firebase Auth
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus(); // Ferme le clavier virtuel

    final bool success = await _authNotifier.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (mounted) {
      if (success) {
        // Redirection chirurgicale et radicale vers le Tableau de Bord central
        context.go('/');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_authNotifier.errorMessage ?? "Échec d'authentification."),
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
        child: AnimatedBuilder(
          animation: _authNotifier,
          builder: (context, _) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'CONNEXION SÉCURISÉE',
                      style: TextStyle(color: AppColors.orange, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Ravi de vous revoir',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.navy, letterSpacing: -0.6),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Connectez-vous pour retrouver votre MecaGo Score™, votre garage et vos rapports d’analyse.',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.45, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 32),

                    // FORMULAIRE DE SAISIE DESIGN APPLE EXCELLENCE
                    PremiumCard(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          // Champ Adresse Email
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
                          
                          // Champ Mot de passe sécurisé masqué
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
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    // BOUTON DE SOUMISSION AVEC INDICATEUR DE SÉCURITÉ ASYNCHRONE
                    _authNotifier.isLoading
                        ? const Center(
                            child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppColors.orange), strokeWidth: 3.5),
                          )
                        : PremiumButton(
                            text: 'Se connecter à l’écosystème',
                            onPressed: _handleLogin,
                          ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
