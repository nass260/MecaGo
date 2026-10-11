// lib/core/services/image_generator_service.dart
import 'package:flutter/material.dart';
import 'package:adaptive_network_image/adaptive_network_image.dart';
import '../theme/app_theme.dart';

/// Service de génération d'images via Edge Function Supabase
/// (qui appelle Pollinations.ai côté serveur — contourne CORS)
///
/// ✅ Stratégie "Scène d'atelier" :
///   Au lieu de gros plans de pièces (qui échouent avec Pollinations),
///   on génère des SCÈNES D'ATELIER cohérentes et fiables.
class ImageGeneratorService {
  const ImageGeneratorService();

  static const String _proxyUrl =
      'https://rpuhqomualtsfwpldtdw.supabase.co/functions/v1/pollinations-proxy';

  // ============================================
  // TABLE 1 — ACTIONS DÉTECTÉES
  // ============================================

  /// Chaque action → une description de scène d'atelier
  static const List<Map<String, dynamic>> _actionScenes = [
    {
      'keywords': ['préparer', 'preparer', 'sécuriser', 'securiser',
                   'lever', 'caler', 'sécurité'],
      'scene':
          'modern car on a lift in a bright automotive workshop, '
          'tools organized on a workbench, safety equipment visible',
    },
    {
      'keywords': ['vérifier', 'verifier', 'contrôler', 'controler',
                   'examiner', 'inspecter', 'observer', 'état', 'usure'],
      'scene':
          'professional mechanic inspecting car parts under the car, '
          'flashlight in hand, focused expression, workshop in background',
    },
    {
      'keywords': ['retirer', 'enlever', 'déposer', 'deposer', 'dévisser',
                   'devisser', 'ôter', 'oter', 'sortir', 'démonter'],
      'scene':
          'professional mechanic with wrench removing a car part, '
          'hands focused on the work, car on lift, clean workshop',
    },
    {
      'keywords': ['nettoyer', 'brosser', 'dégraisser', 'degreaser',
                   'laver', 'purger'],
      'scene':
          'professional mechanic cleaning car parts with a wire brush, '
          'workshop bench, focused hands, clean environment',
    },
    {
      'keywords': ['installer', 'poser', 'monter', 'remettre', 'fixer',
                   'remplacement', 'remplacer', 'changer', 'neuf'],
      'scene':
          'professional mechanic installing a new car part, '
          'hands fitting the part, car on lift, workshop lighting',
    },
    {
      'keywords': ['serrer', 'visser', 'bloquer', 'couple'],
      'scene':
          'professional mechanic using a torque wrench on car parts, '
          'precise work, workshop background, technical atmosphere',
    },
    {
      'keywords': ['mesurer', 'dimension', 'épaisseur', 'epaisseur'],
      'scene':
          'professional mechanic measuring car parts with a caliper, '
          'precision tools, clean workshop bench, focused',
    },
    {
      'keywords': ['vidanger', 'écouler', 'ecouler', 'drainer'],
      'scene':
          'professional mechanic draining oil from a car, '
          'drain pan below the car, clean workshop',
    },
    {
      'keywords': ['remplir', 'ajouter', 'niveau'],
      'scene':
          'professional mechanic filling fluids in a car engine bay, '
          'funnel in hand, clean workshop',
    },
    {
      'keywords': ['tester', 'essayer', 'fonctionnement'],
      'scene':
          'professional mechanic testing a car, '
          'dashboard visible, modern workshop, confident',
    },
    {
      'keywords': ['terminer', 'finaliser', 'remonter'],
      'scene':
          'professional mechanic finishing work on a car, '
          'tools being put away, car ready, clean workshop',
    },
  ];

  // ============================================
  // TABLE 2 — CONTEXTE MÉCANIQUE (rappel visuel)
  // ============================================

  /// Détecte le système mécanique concerné → ajoute un indice visuel
  static const List<Map<String, dynamic>> _systemHints = [
    {
      'keywords': ['plaquette', 'disque', 'frein', 'étrier', 'caliper',
                   'freinage'],
      'hint': 'brake system parts visible on the car',
    },
    {
      'keywords': ['huile', 'vidange', 'filtre à huile'],
      'hint': 'engine oil and drain plug visible',
    },
    {
      'keywords': ['filtre à air', 'filtre air', 'admission'],
      'hint': 'air filter housing visible under the hood',
    },
    {
      'keywords': ['courroie', 'distribution', 'galet'],
      'hint': 'engine bay with belts and pulleys visible',
    },
    {
      'keywords': ['bougie', 'allumage', 'bobine'],
      'hint': 'engine with spark plugs area visible',
    },
    {
      'keywords': ['amortisseur', 'suspension', 'ressort'],
      'hint': 'suspension and wheel visible under the car',
    },
    {
      'keywords': ['rotule', 'direction', 'cardan', 'transmission'],
      'hint': 'steering and drive components under the car',
    },
    {
      'keywords': ['batterie', 'alternateur', 'démarreur'],
      'hint': 'battery and electrical components in engine bay',
    },
    {
      'keywords': ['pneu', 'roue', 'jante'],
      'hint': 'wheel being worked on, tire visible',
    },
    {
      'keywords': ['clim', 'climatisation', 'compresseur'],
      'hint': 'A/C compressor and hoses visible',
    },
  ];

