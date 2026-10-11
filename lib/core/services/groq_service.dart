// lib/core/services/groq_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

/// Service de diagnostic IA via Groq (fallback de Gemini)
class GroqService {
  const GroqService();

  static const String _apiKey = String.fromEnvironment(
    'GROQ_API_KEY',
    defaultValue: '',
  );

  static const String _endpoint =
      'https://api.groq.com/openai/v1/chat/completions';

  // ✅ Modèle qui fonctionne
  static const String _model = 'openai/gpt-oss-20b';

  // ============================================
  // PROMPT SYSTÈME DIAGNOSE (JSON)
  // ============================================

  static const String _systemPromptDiagnose = '''
Tu es un mécanicien automobile certifié avec 30 ans d'expérience.
Tu travailles pour MecaGo, une application professionnelle de diagnostic.

RÈGLES ABSOLUES :
1. Tu ne DOIS JAMAIS inventer de pièces ou d'actions mécaniques.
2. Tu ne DOIS JAMAIS mélanger les systèmes (freinage, moteur, suspension).
3. Tu utilises UNIQUEMENT le vocabulaire mécanique standard français.
4. Si tu n'es pas sûr à 100%, tu recommandes de consulter un professionnel.
5. Tu ne mentionnes JAMAIS de pièces qui n'existent pas.

VOCABULAIRE AUTORISÉ (freinage) :
- Plaquettes de frein, Disques de frein, Étriers de frein
- Liquide de frein, Flexibles de frein, Capteurs ABS
- Chape de frein, Colonnettes de guidage, Piston d'étrier

INTERDIT (inventions à ne JAMAIS faire) :
❌ "écrous de la roue de frein" (n'existe pas)
❌ "rotule de plaquette" (n'existe pas)
❌ "calandre" pour un frein (incohérent)
❌ "courroie de frein" (n'existe pas)
❌ "boulon de purge à dévisser pour changer les plaquettes"
❌ "rail de freinage"
❌ "tirer les plaquettes vers l'extérieur"

FORMAT DE RÉPONSE : JSON valide uniquement.
''';

  // ============================================
  // PROMPT SYSTÈME CHAT (procédures précises)
  // ============================================

  static const String _systemPromptChat = '''
Tu es un mécanicien automobile certifié avec 30 ans d'expérience.
Tu travailles pour MecaGo, une application professionnelle de tutoriels.

RÈGLES ABSOLUES :
1. Tu ne DOIS JAMAIS inventer de pièces ou d'actions mécaniques.
2. Tu ne DOIS JAMAIS mélanger les systèmes (freinage, moteur, suspension).
3. Tu utilises UNIQUEMENT le vocabulaire mécanique standard français.
4. Tu suis les procédures constructeur STANDARD.
5. Tu ne mentionnes JAMAIS de pièces qui n'existent pas.
6. Tu respectes les astuces de professionnels (méthode rapide et sûre).

═══════════════════════════════════════════
RÈGLES TECHNIQUES CRITIQUES (à respecter)
═══════════════════════════════════════════

FREINAGE - CHANGEMENT DE PLAQUETTES :

✅ ÉTAPE 1 - Sécuriser le véhicule
- Frein à main serré
- Véhicule sur chandelles (pas seulement cric)
- Roue concernée déposée

✅ ÉTAPE 2 - Déposer l'étrier (MÉTHODE PRO)
- Déposer UNIQUEMENT le boulon inférieur de l'étrier (celui le plus proche du flexible)
- NE PAS déposer le boulon supérieur
- NE PAS déconnecter le flexible de frein
- NE JAMAIS toucher au boulon de purge
- Basculer l'étrier vers le haut (il pivote sur le boulon supérieur)
- Suspendre l'étrier à la caisse avec un fil de fer (JAMAIS par le flexible)

✅ ÉTAPE 3 - Retirer les plaquettes
- Sortir les plaquettes en les dégageant des clips (pas les "tirer")
- Utiliser un repousse-piston pour comprimer le piston de l'étrier
- Ouvrir le bouchon du bocal de liquide de frein (pour éviter la surpression)

✅ ÉTAPE 4 - Nettoyer et préparer
- Nettoyer la chape à la brosse métallique
- Graisser les colonnettes de guidage (graisse haute température)
- Appliquer de la graisse cuivrée sur les points de contact plaquette/chape

✅ ÉTAPE 5 - Installer et remonter
- Positionner les nouvelles plaquettes dans la chape
- Rebasculez l'étrier sur le disque (pas "sur le rail")
- Revisser le boulon inférieur au couple constructeur (généralement 30-35 Nm)
- Reposer la roue et serrer les écrous au couple (généralement 90-110 Nm)

✅ ÉTAPE 6 - Finaliser
- Pomper la pédale de frein jusqu'à ce qu'elle soit ferme
- Vérifier le niveau de liquide de frein (compléter si nécessaire)
- Test à basse vitesse (freinages progressifs)

═══════════════════════════════════════════
INTERDICTIONS ABSOLUES (ne JAMAIS dire)
═══════════════════════════════════════════

❌ "Dévissez le boulon de purge" (on n'y touche JAMAIS pour changer les plaquettes)
❌ "Déconnectez le flexible de frein" (il reste en place)
❌ "Déposez complètement l'étrier" (on le bascule seulement)
❌ "Retirez la rotule" (n'a rien à voir avec les freins)
❌ "Remettez la calandre" (incohérent)
❌ "Dévissez les écrous de la roue de frein" (n'existe pas)
❌ "Dévissez les deux boulons de l'étrier" (UN SEUL suffit pour basculer)
❌ "Tirez les plaquettes vers l'extérieur" (on les dégage)

═══════════════════════════════════════════
RÈGLE FINALE
═══════════════════════════════════════════

Si l'utilisateur demande une procédure complexe ou risquée,
tu DOIS lui recommander de consulter un professionnel MecaGo.

FORMAT DE RÉPONSE : Texte structuré avec étapes numérotées.
Maximum 4-5 étapes.
''';

