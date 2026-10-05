// lib/core/services/gemini_service.dart
import 'dart:convert';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/material.dart';

/// Service de diagnostic IA via Gemini (Firebase AI Logic)
class GeminiService {
  const GeminiService();

  /// Modèle Gemini utilisé (Flash = rapide + gratuit)
  static const String _modelName = 'gemini-2.5-flash';

  /// Génère un diagnostic à partir d'une description de symptômes
  Future<Map<String, dynamic>> diagnose({
    required String vehicleInfo,
    required String symptoms,
  }) async {
    try {
      debugPrint('🧠 Gemini : analyse en cours...');

      // ✅ Initialisation SIMPLE : le SDK gère App Check tout seul
      final model = FirebaseAI.googleAI().generativeModel(
        model: _modelName,
      );

      // Construire le prompt
      final prompt = _buildPrompt(
        vehicleInfo: vehicleInfo,
        symptoms: symptoms,
      );

      // Envoyer à Gemini
      final response = await model.generateContent([
        Content.text(prompt),
      ]);

      final text = response.text;
      if (text == null || text.isEmpty) {
        throw Exception('Réponse Gemini vide');
      }

      debugPrint('✅ Gemini : analyse terminée');

      // Parser la réponse JSON
      return _parseResponse(text);
    } catch (e) {
      debugPrint('❌ Erreur Gemini : $e');
      rethrow;
    }
  }

  /// Construit le prompt envoyé à Gemini
  String _buildPrompt({
    required String vehicleInfo,
    required String symptoms,
  }) {
    return '''
Tu es un expert mécanicien automobile avec 30 ans d'expérience.
Tu travailles pour MecaGo, une application d'assistance automobile.

VÉHICULE :
$vehicleInfo

SYMPTÔMES DÉCRITS PAR L'UTILISATEUR :
$symptoms

MISSION :
Analyse ces symptômes et fournis un diagnostic professionnel.

RÉPONDS UNIQUEMENT AVEC UN JSON VALIDE (aucun texte avant/après) :

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

CONTRAINTES :
- severity : "critical" si danger immédiat, "high" si à réparer vite, "medium" si à surveiller, "low" si pas urgent
- title : 3-6 mots maximum
- description : explique la cause probable et pourquoi c'est important
- symptoms : 3-5 symptômes détectés (reformulés professionnellement)
- parts : 1-4 pièces nécessaires (les plus probables)
- price_estimate : fourchette réaliste en EUR pour le marché français
- estimated_cost : coût total estimé (main d'œuvre incluse)
- urgent : true si intervention < 1000 km recommandée

RÉPONDS UNIQUEMENT AVEC LE JSON. Aucun texte avant ou après.
''';
  }

  /// Parse la réponse JSON de Gemini
  Map<String, dynamic> _parseResponse(String text) {
    // Nettoyer la réponse
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

    // Parser le JSON
    try {
      return jsonDecode(cleaned) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('❌ Erreur parsing JSON : $e');
      debugPrint('Réponse brute : $cleaned');
      throw Exception('Impossible de parser la réponse Gemini');
    }
  }
}