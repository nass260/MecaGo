// lib/features/home/presentation/managers/home_notifier.dart
import 'package:flutter/material.dart';
import '../../../../core/services/database_service.dart';
import '../../data/models/vehicle_model.dart';

class HomeNotifier with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();

  bool _isLoading = false;
  int _mecaGoScore = 85;
  int _totalSavings = 125;
  Vehicle? _activeVehicle;
  List<Vehicle> _vehicles = [];

  bool get isLoading => _isLoading;
  int get mecaGoScore => _mecaGoScore;
  int get totalSavings => _totalSavings;
  Vehicle? get activeVehicle => _activeVehicle;
  List<Vehicle> get vehicles => _vehicles;

  Future<void> loadDashboardData() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Charger les véhicules depuis SQLite
      _vehicles = await _databaseService.getVehicles();

      // Définir le véhicule actif (le premier par défaut)
      if (_vehicles.isNotEmpty) {
        _activeVehicle = _vehicles.first;
      }

      // Calculer les économies depuis l'historique
      await _calculateSavings();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Erreur lors du chargement : $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _calculateSavings() async {
    int totalSaved = 0;
    for (final vehicle in _vehicles) {
      final logs = await _databaseService.getMaintenanceLogs(vehicle.id);
      for (final log in logs) {
        totalSaved += (log['saved'] as num?)?.toInt() ?? 0;
      }
    }
    _totalSavings = totalSaved > 0 ? totalSaved : 125;
  }

  void selectVehicle(String vehicleId) {
    final vehicle = _vehicles.firstWhere(
      (v) => v.id == vehicleId,
      orElse: () => throw Exception('Vehicle not found'),
    );
    _activeVehicle = vehicle;
    notifyListeners();
  }

  Future<void> addVehicle(Vehicle vehicle) async {
    await _databaseService.insertVehicle(vehicle);
    _vehicles.add(vehicle);
    if (_activeVehicle == null) {
      _activeVehicle = vehicle;
    }
    notifyListeners();
  }

  Future<void> updateVehicle(Vehicle updatedVehicle) async {
    await _databaseService.updateVehicle(updatedVehicle);
    final index = _vehicles.indexWhere((v) => v.id == updatedVehicle.id);
    if (index != -1) {
      _vehicles[index] = updatedVehicle;
      if (_activeVehicle?.id == updatedVehicle.id) {
        _activeVehicle = updatedVehicle;
      }
      notifyListeners();
    }
  }

  Future<void> deleteVehicle(String id) async {
    await _databaseService.deleteVehicle(id);
    _vehicles.removeWhere((v) => v.id == id);
    if (_activeVehicle?.id == id) {
      _activeVehicle = _vehicles.isNotEmpty ? _vehicles.first : null;
    }
    notifyListeners();
  }

  void updateMecaGoScore(int newScore) {
    _mecaGoScore = newScore;
    notifyListeners();
  }

  void updateSavings(int newSavings) {
    _totalSavings = newSavings;
    notifyListeners();
  }
}