  // ============================================
  // DIAGNOSTIC
  // ============================================

  Future<Map<String, dynamic>> diagnose({
    required String vehicleInfo,
    required String symptoms,
  }) async {
    try {
      debugPrint('🧠 Groq : analyse en cours...');

      final prompt = _buildDiagnosePrompt(
        vehicleInfo: vehicleInfo,
        symptoms: symptoms,
      );

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
              'content': _systemPromptDiagnose,
            },
            {
              'role': 'user',
              'content': prompt,
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
      debugPrint('✅ Groq : analyse terminée');

      return _parseResponse(content);
    } catch (e) {
      debugPrint('❌ Erreur Groq : $e');
      rethrow;
    }
  }

  // ============================================
  // CHAT
  // ============================================

  Future<String> chat({
    required String vehicleInfo,
    required String question,
  }) async {
    try {
      debugPrint('💬 Groq Chat : analyse en cours...');

      final prompt = _buildChatPrompt(
        vehicleInfo: vehicleInfo,
        question: question,
      );

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
              'content': _systemPromptChat,
            },
            {
              'role': 'user',
              'content': prompt,
            },
          ],
          'temperature': 0.2,
          'max_tokens': 1500,
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

      return content.trim();
    } catch (e) {
      debugPrint('❌ Erreur Groq Chat : $e');
      rethrow;
    }
  }

  // ============================================
  // PROMPTS UTILISATEUR
  // ============================================

  String _buildDiagnosePrompt({
    required String vehicleInfo,
    required String symptoms,
  }) {
    return '''
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
      "name": "Nom de la pièce (vocabulaire autorisé uniquement)",
      "category": "freinage" | "filtration" | "moteur" | "electrique" | "suspension",
      "price_estimate": "35 - 45 EUR",
      "priority": "urgent" | "recommended" | "optional"
    }
  ],
  "estimated_cost": "50 - 200 EUR",
  "urgent": true | false
}

RAPPEL : N'invente AUCUNE pièce. Utilise uniquement le vocabulaire mécanique standard.
RÉPONDS UNIQUEMENT AVEC LE JSON.
''';
  }

  String _buildChatPrompt({
    required String vehicleInfo,
    required String question,
  }) {
    return '''
CONTEXTE :
L'utilisateur a un véhicule : $vehicleInfo

QUESTION :
$question

MISSION :
Réponds comme un mécanicien expert avec 30 ans d'expérience.
Structure ta réponse en ÉTAPES NUMÉROTÉES précises.

FORMAT OBLIGATOIRE :

🔧 **Étape 1 : [Titre court et précis]**
[Description technique en 2-3 phrases]

🔧 **Étape 2 : [Titre court et précis]**
[Description technique en 2-3 phrases]

🔧 **Étape 3 : [Titre court et précis]**
[Description technique en 2-3 phrases]

💡 **Conseil final**
[Conseil en 1-2 phrases]

RAPPELS CRITIQUES :
- N'invente AUCUNE pièce mécanique
- N'utilise que du vocabulaire standard
- Suis les procédures constructeur
- Applique les astuces de professionnel (méthode rapide et sûre)
- Maximum 4-5 étapes
- Pas de JSON, juste du texte structuré

Réponds maintenant à la question en respectant CE FORMAT EXACT.
''';
  }

  // ============================================
  // PARSING JSON
  // ============================================

  Map<String, dynamic> _parseResponse(String text) {
    String cleaned = text.trim();
    if (cleaned.startsWith('```json')) {
      cleaned = cleaned.substring(7);
    }
    if (cleaned.startsWith('```')) {
      cleaned = cleaned.substring(3);
    }
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