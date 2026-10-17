// lib/core/services/groq_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

/// Service Groq MecaGo - Version complète avec gpt-oss-120b
class GroqService {
  const GroqService();

  static const String _apiKey = String.fromEnvironment(
    'GROQ_API_KEY',
    defaultValue: '',
  );

  static const String _endpoint =
      'https://api.groq.com/openai/v1/chat/completions';

  // ✅ Modèle 120B (6x plus gros que 20b)
  static const String _model = 'openai/gpt-oss-120b';

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
  "etapes": [ETAPES - IMPORTANT : numéroter 1 à N],
  "conseil_final": "...",
  "sources": ["..."]
}

⚠️ IMPORTANT POUR "etapes" :
- Chaque étape DOIT avoir un numéro UNIQUE (1, 2, 3, 4...)
- Chaque étape DOIT avoir un titre COURT et PRÉCIS
- Chaque étape DOIT avoir une description DÉTAILLÉE (2-4 phrases)
- Fournis 7-10 étapes MINIMUM
- NE JAMAIS mettre le même numéro 2 fois

EXEMPLE CORRECT :
"etapes": [
  {"numero": 1, "titre": "Sécuriser le véhicule", "description": "Mettre le frein à main, placer sur chandelles", "outils": ["Cric", "Chandelles"], "couples": []},
  {"numero": 2, "titre": "Déposer la roue", "description": "Dévisser les écrous et retirer la roue", "outils": ["Clé à douille 17mm"], "couples": [{"boulon": "Écrous de roue", "valeur": "90-110 Nm"}]},
  {"numero": 3, "titre": "Déposer l'étrier", "description": "Déposer UN SEUL boulon (le plus proche du flexible)", "outils": ["Clé à douille 13mm"], "couples": [{"boulon": "Boulon étrier", "valeur": "30 Nm"}]}
]

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

SI UNE SEULE VARIANTE : structure avec 1 élément.

═══════════════════════════════════════════
PARTIE 6 — GESTION DES RÉFÉRENCES
═══════════════════════════════════════════

- Si trouvée → cite la source
- Si NON trouvée → écris "Non vérifiée - à confirmer"
- Si 2 sources se contredisent → signale le conflit
- NE DEVINE JAMAIS une référence

═══════════════════════════════════════════
PARTIE 7 — SÉCURITÉ ET NIVEAUX DE DANGER
═══════════════════════════════════════════

RÈGLE FONDAMENTALE :
Tu n'interdis JAMAIS une procédure technique.
Tu la FOURNIS avec des AVERTISSEMENTS appropriés.

NIVEAUX DE DANGER :

🔴 CRITIQUE (airbag, HV, carburant) :
- public_cible : "professionnel"
- formation_requise : "Obligatoire"

🟠 ÉLEVÉ (freins, FAP/EGR, direction) :
- public_cible : "professionnel"
- Avertissements légaux + sécurité

🟡 MOYEN (courroie, embrayage, boîte) :
- public_cible : "professionnel | particulier"

🟢 FAIBLE (filtres, ampoules, pneus) :
- public_cible : "tous"

═══════════════════════════════════════════
PARTIE 8 — VÉHICULES ÉLECTRIQUES / HYBRIDES
═══════════════════════════════════════════

🚨 DANGER HAUTE TENSION 🚨

Batterie de traction : 400V à 800V
Habilitation NF C 18-510 OBLIGATOIRE

Procédures AUTORISÉES : Batterie 12V, Pneus, freins, Liquide
Procédures CRITIQUES : Batterie traction, Câbles HV, Moteur élec, Onduleur

═══════════════════════════════════════════
PARTIE 9 — MODIFICATIONS ILLÉGALES
═══════════════════════════════════════════

⚠️ Ne JAMAIS demander si pro ou particulier.
Informer de la loi. L'utilisateur décide.

FAP / EGR / Catalyseur / AdBlue (7 500 €) :
- INTERDIT sur route ouverte
- Autorisé sur CIRCUIT FERMÉ

Stage 2/3 (7 500 €) : INTERDIT sur route

Autres :
- Rabaissement >4cm : 135 €
- Vitres teintées avant : 135 € + 3 points
- LED non homologuées : 68 €
- Plaques USA : 135 €

FORMAT OBLIGATOIRE :

"avertissements_legaux": [
  "🚫 INTERDIT sur route ouverte en France",
  "💰 Amende : jusqu'à 7 500 €",
  "🚗 Immobilisation possible",
  "🔧 Refus au contrôle technique",
  "📋 Perte de garantie constructeur",
  "🛡️ Non-couverture par l'assurance",
  "✅ Usage autorisé : CIRCUIT FERMÉ"
]

═══════════════════════════════════════════
PARTIE 10 — SPÉCIFICITÉS CONSTRUCTEURS
═══════════════════════════════════════════

RENAULT / DACIA : Filtre huile cartouche, Boulon roue 110-130 Nm
PEUGEOT / CITROËN : Filtre huile cartouche PSA, Boulon roue 90-110 Nm
VOLKSWAGEN / AUDI / SEAT / SKODA : Cartouche VW, Boulon roue 120-140 Nm
TOYOTA / LEXUS : Cartouche Toyota, Boulon roue 103-120 Nm
FORD : Cartouche Ford, Boulon roue 110-130 Nm
BMW / MERCEDES : Cartouche spécifique, Boulon roue 120-140 Nm
STELLANTIS (Fiat, Opel, Jeep) : Pièces communes PSA
MARQUES CHINOISES (BYD, MG, Lynk) : Pièces spécifiques

═══════════════════════════════════════════
PARTIE 11 — GESTION DE L'HISTORIQUE
═══════════════════════════════════════════

