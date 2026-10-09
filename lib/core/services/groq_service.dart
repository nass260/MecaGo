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

  static const String _model = 'openai/gpt-oss-20b';

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
              'content':
                  'Tu es un expert mécanicien automobile avec 30 ans d\'expérience. '
                      'Tu travailles pour MecaGo. Tu réponds UNIQUEMENT en JSON valide.',
            },
            {
              'role': 'user',
              'content': prompt,
            },
          ],
          'temperature': 0.3,
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
              'content':
                  'Tu es un expert mécanicien automobile qui travaille pour MecaGo. '
                      'Tu réponds de manière claire, précise et professionnelle. '
                      'Tu STRUCTURES tes réponses en ÉTAPES numérotées. '
                      'Tu utilises des emojis pour rendre la réponse agréable.',
            },
            {
              'role': 'user',
              'content': prompt,
            },
          ],
          'temperature': 0.7,
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
  // PROMPTS
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
      "name": "Nom de la pièce",
      "category": "freinage" | "filtration" | "moteur" | "electrique" | "suspension",
      "price_estimate": "35 - 45 EUR",
      "priority": "urgent" | "recommended" | "optional"
    }
  ],
  "estimated_cost": "50 - 200 EUR",
  "urgent": true | false
}

CONTRAINTES :
- severity : "critical" si danger immédiat, "high" si à réparer vite
- title : 3-6 mots maximum
- description : cause probable + importance
- symptoms : 3-5 symptômes détectés
- parts : 1-4 pièces nécessaires
- price_estimate : fourchette réaliste en EUR
- estimated_cost : coût total estimé
- urgent : true si intervention < 1000 km recommandée

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
Réponds comme un mécanicien expert. Structure ta réponse en ÉTAPES.

RÈGLES :
- Français, clair, professionnel
- Structure en étapes numérotées (Étape 1, Étape 2, Étape 3...)
- Chaque étape a un TITRE + une DESCRIPTION
- Emojis pour structurer (🔧 📋 ⚠️ 💡)
- Maximum 4 étapes
- Pas de JSON, juste du texte

FORMAT OBLIGATOIRE (RESPECTE EXACTEMENT CE FORMAT) :

🔧 **Étape 1 : [Titre court]**
[Description en 2-3 phrases]

🔧 **Étape 2 : [Titre court]**
[Description en 2-3 phrases]

🔧 **Étape 3 : [Titre court]**
[Description en 2-3 phrases]

💡 **Conseil final**
[Conseil en 1-2 phrases]

Réponds maintenant à la question en respectant CE FORMAT EXACT.
''';
  }

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