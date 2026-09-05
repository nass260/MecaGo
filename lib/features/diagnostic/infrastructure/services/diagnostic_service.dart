import 'package:flutter/material.dart';

class DiagnosticService {
  const DiagnosticService();

  /// Analyse un symptôme textuel ou un code d'erreur sélectionné par l'utilisateur.
  /// Renvoie un diagnostic précis assorti du tutoriel MecaGo recommandé.
  Future<DiagnosticResult> analyzeSymptom(String userSymptom) async {
    try {
      // Simulation du traitement de l'arbre de décision de l'IA locale
      await Future.delayed(const Duration(milliseconds: 1400));

      final String normalizedSymptom = userSymptom.toLowerCase();

      // 1. Diagnostic : Problème de Freinage (Sifflement / Grincement)
      if (normalizedSymptom.contains('frein') || normalizedSymptom.contains('sifflement')) {
        return const DiagnosticResult(
          probableCause: "Usure prononcée des garnitures de friction des plaquettes de frein.",
          gravity: "CRITIQUE",
          colorValue: 0xFFEF4444, // Rouge Urgence
          recommendedTutorialPath: "/tutorial-detail", // Redirige vers le guide à 8 étapes
          tutorialTitle: "Contrôle des plaquettes",
          suggestedPartCategory: "Plaquettes de frein VALEO Tech",
        );
      } 
      
      // 2. Diagnostic : Mauvaise odeur ou faible ventilation
      if (normalizedSymptom.contains('odeur') || normalizedSymptom.contains('air') || normalizedSymptom.contains('ventilation')) {
        return const DiagnosticResult(
          probableCause: "Saturation ou colmatage du filtre d'habitacle par des micro-particules.",
          gravity: "MODÉRÉE",
          colorValue: 0xFFFF6A00, // Orange MecaGo
          recommendedTutorialPath: "/tutorial-detail",
          tutorialTitle: "Filtre d'habitacle HEPA",
          suggestedPartCategory: "Filtre d'habitacle PURFLUX",
        );
      }

      // 3. Diagnostic par défaut : Cas général
      return const DiagnosticResult(
        probableCause: "Anomalie générique nécessitant une inspection visuelle minutieuse.",
        gravity: "MINEURE",
        colorValue: 0xFF10B981, // Vert optimal
        recommendedTutorialPath: "/tutorials", // Renvoie vers le catalogue général
        tutorialTitle: "Catalogue Général",
        suggestedPartCategory: "Pièces d'origine VALEO / PURFLUX",
      );
    } catch (e) {
      debugPrint("MecaGo IA Diagnostic Error - Échec de l'analyse : $e");
      return const DiagnosticResult(
        probableCause: "Erreur d'analyse du moteur de diagnostic IA.",
        gravity: "INCONNUE",
        colorValue: 0xFF64748B,
        recommendedTutorialPath: "/tutorials",
        tutorialTitle: "Catalogue",
        suggestedPartCategory: "Générique",
      );
    }
  }
}

/// Structure de données typée pour le retour du moteur d'IA
class DiagnosticResult {
  final String probableCause;
  final String gravity;
  final int colorValue;
  final String recommendedTutorialPath;
  final String tutorialTitle;
  final String suggestedPartCategory;

  const DiagnosticResult({
    required this.probableCause,
    required this.gravity,
    required this.colorValue,
    required this.recommendedTutorialPath,
    required this.tutorialTitle,
    required this.suggestedPartCategory,
  });
}
