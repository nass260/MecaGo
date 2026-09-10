// lib/features/home/data/models/vehicle_model.dart
class Vehicle {
  final String id;
  final String brand;
  final String model;
  final String plate;
  final double progress;
  final bool isAlert;
  final String imageUrl;

  const Vehicle({
    required this.id,
    required this.brand,
    required this.model,
    required this.plate,
    required this.progress,
    required this.isAlert,
    required this.imageUrl,
  });

  // Convertir un Vehicle en Map pour SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'brand': brand,
      'model': model,
      'plate': plate,
      'progress': progress,
      'is_alert': isAlert ? 1 : 0,
      'image_url': imageUrl,
    };
  }

  // Créer un Vehicle depuis une Map SQLite
  factory Vehicle.fromMap(Map<String, dynamic> map) {
    return Vehicle(
      id: map['id'] as String,
      brand: map['brand'] as String,
      model: map['model'] as String,
      plate: map['plate'] as String,
      progress: (map['progress'] as num).toDouble(),
      isAlert: (map['is_alert'] as int) == 1,
      imageUrl: map['image_url'] as String? ?? '',
    );
  }

  // Créer une copie modifiée
  Vehicle copyWith({
    String? id,
    String? brand,
    String? model,
    String? plate,
    double? progress,
    bool? isAlert,
    String? imageUrl,
  }) {
    return Vehicle(
      id: id ?? this.id,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      plate: plate ?? this.plate,
      progress: progress ?? this.progress,
      isAlert: isAlert ?? this.isAlert,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
