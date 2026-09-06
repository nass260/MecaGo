import 'package:flutter/material.dart';
import '../../data/datasources/history_local_data_source.dart';
import '../../data/models/history_model.dart';
import '../../infrastructure/services/savings_statistics_service.dart';

class GetSavingsStatisticsUseCase {
  final HistoryLocalDataSource _localDataSource;
  final SavingsStatisticsService _statisticsService;

  // Injection de dépendances complète des couches de données et d'infrastructures
  const GetSavingsStatisticsUseCase({
    HistoryLocalDataSource localDataSource = const HistoryLocalDataSource(),
    SavingsStatisticsService statisticsService = const SavingsStatisticsService(),
  })  : _localDataSource = localDataSource,
        _statisticsService = statisticsService;

  /// Exécute l'action métier de calcul et de ventilation des économies par trimestres civils
  Future<Map<String, double>> execute() async {
    try {
      // 1. Récupération des lignes d'interventions réelles lues en base de données SQLite
      final List<HistoryModel> historyItems = await _localDataSource.fetchMaintenanceHistory();

      // 2. Traitement algorithmique de ventilation par trimestres (Jan-Mars, Avr-Juin, etc.)
      final Map<String, double> quarterlyStats = _statisticsService.aggregateSavingsByQuarter(historyItems);

      return quarterlyStats; // Renvoie les données structurées prêtes pour le rendu visuel
    } catch (e) {
      debugPrint("MecaGo Domain Error - Échec du calcul des statistiques métiers : $e");
      return {
        'Trimestre 1': 0.0,
        'Trimestre 2': 0.0,
        'Trimestre 3': 0.0,
        'Trimestre 4': 0.0,
      };
    }
  }
}
