import 'package:flutter/material.dart';
import '../../data/models/history_model.dart';

class SavingsStatisticsService {
  const SavingsStatisticsService();

  /// Ventile l'intégralité des gains réels de l'historique par trimestres pour l'année en cours (2026).
  /// Renvoie un tableau de valeurs numériques exploitable par un graphique de présentation.
  Map<String, double> aggregateSavingsByQuarter(List<HistoryModel> historyItems) {
    try {
      double q1 = 0.0; // Janvier, Février, Mars
      double q2 = 0.0; // Avril, Mai, Juin
      double q3 = 0.0; // Juillet, Août, Septembre
      double q4 = 0.0; // Octobre, Novembre, Décembre

      for (final item in historyItems) {
        final String dateLower = item.date.toLowerCase();

        if (dateLower.contains('janvier') || dateLower.contains('février') || dateLower.contains('mars')) {
          q1 += item.savings.toDouble();
        } else if (dateLower.contains('avril') || dateLower.contains('mai') || dateLower.contains('juin')) {
          q2 += item.savings.toDouble();
        } else if (dateLower.contains('juillet') || dateLower.contains('août') || dateLower.contains('septembre')) {
          q3 += item.savings.toDouble();
        } else if (dateLower.contains('octobre') || dateLower.contains('novembre') || dateLower.contains('décembre')) {
          q4 += item.savings.toDouble();
        }
      }

      return {
        'Trimestre 1': q1,
        'Trimestre 2': q2,
        'Trimestre 3': q3,
        'Trimestre 4': q4,
      };
    } catch (e) {
      debugPrint("MecaGo Analytics Error - Échec d'agrégation trimestrielle : $e");
      return {
        'Trimestre 1': 0.0,
        'Trimestre 2': 0.0,
        'Trimestre 3': 0.0,
        'Trimestre 4': 0.0,
      };
    }
  }
}
