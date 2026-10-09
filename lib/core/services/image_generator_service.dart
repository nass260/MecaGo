// lib/core/services/image_generator_service.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/app_theme.dart';

/// Service de génération d'images via Pollinations.ai (gratuit)
class ImageGeneratorService {
  const ImageGeneratorService();

  static const String _baseUrl = 'https://image.pollinations.ai/prompt';

  /// Génère une URL d'image à partir d'une description
  String buildImageUrl({
    required String description,
    int width = 400,
    int height = 400,
    bool noLogo = true,
  }) {
    final encoded = Uri.encodeComponent(description);
    return '$_baseUrl/$encoded?width=$width&height=$height&nologo=$noLogo';
  }

  /// Widget qui affiche une image générée
  Widget buildGeneratedImage({
    required String description,
    double width = 400,
    double height = 200,
    double borderRadius = 12,
  }) {
    final url = buildImageUrl(
      description: description,
      width: width.toInt(),
      height: height.toInt(),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: CachedNetworkImage(
        imageUrl: url,
        width: width,
        height: height,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.orange),
                ),
                SizedBox(height: 8),
                Text(
                  'Génération de l\'image...',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: AppColors.border),
          ),
          child: const Center(
            child: Icon(
              Icons.broken_image_rounded,
              color: AppColors.textLight,
              size: 40,
            ),
          ),
        ),
        memCacheWidth: (width * 2).toInt(),
        memCacheHeight: (height * 2).toInt(),
      ),
    );
  }
}