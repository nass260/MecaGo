import 'dart:convert';

class VehicleModel {
  final int? id;
  final String brand;
  final String model;
  final String plate;
  final double progress;
  final bool isAlert;
  final String? imageUrl;

  const VehicleModel({
    this.id,
    required this.brand,
    required this.model,
    required this.plate,
    required this.progress,
    required this.isAlert,
    this.imageUrl,
  });

  /// Convertit un objet VehicleModel en Map (format clé/valeur) pour l'insertion SQLite
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'brand': brand,
      'model': model,
      'plate': plate,
      'progress': progress,
      'isAlert': isAlert ? 1 : 0, // SQLite ne stocke pas les booléens, on transforme en entier (0 ou 1)
      'image_url': imageUrl,
    };
  }

  /// Extrait les données brutes de la base de données SQLite pour recréer un objet VehicleModel typé
  factory VehicleModel.fromMap(Map<String, dynamic> map) {
    return VehicleModel(
      id: map['id'] as int?,
      brand: map['brand'] as String,
      model: map['model'] as String,
      plate: map['plate'] as String,
      progress: (map['progress'] as num).toDouble(),
      isAlert: (map['isAlert'] as int) == 1, // Restitution du booléen Flutter depuis le 0 ou 1 SQLite
      imageUrl: map['image_url'] as String?,
    );
  }

  /// Utilitaires de conversion JSON pour les futures synchronisations Cloud (Firebase API)
  String toJson() => json.encode(toMap());
  factory VehicleModel.fromJson(String source) => VehicleModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
