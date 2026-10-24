// lib/features/home/data/models/vehicle_model.dart
import 'package:flutter/foundation.dart';

enum FuelType {
  essence('Essence', '⛽'),
  diesel('Diesel', '🛢️'),
  hybride('Hybride', '🔋⛽'),
  electrique('Électrique', '⚡'),
  gpl('GPL', '💨'),
  e85('E85', '🌱');

  final String label;
  final String icon;
  const FuelType(this.label, this.icon);

  static FuelType fromString(String? value) {
    final v = (value ?? '')
        .toLowerCase()
        .trim()
        .replaceAll('é', 'e')
        .replaceAll('è', 'e')
        .replaceAll('ê', 'e');

    if (v.contains('electri') ||
        v == 'ev' ||
        v.contains('standard range') ||
        v.contains('long range') ||
        v.contains('grande autonomie') ||
        v.contains('performance')) {
      return FuelType.electrique;
    }
    if (v.contains('hybrid')) return FuelType.hybride;
    if (v.contains('diesel') || v.contains('gazole')) return FuelType.diesel;
    if (v.contains('essence') || v.contains('petrol') || v.contains('gasoline')) return FuelType.essence;
    if (v == 'gpl') return FuelType.gpl;
    if (v == 'e85') return FuelType.e85;

    debugPrint('⚠️ Carburant inconnu : "$value" → Essence par défaut');
    return FuelType.essence;
  }
}

enum TransmissionType {
  manuelle('Manuelle', '🕹️'),
  automatique('Automatique', '⚙️'),
  semiAutomatique('Semi-auto', '🔀');

  final String label;
  final String icon;
  const TransmissionType(this.label, this.icon);

  static TransmissionType fromString(String value) {
    return TransmissionType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => TransmissionType.manuelle,
    );
  }
}

class Vehicle {
  final String id;
  final String brand;
  final String model;
  final String plate;
  final int year;
  final int mileage;
  final FuelType fuelType;
  final TransmissionType transmission;
  final double progress;
  final bool isAlert;
  final String imageUrl;
  
  // ✅ NOUVEAUX CHAMPS TECHNIQUES
  final String? power;
  final String? fiscalPower;
  final String? engineSize;
  final String? engineCode;
  final String? notes;

  const Vehicle({
    required this.id,
    required this.brand,
    required this.model,
    required this.plate,
    required this.year,
    required this.mileage,
    required this.fuelType,
    required this.transmission,
    required this.progress,
    required this.isAlert,
    required this.imageUrl,
    this.power,
    this.fiscalPower,
    this.engineSize,
    this.engineCode,
    this.notes,
  });

  bool get isElectric => fuelType == FuelType.electrique;
  bool get isHybrid => fuelType == FuelType.hybride;
  bool get isThermal =>
      fuelType == FuelType.essence ||
      fuelType == FuelType.diesel ||
      fuelType == FuelType.gpl ||
      fuelType == FuelType.e85;

  int get age => DateTime.now().year - year;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'brand': brand,
      'model': model,
      'plate': plate,
      'year': year,
      'mileage': mileage,
      'fuel_type': fuelType.name,
      'transmission': transmission.name,
      'progress': progress,
      'is_alert': isAlert ? 1 : 0,
      'image_url': imageUrl,
      'power': power,
      'fiscal_power': fiscalPower,
      'engine_size': engineSize,
      'engine_code': engineCode,
      'notes': notes,
    };
  }

  factory Vehicle.fromMap(Map<String, dynamic> map) {
    return Vehicle(
      id: map['id'] as String,
      brand: map['brand'] as String,
      model: map['model'] as String,
      plate: map['plate'] as String,
      year: map['year'] as int? ?? 2020,
      mileage: map['mileage'] as int? ?? 0,
      fuelType: FuelType.fromString(map['fuel_type'] as String? ?? 'essence'),
      transmission: TransmissionType.fromString(
        map['transmission'] as String? ?? 'manuelle',
      ),
      progress: (map['progress'] as num).toDouble(),
      isAlert: (map['is_alert'] as int) == 1,
      imageUrl: map['image_url'] as String? ?? '',
      power: map['power'] as String?,
      fiscalPower: map['fiscal_power'] as String?,
      engineSize: map['engine_size'] as String?,
      engineCode: map['engine_code'] as String?,
      notes: map['notes'] as String?,
    );
  }

  Vehicle copyWith({
    String? id,
    String? brand,
    String? model,
    String? plate,
    int? year,
    int? mileage,
    FuelType? fuelType,
    TransmissionType? transmission,
    double? progress,
    bool? isAlert,
    String? imageUrl,
    String? power,
    String? fiscalPower,
    String? engineSize,
    String? engineCode,
    String? notes,
  }) {
    return Vehicle(
      id: id ?? this.id,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      plate: plate ?? this.plate,
      year: year ?? this.year,
      mileage: mileage ?? this.mileage,
      fuelType: fuelType ?? this.fuelType,
      transmission: transmission ?? this.transmission,
      progress: progress ?? this.progress,
      isAlert: isAlert ?? this.isAlert,
      imageUrl: imageUrl ?? this.imageUrl,
      power: power ?? this.power,
      fiscalPower: fiscalPower ?? this.fiscalPower,
      engineSize: engineSize ?? this.engineSize,
      engineCode: engineCode ?? this.engineCode,
      notes: notes ?? this.notes,
    );
  }
}