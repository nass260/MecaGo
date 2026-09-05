import 'package:flutter/material.dart';
import '../../domain/usecases/get_vehicles_usecase.dart';
import '../../data/models/vehicle_model.dart';

class GarageNotifier extends ChangeNotifier {
  final GetVehiclesUseCase _getVehiclesUseCase;

  List<VehicleModel> _vehicles = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Injection de dépendance du cas d'utilisation métier
  GarageNotifier({
    GetVehiclesUseCase getVehiclesUseCase = const GetVehiclesUseCase(),
  }) : _getVehiclesUseCase = getVehiclesUseCase;

  // Getters épurés pour exposer l'état de manière sécurisée à la vue
  List<VehicleModel> get vehicles => _vehicles;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Charge de manière asynchrone les véhicules depuis le stockage SQLite local
  Future<void> loadGarageVehicles() async {
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners(); // Avertit la vue d'afficher l'indicateur de chargement

    try {
      // Exécution de l'action métier scellée au domaine
      _vehicles = await _getVehiclesUseCase.execute();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = "Impossible de charger votre garage. Veuillez réessayer.";
      _vehicles = [];
    } finally {
      _isLoading = false;
      notifyListeners(); // Avertit la vue de rafraîchir les cartes premium avec les vraies données
    }
  }
}
