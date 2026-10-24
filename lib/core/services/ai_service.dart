// lib/core/services/ai_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'gemini_service.dart';
import 'gemini_flash_service.dart';
import 'groq_service.dart';
import 'procedure_service.dart';

class AiService {
  const AiService();

  final GeminiFlashService _geminiFlash = const GeminiFlashService();
  final GroqService _groq = const GroqService();
  final GeminiService _gemini = const GeminiService();
  final ProcedureService _procedureService = const ProcedureService();

  String buildVehicleContext({
    required String brand,
    required String model,
    required int year,
    required String fuel,
    String? engine,
    String? plate,
    String? vin,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('Marque : $brand');
    buffer.writeln('Modèle : $model');
    buffer.writeln('Année : $year');
    buffer.writeln('Carburant : $fuel');

    if (_isElectric(fuel)) {
      buffer.writeln('Moteur : électrique (aucun moteur thermique, pas d\'huile moteur ni de bougies)');
    } else if (engine != null && engine.trim().isNotEmpty) {
      buffer.writeln('Moteur : ${engine.trim()}');
    } else {
      buffer.writeln('Moteur : non précisé (ne pas poser de question, donne la procédure générale pour ce modèle)');
    }

    if (plate != null && plate.trim().isNotEmpty) {
      buffer.writeln('Plaque : ${plate.trim().toUpperCase()}');
    }

    if (vin != null && vin.trim().isNotEmpty) {
      buffer.writeln('VIN : ${vin.trim().toUpperCase()}');
    }

    return buffer.toString();
  }

  String _extractFromContext(String context, String key) {
    final lines = context.split('\n');
    for (final line in lines) {
      if (line.startsWith('$key :')) {
        return line.substring('$key :'.length).trim();
      }
    }
    return '';
  }

  bool _isElectric(String fuel) {
    final f = fuel.toLowerCase().replaceAll('é', 'e').replaceAll('è', 'e');
    return f.contains('electri') && !f.contains('hybrid');
  }

  bool _isThermalOnlyQuestion(String q) {
    final t = q.toLowerCase().replaceAll('é', 'e').replaceAll('è', 'e').replaceAll('ê', 'e');
    const words = [
      'vidange', 'huile moteur', 'filtre a huile', 'bougie',
      'courroie de distribution', 'kit de distribution', 'filtre a gasoil',
      'filtre a carburant', 'injecteur', 'turbo', 'fap', 'egr',
      'echappement', 'catalyseur', 'embrayage',
    ];
    return words.any(t.contains);
  }

  Future<AiDiagnosisResponse> diagnose({
    required String vehicleContext,
    required String symptoms,
  }) async {
    try {
      final json = await _geminiFlash.diagnose(vehicleContext: vehicleContext, symptoms: symptoms);
      return AiDiagnosisResponse(json: json, provider: AiProvider.geminiFlash);
    } catch (e) { debugPrint('⚠️ Gemini Flash diag échoué → $e'); }

    try {
      final json = await _groq.diagnose(vehicleInfo: vehicleContext, symptoms: symptoms);
      return AiDiagnosisResponse(json: json, provider: AiProvider.groq);
    } catch (e) { debugPrint('⚠️ Groq diag échoué → $e'); }

    if (!kIsWeb) {
      try {
        final json = await _gemini.diagnose(vehicleInfo: vehicleContext, symptoms: symptoms);
        return AiDiagnosisResponse(json: json, provider: AiProvider.gemini);
      } catch (e) { debugPrint('⚠️ Gemini FB diag échoué → $e'); }
    }

    throw Exception('Tous les fournisseurs IA ont échoué');
  }

  Future<AiChatResponse> chat({
    required String vehicleContext,
    required String question,
    required List<Map<String, String>> conversationHistory,
  }) async {
    final fuelCtx = _extractFromContext(vehicleContext, 'Carburant');
    if (_isElectric(fuelCtx) && _isThermalOnlyQuestion(question)) {
      final vehicule = '${_extractFromContext(vehicleContext, 'Marque')} ${_extractFromContext(vehicleContext, 'Modèle')}'.trim();
      return AiChatResponse(
        json: {
          'type': 'reponse_simple',
          'titre': 'Pas de vidange moteur sur ce véhicule',
          'reponse': 'La $vehicule est 100 % électrique : elle n\'a pas de moteur thermique, donc ni vidange d\'huile moteur, ni filtre à huile, ni bougies.',
          'details': [
            'À contrôler régulièrement à la place : freins, pneus, filtre d\'habitacle, liquide de frein et batterie 12 V.',
            'Pour le réducteur et le circuit de refroidissement de la batterie, suis le carnet d\'entretien du constructeur.',
          ],
          'sources': [],
        },
        provider: AiProvider.none,
      );
    }

    Map<String, dynamic>? procedure;

    try {
      debugPrint('📚 AiService : recherche dans Supabase...');

      final marque = _extractFromContext(vehicleContext, 'Marque').replaceAll(',', '').trim();
      final modele = _extractFromContext(vehicleContext, 'Modèle').replaceAll(',', '').trim();
      final moteur = _extractFromContext(vehicleContext, 'Moteur').replaceAll(',', '').trim();
      final carburant = _extractFromContext(vehicleContext, 'Carburant').replaceAll(',', '').trim();

      procedure = await _procedureService.findProcedure(
        question: question,
        marque: marque,
        modele: modele,
        moteur: moteur,
        carburant: carburant,
      );
    } catch (e) {
      debugPrint('⚠️ AiService : Supabase a échoué → $e');
    }

    if (procedure != null) {
      // ✅ CORRECTION : On affiche la fiche directe si elle a des options de diagnostic
      final options = procedure['options_diagnostic'];
      if (options != null && options is List && options.isNotEmpty) {
        debugPrint('✅ AiService : fiche diagnostic (options) affichée directement (sans IA)');
        return _buildProcedureResponse(procedure);
      }

      final etapes = procedure['etapes'];
      if (etapes is List && etapes.isNotEmpty) {
        debugPrint('✅ AiService : fiche Supabase affichée directement (sans IA)');
        return _buildProcedureResponse(procedure);
      }
      debugPrint('ℹ️ AiService : fiche sans étapes dans Supabase → IA');
    } else {
      debugPrint('⚠️ AiService : aucune procédure dans Supabase → IA');
    }

    // ✅ VERROUILLAGE DU PROMPT DE SECOURS
    const strictPrompt = """
    CONSIGNES STRICTES DE SÉCURITÉ (MecaGo Premium) :
    1. Tu es un assistant mécanique de confiance pour MecaGo.
    2. Tu NE DOIS JAMAIS inventer une valeur technique (taille de douille, couple de serrage, référence de pièce).
    3. Si tu n'es pas certain à 100% d'une valeur, tu dois écrire : "À vérifier dans le manuel du constructeur".
    4. Tu NE DOIS JAMAIS conseiller d'aller au garage. Tu es là pour donner la marche à suivre.
    5. Sois précis, technique et direct.
    """;

    return _callAiChat(vehicleContext, "$strictPrompt\n\nQuestion : $question", conversationHistory, procedure);
  }

  // ============================================
  // FICHE SUPABASE → RÉPONSE (sans IA)
  // ============================================

  Map<String, dynamic>? _parseSpecificites(dynamic raw) {
    if (raw == null) return null;
    try {
      dynamic decoded = raw is String ? jsonDecode(raw) : raw;
      if (decoded is String) decoded = jsonDecode(decoded);
      if (decoded is! Map) return null;
      final map = Map<String, dynamic>.from(decoded);

      final notes = map['notes'];
      if (notes is List && notes.isNotEmpty) {
        final first = notes.first;
        if (first is Map && first['specificites'] is Map) {
          return Map<String, dynamic>.from(first['specificites']);
        }
        return null;
      }

      if (map.containsKey('specificites')) {
        final s = map['specificites'];
        return s is Map ? Map<String, dynamic>.from(s) : null;
      }

      return map;
    } catch (e) {
      debugPrint('⚠️ Impossible de lire les notes spécifiques : $e');
      return null;
    }
  }

  List<String> _stringList(dynamic v) {
    if (v is List) {
      return v.map((e) => e.toString().trim()).where((e) => e.isNotEmpty).toList();
    }
    return [];
  }

  String _txt(dynamic v) {
    final t = v?.toString().trim() ?? '';
    return t == 'null' ? '' : t;
  }

  AiChatResponse _buildProcedureResponse(Map<String, dynamic> procedure) {
    final etapes = <Map<String, dynamic>>[];
    final rawEtapes = procedure['etapes'];
    if (rawEtapes is List) {
      for (final e in rawEtapes) {
        if (e is Map) etapes.add(Map<String, dynamic>.from(e));
      }
    }

    final spec = _parseSpecificites(procedure['notes_specifiques']);
    var conseil = _txt(procedure['conseil_final']);
    final pieces = <Map<String, dynamic>>[];

    if (spec != null) {
      final loc = spec['localisation_piece'];
      if (loc is Map) {
        final lines = <String>[];
        void add(String label, dynamic v) {
          final t = _txt(v);
          if (t.isNotEmpty) lines.add(label.isEmpty ? t : '$label $t');
        }

        add('', loc['emplacement']);
        add('Accès :', loc['acces']);
        add('À retirer :', loc['conduit_a_retirer']);
        add('Outil :', loc['outil']);
        add('Astuce :', loc['astuce']);

        if (lines.isNotEmpty) {
          etapes.insert(0, {
            'numero': 1,
            'titre': 'Repérer la pièce sur votre véhicule',
            'description': lines.join(' '),
            'outils': _stringList(spec['outils_specifiques']),
            'couples': [],
          });
        }
      }

      final block = <String>[];

      final couples = spec['couples_specifiques'];
      if (couples is List && couples.isNotEmpty) {
        block.add('Couples de serrage :');
        for (final c in couples) {
          if (c is Map) {
            final nom = _txt(c['boulon']);
            final val = _txt(c['valeur']);
            if (nom.isNotEmpty || val.isNotEmpty) block.add('• $nom : $val');
          }
        }
      }

      final huile = _txt(spec['type_huile']);
      if (huile.isNotEmpty && huile != 'N/A') block.add('Huile / fluide : $huile');
      final capacite = _txt(spec['capacite_huile']);
      if (capacite.isNotEmpty && capacite != 'N/A') block.add('Capacité : $capacite');
      final duree = _txt(spec['duree_reelle']);
      if (duree.isNotEmpty) block.add('Durée réelle : $duree');

      final astuces = _stringList(spec['astuces']);
      if (astuces.isNotEmpty) {
        block.add('Astuces :');
        block.addAll(astuces.map((a) => '• $a'));
      }
      final pieges = _stringList(spec['pieges']);
      if (pieges.isNotEmpty) {
        block.add('Pièges à éviter :');
        block.addAll(pieges.map((p) => '• $p'));
      }
      final precautions = _stringList(spec['precautions_specifiques']);
      if (precautions.isNotEmpty) {
        block.add('Précautions :');
        block.addAll(precautions.map((p) => '• $p'));
      }
      final particularites = _txt(spec['particularites_moteur']);
      if (particularites.isNotEmpty) block.add('À savoir : $particularites');

      if (block.isNotEmpty) {
        final text = 'Spécificités pour votre véhicule\n${block.join('\n')}';
        conseil = conseil.isEmpty ? text : '$conseil\n\n$text';
      }

      final recommandees = spec['pieces_recommandees'];
      if (recommandees is List) {
        for (final piece in recommandees) {
          if (piece is! Map) continue;
          pieces.add({
            'nom': piece['nom'],
            'variantes': [
              {
                'numero': 1,
                'ref': piece['ref_origine'] ?? '',
                'prix': piece['prix_estime'] ?? '',
                'criteres': 'Recommandé',
                'equivalents': piece['equivalents'] ?? [],
                'source': 'MecaGo',
                'confiance': 'haute',
              }
            ],
            'avertissement': '',
            'guide_choix': {},
          });
        }
      }
    }

    for (var i = 0; i < etapes.length; i++) {
      etapes[i]['numero'] = i + 1;
    }

    return AiChatResponse(
      json: {
        'type': 'procedure',
        'titre': procedure['titre'] ?? 'Procédure MecaGo',
        'vehicule': procedure['vehicule'] ?? '',
        'duree_estimee': procedure['duree_estimee'] ?? 'Non communiquée',
        'difficulte': procedure['difficulte'] ?? 'intermediaire',
        'niveau_danger': procedure['niveau_danger'] ?? 'faible',
        'public_cible': procedure['public_cible'] ?? 'tous',
        'formation_requise': procedure['formation_requise'] ?? 'Aucune',
        'outils': procedure['outils'] ?? [],
        'pieces': pieces.isNotEmpty ? pieces : (procedure['pieces'] ?? []),
        'avertissements_securite': procedure['avertissements_securite'] ?? [],
        'avertissements_legaux': procedure['avertissements_legaux'] ?? [],
        'etapes': etapes,
        'conseil_final': conseil,
        'sources': procedure['sources'] ?? ['MecaGo'],
        'options_diagnostic': procedure['options_diagnostic'], // ✅ Injection des options
      },
      provider: AiProvider.none,
    );
  }

  // ============================================
  // IA (uniquement quand ta base n'a rien)
  // ============================================

  Future<AiChatResponse> _callAiChat(
    String vehicleContext,
    String question,
    List<Map<String, String>> conversationHistory,
    Map<String, dynamic>? procedure,
  ) async {
    try {
      debugPrint('💬 AiService : tentative Gemini Flash-Lite chat...');
      final json = await _geminiFlash.chat(vehicleContext: vehicleContext, question: question, conversationHistory: conversationHistory);
      if (procedure != null && json['etapes'] == null) { json['etapes'] = procedure['etapes']; json['titre'] = procedure['titre']; }
      return AiChatResponse(json: json, provider: AiProvider.geminiFlash);
    } catch (e) { debugPrint('⚠️ Gemini Flash chat échoué → $e'); }

    try {
      debugPrint('💬 AiService : tentative Groq chat...');
      final json = await _groq.chat(vehicleContext: vehicleContext, question: question, conversationHistory: conversationHistory);
      if (procedure != null && json['etapes'] == null) { json['etapes'] = procedure['etapes']; json['titre'] = procedure['titre']; }
      return AiChatResponse(json: json, provider: AiProvider.groq);
    } catch (e) { debugPrint('⚠️ Groq chat échoué → $e'); }

    if (!kIsWeb) {
      try {
        debugPrint('💬 AiService : tentative Gemini Firebase chat...');
        final response = await _gemini.chat(vehicleInfo: vehicleContext, question: question);
        return AiChatResponse(json: {'type': 'procedure', 'titre': 'Procédure MecaGo', 'vehicule': vehicleContext.split('\n').first, 'duree_estimee': 'N/C', 'difficulte': 'intermediaire', 'niveau_danger': 'moyen', 'public_cible': 'tous', 'formation_requise': 'Aucune', 'outils': [], 'pieces': [], 'avertissements_securite': [], 'avertissements_legaux': [], 'etapes': _parseTextToEtapes(response), 'conseil_final': '', 'sources': ['Fallback FB']}, provider: AiProvider.gemini);
      } catch (e) { debugPrint('⚠️ Gemini FB chat échoué → $e'); }
    }

    throw Exception('Tous les fournisseurs IA ont échoué');
  }

  List<Map<String, dynamic>> _parseTextToEtapes(String text) {
    final etapes = <Map<String, dynamic>>[];
    String? currentTitre;
    final currentDesc = <String>[];
    int numero = 1;
    for (final line in text.split('\n')) {
      final match = RegExp(r'(?:🔧|📋|⚠️|🔩|🛠️|🔨|⚙️)\s*\*?\*?Étape\s*(\d+)\s*:\s*(.+?)\*?\*?$').firstMatch(line);
      if (match != null) {
        if (currentTitre != null) etapes.add({'numero': numero++, 'titre': currentTitre, 'description': currentDesc.join(' ').trim(), 'outils': [], 'couples': []});
        currentTitre = match.group(2)?.replaceAll('*', '').trim();
        currentDesc.clear();
      } else if (currentTitre != null && line.trim().isNotEmpty && !line.contains('Conseil final') && !line.contains('💡')) {
        currentDesc.add(line.trim().replaceAll('*', ''));
      }
    }
    if (currentTitre != null) etapes.add({'numero': numero, 'titre': currentTitre, 'description': currentDesc.join(' ').trim(), 'outils': [], 'couples': []});
    return etapes;
  }
}

enum AiProvider { geminiFlash, gemini, groq, none }

class AiDiagnosisResponse {
  final Map<String, dynamic> json; final AiProvider provider;
  const AiDiagnosisResponse({required this.json, required this.provider});
  bool get isFromAI => provider != AiProvider.none;
  String get providerName => provider == AiProvider.geminiFlash ? 'Gemini Flash' : provider == AiProvider.gemini ? 'Gemini' : provider == AiProvider.groq ? 'MecaGo IA' : 'Local';
}

class AiChatResponse {
  final Map<String, dynamic> json; final AiProvider provider;
  const AiChatResponse({required this.json, required this.provider});
  bool get isFromAI => provider != AiProvider.none;
  String get providerName => provider == AiProvider.geminiFlash ? 'Gemini Flash' : provider == AiProvider.gemini ? 'Gemini' : provider == AiProvider.groq ? 'MecaGo IA' : 'Local';
}