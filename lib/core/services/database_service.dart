// lib/core/services/database_service.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../features/home/data/models/vehicle_model.dart';

// Pour le Web
import 'dart:html' as html;

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static const String _vehiclesKey = 'mecago_vehicles';

  // ============================================
  // STOCKAGE
  // ============================================

  Future<String?> _getString(String key) async {
    if (kIsWeb) {
      return html.window.localStorage[key];
    }
    return null;
  }

  Future<void> _setString(String key, String value) async {
    if (kIsWeb) {
      html.window.localStorage[key] = value;
    }
  }

  // ============================================
  // VÉHICULES
  // ============================================

  Future<List<Vehicle>> getVehicles() async {
    try {
      final jsonString = await _getString(_vehiclesKey);

      if (jsonString == null || jsonString.isEmpty) {
        debugPrint('📦 Aucun véhicule en stockage');
        return [];
      }

      final List<dynamic> data = json.decode(jsonString);
      final vehicles = data
          .map((map) => Vehicle.fromMap(map as Map<String, dynamic>))
          .toList();

      debugPrint('✅ ${vehicles.length} véhicules chargés');
      return vehicles;
    } catch (e) {
      debugPrint('❌ Erreur chargement : $e');
      return [];
    }
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
      await _saveVehicles(vehicles);
      debugPrint('✅ Véhicule ajouté : ${vehicle.brand} ${vehicle.model}');
    } catch (e) {
      debugPrint('❌ Erreur ajout : $e');
      rethrow;
    }
  }

  Future<void> updateVehicle(Vehicle vehicle) async {
    try {
      final vehicles = await getVehicles();
      final index = vehicles.indexWhere((v) => v.id == vehicle.id);
      if (index != -1) {
        vehicles[index] = vehicle;
        await _saveVehicles(vehicles);
        debugPrint('✅ Véhicule mis à jour');
      }
    } catch (e) {
      debugPrint('❌ Erreur mise à jour : $e');
    }
  }

  Future<void> deleteVehicle(String id) async {
    try {
      final vehicles = await getVehicles();
      vehicles.removeWhere((v) => v.id == id);
      await _saveVehicles(vehicles);
      debugPrint('✅ Véhicule supprimé');
    } catch (e) {
      debugPrint('❌ Erreur suppression : $e');
    }
  }

  Future<void> _saveVehicles(List<Vehicle> vehicles) async {
    final jsonString = json.encode(
      vehicles.map((v) => v.toMap()).toList(),
    );
    await _setString(_vehiclesKey, jsonString);
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