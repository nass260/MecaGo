// lib/features/home/data/models/vehicle_model.dart
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

  static FuelType fromString(String value) {
    return FuelType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => FuelType.essence,
    );
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
  });

  /// Véhicule électrique ?
  bool get isElectric => fuelType == FuelType.electrique;

  /// Véhicule hybride ?
  bool get isHybrid => fuelType == FuelType.hybride;

  /// Véhicule thermique ?
  bool get isThermal =>
      fuelType == FuelType.essence ||
      fuelType == FuelType.diesel ||
      fuelType == FuelType.gpl ||
      fuelType == FuelType.e85;

  /// Âge du véhicule
  int get age => DateTime.now().year - year;

  /// Conversion en Map pour SQLite
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
    };
  }

  /// Création depuis une Map SQLite
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
    );
  }
}
