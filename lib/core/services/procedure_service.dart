// lib/core/services/procedure_service.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProcedureService {
  const ProcedureService();

  Future<Map<String, dynamic>?> findProcedure({
    required String question,
    required String marque,
    required String modele,
    String? moteur,
    String? carburant, // <-- AJOUTÉ ICI
  }) async {
    try {
      final supabase = Supabase.instance.client;

      final keywords = _extractKeywords(question);
      debugPrint('🔍 Recherche procédure : $keywords');

      if (keywords.isEmpty) {
        debugPrint('⚠️ Aucun mot-clé détecté');
        return null;
      }

      final response = await supabase
          .from('procedures')
          .select()
          .or(keywords.map((k) => 'mots_cles.cs.{${k}}').join(','));

      if (response.isEmpty) {
        debugPrint('⚠️ Aucune procédure trouvée');
        return null;
      }

      final scored = <MapEntry<Map<String, dynamic>, int>>[];
      for (final proc in response) {
        final score = _calculateScore(proc, keywords);
        scored.add(MapEntry(proc, score));
      }

      scored.sort((a, b) => b.value.compareTo(a.value));
      final best = scored.first;
      debugPrint('✅ Procédure trouvée : ${best.key['titre']} (score: ${best.value})');

      if (best.value < 2) {
        debugPrint('⚠️ Score trop faible (${best.value})');
        return null;
      }

      String? notesSpecifiques;
      if (marque.isNotEmpty && modele.isNotEmpty) {
        try {
          // Nettoyage du modèle (enlever les chiffres romains)
          final modeleClean = modele.replaceAll(RegExp(r'\s+(I|II|III|IV|V|VI|VII|VIII|IX|X)$', caseSensitive: false), '').trim();

          // 1. On cherche le véhicule AVEC le carburant !
          var vQuery = supabase
              .from('vehicules')
              .select('id')
              .ilike('marque', '%$marque%')
              .ilike('modele', '%$modeleClean%');
          
          if (carburant != null && carburant.isNotEmpty) {
            vQuery = vQuery.ilike('carburant', '%$carburant%'); // Filtre crucial !
          }

          final vehiculeData = await vQuery.limit(1).maybeSingle();

          if (vehiculeData != null) {
            final vehiculeId = vehiculeData['id'];
            
            final pvResponse = await supabase
                .from('procedures_vehicules')
                .select('notes_specifiques')
                .eq('procedure_id', best.key['id'])
                .eq('vehicule_id', vehiculeId)
                .maybeSingle();

            if (pvResponse != null && pvResponse['notes_specifiques'] != null) {
              notesSpecifiques = pvResponse['notes_specifiques'];
              debugPrint('✅ NOTES SPÉCIFIQUES TROUVÉES !');
            } else {
              debugPrint('⚠️ Liaison trouvée mais notes vides dans Supabase.');
            }
          } else {
            debugPrint('⚠️ Véhicule $marque $modeleClean ($carburant) introuvable.');
          }
        } catch (e) {
          debugPrint('⚠️ Erreur récupération notes_specifiques : $e');
        }
      }

      return {
        'type': 'procedure',
        'titre': best.key['titre'],
        'vehicule': '$marque $modele',
        'duree_estimee': best.key['duree_estimee'] ?? 'Non communiquée',
        'difficulte': best.key['difficulte'] ?? 'intermediaire',
        'niveau_danger': best.key['niveau_danger'] ?? 'faible',
        'public_cible': best.key['public_cible'] ?? 'tous',
        'formation_requise': best.key['formation_requise'] ?? 'Aucune',
        'outils': best.key['outils'] ?? [],
        'pieces': best.key['pieces'] ?? [],
        'avertissements_securite': best.key['avertissements_securite'] ?? [],
        'avertissements_legaux': best.key['avertissements_legaux'] ?? [],
        'etapes': best.key['etapes'] ?? [],
        'alternative_nettoyage': best.key['alternative_nettoyage'],
        'conseil_final': best.key['conseil_final'] ?? '',
        'sources': best.key['sources'] ?? ['MecaGo'],
        'notes_specifiques': notesSpecifiques,
      };
    } catch (e) {
      debugPrint('❌ Erreur ProcedureService : $e');
      return null;
    }
  }

  int _calculateScore(Map<String, dynamic> procedure, List<String> keywords) {
    int score = 0;
    final motsCles = List<String>.from(procedure['mots_cles'] ?? []);
    final titre = (procedure['titre'] ?? '').toString().toLowerCase();

    for (final keyword in keywords) {
      if (motsCles.contains(keyword)) score += 3;
      if (titre.contains(keyword)) score += 2;
    }
    return score;
  }

  List<String> _extractKeywords(String question) {
    final lower = question.toLowerCase();
    final keywords = <String>{};

    if (lower.contains('plaquette')) keywords.add('plaquettes');
    if (lower.contains('disque')) keywords.add('disques');
    if (lower.contains('purge') || lower.contains('purg')) keywords.add('purge');
    if (lower.contains('étrier') || lower.contains('etrier')) keywords.add('freinage');
    if (lower.contains('frein') || lower.contains('freinage')) keywords.add('freinage');

    if (lower.contains('vidange')) keywords.add('vidange');
    if (lower.contains('huile') && !lower.contains('frein')) keywords.add('vidange');
    if (lower.contains('filtre')) keywords.add('filtre');
    if (lower.contains('habitacle')) keywords.add('habitacle');
    if (lower.contains('carburant') || lower.contains('gazole') || lower.contains('gasoil')) keywords.add('carburant');
    if (lower.contains('bougie')) keywords.add('bougie');
    if (lower.contains('batterie')) keywords.add('batterie');
    if (lower.contains('courroie')) keywords.add('courroie');
    if (lower.contains('accessoire')) keywords.add('courroie');

    if (lower.contains('rotule')) keywords.add('rotule');
    if (lower.contains('biellette')) keywords.add('biellette');
    if (lower.contains('crémaillère') || lower.contains('cremaillere')) keywords.add('crémaillère');
    if (lower.contains('direction')) keywords.add('direction');
    if (lower.contains('volant')) keywords.add('direction');

    if (lower.contains('injecteur')) keywords.add('injecteur');
    if (lower.contains('injection')) keywords.add('injection');
    if (lower.contains('turbo')) keywords.add('turbo');
    if (lower.contains('egr')) keywords.add('EGR');
    if (lower.contains('fap')) keywords.add('FAP');
    if (lower.contains('pompe') && lower.contains('injection')) keywords.add('pompe');
    if (lower.contains('courroie') && lower.contains('distribution')) keywords.add('distribution');
    if (lower.contains('distribution')) keywords.add('distribution');
    if (lower.contains('pompe') && lower.contains('eau')) keywords.add('pompe à eau');
    if (lower.contains('thermostat')) keywords.add('thermostat');
    if (lower.contains('radiateur')) keywords.add('radiateur');
    if (lower.contains('culasse')) keywords.add('culasse');
    if (lower.contains('joint') && lower.contains('culasse')) keywords.add('culasse');

    if (lower.contains('embrayage')) keywords.add('embrayage');
    if (lower.contains('cardan')) keywords.add('cardan');
    if (lower.contains('boîte') || lower.contains('boite')) keywords.add('boîte');
    if (lower.contains('différentiel') || lower.contains('differentiel')) keywords.add('différentiel');
    if (lower.contains('roulement')) keywords.add('roulement');

    if (lower.contains('silencieux')) keywords.add('silencieux');
    if (lower.contains('catalyseur')) keywords.add('catalyseur');
    if (lower.contains('lambda')) keywords.add('lambda');
    if (lower.contains('collecteur')) keywords.add('collecteur');
    if (lower.contains('tube') && lower.contains('échappement')) keywords.add('tube');

    if (lower.contains('clim')) keywords.add('clim');
    if (lower.contains('compresseur')) keywords.add('compresseur');
    if (lower.contains('condenseur')) keywords.add('condenseur');
    if (lower.contains('évaporateur') || lower.contains('evaporateur')) keywords.add('évaporateur');
    if (lower.contains('déshydrateur') || lower.contains('deshydrateur')) keywords.add('déshydrateur');

    if (lower.contains('obd')) keywords.add('OBD');
    if (lower.contains('compression')) keywords.add('compression');
    if (lower.contains('multimètre') || lower.contains('multimetre')) keywords.add('multimètre');
    if (lower.contains('allumage')) keywords.add('allumage');

    if (lower.contains('rétroviseur') || lower.contains('retroviseur')) keywords.add('rétroviseur');
    if (lower.contains('pare-chocs') || lower.contains('parechoc')) keywords.add('pare-chocs');
    if (lower.contains('phare')) keywords.add('phare');
    if (lower.contains('essuie')) keywords.add('essuie-glaces');
    if (lower.contains('garniture')) keywords.add('garniture');

    if (keywords.isEmpty) {
      if (lower.contains('changer') || lower.contains('comment') || lower.contains('remplacer')) {
         keywords.add('vidange');
      }
      final words = lower.split(RegExp(r'[\s,;.!?]+')).where((w) => w.length > 3).toList();
      keywords.addAll(words.take(3));
    }

    return keywords.toList();
  }
}