// lib/features/diagnostic/presentation/pages/tutorial_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';

/// Étape d'un tutoriel
class TutorialStep {
  final int number;
  final String title;
  final String description;
  final String? tip;

  const TutorialStep({
    required this.number,
    required this.title,
    required this.description,
    this.tip,
  });
}

/// Tutoriel complet
class Tutorial {
  final String partName;
  final String category;
  final String difficulty;
  final String duration;
  final String tools;
  final List<TutorialStep> steps;
  final String? videoUrl;
  final String? videoTitle;
  final String? warning;

  const Tutorial({
    required this.partName,
    required this.category,
    required this.difficulty,
    required this.duration,
    required this.tools,
    required this.steps,
    this.videoUrl,
    this.videoTitle,
    this.warning,
  });
}

class TutorialPage extends StatelessWidget {
  final String partName;

  const TutorialPage({
    super.key,
    required this.partName,
  });

  /// Récupère le tutoriel correspondant à la pièce
  Tutorial? _getTutorial() {
    final lower = partName.toLowerCase();

    // ============================================
    // FREINS - PLAQUETTES
    // ============================================
    if (lower.contains('plaquette')) {
      return const Tutorial(
        partName: 'Plaquettes de frein',
        category: 'Freinage',
        difficulty: 'Intermédiaire',
        duration: '1h - 1h30',
        tools:
            'Cric + chandelles · Clé à chocs (16-18mm) · Repousse-piston · Nettoyant frein · Clé dynamométrique',
        warning:
            '⚠️ Ne roulez JAMAIS sans avoir pompé la pédale de frein après le remontage. Risque d\'accident grave.',
        videoUrl: 'https://www.youtube.com/results?search_query=changer+plaquettes+de+frein',
        videoTitle: 'Tutoriel - Changer ses plaquettes de frein',
        steps: [
          TutorialStep(
            number: 1,
            title: 'Préparer le véhicule',
            description:
                'Garez la voiture sur une surface plane. Serrez le frein à main. Desserrez les écrous de la roue concernée (sans les enlever).',
            tip: 'Travaillez toujours moteur froid pour éviter les brûlures.',
          ),
          TutorialStep(
            number: 2,
            title: 'Lever le véhicule',
            description:
                'Placez le cric sous le point de levage (voir manuel). Levez jusqu\'à ce que la roue décolle. Posez une chandelle de sécurité.',
            tip: 'NE JAMAIS travailler sous une voiture tenue uniquement par un cric.',
          ),
          TutorialStep(
            number: 3,
            title: 'Retirer la roue',
            description:
                'Dévissez complètement les écrous. Retirez la roue et posez-la à plat.',
          ),
          TutorialStep(
            number: 4,
            title: 'Démonter l\'étrier',
            description:
                'Localisez les 2 boulons qui maintiennent l\'étrier. Dévissez-les et retirez l\'étrier. Suspendez-le avec un fil de fer (ne tirez PAS sur le flexible de frein).',
            tip: 'Ne laissez JAMAIS l\'étrier pendre par le flexible.',
          ),
          TutorialStep(
            number: 5,
            title: 'Retirer les anciennes plaquettes',
            description:
                'Sortez les plaquettes usées de leur support. Notez leur position (intérieure/extérieure).',
          ),
          TutorialStep(
            number: 6,
            title: 'Repousser le piston',
            description:
                'Utilisez le repousse-piston pour repousser complètement le piston dans l\'étrier.',
            tip: 'Ouvrez le bouchon du réservoir de liquide de frein pour faciliter.',
          ),
          TutorialStep(
            number: 7,
            title: 'Nettoyer l\'étrier',
            description:
                'Nettoyez l\'étrier et le support avec du nettoyant frein. Retirez toute la poussière.',
          ),
          TutorialStep(
            number: 8,
            title: 'Poser les nouvelles plaquettes',
            description:
                'Installez les nouvelles plaquettes dans le support. Appliquez un peu de graisse cuivrée sur les bords (PAS sur la garniture).',
          ),
          TutorialStep(
            number: 9,
            title: 'Remonter l\'étrier',
            description:
                'Replacez l\'étrier et serrez les boulons au couple (25-35 Nm).',
            tip: 'Utilisez une clé dynamométrique pour un serrage précis.',
          ),
          TutorialStep(
            number: 10,
            title: 'Remonter la roue',
            description:
                'Replacez la roue. Serrez les écrous en croix. Abaissez le véhicule. Serrez définitivement au couple (110-130 Nm).',
          ),
          TutorialStep(
            number: 11,
            title: 'Pomper la pédale',
            description:
                'AVANT de rouler : pompez 5-6 fois la pédale de frein pour remettre les plaquettes en contact.',
            tip: 'La pédale doit devenir dure. Si elle reste molle, il y a un problème.',
          ),
          TutorialStep(
            number: 12,
            title: 'Rodage',
            description:
                'Roulez doucement les 200 premiers km. Évitez les freinages brusques.',
          ),
        ],
      );
    }

    // ============================================
    // FREINS - DISQUES
    // ============================================
    if (lower.contains('disque')) {
      return const Tutorial(
        partName: 'Disques de frein',
        category: 'Freinage',
        difficulty: 'Avancé',
        duration: '2h - 3h',
        tools:
            'Cric + chandelles · Clé à chocs · Clé dynamométrique · Nettoyant frein · Étau',
        warning:
            '⚠️ Les disques doivent être remplacés par paire (avant ou arrière). Ne mélangez JAMAIS un disque neuf avec un ancien.',
        videoUrl: 'https://www.youtube.com/results?search_query=changer+disques+de+frein',
        videoTitle: 'Tutoriel - Changer ses disques de frein',
        steps: [
          TutorialStep(
            number: 1,
            title: 'Préparer le véhicule',
            description:
                'Même procédure que pour les plaquettes : lever, sécuriser, retirer la roue.',
          ),
          TutorialStep(
            number: 2,
            title: 'Démonter l\'étrier',
            description:
                'Retirez l\'étrier complet et suspendez-le. Retirez le support d\'étrier (2 boulons supplémentaires).',
          ),
          TutorialStep(
            number: 3,
            title: 'Retirer l\'ancien disque',
            description:
                'Le disque est souvent maintenu par 2 petites vis cruciformes. Dévissez-les et tirez le disque.',
            tip: 'Si le disque est grippé, tapez doucement avec un maillet.',
          ),
          TutorialStep(
            number: 4,
            title: 'Nettoyer le moyeu',
            description:
                'Nettoyez la surface du moyeu avec une brosse métallique. Retirez la rouille.',
            tip: 'Une surface propre = un disque bien centré.',
          ),
          TutorialStep(
            number: 5,
            title: 'Poser le nouveau disque',
            description:
                'Nettoyez le nouveau disque avec du nettoyant frein (enlevez la graisse de protection). Posez-le sur le moyeu.',
          ),
          TutorialStep(
            number: 6,
            title: 'Remonter le support',
            description:
                'Replacez le support d\'étrier et serrez les boulons au couple (100-120 Nm).',
          ),
          TutorialStep(
            number: 7,
            title: 'Poser les plaquettes',
            description:
                'Installez les plaquettes neuves (obligatoire avec des disques neufs).',
          ),
          TutorialStep(
            number: 8,
            title: 'Remonter l\'étrier',
            description:
                'Replacez l\'étrier et serrez les boulons au couple.',
          ),
          TutorialStep(
            number: 9,
            title: 'Remonter la roue',
            description:
                'Replacez la roue et serrez au couple. Abaissez le véhicule.',
          ),
          TutorialStep(
            number: 10,
            title: 'Rodage',
            description:
                'Roulez doucement les 300 premiers km. Évitez les freinages brusques.',
          ),
        ],
      );
    }

    // ============================================
    // FILTRE À AIR
    // ============================================
    if (lower.contains('filtre') && lower.contains('air')) {
      return const Tutorial(
        partName: 'Filtre à air',
        category: 'Filtration',
        difficulty: 'Débutant',
        duration: '15 min',
        tools: 'Tournevis cruciforme · Chiffon',
        videoUrl: 'https://www.youtube.com/results?search_query=changer+filtre+à+air',
        videoTitle: 'Tutoriel - Changer son filtre à air',
        steps: [
          TutorialStep(
            number: 1,
            title: 'Ouvrir le capot',
            description:
                'Moteur froid. Ouvrez le capot et localisez la boîte à air (gros boîtier noir).',
          ),
          TutorialStep(
            number: 2,
            title: 'Ouvrir la boîte',
            description:
                'Dévissez les 4 vis ou déclipsez les 2 attaches de la boîte à air.',
          ),
          TutorialStep(
            number: 3,
            title: 'Retirer l\'ancien filtre',
            description:
                'Sortez le filtre usagé. Notez son sens (flèche ou inscription).',
            tip: 'Si le filtre est très sale, c\'est le signe d\'un entretien négligé.',
          ),
          TutorialStep(
            number: 4,
            title: 'Nettoyer le boîtier',
            description:
                'Aspirez ou essuyez la poussière dans le boîtier avec un chiffon propre.',
          ),
          TutorialStep(
            number: 5,
            title: 'Poser le nouveau filtre',
            description:
                'Installez le filtre neuf dans le bon sens (respectez la flèche).',
          ),
          TutorialStep(
            number: 6,
            title: 'Refermer',
            description:
                'Replacez le couvercle et revissez les vis.',
          ),
        ],
      );
    }

    // ============================================
    // FILTRE HABITACLE
    // ============================================
    if (lower.contains('habitacle')) {
      return const Tutorial(
        partName: 'Filtre habitacle',
        category: 'Filtration',
        difficulty: 'Débutant',
        duration: '20 min',
        tools: 'Tournevis · Lampe torche',
        videoUrl: 'https://www.youtube.com/results?search_query=changer+filtre+habitacle',
        videoTitle: 'Tutoriel - Changer son filtre habitacle',
        steps: [
          TutorialStep(
            number: 1,
            title: 'Localiser le filtre',
            description:
                'Le filtre habitacle est généralement derrière la boîte à gants ou sous le capot.',
            tip: 'Consultez le manuel de votre véhicule pour la localisation exacte.',
          ),
          TutorialStep(
            number: 2,
            title: 'Ouvrir le compartiment',
            description:
                'Ouvrez la boîte à gants et déclipsez-la. Ou dévissez le cache sous le capot.',
          ),
          TutorialStep(
            number: 3,
            title: 'Retirer l\'ancien filtre',
            description:
                'Sortez le filtre usagé en notant son sens.',
          ),
          TutorialStep(
            number: 4,
            title: 'Nettoyer',
            description:
                'Aspirez la poussière dans le compartiment.',
          ),
          TutorialStep(
            number: 5,
            title: 'Poser le nouveau',
            description:
                'Installez le filtre neuf dans le bon sens (flèche vers le bas généralement).',
          ),
          TutorialStep(
            number: 6,
            title: 'Refermer',
            description:
                'Replacez le cache ou la boîte à gants.',
          ),
        ],
      );
    }

    // ============================================
    // BATTERIE
    // ============================================
    if (lower.contains('batterie')) {
      return const Tutorial(
        partName: 'Batterie',
        category: 'Électrique',
        difficulty: 'Débutant',
        duration: '20 min',
        tools: 'Clé plate (10mm) · Gants · Lunettes de protection',
        warning:
            '⚠️ Débranchez TOUJOURS la borne NÉGATIVE (-) en premier. Rebranchez-la en DERNIER. Risque d\'explosion sinon.',
        videoUrl: 'https://www.youtube.com/results?search_query=changer+batterie+voiture',
        videoTitle: 'Tutoriel - Changer sa batterie',
        steps: [
          TutorialStep(
            number: 1,
            title: 'Sécurité',
            description:
                'Moteur éteint. Portez des gants et des lunettes (l\'acide est corrosif).',
          ),
          TutorialStep(
            number: 2,
            title: 'Débrancher la borne NÉGATIVE',
            description:
                'Dévissez la borne NÉGATIVE (-) en PREMIER. Écartez le câble.',
            tip: 'C\'est ESSENTIEL : cela évite les courts-circuits.',
          ),
          TutorialStep(
            number: 3,
            title: 'Débrancher la borne POSITIVE',
            description:
                'Dévissez la borne POSITIVE (+). Écartez le câble.',
          ),
          TutorialStep(
            number: 4,
            title: 'Retirer la batterie',
            description:
                'Dévissez le support de maintien. Sortez la batterie (elle est lourde : 10-20 kg).',
          ),
          TutorialStep(
            number: 5,
            title: 'Poser la nouvelle batterie',
            description:
                'Placez la nouvelle batterie dans le support. Revissez le maintien.',
            tip: 'Comparez les dimensions et l\'ampérage avec l\'ancienne.',
          ),
          TutorialStep(
            number: 6,
            title: 'Rebrancher la borne POSITIVE',
            description:
                'Branchez d\'abord la borne POSITIVE (+). Serrez bien.',
          ),
          TutorialStep(
            number: 7,
            title: 'Rebrancher la borne NÉGATIVE',
            description:
                'Branchez la borne NÉGATIVE (-) en DERNIER. Serrez bien.',
          ),
          TutorialStep(
            number: 8,
            title: 'Test',
            description:
                'Démarrez le moteur. Vérifiez que tout fonctionne (phares, radio, etc.).',
            tip: 'Certains véhicules ont besoin d\'un code radio après débranchement.',
          ),
        ],
      );
    }

    // ============================================
    // BOUGIES
    // ============================================
    if (lower.contains('bougie')) {
      return const Tutorial(
        partName: 'Bougies d\'allumage',
        category: 'Moteur',
        difficulty: 'Intermédiaire',
        duration: '45 min',
        tools: 'Clé à bougie (16mm) · Clé dynamométrique · Soufflette',
        videoUrl: 'https://www.youtube.com/results?search_query=changer+bougies+allumage',
        videoTitle: 'Tutoriel - Changer ses bougies',
        steps: [
          TutorialStep(
            number: 1,
            title: 'Moteur froid',
            description:
                'Attendez que le moteur soit complètement froid (2h minimum).',
          ),
          TutorialStep(
            number: 2,
            title: 'Retirer les bobines',
            description:
                'Débranchez les connecteurs des bobines. Retirez les bobines d\'allumage.',
          ),
          TutorialStep(
            number: 3,
            title: 'Nettoyer',
            description:
                'Soufflez autour des puits de bougies pour éviter que la poussière tombe dans le moteur.',
            tip: 'CRUCIAL : une poussière dans le cylindre peut endommager le moteur.',
          ),
          TutorialStep(
            number: 4,
            title: 'Retirer les anciennes bougies',
            description:
                'Dévissez chaque bougie avec la clé à bougie. Comptez les tours pour le remontage.',
          ),
          TutorialStep(
            number: 5,
            title: 'Poser les nouvelles',
            description:
                'Vissez les bougies à la main d\'abord (pour ne pas foirer le filetage). Serrez au couple (20-30 Nm).',
          ),
          TutorialStep(
            number: 6,
            title: 'Remonter les bobines',
            description:
                'Replacez les bobines et rebranchez les connecteurs.',
          ),
        ],
      );
    }

    // ============================================
    // TUTORIEL GÉNÉRIQUE (si pièce non reconnue)
    // ============================================
    return Tutorial(
      partName: partName,
      category: 'Général',
      difficulty: 'Variable',
      duration: 'Variable',
      tools: 'Consultez le manuel de votre véhicule',
      videoUrl:
          'https://www.youtube.com/results?search_query=${Uri.encodeComponent('changer $partName')}',
      videoTitle: 'Rechercher un tutoriel sur YouTube',
      steps: [
        TutorialStep(
          number: 1,
          title: 'Préparer le véhicule',
          description:
              'Garez le véhicule sur une surface plane. Moteur éteint et froid.',
        ),
        TutorialStep(
          number: 2,
          title: 'Rassembler les outils',
          description:
              'Préparez tous les outils nécessaires avant de commencer.',
        ),
        TutorialStep(
          number: 3,
          title: 'Consulter la documentation',
          description:
              'Référez-vous au manuel de votre véhicule pour les spécificités.',
          tip: 'Chaque véhicule a ses particularités. Le manuel est votre meilleur allié.',
        ),
        TutorialStep(
          number: 4,
          title: 'Travailler en sécurité',
          description:
              'Portez des équipements de protection. Ne travaillez jamais sous un véhicule non sécurisé.',
        ),
        TutorialStep(
          number: 5,
          title: 'Consulter un professionnel',
          description:
              'Si vous n\'êtes pas sûr de vous, faites appel à un garagiste.',
          tip: 'Mieux vaut payer une main d\'œuvre que casser une pièce.',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final tutorial = _getTutorial();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTutorialHeader(tutorial),
                    const SizedBox(height: 20),
                    _buildVideoCard(tutorial),
                    const SizedBox(height: 20),
                    if (tutorial.warning != null) ...[
                      _buildWarningCard(tutorial.warning!),
                      const SizedBox(height: 20),
                    ],
                    const Text(
                      'Outils nécessaires',
                      style: TextStyle(
                        color: AppColors.navy,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildToolsCard(tutorial.tools),
                    const SizedBox(height: 20),
                    const Text(
                      'Étapes du remplacement',
                      style: TextStyle(
                        color: AppColors.navy,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...tutorial.steps.map((step) => _buildStepCard(step)),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: AppShadows.card,
              ),
              child: const Icon(Icons.arrow_back_rounded,
                  color: AppColors.navy, size: 20),
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Text(
              'Tutoriel',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: AppColors.navy,
                letterSpacing: -0.5,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.orange.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.school_rounded,
                    color: AppColors.orange, size: 14),
                SizedBox(width: 4),
                Text(
                  'Guide',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.orange,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTutorialHeader(Tutorial tutorial) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppGradients.navy,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppShadows.hero,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tutorial.partName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildInfoChip(Icons.category_rounded, tutorial.category),
              const SizedBox(width: 8),
              _buildInfoChip(Icons.signal_cellular_alt_rounded,
                  tutorial.difficulty),
            ],
          ),
          const SizedBox(height: 8),
          _buildInfoChip(Icons.access_time_rounded, tutorial.duration),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 12),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoCard(Tutorial tutorial) {
    if (tutorial.videoUrl == null) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.card,
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFFF0000).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.play_circle_filled_rounded,
                color: Color(0xFFFF0000), size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Vidéo explicative',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  tutorial.videoTitle ?? 'Voir le tutoriel',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.navy,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded,
              color: AppColors.textLight, size: 22),
        ],
      ),
    );
  }

  Widget _buildWarningCard(String warning) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.danger.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.danger.withOpacity(0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_rounded,
              color: AppColors.danger, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              warning,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.danger,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolsCard(String tools) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.card,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.construction_rounded,
                color: AppColors.orange, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              tools,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.navy,
                height: 1.6,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepCard(TutorialStep step) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: AppGradients.orange,
                  shape: BoxShape.circle,
                  boxShadow: AppShadows.orangeButton,
                ),
                child: Center(
                  child: Text(
                    '${step.number}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  step.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.navy,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            step.description,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.navy,
              height: 1.6,
            ),
          ),
          if (step.tip != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7ED),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.orange.withOpacity(0.2),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.lightbulb_rounded,
                      color: AppColors.orange, size: 14),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      step.tip!,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.orange,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}