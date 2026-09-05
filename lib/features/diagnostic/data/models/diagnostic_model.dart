import 'dart:convert';

class DiagnosticModel {
  final int? id;
  final String symptomAnalyzed;
  final String probableCause;
  final String gravity;
  final int colorValue;
  final String recommendedTutorialPath;
  final String tutorialTitle;
  final String suggestedPartCategory;
  final String timestamp; // Date et heure de l'analyse (Ex: "05/09/2026 14:58")

  const DiagnosticModel({
    this.id,
    required this.symptomAnalyzed,
    required this.probableCause,
    required this.gravity,
    required this.colorValue,
    required this.recommendedTutorialPath,
    required this.tutorialTitle,
    required this.suggestedPartCategory,
    required this.timestamp,
  });

  /// Convertit un objet DiagnosticModel en Map pour l'insertion SQLite
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'symptom_analyzed': symptomAnalyzed,
      'probable_cause': probableCause,
      'gravity': gravity,
      'color_value': colorValue,
      'recommended_tutorial_path': recommendedTutorialPath,
      'tutorial_title': tutorialTitle,
      'suggested_part_category': suggestedPartCategory,
      'timestamp': timestamp,
    };
  }

  /// Extrait les données brutes de SQLite pour recréer un objet DiagnosticModel typé
  factory DiagnosticModel.fromMap(Map<String, dynamic> map) {
    return DiagnosticModel(
      id: map['id'] as int?,
      symptomAnalyzed: map['symptom_analyzed'] as String,
      probableCause: map['probable_cause'] as String,
      gravity: map['gravity'] as String,
      colorValue: map['color_value'] as int,
      recommendedTutorialPath: map['recommended_tutorial_path'] as String,
      tutorialTitle: map['tutorial_title'] as String,
      suggestedPartCategory: map['suggested_part_category'] as String,
      timestamp: map['timestamp'] as String,
    );
  }

  /// Utilitaires de conversion JSON pour les futures synchronisations Cloud Firebase
  String toJson() => json.encode(toMap());
  factory DiagnosticModel.fromJson(String source) => DiagnosticModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
