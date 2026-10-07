// lib/core/services/marque_image_service.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/app_theme.dart';

/// Service de récupération des logos de marques depuis Supabase
class MarqueImageService {
  const MarqueImageService();

  /// Normalise le nom de la marque (lowercase + tirets)
  String _normalizeMarque(String marque) {
    return marque
        .toLowerCase()
        .trim()
        .replaceAll(' ', '-')
        .replaceAll('_', '-');
  }

  /// Récupère l'URL du logo d'une marque depuis Supabase
  Future<String?> getMarqueLogoUrl(String marque) async {
    try {
      final supabase = Supabase.instance.client;
      final normalized = _normalizeMarque(marque);

      debugPrint('🔍 Recherche logo : $normalized (depuis "$marque")');

      final response = await supabase
          .from('marques_images')
          .select('url_logo')
          .eq('nom_marque', normalized)
          .limit(1)
          .maybeSingle();

      if (response != null && response['url_logo'] != null) {
        debugPrint('✅ Logo trouvé : $normalized');
        return response['url_logo'] as String;
      }

      debugPrint('⚠️ Aucun logo pour "$normalized"');
      return null;
    } catch (e) {
      debugPrint('❌ Erreur récupération logo marque : $e');
      return null;
    }
  }

  /// Widget asynchrone qui affiche le logo d'une marque
  Widget buildMarqueLogo({
    required String marque,
    double width = 44,
    double height = 44,
    double borderRadius = 12,
    BoxFit fit = BoxFit.contain,
  }) {
    return FutureBuilder<String?>(
      future: getMarqueLogoUrl(marque),
      builder: (context, snapshot) {
        // État 1 : Chargement
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildPlaceholder(
            width: width,
            height: height,
            borderRadius: borderRadius,
            child: const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppColors.orange),
                ),
              ),
            ),
          );
        }

        // État 2 : Erreur ou URL null → icône voiture par défaut
        if (snapshot.hasError || snapshot.data == null) {
          return _buildPlaceholder(
            width: width,
            height: height,
            borderRadius: borderRadius,
            child: Icon(
              Icons.directions_car_rounded,
              color: AppColors.orange,
              size: width * 0.5,
            ),
          );
        }

        // État 3 : Logo trouvé
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: AppColors.border.withOpacity(0.5),
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(borderRadius),
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: CachedNetworkImage(
                imageUrl: snapshot.data!,
                width: width,
                height: height,
                fit: fit,
                placeholder: (context, url) => const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColors.orange),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Icon(
                  Icons.broken_image_rounded,
                  color: AppColors.textLight,
                  size: width * 0.5,
                ),
                memCacheWidth: (width * 3).toInt(),
                memCacheHeight: (height * 3).toInt(),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlaceholder({
    required double width,
    required double height,
    required double borderRadius,
    required Widget child,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
      ),
      child: child,
    );
  }
}