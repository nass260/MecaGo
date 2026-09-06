import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/premium_button.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingStep> _steps = const [
    _OnboardingStep(
      title: "Scannez votre plaque",
      description: "Approchez-vous du véhicule, scannez sa plaque française et laissez l'IA extraire instantanément la fiche technique d'origine constructeur.",
      imageUrl: "https://unsplash.com",
    ),
    _OnboardingStep(
      title: "Tutoriels d'Atelier",
      description: "Accédez à des guides de maintenance illustrés étape par étape avec le bon outillage requis pour réparer vous-même en mode Mains Sales.",
      imageUrl: "https://unsplash.com",
    ),
    _OnboardingStep(
      title: "Optimisez vos dépenses",
      description: "Suivez l'usure kilométrique prédictive de vos pièces et centralisez l'historique de vos interventions pour économiser des centaines d'euros.",
      imageUrl: "https://unsplash.com",
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _steps.length,
                onPageChanged: (int index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  final step = _steps[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: MediaQuery.of(context).size.height * 0.35,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(32),
                            image: DecorationImage(
                              image: NetworkImage(step.imageUrl),
                              fit: BoxFit.cover,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 24,
                                offset: const Offset(0, 12),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
                        Text(
                          step.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.navy,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.8,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          step.description,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 15,
                            height: 1.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_steps.length, (index) => _buildDotIndicator(index)),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: _currentPage == _steps.length - 1
                  ? Column(
                      children: [
                        PremiumButton(
                          text: "Créer un compte MecaGo",
                          onPressed: () => context.go('/register'),
                        ),
                        const SizedBox(height: 14),
                        TextButton(
                          onPressed: () => context.go('/login'),
                          child: const Text(
                            "J'ai déjà un compte, se connecter",
                            style: TextStyle(
                              color: AppColors.orange,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        PremiumButton(
                          text: "Suivant",
                          onPressed: () {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeInOut,
                            );
                          },
                        ),
                        const SizedBox(height: 14),
                        TextButton(
                          onPressed: () {
                            _pageController.jumpToPage(_steps.length - 1);
                          },
                          child: const Text(
                            "Passer l'introduction",
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDotIndicator(int index) {
    final bool isActive = _currentPage == index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: isActive ? 24 : 8,
      decoration: BoxDecoration(
        color: isActive ? AppColors.orange : AppColors.border,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class _OnboardingStep {
  final String title;
  final String description;
  final String imageUrl;

  const _OnboardingStep({
    required this.title,
    required this.description,
    required this.imageUrl,
  });
}
