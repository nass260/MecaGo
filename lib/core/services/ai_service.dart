// lib/core/services/ai_service.dart
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'gemini_service.dart';
import 'gemini_flash_service.dart';
import 'groq_service.dart';

/// Service IA unifié MecaGo
///
/// Cascade intelligente :
/// 1. Gemini Flash-Lite (gratuit, prioritaire) → JSON structuré
/// 2. Groq (fallback gratuit) → texte simple
/// 3. Gemini Firebase (Android uniquement)
class AiService {
  const AiService();

  final GeminiFlashService _geminiFlash = const GeminiFlashService();
  final GroqService _groq = const GroqService();
  final GeminiService _gemini = const GeminiService();

  // ============================================
  // CONSTRUCTION DU CONTEXTE VÉHICULE COMPLET
  // ============================================

  /// Construit un contexte véhicule COMPLET pour Gemini
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

    if (engine != null && engine.trim().isNotEmpty) {
      buffer.writeln('Moteur : ${engine.trim()}');
    } else {
      buffer.writeln('Moteur : Non spécifié (demander à l\'utilisateur)');
    }

    if (plate != null && plate.trim().isNotEmpty) {
      buffer.writeln('Plaque : ${plate.trim().toUpperCase()}');
    }

    if (vin != null && vin.trim().isNotEmpty) {
      buffer.writeln('VIN : ${vin.trim().toUpperCase()}');
    }

