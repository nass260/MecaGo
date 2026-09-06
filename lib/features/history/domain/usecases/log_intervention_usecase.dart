import 'package:flutter/material.dart';
import '../../data/datasources/history_local_data_source.dart';
import '../../data/models/history_model.dart';

class LogInterventionUseCase {
  final HistoryLocalDataSource _localDataSource;

  // Injection de dépendance de notre source de données historique locale
  const LogInterventionUseCase({
    HistoryLocalDataSource localDataSource = const HistoryLocalDataSource(),
  }) : _localDataSource = localDataSource;

  /// Exécute l'action métier de création et d'archivage d'une nouvelle ligne d'historique d'entretien.
  /// Met automatiquement à jour les métadonnées et persiste le gain financier dans SQLite.
  Future<bool> execute({
    required String title,
    required int savingsAmount,
    required String vehicleMileage,
    required int iconMaterialCodePoint,
  }) async {
    try {
      // 1. Capture temporelle précise au format français
      final DateTime now = DateTime.now();
      final List<String> months = [
        "janvier", "février", "mars", "avril", "mai", "juin",
        "juillet", "août", "septembre", "octobre", "novembre", "décembre"
      ];
      final String formattedDate = "${now.day} ${months[now.month - 1]} ${now.year}";

      // 2. Instanciation propre de notre modèle de données structurel
      final HistoryModel newIntervention = HistoryModel(
        title: title,
        date: formattedDate,
        mileage: vehicleMileage,
        savings: savingsAmount,
        iconCodePoint: iconMaterialCodePoint,
      );

      // 3. Persistance physique dans la base de données locale SQLite
      final bool isSaved = await _localDataSource.logNewIntervention(newIntervention);
      
      if (isSaved) {
        debugPrint("MecaGo Domain - Intervention archivée avec succès : +$savingsAmount € en base.");
      }
      return isSaved;
    } catch (e) {
      debugPrint("MecaGo Domain Error - Échec du traitement de validation de révision : $e");
      return false;
    }
  }
}
