import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/premium_button.dart';
import '../widgets/social_login_button.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const SizedBox(height: 30),

              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                ),
              ),

              const SizedBox(height: 16),

              Container(
                width: 86,
                height: 86,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.blue.withOpacity(.12),
                      blurRadius: 28,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.build_rounded,
                  size: 40,
                  color: AppColors.orange,
                ),
              ),

              const SizedBox(height: 28),

              const Text(
                "Bienvenue sur MecaGo",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: AppColors.navy,
                  height: 1.1,
                ),
              ),

              const SizedBox(height: 14),

              const Text(
                "Connectez-vous pour sauvegarder votre garage, votre historique et vos rappels.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 42),

              SocialLoginButton.apple(
                onPressed: () {},
              ),

              const SizedBox(height: 16),

              SocialLoginButton.google(
                onPressed: () {},
              ),

              const SizedBox(height: 26),

              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      "ou",
                      style: TextStyle(
                        color: AppColors.textSecondary.withOpacity(.8),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),

              const SizedBox(height: 26),

              TextField(
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  hintText: "Adresse e-mail",
                  prefixIcon: Icon(Icons.mail_outline_rounded),
                ),
              ),

              const SizedBox(height: 18),

              PremiumButton(
                text: "Continuer avec l'e-mail", // <-- CORRECTION ICI
                onPressed: () {},
              ),

              const Spacer(),

              Text.rich(
                TextSpan(
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    height: 1.5,
                  ),
                  children: [
                    const TextSpan(
                      text: "En continuant, vous acceptez les ",
                    ),
                    TextSpan(
                      text: "Conditions d'utilisation",
                      style: TextStyle(
                        color: AppColors.blue,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const TextSpan(text: " et la "),
                    TextSpan(
                      text: "Politique de confidentialité",
                      style: TextStyle(
                        color: AppColors.blue,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const TextSpan(text: "."),
                  ],
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
