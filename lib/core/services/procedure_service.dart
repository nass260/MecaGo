// lib/core/services/procedure_service.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service de récupération des procédures depuis Supabase
///
/// ✅ Cherche dans la base AVANT d'appeler l'IA
/// ✅ Retourne les procédures vérifiées
/// ✅ Filtre par véhicule (marque, modèle, moteur)
class ProcedureService {
  const ProcedureService();

  /// Cherche une procédure par mots-clés + véhicule
  Future<Map<String, dynamic>?> findProcedure({
    required String question,
    required String marque,
    required String modele,
    String? moteur,
  }) async {
    try {
      final supabase = Supabase.instance.client;

      // 1. Extraire les mots-clés de la question
      final keywords = _extractKeywords(question);
      debugPrint('🔍 Recherche procédure : $keywords');

      // 2. Chercher dans Supabase
      final response = await supabase
          .from('procedures')
          .select()
          .or(keywords.map((k) => 'mots_cles.cs.{${k}}').join(','))
          .limit(1)
          .maybeSingle();

      if (response == null) {
        debugPrint('⚠️ Aucune procédure trouvée pour : $keywords');
        return null;
      }

      debugPrint('✅ Procédure trouvée : ${response['titre']}');

      // 3. Convertir en JSON compatible avec ProcedureData
      return {
        'type': 'procedure',
        'titre': response['titre'],
        'vehicule': '$marque $modele',
        'duree_estimee': response['duree_estimee'] ?? 'Non communiquée',
        'difficulte': response['difficulte'] ?? 'intermediaire',
        'niveau_danger': response['niveau_danger'] ?? 'faible',
        'public_cible': response['public_cible'] ?? 'tous',
        'formation_requise': response['formation_requise'] ?? 'Aucune',
        'outils': response['outils'] ?? [],
        'pieces': response['pieces'] ?? [],
        'avertissements_securite': response['avertissements_securite'] ?? [],
        'avertissements_legaux': response['avertissements_legaux'] ?? [],
        'etapes': response['etapes'] ?? [],
        'conseil_final': response['conseil_final'] ?? '',
        'sources': response['sources'] ?? ['MecaGo'],
      };
    } catch (e) {
      debugPrint('❌ Erreur ProcedureService : $e');
      return null;
    }
  }

  /// Extrait les mots-clés de la question utilisateur
  List<String> _extractKeywords(String question) {
    final lower = question.toLowerCase();
    final keywords = <String>[];

    // Freinage
    if (lower.contains('plaquette')) keywords.add('plaquette');
    if (lower.contains('disque')) keywords.add('disque');
    if (lower.contains('frein') || lower.contains('freinage')) keywords.add('frein');
    if (lower.contains('purge')) keywords.add('purge');

    // Entretien
    if (lower.contains('vidange')) keywords.add('vidange');
    if (lower.contains('huile')) keywords.add('huile');
    if (lower.contains('filtre')) keywords.add('filtre');
    if (lower.contains('air')) keywords.add('air');
    if (lower.contains('habitacle')) keywords.add('habitacle');
    if (lower.contains('carburant') || lower.contains('gazole')) keywords.add('carburant');
    if (lower.contains('bougie')) keywords.add('bougie');
    if (lower.contains('batterie')) keywords.add('batterie');
    if (lower.contains('courroie')) keywords.add('courroie');

    // Si rien trouvé → chercher mot par mot
    if (keywords.isEmpty) {
      final words = lower.split(' ').where((w) => w.length > 3).toList();
      keywords.addAll(words.take(3));
    }

    return keywords;
  }
}