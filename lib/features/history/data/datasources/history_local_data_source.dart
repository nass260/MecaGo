import 'package:flutter/material.dart';
import '../../../../core/services/database_helper.dart';
import '../models/history_model.dart';

class HistoryLocalDataSource {
  const HistoryLocalDataSource();

  /// Extrait l'historique complet des interventions validées sur le parc de l'utilisateur.
  /// Mappe chaque ligne SQLite en un objet financier et visuel sécurisé 'HistoryModel'.
  Future<List<HistoryModel>> fetchMaintenanceHistory() async {
    try {
      // 1. Appel physique au gestionnaire central SQLite configuré au démarrage
      final List<Map<String, dynamic>> rawRows = await DatabaseHelper.instance.getAllVehicles();

      // 2. Traitement algorithmique temporaire simulant le retour de la table historique hydratée par le Seeder
      // En production finale branchée, cela consommera : await DatabaseHelper.instance.query('maintenance_history')
      final List<HistoryModel> activeHistory = [
        const HistoryModel(title: "Remplacement filtre d'habitacle HEPA", date: "18 août 2026", mileage: "42 150 km", savings: 35, iconCodePoint: 0xe056),
        const HistoryModel(title: "Rotation des pneumatiques", date: "02 juillet 2026", mileage: "39 800 km", savings: 40, iconCodePoint: 0xf0244),
        const HistoryModel(title: "Remplissage liquide lave-glace", date: "12 mai 2026", mileage: "37 100 km", savings: 10, iconCodePoint: 0xe6e4),
        const HistoryModel(title: "Contrôle pression des pneus", date: "28 mars 2026", mileage: "34 600 km", savings: 15, iconCodePoint: 0xe5d9),
        const HistoryModel(title: "Nettoyage capteurs d'assistance", date: "09 février 2026", mileage: "32 900 km", savings: 25, iconCodePoint: 0xe14c),
      ];

      return activeHistory; // Renvoie les interventions typées prêtes pour le Use Case
    } catch (e) {
      debugPrint("MecaGo Data Error - Échec de lecture de la table historique : $e");
      return const <HistoryModel>[];
    }
  }

  /// Enregistre de manière persistante un nouvel entretien validé à la fin d'un tutoriel
  Future<bool> logNewIntervention(HistoryModel item) async {
    try {
      final int resultId = await DatabaseHelper.instance.insertHistoryItem(item.toMap());
      return resultId > 0;
    } catch (e) {
      debugPrint("MecaGo Data Error - Échec d'écriture de la nouvelle ligne d'historique : $e");
      return false;
    }
  }
}
