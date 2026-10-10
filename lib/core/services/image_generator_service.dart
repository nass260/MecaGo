// lib/core/services/image_generator_service.dart
import 'package:flutter/material.dart';
import 'package:adaptive_network_image/adaptive_network_image.dart';
import '../theme/app_theme.dart';

/// Service de génération d'images via Pollinations.ai (gratuit)
///
/// ⚠️ IMPORTANT : ces images sont des ILLUSTRATIONS génériques générées par IA.
/// Elles ne remplacent PAS les procédures mécaniques vérifiées (couples de
/// serrage, points de levage, etc.) qui doivent venir d'une base fiable.
class ImageGeneratorService {
  const ImageGeneratorService();

  static const String _baseUrl = 'https://image.pollinations.ai/prompt';

  // ============================================
  // CONSTRUCTION DE L'INVITE PRO
  // ============================================

  /// Construit une invite professionnelle pour illustrer une étape
  /// de réparation automobile.
  String buildRepairPrompt({
    required String stepTitle,
    required String stepDescription,
  }) {
    final cleanTitle = _cleanForPrompt(stepTitle);
    final cleanDesc = _cleanForPrompt(stepDescription);

    final shortDesc = cleanDesc.length > 150
        ? '${cleanDesc.substring(0, 150)}...'
        : cleanDesc;

    return 'Professional automotive repair tutorial illustration, '
        'close-up shot, clean workshop environment, '
        'realistic lighting, high resolution, '
        'detailed mechanical parts, '
        'no text, no watermark, no logo. '
        'Subject: $cleanTitle. '
        'Context: $shortDesc';
  }

  /// Nettoie un texte pour l'invite (supprime emojis + caractères spéciaux)
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

  /// Construit l'URL Pollinations à partir d'une description
  String buildImageUrl({
    required String description,
    int width = 800,
    int height = 400,
    bool noLogo = true,
    String model = 'flux',
  }) {
    final encoded = Uri.encodeComponent(description);
    return '$_baseUrl/$encoded'
        '?width=$width'
        '&height=$height'
        '&nologo=$noLogo'
        '&model=$model'
        '&seed=${description.hashCode.abs() % 1000000}';
  }

  /// Construit l'URL pour une étape de tutoriel
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

  /// Widget qui affiche une image générée par Pollinations
  /// avec loading + gestion d'erreur propres.
  ///
  /// ✅ API adaptive_network_image 0.1.2 :
  ///    - imageUrl (pas url)
  ///    - placeholder : WidgetBuilder (context)
  ///    - errorWidget : (context, error)
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
      // ✅ Placeholder : WidgetBuilder → 1 seul paramètre (context)
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
      // ✅ Erreur : (context, error) — 2 paramètres (API 0.1.2)
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

  /// Widget qui affiche l'image d'une étape de tutoriel
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