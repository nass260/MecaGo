// lib/core/services/mvdb_service.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MvdbService {
  static List<Map<String, dynamic>> _allMakes = [];
  static bool _isLoaded = false;

  static Future<void> _load() async {
    if (_isLoaded) return;
    try {
      final String response =
          await rootBundle.loadString('assets/vehicles.json');
      final dynamic data = json.decode(response);

      if (data is Map<String, dynamic> && data['makes'] is List) {
        _allMakes = (data['makes'] as List).cast<Map<String, dynamic>>();
      } else if (data is List) {
        _allMakes = data.cast<Map<String, dynamic>>();
      }

      _isLoaded = true;
      debugPrint('✅ MVDB : ${_allMakes.length} marques');
    } catch (e) {
      debugPrint('❌ Erreur MVDB : $e');
    }
  }

  static Future<List<String>> getBrands() async {
    await _load();
    final brands = <String>{};
    for (final m in _allMakes) {
      final make = m['make'] ?? m['name'];
      if (make != null) brands.add(make.toString());
    }
    return brands.toList()..sort();
  }

  static Future<List<String>> getModels(String brand) async {
    await _load();
    final models = <String>{};
    final searchBrand = brand.toLowerCase();
    for (final m in _allMakes) {
      final make = (m['make'] ?? m['name'] ?? '').toString().toLowerCase();
      if (make == searchBrand) {
        final modelList = m['models'];
        if (modelList is List) {
          for (final model in modelList) {
            final modelName = model['model'] ?? model['name'];
            if (modelName != null) models.add(modelName.toString());
          }
        }
        break;
      }
    }
    return models.toList()..sort();
  }

  static Future<List<String>> getEngines(String brand, String model) async {
    await _load();
    final trims = <String>{};
    final searchBrand = brand.toLowerCase();
    final searchModel = model.toLowerCase();
    for (final m in _allMakes) {
      final make = (m['make'] ?? m['name'] ?? '').toString().toLowerCase();
      if (make == searchBrand) {
        final modelList = m['models'];
        if (modelList is List) {
          for (final mdl in modelList) {
            final modelName =
                (mdl['model'] ?? mdl['name'] ?? '').toString().toLowerCase();
            if (modelName == searchModel) {
              final trimList = mdl['trims'] ?? mdl['trim'] ?? [];
              if (trimList is List) {
                for (final trim in trimList) {
                  final trimName = trim['trim'] ?? trim['name'] ?? trim;
                  if (trimName != null) trims.add(trimName.toString());
                }
              }
            }
          }
        }
        break;
      }
    }
    return trims.toList()..sort();
  }

  static Future<List<int>> getYears(String brand, String model) async {
    await _load();
    return List.generate(22, (i) => 2005 + i);
  }

  static Future<Map<String, dynamic>?> getVehicleDetails({
    required String brand,
    required String model,
    required String engine,
  }) async {
    await _load();
    return {
      'brand': brand,
      'model': model,
      'engine': engine,
      'fuel': 'Essence',
      'power_hp': 100,
      'transmission': 'Manuelle',
      'body': 'Non spécifié',
    };
  }
}