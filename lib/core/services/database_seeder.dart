import 'package:flutter/material.dart';
import 'database_helper.dart';

class DatabaseSeeder {
  const DatabaseSeeder();

  /// Injecte les données de démonstration conformes aux spécifications de la maquette MecaGo.
  /// S'exécute uniquement si la base de données locale est totalement vide.
  static Future<void> seedInitialData() async {
    try {
      final DatabaseHelper db = DatabaseHelper.instance;
      
      // 1. Vérification de l'état du garage
      final List<Map<String, dynamic>> existingVehicles = await db.getAllVehicles();
      
      // Si des véhicules existent déjà, on n'écrase rien pour préserver les données utilisateur
      if (existingVehicles.isNotEmpty) {
        debugPrint("MecaGo Seeder - Base de données déjà alimentée. Saut de l'étape.");
        return;
      }

      debugPrint("MecaGo Seeder - Hydratation initiale du garage français...");

      // 2. Hydratation de la table des véhicules (Tesla + Clio)
      await db.insertVehicle({
        'brand': 'Tesla',
        'model': 'Model 3',
        'plate': 'AB-123-CD',
        'progress': 0.76,
        'isAlert': 1,
        'image_url': 'https://unsplash.com'
      });

      await db.insertVehicle({
        'brand': 'Renault',
        'model': 'Clio 5',
        'plate': 'EE-987-ZZ',
        'progress': 0.95,
        'isAlert': 0,
        'image_url': 'https://unsplash.com'
      });

      // 3. Hydratation de la table historique pour totaliser les 125 € d'économies de la maquette
      await db.insertHistoryItem({
        'title': "Remplacement filtre d'habitacle HEPA",
        'date': '18 août 2026',
        'mileage': '42 150 km',
        'savings': 35,
        'icon_code_point': 0xe056, // Icons.air_rounded
      });

      await db.insertHistoryItem({
        'title': 'Rotation des pneumatiques',
        'date': '02 juillet 2026',
        'mileage': '39 800 km',
        'savings': 40,
        'icon_code_point': 0xf0244, // Icons.tire_repair_rounded
      });

      await db.insertHistoryItem({
        'title': 'Remplissage liquide lave-glace',
        'date': '12 mai 2026',
        'mileage': '37 100 km',
        'savings': 10,
        'icon_code_point': 0xe6e4, // Icons.water_drop_rounded
      });

      await db.insertHistoryItem({
        'title': 'Contrôle pression des pneus',
        'date': '28 mars 2026',
        'mileage': '34 600 km',
        'savings': 15,
        'icon_code_point': 0xe5d9, // Icons.speed_rounded
      });

      await db.insertHistoryItem({
        'title': "Nettoyage capteurs d'assistance",
        'date': '09 février 2026',
        'mileage': '32 900 km',
        'savings': 25,
        'icon_code_point': 0xe14c, // Icons.center_focus_strong_rounded
      });

      debugPrint("MecaGo Seeder - Base de données hydratée avec succès (125€ d'économies cumulées).");
    } catch (e) {
      debugPrint("MecaGo Seeder Error - Échec du peuplement des données : $e");
    }
  }
}
