import 'package:flutter/material.dart';
import '../../domain/usecases/analyze_symptom_usecase.dart';
import '../../data/models/diagnostic_model.dart';

class DiagnosticNotifier extends ChangeNotifier {
  final AnalyzeSymptomUseCase _analyzeSymptomUseCase;

  DiagnosticModel? _currentReport;
  bool _isAnalyzing = false;
  String? _errorMessage;

  // Injection de dépendance du cas d'utilisation du domaine
  DiagnosticNotifier({
    AnalyzeSymptomUseCase analyzeSymptomUseCase = const AnalyzeSymptomUseCase(),
  }) : _analyzeSymptomUseCase = analyzeSymptomUseCase;

  // Getters sécurisés pour exposer l'état à la vue de diagnostic
  DiagnosticModel? get currentReport => _currentReport;
  bool get isAnalyzing => _isAnalyzing;
  String? get errorMessage => _errorMessage;

  /// Soumet un symptôme mécanique au moteur d'analyse décisionnel de l'IA MecaGo
  Future<void> submitSymptomAnalysis(String symptom) async {
    if (symptom.trim().isEmpty || _isAnalyzing) return;

    _isAnalyzing = true;
    _errorMessage = null;
    _currentReport = null;
    notifyListeners(); // Avertit la vue d'afficher l'animation d'analyse

    try {
      // Exécution de la règle métier isolée au domaine
      _currentReport = await _analyzeSymptomUseCase.execute(symptom);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = "Le moteur de diagnostic de l'IA a rencontré une anomalie. Veuillez réessayer.";
      _currentReport = null;
    } finally {
      _isAnalyzing = false;
      notifyListeners(); // Force la mise à jour visuelle du rapport d'analyse final
    }
  }

  /// Réinitialise l'état pour lancer une nouvelle recherche de panne
  void resetDiagnostic() {
    _currentReport = null;
    _errorMessage = null;
    _isAnalyzing = false;
    notifyListeners();
  }
}
