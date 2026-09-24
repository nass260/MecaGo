// lib/features/home/presentation/managers/home_notifier.dart
import 'package:flutter/material.dart';
import '../../../../core/services/database_service.dart';
import '../../../../core/services/notification_service.dart';
import '../../data/models/vehicle_model.dart';

class HomeNotifier with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  final NotificationService _notificationService = const NotificationService();

  bool _isLoading = false;
  int _mecaGoScore = 0;
  double _totalSavings = 0.0;
  Vehicle? _activeVehicle;
  List<Vehicle> _vehicles = [];

  bool get isLoading => _isLoading;
  int get mecaGoScore => _mecaGoScore;
  double get totalSavings => _totalSavings;
  Vehicle? get activeVehicle => _activeVehicle;
  List<Vehicle> get vehicles => _vehicles;

  Future<void> loadDashboardData() async {
    _isLoading = true;
    notifyListeners();

    try {
      _vehicles = await _databaseService.getVehicles();

      if (_vehicles.isNotEmpty) {
        _activeVehicle = _vehicles.first;
        _calculateMecaGoScore();
      }

      _isLoading = false;
      notifyListeners();
      debugPrint('🔄 ${_vehicles.length} véhicules chargés');
    } catch (e) {
      debugPrint('❌ Erreur chargement : $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> reloadVehicles() async {
    try {
      _vehicles = await _databaseService.getVehicles();
      if (_vehicles.isNotEmpty) {
        _activeVehicle = _vehicles.first;
      } else {
        _activeVehicle = null;
      }
      _calculateMecaGoScore();
      notifyListeners();
      debugPrint('🔄 Véhicules rechargés : ${_vehicles.length}');
    } catch (e) {
      debugPrint('❌ Erreur reload : $e');
    }
  }

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

  void selectVehicle(String vehicleId) {
    final vehicle = _vehicles.firstWhere((v) => v.id == vehicleId);
    _activeVehicle = vehicle;
    notifyListeners();
  }

  /// ✅ AJOUTER UN VÉHICULE AVEC NOTIFICATION
  Future<void> addVehicle(Vehicle vehicle) async {
    try {
      await _databaseService.insertVehicle(vehicle);
      _vehicles.add(vehicle);
      if (_activeVehicle == null) {
        _activeVehicle = vehicle;
      }
      _calculateMecaGoScore();
      notifyListeners();

      debugPrint('✅ Véhicule ajouté : ${vehicle.brand} ${vehicle.model}');

      // 🔔 NOTIFICATION DE BIENVENUE
      await _notificationService.showWelcomeNotification(
        '${vehicle.brand} ${vehicle.model}',
      );

      // 🔔 PROGRAMMER UN RAPPEL D'ENTRETIEN (simulation)
      await Future.delayed(const Duration(seconds: 3));
      await _notificationService.showMaintenanceReminder(
        vehicleName: '${vehicle.brand} ${vehicle.model}',
        maintenanceTitle: 'Vidange moteur',
        remainingKm: '1 200 km',
      );
    } catch (e) {
      debugPrint('❌ Erreur ajout : $e');
    }
  }

  Future<void> addVehicleFromMvdb({
    required String brand,
    required String model,
    required String engine,
    required int year,
  }) async {
    final fuelType = _getFuelType(engine);
    final transmission = _getTransmission(engine);

    final newVehicle = Vehicle(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      brand: brand,
      model: model,
      plate: 'À DÉFINIR',
      year: year,
      mileage: 0,
      fuelType: fuelType,
      transmission: transmission,
      progress: 1.0,
      isAlert: false,
      imageUrl: _getVehicleImage(brand, model),
    );

    await addVehicle(newVehicle);
  }

  FuelType _getFuelType(String engine) {
    final lower = engine.toLowerCase();
    if (lower.contains('électrique') || lower.contains('electric')) {
      return FuelType.electrique;
    }
    if (lower.contains('hybride')) {
      return FuelType.hybride;
    }
    if (lower.contains('diesel') ||
        lower.contains('dci') ||
        lower.contains('hdi') ||
        lower.contains('tdi') ||
        lower.contains('bluehdi') ||
        lower.contains('ecoblue')) {
      return FuelType.diesel;
    }
    if (lower.contains('gpl')) {
      return FuelType.gpl;
    }
    if (lower.contains('e85')) {
      return FuelType.e85;
    }
    return FuelType.essence;
  }

  TransmissionType _getTransmission(String engine) {
    final lower = engine.toLowerCase();
    if (lower.contains('automatique') ||
        lower.contains('auto') ||
        lower.contains('eat')) {
      return TransmissionType.automatique;
    }
    if (lower.contains('semi')) {
      return TransmissionType.semiAutomatique;
    }
    return TransmissionType.manuelle;
  }

  String _getVehicleImage(String brand, String model) {
    final key = '${brand.toLowerCase()}_${model.toLowerCase()}';
    final images = <String, String>{
      // ✅ Chemin corrigé : ressources/ au lieu de assets/
      'tesla_model 3': 'ressources/images/tesla_model_3.jpg',
    };
    return images[key] ?? '';
  }

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
      debugPrint('❌ Erreur mise à jour : $e');
    }
  }

  Future<void> deleteVehicle(String id) async {
    try {
      await _databaseService.deleteVehicle(id);
      _vehicles.removeWhere((v) => v.id == id);
      if (_activeVehicle?.id == id) {
        _activeVehicle = _vehicles.isNotEmpty ? _vehicles.first : null;
      }
      _calculateMecaGoScore();
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Erreur suppression : $e');
    }
  }

  Future<void> refresh() async {
    await loadDashboardData();
  }
}