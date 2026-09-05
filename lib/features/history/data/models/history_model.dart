import 'dart:convert';

class HistoryModel {
  final int? id;
  final String title;
  final String date;
  final String mileage;
  final int savings; // Stocké sous forme d'entier pur (ex: 35) pour faciliter les additions de gains algorithmiques
  final int iconCodePoint; // Code numérique de l'icône Flutter pour le stockage en base

  const HistoryModel({
    this.id,
    required this.title,
    required this.date,
    required this.mileage,
    required this.savings,
    required this.iconCodePoint,
  });

  /// Convertit un objet HistoryModel en Map (format clé/valeur) pour l'insertion SQLite
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'date': date,
      'mileage': mileage,
      'savings': savings,
      'icon_code_point': iconCodePoint,
    };
  }

  /// Extrait les données brutes de la base de données SQLite pour recréer un objet HistoryModel typé
  factory HistoryModel.fromMap(Map<String, dynamic> map) {
    return HistoryModel(
      id: map['id'] as int?,
      title: map['title'] as String,
      date: map['date'] as String,
      mileage: map['mileage'] as String,
      savings: map['savings'] as int,
      iconCodePoint: map['icon_code_point'] as int,
    );
  }

  /// Utilitaires de conversion JSON pour les futures synchronisations Cloud (Firebase API)
  String toJson() => json.encode(toMap());
  factory HistoryModel.fromJson(String source) => HistoryModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
