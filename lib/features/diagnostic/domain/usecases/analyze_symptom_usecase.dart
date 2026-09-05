import 'package:flutter/material.dart';
import '../../data/models/diagnostic_model.dart';
import '../../infrastructure/services/diagnostic_service.dart';

class AnalyzeSymptomUseCase {
  final DiagnosticService _diagnosticService;

  // Injection de dépendance du service d'infrastructure IA
  const AnalyzeSymptomUseCase({
    DiagnosticService diagnosticService = const DiagnosticService(),
  }) : _diagnosticService = diagnosticService;

  /// Exécute l'action métier d'analyse de panne et génère un rapport daté.
  Future<DiagnosticModel> execute(String symptom) async {
    try {
      // 1. Appel physique au moteur décisionnel de l'IA
      final DiagnosticResult rawResult = await _diagnosticService.analyzeSymptom(symptom);

      // 2. Capture temporelle précise pour l'archivage du rapport d'entretien
      final DateTime now = DateTime.now();
      final String formattedTimestamp = "${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

      // 3. Conversion et empaquetage dans notre modèle de données structurel
      return DiagnosticModel(
        symptomAnalyzed: symptom,
        probableCause: rawResult.probableCause,
        gravity: rawResult.gravity,
        colorValue: rawResult.colorValue,
        recommendedTutorialPath: rawResult.recommendedTutorialPath,
        tutorialTitle: rawResult.tutorialTitle,
        suggestedPartCategory: rawResult.suggestedPartCategory,
        timestamp: formattedTimestamp,
      );
    } catch (e) {
      debugPrint("MecaGo Domain Error - Échec d'exécution du cas d'utilisation : $e");
      
      // Rapport de secours sécurisé anti-crash
      return DiagnosticModel(
        symptomAnalyzed: symptom,
        probableCause: "Erreur lors du traitement de la requête métier.",
        gravity: "INCONNUE",
        colorValue: 0xFF64748B,
        recommendedTutorialPath: "/tutorials",
        tutorialTitle: "Catalogue",
        suggestedPartCategory: "Générique",
        timestamp: "Indisponible",
      );
    }
  }
}
