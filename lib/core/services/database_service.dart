// lib/core/services/database_service.dart
import 'package:flutter/material.dart';
import 'hive_service.dart';
import '../../features/home/data/models/vehicle_model.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  final HiveService _hiveService = HiveService();

  // ============================================
  // VÉHICULES
  // ============================================

  Future<List<Vehicle>> getVehicles() async {
    return await _hiveService.getVehicles();
  }

  Future<Vehicle?> getVehicle(String id) async {
    final vehicles = await getVehicles();
    try {
      return vehicles.firstWhere((v) => v.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> insertVehicle(Vehicle vehicle) async {
    try {
      final vehicles = await getVehicles();
      final exists = vehicles.any((v) => v.id == vehicle.id);
      if (exists) {
        debugPrint('⚠️ Véhicule déjà existant');
        return;
      }
      vehicles.add(vehicle);
      await _hiveService.saveVehicles(vehicles);
      debugPrint('✅ Véhicule ajouté : ${vehicle.brand} ${vehicle.model}');
    } catch (e) {
      debugPrint('❌ Erreur insertVehicle : $e');
      rethrow;
    }
  }

  Future<void> updateVehicle(Vehicle vehicle) async {
    try {
      final vehicles = await getVehicles();
      final index = vehicles.indexWhere((v) => v.id == vehicle.id);
      if (index != -1) {
        vehicles[index] = vehicle;
        await _hiveService.saveVehicles(vehicles);
        debugPrint('✅ Véhicule mis à jour');
      }
    } catch (e) {
      debugPrint('❌ Erreur updateVehicle : $e');
    }
  }

  Future<void> deleteVehicle(String id) async {
    try {
      final vehicles = await getVehicles();
      vehicles.removeWhere((v) => v.id == id);
      await _hiveService.saveVehicles(vehicles);
      debugPrint('✅ Véhicule supprimé');
    } catch (e) {
      debugPrint('❌ Erreur deleteVehicle : $e');
    }
  }

  // ============================================
  // MÉTHODES POUR COMPATIBILITÉ
  // ============================================

  Future<List<dynamic>> getMaintenanceLogs(String vehicleId) async {
    return [];
  }

  Future<List<dynamic>> getReminders({String? vehicleId}) async {
    return [];
  }
}