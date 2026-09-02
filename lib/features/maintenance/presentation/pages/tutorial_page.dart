import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/premium_button.dart';
import '../../../../core/widgets/premium_card.dart';

class TutorialPage extends StatefulWidget {
  const TutorialPage({super.key});

  @override
  State<TutorialPage> createState() => _TutorialPageState();
}

class _TutorialPageState extends State<TutorialPage> {
  int currentStep = 0;

  final List<TutorialStep> steps = const [
    TutorialStep(
      title: "Préparer le véhicule",
      description:
          "Stationnez la Tesla sur une surface plane et coupez complètement le système de ventilation.",
      image:
          "https://unsplash.com",
      warning: "Retirez la clé ou assurez-vous que le véhicule est à l'arrêt.",
    ),
    TutorialStep(
      title: "Ouvrir la boîte à gants",
      description:
          "Ouvrez complètement la boîte à gants pour accéder au panneau latéral.",
      image:
          "https://unsplash.com",
    ),
    TutorialStep(
      title: "Retirer le panneau latéral",
      description:
          "Déclipsez doucement le panneau en plastique situé sur le côté droit.",
      image:
          "https://unsplash.com",
      warning: "Ne forcez pas sur les clips.",
    ),
    TutorialStep(
      title: "Dévisser le cache du filtre",
      description:
          "Retirez la vis de maintien puis enlevez le couvercle du compartiment.",
      image:
          "https://unsplash.com",
    ),
    TutorialStep(
      title: "Retirer les anciens filtres",
      description:
          "Faites glisser les deux filtres d'habitacle vers le bas.",
      image:
          "https://unsplash.com",
      warning: "Faites attention à la poussière.",
    ),
    TutorialStep(
      title: "Installer les nouveaux filtres",
      description:
          "Respectez le sens du flux d'air indiqué par les flèches.",
      image:
          "https://unsplash.com",
    ),
    TutorialStep(
      title: "Remonter le cache",
      description:
          "Replacez le couvercle puis revissez correctement la fixation.",
      image:
          "https://unsplash.com",
    ),
    TutorialStep(
      title: "Vérification finale",
      description:
          "Allumez la ventilation et vérifiez que le débit d'air est normal.",
      image:
          "https://unsplash.com",
    ),
  ];

  double get progress => (currentStep + 1) / steps.length;

  @override
  Widget build(BuildContext context) {
    final step = steps[currentStep];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Barre supérieure épurée Apple style
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.navy),
                  ),
                  const Expanded(
                    child: Text(
                      "Filtre d'habitacle",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.navy,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48), // Équilibreur pour centrer le titre
                ],
              ),
            ),

            // 2. Jauge de progression horizontale
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  LinearProgressIndicator(
                    value: progress,
                    minHeight: 7,
                    backgroundColor: AppColors.border,
                    valueColor: const AlwaysStoppedAnimation(AppColors.orange),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Étape ${currentStep + 1} sur ${steps.length}",
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 3. Contenu de l'étape défilant
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Grande image de l'étape avec l'ombre de profondeur Apple
                    Container(
                      height: 240,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        image: DecorationImage(
                          image: NetworkImage(step.image),
                          fit: BoxFit.cover,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(.06),
                            blurRadius: 30,
                            offset: const Offset(0, 15),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 26),

                    // Titre officiel Navy
                    Text(
                      step.title,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: AppColors.navy,
                        letterSpacing: -0.5,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Description claire
                    Text(
                      step.description,
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 26),

                    // Carte des outils recommandés (Intégration PremiumCard)
                    const PremiumCard(
                      padding: EdgeInsets.all(18),
                      child: Row(
                        children: [
                          Icon(Icons.build_circle_rounded, color: AppColors.orange, size: 28),
                          SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              "Outil requis : Tournevis Torx T20",
                              style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.navy, fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Encart d'avertissement orange dynamique
                    if (step.warning != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF7ED), // Fond orange très clair style iOS
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: const Color(0xFFFFEDD5)),
                        ),
                        child: Row(
                          children: [
                            const Text("⚠️", style: TextStyle(fontSize: 18)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                step.warning!,
                                style: const TextStyle(
                                  color: Color(0xFFC2410C),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),

            // 4. Barre de navigation basse fixe (Boutons élastiques)
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  if (currentStep > 0) ...[
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 56),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
