import '../../data/datasources/garage_local_data_source.dart';
import '../../../home/data/models/vehicle_model.dart'; // Importation corrigée

class GetVehiclesUseCase {
  final GarageLocalDataSource _localDataSource;

  // Injection de dépendance de notre source de données locale
  const GetVehiclesUseCase({
    GarageLocalDataSource localDataSource = const GarageLocalDataSource(),
  }) : _localDataSource = localDataSource;

  /// Exécute l’action métier de récupération et de conversion des véhicules du garage.
  /// Consomme de manière isolée la couche Data Source SQLite de production.
  Future<List<Vehicle>> execute() async {
    try {
      // 1. Récupération via notre source de données locale physique scellée
      final List<Vehicle> vehicles = await _localDataSource.fetchSavedVehicles();

      return vehicles; // Renvoie la liste d’objets typés prête pour l’affichage de l’interface
    } catch (e) {
      // Sécurité anti-crash : renvoie une liste vide de secours
      return const <Vehicle>[];
    }
  }
}
