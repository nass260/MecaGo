// lib/core/services/mvdb_service.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MvdbService {
  static List<Map<String, dynamic>> _allMakes = [];
  static bool _isLoaded = false;

  /// Charge la base MVDB
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

  /// ✅ BASE DE MODÈLES RÉCENTS (ajoutés manuellement)
  static final Map<String, List<String>> _recentModels = {
    'tesla': [
      'Model 3',
      'Model 3 Highland',
      'Model Y',
      'Model S',
      'Model X',
      'Cybertruck',
    ],
    'renault': [
      'Clio V',
      'Captur II',
      'Megane IV',
      'Megane E-Tech',
      'Arkana',
      'Austral',
      'Espace VI',
      'Scenic E-Tech',
      'Zoe',
      'Twingo III',
      'Kangoo III',
    ],
    'peugeot': [
      '208 II',
      '2008 II',
      '308 III',
      '3008 II',
      '5008 II',
      '508 II',
      'Rifter',
      'Partner',
      'Boxer',
      'Traveller',
    ],
    'citroen': [
      'C3 III',
      'C3 Aircross',
      'C4 III',
      'C5 Aircross',
      'C5 X',
      'Berlingo III',
      'Jumpy',
      'Jumper',
    ],
    'dacia': [
      'Sandero III',
      'Duster II',
      'Duster III',
      'Logan III',
      'Jogger',
      'Spring',
    ],
    'toyota': [
      'Yaris IV',
      'Yaris Cross',
      'Corolla XII',
      'C-HR',
      'RAV4 V',
      'Prius V',
      'Aygo X',
      'bZ4X',
      'Hilux',
    ],
    'volkswagen': [
      'Golf VIII',
      'Polo VI',
      'T-Roc',
      'T-Cross',
      'Tiguan II',
      'Passat VIII',
      'ID.3',
      'ID.4',
      'ID.5',
    ],
    'bmw': [
      'Série 1 F40',
      'Série 2',
      'Série 3 G20',
      'Série 4',
      'Série 5 G30',
      'X1 F48',
      'X2',
      'X3 G01',
      'X4',
      'X5 G05',
      'X6',
      'X7',
      'i3',
      'i4',
      'iX',
      'iX3',
    ],
    'mercedes': [
      'Classe A W177',
      'Classe B W247',
      'Classe C W206',
      'Classe E W213',
      'Classe S W223',
      'CLA',
      'CLS',
      'GLA',
      'GLB',
      'GLC',
      'GLE',
      'GLS',
      'EQA',
      'EQB',
      'EQC',
      'EQE',
      'EQS',
    ],
    'audi': [
      'A1 GB',
      'A3 8Y',
      'A4 B9',
      'A5',
      'A6 C8',
      'A7',
      'A8 D5',
      'Q2',
      'Q3 F3',
      'Q4 e-tron',
      'Q5 FY',
      'Q7 4M',
      'Q8',
      'e-tron',
    ],
    'ford': [
      'Fiesta VII',
      'Focus IV',
      'Puma',
      'Kuga III',
      'Mustang Mach-E',
      'Explorer EV',
      'Transit',
      'Ranger',
    ],
    'opel': [
      'Corsa VI',
      'Astra L',
      'Mokka B',
      'Grandland X',
      'Crossland X',
      'Insignia B',
      'Vivaro',
      'Movano',
    ],
    'fiat': [
      '500 III',
      '500X',
      'Panda III',
      'Tipo II',
      'Ducato',
      '500e',
    ],
    'seat': [
      'Ibiza VI',
      'Leon IV',
      'Arona',
      'Ateca',
      'Tarraco',
    ],
    'skoda': [
      'Fabia IV',
      'Octavia IV',
      'Superb III',
      'Kamiq',
      'Karoq',
      'Kodiaq',
      'Scala',
      'Enyaq',
    ],
    'nissan': [
      'Micra V',
      'Juke II',
      'Qashqai III',
      'X-Trail IV',
      'Leaf II',
      'Ariya',
    ],
    'hyundai': [
      'i10 III',
      'i20 III',
      'i30 III',
      'Kona II',
      'Tucson IV',
      'Santa Fe',
      'Ioniq 5',
      'Ioniq 6',
    ],
    'kia': [
      'Picanto III',
      'Rio IV',
      'Ceed III',
      'Stonic',
      'Sportage V',
      'Sorento IV',
      'Niro',
      'EV6',
      'EV9',
    ],
    'volvo': [
      'XC40',
      'XC60',
      'XC90',
      'S60',
      'S90',
      'V60',
      'V90',
      'EX30',
      'EX90',
    ],
    'mini': [
      'Cooper III',
      'Countryman II',
      'Clubman',
      'Cabrio',
      'Electric',
    ],
    'suzuki': [
      'Swift VI',
      'Vitara',
      'S-Cross',
      'Jimny',
      'Ignis',
      'Across',
    ],
    'honda': [
      'Civic XI',
      'Jazz IV',
      'CR-V VI',
      'HR-V III',
      'e:Ny1',
    ],
    'mazda': [
      'Mazda2 III',
      'Mazda3 IV',
      'Mazda6 III',
      'CX-3',
      'CX-30',
      'CX-5',
      'CX-60',
      'MX-5',
    ],
    'jeep': [
      'Renegade',
      'Compass',
      'Cherokee',
      'Grand Cherokee',
      'Wrangler',
      'Avenger',
    ],
    'mg': [
      'MG4',
      'MG5',
      'MG ZS',
      'MG HS',
      'Marvel R',
      'Cyberster',
    ],
    'byd': [
      'Atto 3',
      'Dolphin',
      'Seal',
      'Han',
      'Tang',
      'Seal U',
    ],
    'polestar': [
      'Polestar 1',
      'Polestar 2',
      'Polestar 3',
      'Polestar 4',
    ],
    'cupra': [
      'Formentor',
      'Leon',
      'Born',
      'Ateca',
      'Tavascan',
      'Terramar',
    ],
    'ds': [
      'DS3',
      'DS3 Crossback',
      'DS4',
      'DS4 II',
      'DS5',
      'DS7 Crossback',
      'DS9',
    ],
    'alpine': [
      'A110',
      'A110 S',
      'A110 R',
      'A290',
    ],
  };

  /// Récupère toutes les marques
  static Future<List<String>> getBrands() async {
    await _load();
    final brands = <String>{};

    for (final m in _allMakes) {
      final make = m['make'] ?? m['name'];
      if (make != null) brands.add(make.toString());
    }

    // Ajouter les marques récentes
    for (final brand in _recentModels.keys) {
      brands.add(brand[0].toUpperCase() + brand.substring(1));
    }

    return brands.toList()..sort();
  }

  /// Récupère les modèles d'une marque
  static Future<List<String>> getModels(String brand) async {
    await _load();
    final models = <String>{};
    final searchBrand = brand.toLowerCase();

    // 1. Ajouter les modèles récents
    if (_recentModels.containsKey(searchBrand)) {
      models.addAll(_recentModels[searchBrand]!);
    }

    // 2. Ajouter les modèles de la base
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

  /// Récupère les motorisations
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

  /// Récupère les années
  static Future<List<int>> getYears(String brand, String model) async {
    await _load();
    return List.generate(22, (i) => 2005 + i);
  }

  /// Récupère les détails d'un véhicule
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