// lib/core/services/gemini_service.dart
import 'dart:convert';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

/// Service de diagnostic IA via Gemini (Firebase AI Logic)
///
/// ⚠️ Gemini est UNIQUEMENT utilisé sur mobile.
///    Sur Web, ce service n'est jamais appelé (voir ai_service.dart).
class GeminiService {
  const GeminiService();

  static const String _modelName = 'gemini-2.5-flash';

  // ============================================
  // DIAGNOSTIC
  // ============================================

  Future<Map<String, dynamic>> diagnose({
    required String vehicleInfo,
    required String symptoms,
  }) async {
    // ✅ Sécurité : Gemini non supporté sur Web
    if (kIsWeb) {
      throw Exception('Gemini n\'est pas supporté sur Web (utiliser Groq)');
    }

    try {
      debugPrint('🧠 Gemini : analyse en cours...');

      final model = FirebaseAI.googleAI(
        appCheck: FirebaseAppCheck.instance,
      ).generativeModel(
        model: _modelName,
      );

      final prompt = _buildDiagnosePrompt(
        vehicleInfo: vehicleInfo,
        symptoms: symptoms,
      );

      final response = await model.generateContent([
        Content.text(prompt),
      ]);

      final text = response.text;
      if (text == null || text.isEmpty) {
        throw Exception('Réponse Gemini vide');
      }

      debugPrint('✅ Gemini : analyse terminée');
      return _parseResponse(text);
    } catch (e) {
      debugPrint('❌ Erreur Gemini : $e');
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
    // ✅ Sécurité : Gemini non supporté sur Web
    if (kIsWeb) {
      throw Exception('Gemini n\'est pas supporté sur Web (utiliser Groq)');
    }

    try {
      debugPrint('💬 Gemini Chat : analyse en cours...');

      final model = FirebaseAI.googleAI(
        appCheck: FirebaseAppCheck.instance,
      ).generativeModel(
        model: _modelName,
      );

      final prompt = _buildChatPrompt(
        vehicleInfo: vehicleInfo,
        question: question,
      );

      final response = await model.generateContent([
        Content.text(prompt),
      ]);

      final text = response.text;
      if (text == null || text.isEmpty) {
        throw Exception('Réponse Gemini vide');
      }

      debugPrint('✅ Gemini Chat : réponse générée');
      return text.trim();
    } catch (e) {
      debugPrint('❌ Erreur Gemini Chat : $e');
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
  "title": "Titre court du diagnostic",
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
      debugPrint('❌ Erreur parsing JSON Gemini : $e');
      throw Exception('Impossible de parser la réponse Gemini');
    }
  }
}