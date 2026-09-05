import 'package:flutter/material.dart';

class DatabaseHelper {
  // Instance unique (Singleton) pour garantir une seule connexion ouverte
  static final DatabaseHelper instance = DatabaseHelper._init();
  
  const DatabaseHelper._init();

  /// Initialise la connexion et configure l'arborescence des tables locales
  Future<void> initializeDatabase() async {
    try {
      // Simulation de l'ouverture du fichier de base de données sqlite (.db)
      await Future.delayed(const Duration(milliseconds: 500));
      debugPrint("MecaGo Database - SQLite initialisé avec succès pour le parc européen.");
    } catch (e) {
      debugPrint("MecaGo Database Error - Échec d'initialisation : $e");
    }
  }

  /// Insère un nouveau véhicule (Tesla, Renault, Peugeot...) après le scan OCR
  Future<int> insertVehicle(Map<String, dynamic> vehicleRow) async {
    // Simulation d'insertion dans la table 'vehicles'
    await Future.delayed(const Duration(milliseconds: 100));
    debugPrint("MecaGo Database - Véhicule enregistré : ${vehicleRow['brand']} ${vehicleRow['model']} [${vehicleRow['plate']}]");
    return 1; // Retourne l'ID unique de la ligne générée
  }

  /// Récupère la liste complète des véhicules du garage de l'utilisateur
  Future<List<Map<String, dynamic>>> getAllVehicles() async {
    await Future.delayed(const Duration(milliseconds: 150));
    // Retourne un jeu de données dynamique conforme aux deux véhicules de votre maquette
    return [
      {
        'id': 1,
        'brand': 'Tesla',
        'model': 'Model 3',
        'plate': 'AB-123-CD',
        'progress': 0.76,
        'isAlert': 1,
      },
      {
        'id': 2,
        'brand': 'Renault',
        'model': 'Clio 5',
        'plate': 'EE-987-ZZ',
        'progress': 0.95,
        'isAlert': 0,
      }
    ];
  }

  /// Insère une ligne de réparation validée dans la table historique
  Future<int> insertHistoryItem(Map<String, dynamic> historyRow) async {
    await Future.delayed(const Duration(milliseconds: 100));
    debugPrint("MecaGo Database - Entretien consigné : ${historyRow['title']} (${historyRow['savings']}€ économisés)");
    return 1;
  }
}
