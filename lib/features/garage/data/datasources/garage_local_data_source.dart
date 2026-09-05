import 'package:flutter/material.dart';
import '../../../../core/services/database_helper.dart';
import '../models/vehicle_model.dart';

class GarageLocalDataSource {
  const GarageLocalDataSource();

  /// Interroge directement la persistance locale pour extraire le parc automobile de l'utilisateur.
  /// Mappe et convertit chaque ligne brute SQLite en un objet sécurisé 'VehicleModel'.
  Future<List<VehicleModel>> fetchSavedVehicles() async {
    try {
      // 1. Appel physique au gestionnaire central SQLite configuré au Sprint 3
      final List<Map<String, dynamic>> rawRows = await DatabaseHelper.instance.getAllVehicles();

      // 2. Traitement algorithmique de désérialisation via la factory de notre modèle de données
      final List<VehicleModel> activeGarage = rawRows.map((map) {
        return VehicleModel.fromMap(map);
      }).toList();

      return activeGarage; // Renvoie les objets typés prêts pour l'affichage
    } catch (e) {
      debugPrint("MecaGo Data Error - Échec d'extraction de la table garage : $e");
      // Renvoie une liste vide de secours en cas d'anomalie réseau ou matérielle
      return const <VehicleModel>[];
    }
  }

  /// Persiste un nouveau modèle de véhicule au sein du stockage local après validation OCR
  Future<bool> saveNewVehicle(VehicleModel vehicle) async {
    try {
      final int resultId = await DatabaseHelper.instance.insertVehicle(vehicle.toMap());
      return resultId > 0;
    } catch (e) {
      debugPrint("MecaGo Data Error - Échec d'écriture du nouveau véhicule : $e");
      return false;
    }
  }
}
