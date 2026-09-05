import 'dart:convert';

class ReminderModel {
  final int? id;
  final String title;
  final String subtitle;
  final int remaining; // Pourcentage restant (ex: 82) pour animer la jauge
  final String mileage; // Texte kilométrique (ex: "58 000 / 72 000 km")
  final int colorValue; // Code ARGB de la couleur pour le stockage (Vert, Orange, Rouge)

  const ReminderModel({
    this.id,
    required this.title,
    required this.subtitle,
    required this.remaining,
    required this.mileage,
    required this.colorValue,
  });

  /// Convertit un objet ReminderModel en Map pour l'insertion SQLite
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'brand': title,
      'subtitle': subtitle,
      'remaining': remaining,
      'mileage': mileage,
      'color_value': colorValue,
    };
  }

  /// Extrait les données brutes de la base de données SQLite pour recréer un objet ReminderModel typé
  factory ReminderModel.fromMap(Map<String, dynamic> map) {
    return ReminderModel(
      id: map['id'] as int?,
      title: map['title'] as String,
      subtitle: map['subtitle'] as String,
      remaining: map['remaining'] as int,
      mileage: map['mileage'] as String,
      colorValue: map['color_value'] as int,
    );
  }

  /// Utilitaires de conversion JSON pour les futures synchronisations Cloud
  String toJson() => json.encode(toMap());
  factory ReminderModel.fromJson(String source) => ReminderModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
