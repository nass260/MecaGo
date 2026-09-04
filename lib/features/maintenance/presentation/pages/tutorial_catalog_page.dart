import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/premium_card.dart';
import '../../../../core/widgets/premium_button.dart';

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
      description: "Stationnez le véhicule sur une surface plane. Coupez complètement le contact et le système de ventilation avant de commencer.",
      image: "https://unsplash.com",
      warning: "Assurez-vous que le véhicule est totalement immobilisé.",
    ),
    TutorialStep(
      title: "Accéder à la boîte à gants",
      description: "Ouvrez la boîte à gants passager. Déclipsez délicatement le bras d'arrêt situé sur le côté droit pour la descendre au maximum.",
      image: "https://unsplash.com",
    ),
    TutorialStep(
      title: "Retirer le panneau d'accès",
      description: "À l'aide de vos doigts ou d'un outil de déclipsage en plastique, retirez le panneau de garniture latéral droit pour exposer le cache du filtre.",
      image: "https://unsplash.com",
      warning: "Ne forcez pas sur les clips pour éviter de les casser.",
    ),
    TutorialStep(
      title: "Dévisser le volet de fermeture",
      description: "Utilisez un tournevis Torx T20 pour retirer la vis de fixation du couvercle, puis retirez délicatement le cache du compartiment.",
      image: "https://unsplash.com",
    ),
    TutorialStep(
      title: "Extraire les anciens filtres",
      description: "Tirez doucement sur les languettes pour extraire les deux anciens filtres d'habitacle. Notez bien le sens des flèches de flux d'air.",
      image: "https://unsplash.com",
      warning: "De la poussière ou des débris peuvent tomber lors de l'extraction.",
    ),
    TutorialStep(
      title: "Insérer les nouveaux filtres HEPA",
      description: "Glissez le premier filtre neuf au fond, poussez-le vers le haut, puis insérez le second en dessous. Respectez le sens des flèches Air Flow.",
      image: "https://unsplash.com",
    ),
    TutorialStep(
      title: "Remonter le couvercle de protection",
      description: "Repositionnez le volet d'accès, revissez la vis Torx T20 sans forcer excessivement, puis reclipsez le panneau de garniture latéral.",
      image: "https://unsplash.com",
    ),
    TutorialStep(
      title: "Vérification et validation",
      description: "Démarrez le véhicule, activez la climatisation à puissance maximale et vérifiez l'absence de bruit anormal ou de voyant d'alerte.",
      image: "https://unsplash.com",
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
            // 1. BARRE SUPÉRIEURE ÉPURÉE APPPLE STYLE
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 20, 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.navy),
                  ),
                  const Expanded(
                    child: Text(
                      "Intervention Atelier",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.navy,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48), // Équilibreur de centrage
                ],
              ),
            ),

            // 2. JAUGE DE PROGRESSION INTERACTIVE DE MAQUETTE
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: AppColors.border,
                      valueColor: const AlwaysStoppedAnimation(AppColors.orange),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Étape ${currentStep + 1} sur ${steps.length}",
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 3. ZONE DE CONTENU DÉFILANTE ACCESSIBLE (MODE ATELIER)
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Grande illustration de l'étape
                    Container(
                      height: 220,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        image: DecorationImage(
                          image: NetworkImage(step.image),
                          fit: BoxFit.cover,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(.04),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Titre de l'étape en gras
                    Text(
                      step.title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: AppColors.navy,
                        letterSpacing: -0.5,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Description textuelle agrandie pour la lisibilité mains sales
                    Text(
                      step.description,
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.navy,
                        height: 1.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Outil requis universel
                    const PremiumCard(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(Icons.build_circle_rounded, color: AppColors.orange, size: 24),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "Outillage requis : Clé Torx T20 / Kit plastique",
                              style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.navy, fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Bloc d'avertissement orange constructeur dynamique
                    if (step.warning != null) ...[
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF7ED),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFFFEDD5)),
                        ),
                        child: Row(
                          children: [
                            const Text("⚠️", style: TextStyle(fontSize: 16)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                step.warning!,
                                style: const TextStyle(
                                  color: Color(0xFFC2410C),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