    return buffer.toString();
  }

  // ============================================
  // DIAGNOSTIC
  // ============================================

  Future<AiDiagnosisResponse> diagnose({
    required String vehicleContext,
    required String symptoms,
  }) async {
    // ✅ PRIORITÉ 1 : Gemini Flash-Lite
    try {
      debugPrint('🧠 AiService : tentative Gemini Flash-Lite...');
      final json = await _geminiFlash.diagnose(
        vehicleContext: vehicleContext,
        symptoms: symptoms,
      );
      debugPrint('✅ AiService : Gemini Flash-Lite a répondu');
      return AiDiagnosisResponse(
        json: json,
        provider: AiProvider.geminiFlash,
      );
    } catch (e) {
      debugPrint('⚠️ AiService : Gemini Flash-Lite a échoué → $e');
    }

    // ✅ PRIORITÉ 2 : Groq
    try {
      debugPrint('🧠 AiService : tentative Groq...');
      final json = await _groq.diagnose(
        vehicleInfo: vehicleContext,
        symptoms: symptoms,
      );
      debugPrint('✅ AiService : Groq a répondu');
      return AiDiagnosisResponse(
        json: json,
        provider: AiProvider.groq,
      );
    } catch (e) {
      debugPrint('⚠️ AiService : Groq a échoué → $e');
    }

    // ✅ PRIORITÉ 3 : Gemini Firebase (mobile uniquement)
    if (!kIsWeb) {
      try {
        debugPrint('🧠 AiService : tentative Gemini Firebase...');
        final json = await _gemini.diagnose(
          vehicleInfo: vehicleContext,
          symptoms: symptoms,
        );
        debugPrint('✅ AiService : Gemini Firebase a répondu');
        return AiDiagnosisResponse(
          json: json,
          provider: AiProvider.gemini,
        );
      } catch (e) {
        debugPrint('⚠️ AiService : Gemini Firebase a échoué → $e');
      }
    }

    debugPrint('❌ AiService : tous les fournisseurs ont échoué');
    throw Exception('Tous les fournisseurs IA ont échoué');
  }

  // ============================================
  // CHAT (retourne JSON : procedure | reponse_simple | emplacement_piece)
  // ============================================

  Future<AiChatResponse> chat({
    required String vehicleContext,
    required String question,
  }) async {
    // ✅ PRIORITÉ 1 : Gemini Flash-Lite (JSON structuré complet)
    try {
      debugPrint('💬 AiService : tentative Gemini Flash-Lite chat...');
      final json = await _geminiFlash.chat(
        vehicleContext: vehicleContext,
        question: question,
      );
      debugPrint('✅ AiService : Gemini Flash-Lite chat a répondu');
      return AiChatResponse(
        json: json,
        provider: AiProvider.geminiFlash,
      );
    } catch (e) {
      debugPrint('⚠️ AiService : Gemini Flash-Lite chat a échoué → $e');
    }

    // ✅ PRIORITÉ 2 : Groq (fallback texte → transformé en JSON procédure)
    try {
      debugPrint('💬 AiService : tentative Groq chat...');
      final response = await _groq.chat(
        vehicleInfo: vehicleContext,
        question: question,
      );
      debugPrint('✅ AiService : Groq chat a répondu');

      return AiChatResponse(
        json: {
          'type': 'procedure',
          'titre': 'Procédure MecaGo',
          'vehicule': vehicleContext.split('\n').first,
          'duree_estimee': 'Non communiquée',
          'difficulte': 'intermediaire',
          'niveau_danger': 'moyen',
          'public_cible': 'tous',
          'formation_requise': 'Aucune',
          'outils': [],
          'pieces': [],
          'avertissements_securite': [],
          'avertissements_legaux': [],
          'etapes': _parseGroqTextToEtapes(response),
          'conseil_final': '',
          'sources': ['Fallback Groq'],
        },
        provider: AiProvider.groq,
      );
    } catch (e) {
      debugPrint('⚠️ AiService : Groq chat a échoué → $e');
    }

    // ✅ PRIORITÉ 3 : Gemini Firebase (mobile uniquement)
    if (!kIsWeb) {
      try {
        debugPrint('💬 AiService : tentative Gemini Firebase chat...');
        final response = await _gemini.chat(
          vehicleInfo: vehicleContext,
          question: question,
        );
        debugPrint('✅ AiService : Gemini Firebase chat a répondu');

        return AiChatResponse(
          json: {
            'type': 'procedure',
            'titre': 'Procédure MecaGo',
            'vehicule': vehicleContext.split('\n').first,
            'duree_estimee': 'Non communiquée',
            'difficulte': 'intermediaire',
            'niveau_danger': 'moyen',
            'public_cible': 'tous',
            'formation_requise': 'Aucune',
            'outils': [],
            'pieces': [],
            'avertissements_securite': [],
            'avertissements_legaux': [],
            'etapes': _parseGroqTextToEtapes(response),
            'conseil_final': '',
            'sources': ['Fallback Gemini Firebase'],
          },
          provider: AiProvider.gemini,
        );
      } catch (e) {
        debugPrint('⚠️ AiService : Gemini Firebase chat a échoué → $e');
      }
    }

    debugPrint('❌ AiService : tous les fournisseurs chat ont échoué');
    throw Exception('Tous les fournisseurs IA ont échoué');
  }

  // ============================================
  // FALLBACK : texte Groq → étapes JSON
  // ============================================

  List<Map<String, dynamic>> _parseGroqTextToEtapes(String text) {
    final etapes = <Map<String, dynamic>>[];
    final lines = text.split('\n');
    String? currentTitre;
    final currentDesc = <String>[];
    int numero = 1;

    for (final line in lines) {
      final match = RegExp(
              r'(?:🔧|📋|⚠️|🔩|🛠️|🔨|⚙️)\s*\*?\*?Étape\s*(\d+)\s*:\s*(.+?)\*?\*?$')
          .firstMatch(line);
      if (match != null) {
        if (currentTitre != null) {
          etapes.add({
            'numero': numero++,
            'titre': currentTitre,
            'description': currentDesc.join(' ').trim(),
            'outils': [],
            'couples': [],
          });
        }
        currentTitre = match.group(2)?.replaceAll('*', '').trim();
        currentDesc.clear();
      } else if (currentTitre != null && line.trim().isNotEmpty) {
        if (!line.contains('Conseil final') && !line.contains('💡')) {
          currentDesc.add(line.trim().replaceAll('*', ''));
        }
      }
    }
    if (currentTitre != null) {
      etapes.add({
        'numero': numero,
        'titre': currentTitre,
        'description': currentDesc.join(' ').trim(),
        'outils': [],
        'couples': [],
      });
    }
    return etapes;
  }
}

/// Fournisseur IA utilisé
enum AiProvider { geminiFlash, gemini, groq, none }

class AiDiagnosisResponse {
  final Map<String, dynamic> json;
  final AiProvider provider;

  const AiDiagnosisResponse({required this.json, required this.provider});

  bool get isFromAI => provider != AiProvider.none;

  String get providerName {
    switch (provider) {
      case AiProvider.geminiFlash:
        return 'Gemini Flash';
      case AiProvider.gemini:
        return 'Gemini';
      case AiProvider.groq:
        return 'MecaGo IA';
      case AiProvider.none:
        return 'Local';
    }
  }
}

class AiChatResponse {
  final Map<String, dynamic> json;
  final AiProvider provider;

  const AiChatResponse({required this.json, required this.provider});

  bool get isFromAI => provider != AiProvider.none;

  String get providerName {
    switch (provider) {
      case AiProvider.geminiFlash:
        return 'Gemini Flash';
      case AiProvider.gemini:
        return 'Gemini';
      case AiProvider.groq:
        return 'MecaGo IA';
      case AiProvider.none:
        return 'Local';
    }
  }
}