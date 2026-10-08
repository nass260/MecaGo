// lib/core/services/piece_image_service.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/app_theme.dart';

/// Service de récupération des images de pièces depuis Supabase
class PieceImageService {
  const PieceImageService();

  /// Extrait un mot-clé générique à partir du nom de la pièce
  /// COUVRE TOUS LES CAS DU MONDE AUTOMOBILE
  String _extractKeyword(String nomPieceIa) {
    final lower = nomPieceIa.toLowerCase();

    // ============================================
    // FREINAGE
    // ============================================
    if (lower.contains('plaquette')) return 'plaquettes';
    if (lower.contains('disque')) return 'disques';
    if (lower.contains('étrier') || lower.contains('etrier')) return 'etrier';
    if (lower.contains('caliper')) return 'etrier';
    if (lower.contains('mâchoire') || lower.contains('machoire')) return 'freins';
    if (lower.contains('boulon') && lower.contains('frein')) return 'boulons';
    if (lower.contains('boulon')) return 'boulons';
    if (lower.contains('frein')) return 'freins';
    if (lower.contains('abs')) return 'capteur_abs';
    if (lower.contains('liquide') && lower.contains('frein')) return 'liquide_frein';

    // ============================================
    // FILTRATION
    // ============================================
    if (lower.contains('habitacle') || lower.contains('pollen')) return 'filtre_habitacle';
    if (lower.contains('gasoil') || lower.contains('diesel')) return 'filtre_gasoil';
    if (lower.contains('huile') && lower.contains('filtre')) return 'filtre_huile';
    if (lower.contains('filtre') && lower.contains('huile')) return 'filtre_huile';
    if (lower.contains('air') && lower.contains('filtre')) return 'filtre_air';
    if (lower.contains('filtre') && lower.contains('air')) return 'filtre_air';
    if (lower.contains('filtre')) return 'filtre_huile';

    // ============================================
    // MOTEUR
    // ============================================
    if (lower.contains('bougie')) return 'bougies';
    if (lower.contains('courroie') && lower.contains('distribution')) return 'courroie';
    if (lower.contains('courroie')) return 'courroie';
    if (lower.contains('galet')) return 'courroie';
    if (lower.contains('vanne') && lower.contains('egr')) return 'vanne_egr';
    if (lower.contains('egr')) return 'vanne_egr';
    if (lower.contains('turbo') || lower.contains('turbocompresseur')) return 'turbo';
    if (lower.contains('injecteur')) return 'injecteur';
    if (lower.contains('pompe') && lower.contains('eau')) return 'pompe_eau';
    if (lower.contains('pompe') && lower.contains('huile')) return 'pompe_huile';
    if (lower.contains('pompe') && lower.contains('carburant')) return 'pompe_carburant';
    if (lower.contains('pompe')) return 'pompe_eau';
    if (lower.contains('radiateur')) return 'radiateur';
    if (lower.contains('thermostat')) return 'thermostat';
    if (lower.contains('joint') && lower.contains('culasse')) return 'joint_culasse';
    if (lower.contains('culasse')) return 'joint_culasse';
    if (lower.contains('débitmètre') || lower.contains('debimetre')) return 'debimetre';
    if (lower.contains('sonde') && lower.contains('lambda')) return 'sonde_lambda';
    if (lower.contains('lambda')) return 'sonde_lambda';
    if (lower.contains('bobine') && lower.contains('allumage')) return 'bobine';
    if (lower.contains('bobine')) return 'bobine';
    if (lower.contains('démarreur') || lower.contains('demarreur')) return 'demarreur';
    if (lower.contains('alternateur')) return 'alternateur';
    if (lower.contains('échap') || lower.contains('echap')) return 'echappement';
    if (lower.contains('silencieux')) return 'echappement';
    if (lower.contains('pot') && lower.contains('échappement')) return 'echappement';
    if (lower.contains('catalyseur') || lower.contains('catalytique')) return 'catalyseur';
    if (lower.contains('fap') || lower.contains('particule')) return 'fap';
    if (lower.contains('embrayage') || lower.contains('kit embrayage')) return 'embrayage';
    if (lower.contains('volant') && lower.contains('moteur')) return 'volant_moteur';
    if (lower.contains('vilebrequin')) return 'vilebrequin';
    if (lower.contains('piston')) return 'piston';
    if (lower.contains('soupape')) return 'soupape';
    if (lower.contains('moteur')) return 'moteur';

    // ============================================
    // ÉLECTRICITÉ
    // ============================================
    if (lower.contains('batterie') || lower.contains('accumulateur')) return 'batterie';
    if (lower.contains('alternateur')) return 'alternateur';
    if (lower.contains('démarreur') || lower.contains('demarreur')) return 'demarreur';
    if (lower.contains('ampoule') || lower.contains('phare')) return 'ampoule';
    if (lower.contains('feu') && lower.contains('arrière')) return 'feu_arriere';
    if (lower.contains('feu') && lower.contains('stop')) return 'feu_stop';
    if (lower.contains('fusible')) return 'fusible';
    if (lower.contains('relais')) return 'relais';
    if (lower.contains('capteur')) return 'capteur';

    // ============================================
    // SUSPENSION & DIRECTION
    // ============================================
    if (lower.contains('amortisseur')) return 'amortisseur';
    if (lower.contains('ressort')) return 'ressort';
    if (lower.contains('rotule')) return 'rotule';
    if (lower.contains('cardan')) return 'cardan';
    if (lower.contains('roulement')) return 'roulement';
    if (lower.contains('triangle') && lower.contains('suspension')) return 'triangle';
    if (lower.contains('biellette')) return 'biellette';
    if (lower.contains('barre') && lower.contains('stabilisatrice')) return 'barre_stabilisatrice';
    if (lower.contains('direction')) return 'direction';
    if (lower.contains('crémaillère') || lower.contains('cremaillere')) return 'cremaillere';

    // ============================================
    // TRANSMISSION
    // ============================================
    if (lower.contains('boîte') && lower.contains('vitesse')) return 'boite_vitesse';
    if (lower.contains('boite') && lower.contains('vitesse')) return 'boite_vitesse';
    if (lower.contains('embrayage')) return 'embrayage';
    if (lower.contains('cardan')) return 'cardan';
    if (lower.contains('différentiel') || lower.contains('differentiel')) return 'differentiel';
    if (lower.contains('arbre') && lower.contains('transmission')) return 'arbre_transmission';

    // ============================================
    // CLIMATISATION
    // ============================================
    if (lower.contains('clim') || lower.contains('climatisation')) return 'clim';
    if (lower.contains('compresseur') && lower.contains('clim')) return 'compresseur_clim';
    if (lower.contains('compresseur')) return 'compresseur_clim';
    if (lower.contains('condenseur')) return 'condenseur';
    if (lower.contains('évaporateur') || lower.contains('evaporateur')) return 'evaporateur';
    if (lower.contains('gaz') && lower.contains('clim')) return 'gaz_clim';

    // ============================================
    // CARROSSERIE
    // ============================================
    if (lower.contains('pare-choc') || lower.contains('parechoc')) return 'pare_choc';
    if (lower.contains('capot')) return 'capot';
    if (lower.contains('aile')) return 'aile';
    if (lower.contains('portière') || lower.contains('portiere')) return 'portiere';
    if (lower.contains('rétroviseur') || lower.contains('retroviseur')) return 'retroviseur';
    if (lower.contains('pare-brise') || lower.contains('parebrise')) return 'pare_brise';
    if (lower.contains('vitre')) return 'vitre';
    if (lower.contains('calandre')) return 'calandre';

    // ============================================
    // PNEUMATIQUES
    // ============================================
    if (lower.contains('pneu') || lower.contains('pneumatique')) return 'pneus';
    if (lower.contains('jante')) return 'jante';
    if (lower.contains('valve')) return 'valve';
    if (lower.contains('roue')) return 'roue';

    // ============================================
    // SYSTÈMES (avec __)
    // ============================================
    if (lower.contains('__systeme_moteur')) return '__systeme_moteur';
    if (lower.contains('__systeme_freins')) return '__systeme_freins';
    if (lower.contains('__systeme_clim')) return '__systeme_clim';
    if (lower.contains('__systeme_batterie')) return '__systeme_batterie';

    // ============================================
    // PAR DÉFAUT : remplacer les espaces par des underscores
    // ============================================
    return nomPieceIa.toLowerCase().replaceAll(' ', '_');
  }

  /// Récupère l'URL de l'image d'une pièce depuis Supabase
  Future<String?> getPieceImageUrl(String nomPieceIa) async {
    try {
      final supabase = Supabase.instance.client;
      final keyword = _extractKeyword(nomPieceIa);

      debugPrint('🔍 Recherche image pièce : $keyword (depuis "$nomPieceIa")');

      final response = await supabase
          .from('pieces_diagnostic')
          .select('url_image')
          .eq('nom_piece_ia', keyword)
          .limit(1)
          .maybeSingle();

      if (response != null && response['url_image'] != null) {
        debugPrint('✅ Image trouvée : $keyword');
        return response['url_image'] as String;
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
    required String nomPieceIa,
    double width = 80,
    double height = 80,
    double borderRadius = 12,
  }) {
    return FutureBuilder<String?>(
      future: getPieceImageUrl(nomPieceIa),
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
              Icons.build_rounded,
              color: AppColors.orange,
              size: width * 0.5,
            ),
          );
        }

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
              padding: const EdgeInsets.all(4),
              child: CachedNetworkImage(
                imageUrl: snapshot.data!,
                width: width,
                height: height,
                fit: BoxFit.contain,
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