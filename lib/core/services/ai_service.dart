// lib/core/services/ai_service.dart
import 'package:flutter/material.dart';
import 'gemini_service.dart';
import 'groq_service.dart';

/// Service IA unifié : Gemini en priorité, Groq en fallback
class AiService {
  const AiService();

  final GeminiService _gemini = const GeminiService();
  final GroqService _groq = const GroqService();

  // ============================================
  // DIAGNOSTIC
  // ============================================

  Future<AiDiagnosisResponse> diagnose({
    required String vehicleInfo,
    required String symptoms,
  }) async {
    // ÉTAPE 1 : Essayer Gemini
    try {
      debugPrint('🧠 AiService : tentative Gemini...');
      final json = await _gemini.diagnose(
        vehicleInfo: vehicleInfo,
        symptoms: symptoms,
      );
      debugPrint('✅ AiService : Gemini a répondu');
      return AiDiagnosisResponse(
        json: json,
        provider: AiProvider.gemini,
      );
    } catch (e) {
      debugPrint('⚠️ AiService : Gemini a échoué → $e');
    }

    // ÉTAPE 2 : Essayer Groq
    try {
      debugPrint('🧠 AiService : tentative Groq...');
      final json = await _groq.diagnose(
        vehicleInfo: vehicleInfo,
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

    // ÉTAPE 3 : Aucun fournisseur n'a fonctionné
    debugPrint('❌ AiService : tous les fournisseurs ont échoué');
    throw Exception('Tous les fournisseurs IA ont échoué');
  }

  // ============================================
  // CHAT
  // ============================================

  Future<AiChatResponse> chat({
    required String vehicleInfo,
    required String question,
  }) async {
    // ÉTAPE 1 : Essayer Gemini
    try {
      debugPrint('💬 AiService : tentative Gemini chat...');
      final response = await _gemini.chat(
        vehicleInfo: vehicleInfo,
        question: question,
      );
      debugPrint('✅ AiService : Gemini chat a répondu');
      return AiChatResponse(
        text: response,
        provider: AiProvider.gemini,
      );
    } catch (e) {
      debugPrint('⚠️ AiService : Gemini chat a échoué → $e');
    }

    // ÉTAPE 2 : Essayer Groq
    try {
      debugPrint('💬 AiService : tentative Groq chat...');
      final response = await _groq.chat(
        vehicleInfo: vehicleInfo,
        question: question,
      );
      debugPrint('✅ AiService : Groq chat a répondu');
      return AiChatResponse(
        text: response,
        provider: AiProvider.groq,
      );
    } catch (e) {
      debugPrint('⚠️ AiService : Groq chat a échoué → $e');
    }

    // ÉTAPE 3 : Aucun fournisseur n'a fonctionné
    debugPrint('❌ AiService : tous les fournisseurs chat ont échoué');
    throw Exception('Tous les fournisseurs IA ont échoué');
  }
}

/// Fournisseur IA utilisé
enum AiProvider {
  gemini,
  groq,
  none,
}

/// Réponse du service IA unifié (diagnostic)
class AiDiagnosisResponse {
  final Map<String, dynamic> json;
  final AiProvider provider;

  const AiDiagnosisResponse({
    required this.json,
    required this.provider,
  });

  bool get isFromAI => provider != AiProvider.none;

  String get providerName {
    switch (provider) {
      case AiProvider.gemini:
        return 'Gemini';
      case AiProvider.groq:
        return 'MecaGo IA';
      case AiProvider.none:
        return 'Local';
    }
  }
}

/// Réponse du service IA unifié (chat)
class AiChatResponse {
  final String text;
  final AiProvider provider;

  const AiChatResponse({
    required this.text,
    required this.provider,
  });

  bool get isFromAI => provider != AiProvider.none;
}