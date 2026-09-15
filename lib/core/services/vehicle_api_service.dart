// lib/core/services/vehicle_api_service.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Service qui utilise la base de données locale de véhicules
/// Structure : makes → models → trims
class VehicleApiService {
  static List<Map<String, dynamic>> _allMakes = [];
  static bool _isLoaded = false;
  static bool _isLoading = false;

  /// Charge la base SEULEMENT quand on en a besoin
  static Future<void> _loadDatabase() async {
    if (_isLoaded) return;
    if (_isLoading) {
      // Attendre si déjà en cours
      while (_isLoading) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      return;
    }

    _isLoading = true;
    try {
      debugPrint('📦 Chargement de la base...');
      final String response =
          await rootBundle.loadString('assets/vehicles.json');
      debugPrint('📦 Fichier lu (${response.length} caractères)');

      final dynamic data = json.decode(response);

      if (data is Map<String, dynamic> && data['makes'] is List) {
        _allMakes = (data['makes'] as List).cast<Map<String, dynamic>>();
        debugPrint('✅ ${_allMakes.length} marques chargées');
      } else if (data is List) {
        _allMakes = data.cast<Map<String, dynamic>>();
        debugPrint('✅ ${_allMakes.length} marques chargées');
      } else {
        debugPrint('❌ Format JSON non reconnu');
      }

      _isLoaded = true;
    } catch (e) {
      debugPrint('❌ Erreur chargement : $e');
    } finally {
      _isLoading = false;
    }
  }

  static Future<List<String>> getBrands() async {
    await _loadDatabase();
    final brands = <String>{};
    for (final m in _allMakes) {
      final make = m['make'] ?? m['name'];
      if (make != null) brands.add(make.toString());
    }
    return brands.toList()..sort();
  }

  static Future<List<String>> getModels(String brand) async {
    await _loadDatabase();
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

  static Future<List<String>> getTrims({
    required String brand,
    required String model,
  }) async {
    await _loadDatabase();
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
              final trimList = mdl['trims'] ?? mdl['trim'];
              if (trimList is List) {
                for (final trim in trimList) {
                  final trimName = trim['trim'] ?? trim['name'] ?? trim;
                  if (trimName != null) trims.add(trimName.toString());
                }
              }
              break;
            }
          }
        }
        break;
      }
    }
    return trims.toList()..sort();
  }

  static Future<Map<String, dynamic>?> getVehicleInfo({
    required String brand,
    required String model,
  }) async {
    await _loadDatabase();
    final searchBrand = brand.toLowerCase().trim();
    final searchModel = model.toLowerCase().trim();

    for (final m in _allMakes) {
      final make = (m['make'] ?? m['name'] ?? '').toString().toLowerCase();
      if (make == searchBrand) {
        final modelList = m['models'];
        if (modelList is List) {
          for (final mdl in modelList) {
            final modelName =
                (mdl['model'] ?? mdl['name'] ?? '').toString().toLowerCase();
            if (modelName == searchModel ||
                modelName.contains(searchModel)) {
              return {
                'make': m['make'] ?? m['name'],
                'model': mdl['model'] ?? mdl['name'],
                'trims': mdl['trims'] ?? [],
              };
            }
          }
        }
      }
    }
    return null;
  }
}