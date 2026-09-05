import '../../../../core/services/database_helper.dart';
import '../../data/models/vehicle_model.dart';

class GetVehiclesUseCase {
  const GetVehiclesUseCase();

  /// Exécute l'action métier de récupération et de conversion des véhicules du garage.
  /// Transforme les lignes brutes de la table SQLite en objets Flutter typés 'VehicleModel'.
  Future<List<VehicleModel>> execute() async {
    try {
      // 1. Récupération des données brutes de persistance locale SQLite
      final List<Map<String, dynamic>> rawVehicles = await DatabaseHelper.instance.getAllVehicles();

      // 2. Conversion et typage algorithmique instantané via le modèle de données du garage
      final List<VehicleModel> typedVehicles = rawVehicles.map((map) {
        return VehicleModel.fromMap(map);
      }).toList();

      return typedVehicles; // Renvoie la liste de véhicules propre et exploitable par l'interface
    } catch (e) {
      // Sécurité anti-crash : renvoie une liste vide en cas d'erreur de lecture
      return const <VehicleModel>[];
    }
  }
}
