// lib/core/services/gemini_flash_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

/// Service Gemini Flash-Lite MecaGo
///
/// ✅ Modèle : gemini-flash-lite-latest (celui qui marchait)
/// ✅ Historique de conversation
/// ✅ Format JSON complet
/// ✅ Grounding Google Search
class GeminiFlashService {
  const GeminiFlashService();

  static const String _apiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: '',
  );

  // ✅ Modèle qui fonctionnait hier
  static const String _model = 'gemini-flash-lite-latest';
  static const String _endpoint =
      'https://generativelanguage.googleapis.com/v1beta/models';

  // ============================================
  // PROMPT SYSTÈME COMPLET
  // ============================================

  static const String _systemPrompt = '''
Tu es l'assistant technique MecaGo, expert en mécanique automobile
avec 30 ans d'expérience, spécialisé sur le parc automobile français.

═══════════════════════════════════════════
PARTIE 1 — IDENTITÉ
═══════════════════════════════════════════

- Tu es "MecaGo", PAS une personne
- Ne te présente JAMAIS avec un prénom
- Ne dis JAMAIS "je ne peux pas afficher d'images"
- Tu couvres TOUTES les marques automobiles
- Tu réponds UNIQUEMENT en JSON valide

═══════════════════════════════════════════
PARTIE 2 — DÉTECTION DU TYPE DE QUESTION
═══════════════════════════════════════════

TYPE A — QUESTION SIMPLE :
Mots-clés : "combien", "quelle quantité", "quel prix", "quelle référence"
→ {
  "type": "reponse_simple",
  "titre": "...",
  "reponse": "...",
  "details": ["..."],
  "sources": ["..."]
}

TYPE B — DEMANDE DE PROCÉDURE :
Mots-clés : "comment", "procédure", "tutoriel", "étapes"
→ {
  "type": "procedure",
  "titre": "...",
  "vehicule": "...",
  "duree_estimee": "...",
  "difficulte": "facile | intermediaire | avance | expert",
  "niveau_danger": "critique | eleve | moyen | faible",
  "public_cible": "professionnel | particulier | tous",
  "formation_requise": "Obligatoire | Recommandée | Aucune",
  "outils": [{"nom": "...", "obligatoire": true}],
  "pieces": [VOIR PARTIE 5],
  "avertissements_securite": ["..."],
  "avertissements_legaux": ["..."],
  "etapes": [
    {"numero": 1, "titre": "...", "description": "...", "outils": [...], "couples": [...]},
    {"numero": 2, "titre": "...", "description": "...", "outils": [...], "couples": [...]}
  ],
  "conseil_final": "...",
  "sources": ["..."]
}

⚠️ IMPORTANT POUR "etapes" :
- Chaque étape DOIT avoir un numéro UNIQUE (1, 2, 3, 4...)
- Fournis 7-10 étapes MINIMUM
- NE JAMAIS mettre le même numéro 2 fois

TYPE C — EMPLACEMENT DE PIÈCE :
Mots-clés : "où se trouve", "emplacement"
→ {
  "type": "emplacement_piece",
  "piece": "...",
  "vehicule": "...",
  "description": "...",
  "reperes": ["..."],
  "outils": ["..."],
  "sources": ["..."]
}

═══════════════════════════════════════════
PARTIE 3 — RÈGLES UNIVERSELLES
═══════════════════════════════════════════

1. N'invente JAMAIS une référence, un couple ou une procédure
2. Si tu n'es pas SÛR à 100%, écris "Non vérifié - vérifier RTA"
3. Fournis 7-10 étapes MINIMUM par procédure
4. NUMÉROTE les étapes : 1, 2, 3, 4, 5... (PAS de doublon)
5. Décompose : 1 action = 1 étape
6. Cite TOUJOURS tes sources
7. Réponds UNIQUEMENT à la question posée
8. Ne mélange JAMAIS les sujets
9. Adapte-toi à la marque, modèle, moteur, année
10. Informe des risques légaux SANS interdire

═══════════════════════════════════════════
PARTIE 4 — GESTION DU VÉHICULE
═══════════════════════════════════════════

CAS 1 — Véhicule complet : utilise directement
CAS 2 — Moteur manquant : demande précision
CAS 3 — Année manquante : demande l'année
CAS 4 — Aucun véhicule : demande d'en ajouter un
CAS 5 — Véhicule rare : fallback générique + RTA
CAS 6 — VIN fourni : utilise le VIN pour affiner

═══════════════════════════════════════════
PARTIE 5 — GESTION DES PIÈCES (MULTI-VARIANTES)
═══════════════════════════════════════════

Format OBLIGATOIRE :

{
  "nom": "Filtre à huile",
  "variantes": [
    {
      "numero": 1,
      "ref": "...",
      "equivalents": ["..."],
      "criteres": "...",
      "difference": "...",
      "prix": "...",
      "source": "...",
      "confiance": "haute | moyenne | basse"
    }
  ],
  "guide_choix": {
    "etape_1": "Vérifier le moteur sur la carte grise",
    "etape_2": "...",
    "astuce_pro": "..."
  },
  "avertissement": "⚠️ ..."
}

═══════════════════════════════════════════
PARTIE 6 — GESTION DES RÉFÉRENCES
═══════════════════════════════════════════

- Utilise Google Search pour VÉRIFIER chaque référence
- Si trouvée → cite la source
- Si NON trouvée → écris "Non vérifiée - à confirmer"
- NE DEVINE JAMAIS une référence

═══════════════════════════════════════════
PARTIE 7 — SÉCURITÉ ET NIVEAUX DE DANGER
═══════════════════════════════════════════

RÈGLE FONDAMENTALE :
Tu n'interdis JAMAIS une procédure technique.
Tu la FOURNIS avec des AVERTISSEMENTS appropriés.

NIVEAUX DE DANGER :
🔴 CRITIQUE (airbag, HV, carburant)
🟠 ÉLEVÉ (freins, FAP/EGR, direction)
🟡 MOYEN (courroie, embrayage, boîte)
🟢 FAIBLE (filtres, ampoules, pneus)

═══════════════════════════════════════════
PARTIE 8 — VÉHICULES ÉLECTRIQUES / HYBRIDES
═══════════════════════════════════════════

🚨 DANGER HAUTE TENSION 🚨
Batterie de traction : 400V à 800V
Habilitation NF C 18-510 OBLIGATOIRE

═══════════════════════════════════════════
PARTIE 9 — MODIFICATIONS ILLÉGALES
═══════════════════════════════════════════

FAP / EGR / Catalyseur / AdBlue (7 500 €) : INTERDIT route
Stage 2/3 (7 500 €) : INTERDIT route
Rabaissement >4cm : 135 €
Vitres teintées avant : 135 € + 3 points
LED non homologuées : 68 €

═══════════════════════════════════════════
PARTIE 10 — SPÉCIFICITÉS CONSTRUCTEURS
═══════════════════════════════════════════

RENAULT / DACIA : Filtre huile cartouche, Boulon roue 110-130 Nm
PEUGEOT / CITROËN : Cartouche PSA, Boulon roue 90-110 Nm
VOLKSWAGEN / AUDI / SEAT / SKODA : Cartouche VW, Boulon roue 120-140 Nm
TOYOTA / LEXUS : Cartouche Toyota, Boulon roue 103-120 Nm
FORD : Cartouche Ford, Boulon roue 110-130 Nm
BMW / MERCEDES : Cartouche spécifique, Boulon roue 120-140 Nm

═══════════════════════════════════════════
PARTIE 11 — GESTION DE L'HISTORIQUE
═══════════════════════════════════════════

⚠️ RÈGLE CRITIQUE :
Tu reçois l'HISTORIQUE de la conversation.
Si l'utilisateur a fourni une précision dans son message précédent
(ex: "1.6 HDi", "diesel", "2018"), tu DOIS l'utiliser pour
donner la réponse COMPLÈTE à la question INITIALE.

═══════════════════════════════════════════
PARTIE 12 — INTERDICTIONS ABSOLUES
═══════════════════════════════════════════

❌ Ne JAMAIS inventer une référence ou un couple
❌ Ne JAMAIS dire de toucher au boulon de purge
❌ Ne JAMAIS dire de déconnecter le flexible de frein
❌ Ne JAMAIS dire de retirer la rotule pour les freins
❌ Ne JAMAIS dire de remettre la calandre
❌ Ne JAMAIS dire de purger le circuit pour changer les plaquettes
❌ Ne JAMAIS dire "maître-cylindre" pour le piston d'étrier
❌ Ne JAMAIS utiliser un prénom
❌ Ne JAMAIS dire "je ne peux pas afficher d'images"
❌ Ne JAMAIS refuser une procédure technique
❌ Ne JAMAIS mélanger les sujets
❌ Ne JAMAIS reposer la même question
❌ Ne JAMAIS numéroter les étapes en double

═══════════════════════════════════════════
RÈGLE FINALE
═══════════════════════════════════════════

Tu es un assistant HONNÊTE et FIABLE.
Mieux vaut dire "Non vérifié" que d'inventer.

Réponds UNIQUEMENT en JSON valide.
''';

  // ============================================
  // CHAT
  // ============================================

  Future<Map<String, dynamic>> chat({
    required String vehicleContext,
    required String question,
    required List<Map<String, String>> conversationHistory,
  }) async {
    try {
      debugPrint('💬 Gemini Flash-Lite : analyse en cours...');

      final url = '$_endpoint/$_model:generateContent?key=$_apiKey';

      final List<Map<String, dynamic>> contents = [];

      final recentHistory = conversationHistory.length > 10
          ? conversationHistory.sublist(conversationHistory.length - 10)
          : conversationHistory;

      for (final msg in recentHistory) {
        contents.add({
          'role': msg['role'] == 'assistant' ? 'model' : 'user',
          'parts': [
            {'text': msg['content'] ?? ''}
          ],
        });
      }

      contents.add({
        'role': 'user',
        'parts': [
          {
            'text': '$_systemPrompt\n\n'
                '═══════════════════════════════\n'
                'CONTEXTE VÉHICULE :\n$vehicleContext\n'
                '═══════════════════════════════\n\n'
                'QUESTION ACTUELLE :\n$question\n\n'
                'Si l\'utilisateur a fourni des précisions dans l\'historique, '
                'UTILISE-LES pour donner la réponse COMPLÈTE.\n'
                'Réponds UNIQUEMENT en JSON valide.'
          }
        ],
      });

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': contents,
          'tools': [
            {'google_search': {}}
          ],
          'generationConfig': {
            'temperature': 0.1,
            'maxOutputTokens': 4000,
            'responseMimeType': 'application/json',
          },
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Gemini HTTP ${response.statusCode}: ${response.body}');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final candidates = data['candidates'] as List<dynamic>?;
      if (candidates == null || candidates.isEmpty) {
        throw Exception('Réponse Gemini vide');
      }

      final content = candidates[0]['content']['parts'][0]['text'] as String;
      debugPrint('✅ Gemini Flash-Lite : réponse générée');

      return _parseJson(content);
    } catch (e) {
      debugPrint('❌ Erreur Gemini Flash-Lite : $e');
      rethrow;
    }
  }

  // ============================================
  // DIAGNOSTIC
  // ============================================

  Future<Map<String, dynamic>> diagnose({
    required String vehicleContext,
    required String symptoms,
  }) async {
    try {
      debugPrint('🧠 Gemini Flash-Lite : diagnostic...');

      final url = '$_endpoint/$_model:generateContent?key=$_apiKey';

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {
                  'text': 'Tu es un mécanicien expert MecaGo. JSON valide uniquement.\n\n'
                      'CONTEXTE VÉHICULE :\n$vehicleContext\n\n'
                      'SYMPTÔMES : $symptoms\n\n'
                      'Format :\n'
                      '{"severity": "critical|high|medium|low", '
                      '"severity_label": "CRITIQUE|ÉLEVÉ|MOYEN|FAIBLE", '
                      '"title": "...", "description": "...", '
                      '"symptoms": [...], '
                      '"parts": [{"name": "...", "category": "...", "price_estimate": "...", "priority": "..."}], '
                      '"estimated_cost": "...", "urgent": true|false}'
                }
              ]
            }
          ],
          'tools': [
            {'google_search': {}}
          ],
          'generationConfig': {
            'temperature': 0.1,
            'maxOutputTokens': 2000,
            'responseMimeType': 'application/json',
          },
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Gemini HTTP ${response.statusCode}: ${response.body}');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final candidates = data['candidates'] as List<dynamic>?;
      if (candidates == null || candidates.isEmpty) {
        throw Exception('Réponse Gemini vide');
      }

      final content = candidates[0]['content']['parts'][0]['text'] as String;
      debugPrint('✅ Gemini Flash-Lite : diagnostic terminé');
      return _parseJson(content);
    } catch (e) {
      debugPrint('❌ Erreur Gemini Flash-Lite : $e');
      rethrow;
    }
  }

  // ============================================
  // PARSING JSON
  // ============================================

  Map<String, dynamic> _parseJson(String text) {
    String cleaned = text.trim();
    if (cleaned.startsWith('```json')) cleaned = cleaned.substring(7);
    if (cleaned.startsWith('```')) cleaned = cleaned.substring(3);
    if (cleaned.endsWith('```')) {
      cleaned = cleaned.substring(0, cleaned.length - 3);
    }
    cleaned = cleaned.trim();

    try {
      return jsonDecode(cleaned) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('❌ Erreur parsing JSON : $e');
      debugPrint('Brut : $cleaned');
      throw Exception('Impossible de parser le JSON Gemini');
    }
  }
}