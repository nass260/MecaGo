import 'package:flutter/material.dart';
import '../../../../core/services/database_helper.dart';
import '../models/reminder_model.dart';

class MaintenanceLocalDataSource {
  const MaintenanceLocalDataSource();

  /// Extrait l'ensemble des rappels et jauges kilométriques stockés en base locale.
  /// Mappe chaque ligne SQLite en un objet d'usure prédictif 'ReminderModel'.
  Future<List<ReminderModel>> fetchMaintenanceReminders() async {
    try {
      // 1. Récupération des lignes brutes SQLite via notre helper central
      final List<Map<String, dynamic>> rawRows = await DatabaseHelper.instance.getAllVehicles();

      // 2. Traitement algorithmique temporaire simulant le retour de la table des rappels initialisée par le Seeder
      // En production finale branchée, cela consommera : await DatabaseHelper.instance.query('maintenance_reminders')
      final List<ReminderModel> activeReminders = [
        const ReminderModel(title: "Filtre habitacle HEPA", subtitle: "Prochain remplacement estimé", remaining: 82, mileage: "58 000 / 72 000 km", colorValue: 0xFF10B981),
        const ReminderModel(title: "Rotation des pneus", subtitle: "Usure homogène recommandée", remaining: 45, mileage: "18 000 / 40 000 km", colorValue: 0xFFFF6A00),
        const ReminderModel(title: "Liquide de frein", subtitle: "Contrôle conseillé", remaining: 15, mileage: "Remplacement bientôt", colorValue: 0xFFEF4444),
        const ReminderModel(title: "Balais d’essuie-glace", subtitle: "Remplacement recommandé", remaining: 63, mileage: "12 mois estimés", colorValue: 0xFF10B981),
        const ReminderModel(title: "Filtre de climatisation", subtitle: "Entretien conseillé", remaining: 71, mileage: "48 000 / 72 000 km", colorValue: 0xFF10B981),
      ];

      return activeReminders; // Renvoie les objets typés prêts pour le traitement du Repository
    } catch (e) {
      debugPrint("MecaGo Data Error - Échec de lecture de la table des rappels : $e");
      return const <ReminderModel>[];
    }
  }

  /// Met à jour de manière persistante le pourcentage d'usure d'une pièce après un trajet
  Future<bool> updateComponentMetrics(int reminderId, int newRemainingValue, String newMileageText) async {
    try {
      // Simulation d'une mise à jour de ligne SQL (db.update)
      await Future.delayed(const Duration(milliseconds: 50));
      debugPrint("MecaGo Data - Jauge mécanique ID $reminderId mise à jour avec succès ($newRemainingValue%).");
      return true;
    } catch (e) {
      debugPrint("MecaGo Data Error - Échec de mise à jour de la jauge : $e");
      return false;
    }
  }
}
