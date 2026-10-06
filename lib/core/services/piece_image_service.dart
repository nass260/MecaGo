// lib/core/services/piece_image_service.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/app_theme.dart';

/// Service de récupération des images de pièces depuis Supabase
class PieceImageService {
  const PieceImageService();

  /// Extrait un mot-clé générique à partir du nom de la pièce
  String _extractKeyword(String nomPieceIa) {
    final lower = nomPieceIa.toLowerCase();

    // Freinage
    if (lower.contains('plaquette')) return 'plaquettes';
    if (lower.contains('disque')) return 'disques';
    if (lower.contains('étrier')) return 'etrier';
    if (lower.contains('frein')) return 'freins';

    // Filtration
    if (lower.contains('huile') && lower.contains('filtre')) {
      return 'filtre_huile';
    }
    if (lower.contains('air') && lower.contains('filtre')) {
      return 'filtre_air';
    }
    if (lower.contains('habitacle')) return 'filtre_habitacle';
    if (lower.contains('gasoil') || lower.contains('diesel')) {
      return 'filtre_gasoil';
    }

    // Moteur
    if (lower.contains('bougie')) return 'bougies';
    if (lower.contains('courroie')) return 'courroie';
    if (lower.contains('vanne') && lower.contains('egr')) return 'vanne_egr';
    if (lower.contains('turbo')) return 'turbo';
    if (lower.contains('injecteur')) return 'injecteur';

    // Électrique
    if (lower.contains('batterie')) return 'batterie';
    if (lower.contains('alternateur')) return 'alternateur';
    if (lower.contains('démarreur')) return 'demarreur';
    if (lower.contains('ampoule') || lower.contains('phare')) {
      return 'ampoule';
    }

    // Suspension
    if (lower.contains('amortisseur')) return 'amortisseur';
    if (lower.contains('rotule')) return 'rotule';
    if (lower.contains('cardan')) return 'cardan';
    if (lower.contains('roulement')) return 'roulement';

    // Climatisation
    if (lower.contains('clim')) return 'clim';
    if (lower.contains('compresseur')) return 'compresseur_clim';

    // Par défaut : remplacer les espaces par des underscores
    return nomPieceIa.toLowerCase().replaceAll(' ', '_');
  }

  /// Récupère l'URL de l'image d'une pièce depuis Supabase
  Future<String?> getPieceImageUrl({
    required String marque,
    required String modele,
    required String motorisation,
    required String nomPieceIa,
  }) async {
    try {
      final supabase = Supabase.instance.client;
      final keyword = _extractKeyword(nomPieceIa);

      debugPrint('🔍 Recherche image : $keyword (depuis "$nomPieceIa")');

      // Requête principale (marque + modele + motorisation + nom_piece_ia)
      final response = await supabase
          .from('pieces_diagnostic')
          .select('url_image')
          .eq('marque', marque)
          .eq('modele', modele)
          .eq('motorisation', motorisation)
          .eq('nom_piece_ia', keyword)
          .limit(1)
          .maybeSingle();

      if (response != null && response['url_image'] != null) {
        debugPrint('✅ Image trouvée (exacte)');
        return response['url_image'] as String;
      }

      // Fallback 1 : marque + nom_piece_ia
      final fallback1 = await supabase
          .from('pieces_diagnostic')
          .select('url_image')
          .eq('marque', marque)
          .eq('nom_piece_ia', keyword)
          .limit(1)
          .maybeSingle();

      if (fallback1 != null && fallback1['url_image'] != null) {
        debugPrint('✅ Image trouvée (marque)');
        return fallback1['url_image'] as String;
      }

      // Fallback 2 : nom_piece_ia uniquement
      final fallback2 = await supabase
          .from('pieces_diagnostic')
          .select('url_image')
          .eq('nom_piece_ia', keyword)
          .limit(1)
          .maybeSingle();

      if (fallback2 != null && fallback2['url_image'] != null) {
        debugPrint('✅ Image trouvée (générique)');
        return fallback2['url_image'] as String;
      }

      debugPrint('⚠️ Aucune image pour "$keyword"');
      return null;
    } catch (e) {
      debugPrint('❌ Erreur récupération image pièce : $e');
      return null;
    }
  }

  /// Widget asynchrone qui affiche l'image d'une pièce
  Widget buildPieceImage({
    required String marque,
    required String modele,
    required String motorisation,
    required String nomPieceIa,
    double width = 80,
    double height = 80,
    double borderRadius = 12,
  }) {
    return FutureBuilder<String?>(
      future: getPieceImageUrl(
        marque: marque,
        modele: modele,
        motorisation: motorisation,
        nomPieceIa: nomPieceIa,
      ),
      builder: (context, snapshot) {
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

        if (snapshot.hasError || snapshot.data == null) {
          return _buildPlaceholder(
            width: width,
            height: height,
            borderRadius: borderRadius,
            child: Icon(
              Icons.image_not_supported_rounded,
              color: AppColors.textLight,
              size: width * 0.4,
            ),
          );
        }

        return ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: CachedNetworkImage(
            imageUrl: snapshot.data!,
            width: width,
            height: height,
            fit: BoxFit.cover,
            placeholder: (context, url) => _buildPlaceholder(
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
            ),
            errorWidget: (context, url, error) => _buildPlaceholder(
              width: width,
              height: height,
              borderRadius: borderRadius,
              child: Icon(
                Icons.broken_image_rounded,
                color: AppColors.textLight,
                size: width * 0.4,
              ),
            ),
            memCacheWidth: (width * 2).toInt(),
            memCacheHeight: (height * 2).toInt(),
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