  // ============================================
  // DÉTECTION
  // ============================================

  String _detectActionScene(String text) {
    final lower = text.toLowerCase();

    for (final action in _actionScenes) {
      final keywords = action['keywords'] as List<String>;
      for (final keyword in keywords) {
        if (lower.contains(keyword)) {
          return action['scene'] as String;
        }
      }
    }

    // Fallback : vue générale d'atelier
    return 'professional mechanic working on a car in a clean workshop';
  }

  String _detectSystemHint(String text) {
    final lower = text.toLowerCase();

    for (final system in _systemHints) {
      final keywords = system['keywords'] as List<String>;
      for (final keyword in keywords) {
        if (lower.contains(keyword)) {
          return system['hint'] as String;
        }
      }
    }

    return 'car parts being worked on';
  }

  // ============================================
  // CONSTRUCTION DU PROMPT
  // ============================================

  String buildRepairPrompt({
    required String stepTitle,
    required String stepDescription,
  }) {
    final fullText = '$stepTitle $stepDescription';
    final cleanText = _cleanForPrompt(fullText);

    // ✅ Détection action + système
    final actionScene = _detectActionScene(cleanText);
    final systemHint = _detectSystemHint(cleanText);

    // ✅ Prompt final : scène + hint + garde-fous anti-texte
    return 'Professional automotive workshop photography, '
        '$actionScene, '
        '$systemHint, '
        'bright and clean environment, realistic lighting, '
        'sharp focus, photorealistic, 4k, '
        'NO TEXT, NO LETTERS, NO NUMBERS, NO WRITING, '
        'NO SYMBOLS, NO LABELS, NO LOGOS, NO WATERMARKS, '
        'no close-up on isolated parts';
  }

  String _cleanForPrompt(String text) {
    return text
        .replaceAll(RegExp(r'[\u{1F300}-\u{1F9FF}]', unicode: true), '')
        .replaceAll(RegExp(r'[\u{2600}-\u{27BF}]', unicode: true), '')
        .replaceAll('**', '')
        .replaceAll('*', '')
        .replaceAll('"', '')
        .replaceAll('\n', ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  // ============================================
  // URL DE GÉNÉRATION
  // ============================================

  String buildImageUrl({
    required String description,
    int width = 800,
    int height = 400,
    String model = 'flux',
  }) {
    final encoded = Uri.encodeComponent(description);
    final buffer = StringBuffer();

    buffer.write('$_proxyUrl');
    buffer.write('?prompt=$encoded');
    buffer.write('&width=$width');
    buffer.write('&height=$height');
    buffer.write('&model=$model');
    buffer.write('&seed=${description.hashCode.abs() % 1000000}');

    return buffer.toString();
  }

  String buildStepImageUrl({
    required String stepTitle,
    required String stepDescription,
    int width = 800,
    int height = 400,
  }) {
    final prompt = buildRepairPrompt(
      stepTitle: stepTitle,
      stepDescription: stepDescription,
    );
    return buildImageUrl(
      description: prompt,
      width: width,
      height: height,
    );
  }

  // ============================================
  // WIDGET POUR AFFICHER L'IMAGE GÉNÉRÉE
  // ============================================

  Widget buildGeneratedImage({
    required String description,
    double width = 400,
    double height = 200,
    double borderRadius = 12,
  }) {
    final url = buildImageUrl(
      description: description,
      width: (width * 2).toInt(),
      height: (height * 2).toInt(),
    );

    return AdaptiveNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: BoxFit.cover,
      borderRadius: BorderRadius.circular(borderRadius),
      placeholder: (context) {
        return Container(
          width: width,
          height: height,
          decoration: const BoxDecoration(
            gradient: AppGradients.navy,
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColors.orangeMecaGo),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Génération de l\'illustration...',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      },
      errorWidget: (context, error) {
        return Container(
          width: width,
          height: height,
          decoration: const BoxDecoration(
            gradient: AppGradients.navy,
          ),
          child: const Center(
            child: Icon(
              Icons.image_rounded,
              color: Colors.white24,
              size: 60,
            ),
          ),
        );
      },
    );
  }

  Widget buildStepImage({
    required String stepTitle,
    required String stepDescription,
    double width = 400,
    double height = 200,
    double borderRadius = 18,
  }) {
    final prompt = buildRepairPrompt(
      stepTitle: stepTitle,
      stepDescription: stepDescription,
    );

    return buildGeneratedImage(
      description: prompt,
      width: width,
      height: height,
      borderRadius: borderRadius,
    );
  }
}