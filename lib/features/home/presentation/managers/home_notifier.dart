import 'package:flutter/material.dart';
import '../../../garage/domain/usecases/get_vehicles_usecase.dart';
import '../../../garage/data/models/vehicle_model.dart';
import '../../../history/domain/usecases/get_history_usecase.dart';

class HomeNotifier extends ChangeNotifier {
  final GetVehiclesUseCase _getVehiclesUseCase;
  final GetHistoryUseCase _getHistoryUseCase;

  VehicleModel? _activeVehicle;
  int _totalSavings = 0;
  int _mecaGoScore = 100;
  bool _isLoading = false;
  String? _errorMessage;

  // Injection de dépendances croisée pour agréger le tableau de bord
  HomeNotifier({
    GetVehiclesUseCase getVehiclesUseCase = const GetVehiclesUseCase(),
    GetHistoryUseCase getHistoryUseCase = const GetHistoryUseCase(),
  })  : _getVehiclesUseCase = getVehiclesUseCase,
        _getHistoryUseCase = getHistoryUseCase;

  // Getters sécurisés pour la vue d'accueil
  VehicleModel? get activeVehicle => _activeVehicle;
  int get totalSavings => _totalSavings;
  int get mecaGoScore => _mecaGoScore;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Charge l'intégralité des données de synthèse de la page d'accueil depuis SQLite
  Future<void> loadDashboardData() async {
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Récupération des véhicules et sélection du premier comme véhicule actif
      final vehicles = await _getVehiclesUseCase.execute();
      if (vehicles.isNotEmpty) {
        _activeVehicle = vehicles.first; // Sélectionne la Tesla Model 3
        _mecaGoScore = (vehicles.first.progress * 100).round(); // Calcule dynamiquement le score (85)
      }

      // 2. Récupération et synchronisation du compteur d'économies réelles (125 €)
      final historyResponse = await _getHistoryUseCase.execute();
      _totalSavings = historyResponse.totalSavings;

      _errorMessage = null;
    } catch (e) {
      _errorMessage = "Erreur de synchronisation du tableau de bord.";
    } finally {
      _isLoading = false;
      notifyListeners(); // Force le rafraîchissement immédiat de la page d'accueil premium
    }
  }
}
