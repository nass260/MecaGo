// lib/features/home/presentation/managers/home_notifier.dart
import 'package:flutter/material.dart';
import '../../../../core/services/database_service.dart';
import '../../data/models/vehicle_model.dart';

class HomeNotifier with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();

  bool _isLoading = false;
  int _mecaGoScore = 85;
  double _totalSavings = 0.0;
  Vehicle? _activeVehicle;
  List<Vehicle> _vehicles = [];

  // Getters
  bool get isLoading => _isLoading;
  int get mecaGoScore => _mecaGoScore;
  double get totalSavings => _totalSavings;
  Vehicle? get activeVehicle => _activeVehicle;
  List<Vehicle> get vehicles => _vehicles;

  /// Charge toutes les données du dashboard depuis SQLite
  Future<void> loadDashboardData() async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Charger les véhicules
      _vehicles = await _databaseService.getVehicles();

      // 2. Définir le véhicule actif (premier par défaut)
      if (_vehicles.isNotEmpty) {
        _activeVehicle = _vehicles.first;
      }

      // 3. Calculer les économies totales
      await _calculateTotalSavings();

      // 4. Calculer le score MecaGo
      _calculateMecaGoScore();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Erreur lors du chargement : $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Calcule les économies totales depuis l'historique
  Future<void> _calculateTotalSavings() async {
    double total = 0.0;
    for (final vehicle in _vehicles) {
      final logs = await _databaseService.getMaintenanceLogs(vehicle.id);
      for (final log in logs) {
        total += log.saved;
      }
    }
    _totalSavings = total;
  }

  /// Calcule le score MecaGo en fonction de la santé des véhicules
  void _calculateMecaGoScore() {
    if (_vehicles.isEmpty) {
      _mecaGoScore = 0;
      return;
    }

    double totalProgress = 0.0;
    for (final vehicle in _vehicles) {
      totalProgress += vehicle.progress;
    }

    _mecaGoScore = ((totalProgress / _vehicles.length) * 100).round();
  }

  /// Change le véhicule actif
  void selectVehicle(String vehicleId) {
    final vehicle = _vehicles.firstWhere(
      (v) => v.id == vehicleId,
      orElse: () => throw Exception('Véhicule non trouvé'),
    );
    _activeVehicle = vehicle;
    notifyListeners();
  }

  /// Ajoute un nouveau véhicule
  Future<void> addVehicle(Vehicle vehicle) async {
    try {
      await _databaseService.insertVehicle(vehicle);
      _vehicles.add(vehicle);
      if (_activeVehicle == null) {
        _activeVehicle = vehicle;
      }
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Erreur ajout véhicule : $e');
    }
  }

  /// Met à jour un véhicule
  Future<void> updateVehicle(Vehicle updatedVehicle) async {
    try {
      await _databaseService.updateVehicle(updatedVehicle);
      final index = _vehicles.indexWhere((v) => v.id == updatedVehicle.id);
      if (index != -1) {
        _vehicles[index] = updatedVehicle;
        if (_activeVehicle?.id == updatedVehicle.id) {
          _activeVehicle = updatedVehicle;
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint('❌ Erreur mise à jour véhicule : $e');
    }
  }

  /// Supprime un véhicule
  Future<void> deleteVehicle(String id) async {
    try {
      await _databaseService.deleteVehicle(id);
      _vehicles.removeWhere((v) => v.id == id);
      if (_activeVehicle?.id == id) {
        _activeVehicle = _vehicles.isNotEmpty ? _vehicles.first : null;
      }
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Erreur suppression véhicule : $e');
    }
  }

  /// Rafraîchit toutes les données
  Future<void> refresh() async {
    await loadDashboardData();
  }
}
