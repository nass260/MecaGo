// lib/features/home/presentation/managers/home_notifier.dart
import 'package:flutter/material.dart';
import '../../data/models/vehicle_model.dart';

class HomeNotifier with ChangeNotifier {
  bool _isLoading = false;
  int _mecaGoScore = 85;
  double _totalSavings = 125.0;
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

    await Future.delayed(const Duration(milliseconds: 500));

    _vehicles = [
      const Vehicle(
        id: '1',
        brand: 'Tesla',
        model: 'Model 3',
        plate: 'AB-123-CD',
        year: 2024,
        mileage: 23450,
        fuelType: FuelType.electrique,
        transmission: TransmissionType.automatique,
        progress: 0.85,
        isAlert: false,
        imageUrl: 'assets/images/tesla_model_3.jpg',
      ),
      const Vehicle(
        id: '2',
        brand: 'Renault',
        model: 'Clio 5',
        plate: 'EF-456-GH',
        year: 2019,
        mileage: 87200,
        fuelType: FuelType.diesel,
        transmission: TransmissionType.manuelle,
        progress: 0.45,
        isAlert: true,
        imageUrl: '',
      ),
      const Vehicle(
        id: '3',
        brand: 'Peugeot',
        model: '208',
        plate: 'IJ-789-KL',
        year: 2021,
        mileage: 45000,
        fuelType: FuelType.essence,
        transmission: TransmissionType.manuelle,
        progress: 0.72,
        isAlert: false,
        imageUrl: '',
      ),
      const Vehicle(
        id: '4',
        brand: 'Peugeot',
        model: 'Boxer',
        plate: 'MN-012-OP',
        year: 2010,
        mileage: 185000,
        fuelType: FuelType.diesel,
        transmission: TransmissionType.manuelle,
        progress: 0.55,
        isAlert: false,
        imageUrl: '',
      ),
    ];

    _activeVehicle = _vehicles.first;
    _isLoading = false;
    notifyListeners();
  }

  void selectVehicle(String vehicleId) {
    final vehicle = _vehicles.firstWhere((v) => v.id == vehicleId);
    _activeVehicle = vehicle;
    notifyListeners();
  }

  Future<void> addVehicle(Vehicle vehicle) async {
    _vehicles.add(vehicle);
    if (_activeVehicle == null) {
      _activeVehicle = vehicle;
    }
    notifyListeners();
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
      imageUrl: '',
    );

    _vehicles.add(newVehicle);
    if (_activeVehicle == null) {
      _activeVehicle = newVehicle;
    }
    notifyListeners();
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

  Future<void> updateVehicle(Vehicle updatedVehicle) async {
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
    _vehicles.removeWhere((v) => v.id == id);
    if (_activeVehicle?.id == id) {
      _activeVehicle = _vehicles.isNotEmpty ? _vehicles.first : null;
    }
    notifyListeners();
  }

  Future<void> refresh() async {
    await loadDashboardData();
  }
}