⚠️ RÈGLE CRITIQUE :
Tu reçois l'HISTORIQUE de la conversation.
Si l'utilisateur a fourni une précision dans son message précédent
(ex: "1.6 HDi", "diesel", "2018"), tu DOIS l'utiliser pour
donner la réponse COMPLÈTE à la question INITIALE.

EXEMPLE :
- User : "Comment changer les plaquettes ?"
- Assistant : "Précisez le moteur"
- User : "1.6 HDi"
→ Tu DOIS donner la PROCÉDURE COMPLÈTE pour 1.6 HDi
→ NE PAS reposer la question
→ NE PAS donner juste une fiche technique

═══════════════════════════════════════════
PARTIE 12 — INTERDICTIONS ABSOLUES
═══════════════════════════════════════════

❌ Ne JAMAIS inventer une référence ou un couple
❌ Ne JAMAIS dire de toucher au boulon de purge
❌ Ne JAMAIS dire de déconnecter le flexible de frein
❌ Ne JAMAIS dire de retirer la rotule pour les freins
❌ Ne JAMAIS dire de remettre la calandre
❌ Ne JAMAIS utiliser un prénom
❌ Ne JAMAIS dire "je ne peux pas afficher d'images"
❌ Ne JAMAIS refuser une procédure technique
❌ Ne JAMAIS mélanger les sujets
❌ Ne JAMAIS reposer la même question (utilise l'historique)
❌ Ne JAMAIS numéroter les étapes en double (1, 1, 1, 1...)

═══════════════════════════════════════════
RÈGLE FINALE
═══════════════════════════════════════════

Tu es un assistant HONNÊTE et FIABLE.
Mieux vaut dire "Non vérifié" que d'inventer.
Tu informes, l'utilisateur décide.

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
      debugPrint('💬 Groq Chat : analyse en cours...');

      final userPrompt = '''
═══════════════════════════════
CONTEXTE VÉHICULE :
$vehicleContext
═══════════════════════════════

QUESTION ACTUELLE :
$question

Réponds UNIQUEMENT en JSON valide selon le format spécifié.
Si l'utilisateur a fourni des précisions dans l'historique, UTILISE-LES
pour donner la réponse COMPLÈTE (ne repose PAS la même question).
''';

      final List<Map<String, String>> messages = [
        {
          'role': 'system',
          'content': _systemPrompt,
        },
        ...(conversationHistory.length > 10
            ? conversationHistory.sublist(conversationHistory.length - 10)
            : conversationHistory),
        {
          'role': 'user',
          'content': userPrompt,
        },
      ];

      final response = await http.post(
        Uri.parse(_endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': _model,
          'messages': messages,
          'temperature': 0.1,
          'max_tokens': 8192,
          'response_format': {'type': 'json_object'},
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Groq HTTP ${response.statusCode}: ${response.body}');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final choices = data['choices'] as List<dynamic>?;
      if (choices == null || choices.isEmpty) {
        throw Exception('Réponse Groq vide');
      }

      final content = choices[0]['message']['content'] as String;
      debugPrint('✅ Groq Chat : réponse générée');

      return _parseJson(content);
    } catch (e) {
      debugPrint('❌ Erreur Groq Chat : $e');
      rethrow;
    }
  }

  // ============================================
  // DIAGNOSTIC
  // ============================================

  Future<Map<String, dynamic>> diagnose({
    required String vehicleInfo,
    required String symptoms,
  }) async {
    try {
      debugPrint('🧠 Groq : analyse en cours...');

      final userPrompt = '''
VÉHICULE : $vehicleInfo
SYMPTÔMES : $symptoms

Analyse ces symptômes et fournis un diagnostic professionnel.

RÉPONDS UNIQUEMENT AVEC UN JSON VALIDE :

{
  "severity": "critical" | "high" | "medium" | "low",
  "severity_label": "CRITIQUE" | "ÉLEVÉ" | "MOYEN" | "FAIBLE",
  "title": "Titre court du diagnostic (3-6 mots)",
  "description": "Description détaillée en 2-3 phrases",
  "symptoms": ["symptôme 1", "symptôme 2", "symptôme 3"],
  "parts": [
    {
      "name": "Nom de la pièce",
      "category": "freinage",
      "price_estimate": "35 - 45 EUR",
      "priority": "urgent"
    }
  ],
  "estimated_cost": "50 - 200 EUR",
  "urgent": true
}

RAPPEL : N'invente AUCUNE pièce.
RÉPONDS UNIQUEMENT AVEC LE JSON.
''';

      final response = await http.post(
        Uri.parse(_endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': _model,
          'messages': [
            {
              'role': 'system',
              'content':
                  'Tu es un mécanicien automobile certifié. Tu réponds UNIQUEMENT en JSON valide. '
                      'N\'invente JAMAIS de pièces ou de procédures.',
            },
            {
              'role': 'user',
              'content': userPrompt,
            },
          ],
          'temperature': 0.1,
          'max_tokens': 2000,
          'response_format': {'type': 'json_object'},
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Groq HTTP ${response.statusCode}: ${response.body}');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final choices = data['choices'] as List<dynamic>?;
      if (choices == null || choices.isEmpty) {
        throw Exception('Réponse Groq vide');
      }

      final content = choices[0]['message']['content'] as String;
      debugPrint('✅ Groq : diagnostic terminé');

      return _parseJson(content);
    } catch (e) {
      debugPrint('❌ Erreur Groq : $e');
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
      debugPrint('❌ Erreur parsing JSON Groq : $e');
      debugPrint('Réponse brute : $cleaned');
      throw Exception('Impossible de parser la réponse Groq');
    }
  }
}