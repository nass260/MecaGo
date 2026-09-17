// lib/core/services/hive_service.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../features/home/data/models/vehicle_model.dart';

class HiveService {
  static final HiveService _instance = HiveService._internal();
  factory HiveService() => _instance;
  HiveService._internal();

  static const String _vehiclesBox = 'vehicles_box';
  static const String _vehiclesKey = 'vehicles_list';

  bool _isInitialized = false;

  /// Initialise Hive
  Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      await Hive.initFlutter();
      await Hive.openBox(_vehiclesBox);
      _isInitialized = true;
      debugPrint('✅ Hive initialisé');
    } catch (e) {
      debugPrint('❌ Erreur Hive : $e');
    }
  }

  // ============================================
  // VÉHICULES
  // ============================================

  Future<List<Vehicle>> getVehicles() async {
    try {
      await initialize();
      final box = Hive.box(_vehiclesBox);
      final String? jsonString = box.get(_vehiclesKey);

      if (jsonString == null || jsonString.isEmpty) {
        debugPrint('📦 Hive : aucun véhicule');
        return [];
      }

      final List<dynamic> data = json.decode(jsonString);
      final vehicles = data
          .map((map) => Vehicle.fromMap(map as Map<String, dynamic>))
          .toList();

      debugPrint('✅ Hive : ${vehicles.length} véhicules chargés');
      return vehicles;
    } catch (e) {
      debugPrint('❌ Erreur Hive getVehicles : $e');
      return [];
    }
  }

  Future<void> saveVehicles(List<Vehicle> vehicles) async {
    try {
      await initialize();
      final box = Hive.box(_vehiclesBox);
      final String jsonString = json.encode(
        vehicles.map((v) => v.toMap()).toList(),
      );
      await box.put(_vehiclesKey, jsonString);
      debugPrint('✅ Hive : ${vehicles.length} véhicules sauvegardés');
    } catch (e) {
      debugPrint('❌ Erreur Hive saveVehicles : $e');
    }
  }

  Future<void> clearAll() async {
    try {
      await initialize();
      final box = Hive.box(_vehiclesBox);
      await box.clear();
      debugPrint('✅ Hive : toutes les données effacées');
    } catch (e) {
      debugPrint('❌ Erreur Hive clearAll : $e');
    }
  }
}