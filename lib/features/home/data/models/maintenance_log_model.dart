// lib/features/home/data/models/maintenance_log_model.dart
class MaintenanceLog {
  final String id;
  final String vehicleId;
  final String date;
  final int mileage;
  final String title;
  final String brand;
  final double cost;
  final double saved;
  final String icon;

  const MaintenanceLog({
    required this.id,
    required this.vehicleId,
    required this.date,
    required this.mileage,
    required this.title,
    required this.brand,
    required this.cost,
    required this.saved,
    required this.icon,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vehicle_id': vehicleId,
      'date': date,
      'mileage': mileage,
      'title': title,
      'brand': brand,
      'cost': cost,
      'saved': saved,
      'icon': icon,
    };
  }

  factory MaintenanceLog.fromMap(Map<String, dynamic> map) {
    return MaintenanceLog(
      id: map['id'] as String,
      vehicleId: map['vehicle_id'] as String,
      date: map['date'] as String,
      mileage: map['mileage'] as int,
      title: map['title'] as String,
      brand: map['brand'] as String,
      cost: (map['cost'] as num).toDouble(),
      saved: (map['saved'] as num).toDouble(),
      icon: map['icon'] as String,
    );
  }
}
