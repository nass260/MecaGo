// lib/features/home/data/models/reminder_model.dart
class Reminder {
  final String id;
  final String vehicleId;
  final String title;
  final String description;
  final String dueDate;
  final int remainingKm;
  final String priority;
  final String icon;
  final bool isDone;

  const Reminder({
    required this.id,
    required this.vehicleId,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.remainingKm,
    required this.priority,
    required this.icon,
    required this.isDone,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vehicle_id': vehicleId,
      'title': title,
      'description': description,
      'due_date': dueDate,
      'remaining_km': remainingKm,
      'priority': priority,
      'icon': icon,
      'is_done': isDone ? 1 : 0,
    };
  }

  factory Reminder.fromMap(Map<String, dynamic> map) {
    return Reminder(
      id: map['id'] as String,
      vehicleId: map['vehicle_id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      dueDate: map['due_date'] as String,
      remainingKm: map['remaining_km'] as int,
      priority: map['priority'] as String,
      icon: map['icon'] as String,
      isDone: (map['is_done'] as int) == 1,
    );
  }

  Reminder copyWith({
    String? id,
    String? vehicleId,
    String? title,
    String? description,
    String? dueDate,
    int? remainingKm,
    String? priority,
    String? icon,
    bool? isDone,
  }) {
    return Reminder(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      remainingKm: remainingKm ?? this.remainingKm,
      priority: priority ?? this.priority,
      icon: icon ?? this.icon,
      isDone: isDone ?? this.isDone,
    );
  }
}
