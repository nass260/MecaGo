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
  final PageController _controller = PageController();
  int _index = 0;

  // Liste des 3 écrans officiels avec images HD Unsplash (Tesla / Porsche / Atelier)
  final _pages = const [
    _OnboardingData(
      title: "Entretenez votre voiture comme un pro",
      description:
          "Des tutoriels adaptés à votre véhicule pour économiser du temps et de l'argent.",
      image:
          "https://unsplash.com",
      icon: Icons.directions_car_filled_rounded,
    ),
    _OnboardingData(
      title: "Scannez votre plaque en quelques secondes",
      description:
          "Identification automatique du véhicule grâce à la caméra et à l'OCR.",
      image:
          "https://unsplash.com",
      icon: Icons.document_scanner_rounded,
    ),
    _OnboardingData(
      title: "Mode Garage pensé pour les mains sales",
      description:
          "Lampe, minuteur, checklist et gros boutons pour intervenir sereinement.",
      image:
          "https://unsplash.com",
      icon: Icons.build_circle_rounded,
    ),
  ];

  void _next() {
    if (_index == _pages.length - 1) {
      context.go("/");
      return;
    }

    _controller.nextPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Bouton "Passer" style Apple
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 12, right: 20),
                child: TextButton(
                  onPressed: () => context.go("/"),
                  child: const Text(
                    "Passer",
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),

            // Carrousel central d'images et textes
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (value) => setState(() => _index = value),
                itemBuilder: (_, i) {
                  final page = _pages[i];

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      children: [
                        const SizedBox(height: 8),

                        // Image arrondie premium avec double ombre et icône d'action flottante
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(34),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(.08),
                                  blurRadius: 40,
                                  offset: const Offset(0, 20),
                                ),
                              ],
                              image: DecorationImage(
                                image: NetworkImage(page.image),
                                fit: BoxFit.cover,
                                alignment: Alignment.center,
                              ),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(34),
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black.withOpacity(.05),
                                    Colors.black.withOpacity(.35),
                                  ],
                                ),
                              ),
                              child: Align(
                                alignment: Alignment.topRight,
                                child: Container(
                                  margin: const EdgeInsets.all(20),
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(.92),
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: Icon(
                                    page.icon,
                                    color: AppColors.orange,
                                    size: 28,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 34),

                        // Titre Navy texturé
                        Text(
                          page.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: AppColors.navy,
                            height: 1.08,
                            letterSpacing: -.8,
                          ),
                        ),

                        const SizedBox(height: 18),

                        // Description grise raffinée
                        Text(
                          page.description,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                        ),

                        const SizedBox(height: 34),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Pilules de progression animées en bas
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: i == _index ? 26 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: i == _index
                        ? AppColors.orange
                        : AppColors.border,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 28),

            // Bouton élastique réutilisable
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: PremiumButton(
                text: _index == _pages.length - 1
                    ? "Commencer"
                    : "Suivant",
                onPressed: _next,
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class _OnboardingData {
  const _OnboardingData({
    required this.title,
    required this.description,
    required this.image,
    required this.icon,
  });

  final String title;
  final String description;
  final String image;
  final IconData icon;
}
