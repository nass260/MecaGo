// lib/core/services/database_service.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../features/home/data/models/vehicle_model.dart';
import '../../features/home/data/models/maintenance_log_model.dart';
import '../../features/home/data/models/reminder_model.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = await getDatabasesPath();
    final databasePath = join(path, 'mecago.db');

    return await openDatabase(
      databasePath,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Table des véhicules
    await db.execute('''
      CREATE TABLE vehicles (
        id TEXT PRIMARY KEY,
        brand TEXT NOT NULL,
        model TEXT NOT NULL,
        plate TEXT NOT NULL,
        progress REAL NOT NULL,
        is_alert INTEGER NOT NULL,
        image_url TEXT
      )
    ''');

    // Table des entretiens
    await db.execute('''
      CREATE TABLE maintenance_logs (
        id TEXT PRIMARY KEY,
        vehicle_id TEXT NOT NULL,
        date TEXT NOT NULL,
        mileage INTEGER NOT NULL,
        title TEXT NOT NULL,
        brand TEXT NOT NULL,
        cost REAL NOT NULL,
        saved REAL NOT NULL,
        icon TEXT NOT NULL,
        FOREIGN KEY (vehicle_id) REFERENCES vehicles (id)
      )
    ''');

    // Table des rappels
    await db.execute('''
      CREATE TABLE reminders (
        id TEXT PRIMARY KEY,
        vehicle_id TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        due_date TEXT NOT NULL,
        remaining_km INTEGER NOT NULL,
        priority TEXT NOT NULL,
        icon TEXT NOT NULL,
        is_done INTEGER DEFAULT 0,
        FOREIGN KEY (vehicle_id) REFERENCES vehicles (id)
      )
    ''');

    // Insertion des données initiales
    await _insertInitialData(db);
  }

  Future<void> _insertInitialData(Database db) async {
    // Véhicules
    await db.insert('vehicles', {
      'id': '1',
      'brand': 'Tesla',
      'model': 'Model 3',
      'plate': 'AB-123-CD',
      'progress': 0.85,
      'is_alert': 0,
      'image_url': '',
    });

    await db.insert('vehicles', {
      'id': '2',
      'brand': 'Renault',
      'model': 'Clio 5',
      'plate': 'EF-456-GH',
      'progress': 0.45,
      'is_alert': 1,
      'image_url': '',
    });

    // Entretiens
    await db.insert('maintenance_logs', {
      'id': '1',
      'vehicle_id': '1',
      'date': '2026-03-15',
      'mileage': 15000,
      'title': 'Vidange moteur',
      'brand': 'Tesla',
      'cost': 89.00,
      'saved': 45.00,
      'icon': 'opacity_rounded',
    });

    await db.insert('maintenance_logs', {
      'id': '2',
      'vehicle_id': '1',
      'date': '2026-01-02',
      'mileage': 12000,
      'title': 'Filtre habitacle HEPA',
      'brand': 'Tesla',
      'cost': 34.50,
      'saved': 20.00,
      'icon': 'filter_alt_rounded',
    });

    // Rappels
    await db.insert('reminders', {
      'id': '1',
      'vehicle_id': '1',
      'title': 'Vidange moteur',
      'description': 'Huile moteur + filtre',
      'due_date': '2026-04-15',
      'remaining_km': 1200,
      'priority': 'Élevée',
      'icon': 'opacity_rounded',
      'is_done': 0,
    });

    await db.insert('reminders', {
      'id': '2',
      'vehicle_id': '1',
      'title': 'Filtre habitacle HEPA',
      'description': 'Remplacement recommandé',
      'due_date': '2026-05-30',
      'remaining_km': 8500,
      'priority': 'Moyenne',
      'icon': 'filter_alt_rounded',
      'is_done': 0,
    });
  }

  // ============================================
  // MÉTHODES VÉHICULES
  // ============================================

  Future<List<Vehicle>> getVehicles() async {
    final db = await database;
    final result = await db.query('vehicles');
    return result.map((map) => Vehicle.fromMap(map)).toList();
  }

  Future<Vehicle?> getVehicle(String id) async {
    final db = await database;
    final result = await db.query(
      'vehicles',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isEmpty) return null;
    return Vehicle.fromMap(result.first);
  }

  Future<void> insertVehicle(Vehicle vehicle) async {
    final db = await database;
    await db.insert('vehicles', vehicle.toMap());
  }

  Future<void> updateVehicle(Vehicle vehicle) async {
    final db = await database;
    await db.update(
      'vehicles',
      vehicle.toMap(),
      where: 'id = ?',
      whereArgs: [vehicle.id],
    );
  }

  Future<void> deleteVehicle(String id) async {
    final db = await database;
    await db.delete('vehicles', where: 'id = ?', whereArgs: [id]);
  }

  // ============================================
  // MÉTHODES ENTRETIENS
  // ============================================

  Future<List<MaintenanceLog>> getMaintenanceLogs(String vehicleId) async {
    final db = await database;
    final result = await db.query(
      'maintenance_logs',
      where: 'vehicle_id = ?',
      whereArgs: [vehicleId],
      orderBy: 'date DESC',
    );
    return result.map((map) => MaintenanceLog.fromMap(map)).toList();
  }

  Future<void> insertMaintenanceLog(MaintenanceLog log) async {
    final db = await database;
    await db.insert('maintenance_logs', log.toMap());
  }

  // ============================================
  // MÉTHODES RAPPELS
  // ============================================

  Future<List<Reminder>> getReminders({String? vehicleId}) async {
    final db = await database;
    final List<String> where = [];
    final List<dynamic> whereArgs = [];

    if (vehicleId != null) {
      where.add('vehicle_id = ?');
      whereArgs.add(vehicleId);
    }

    where.add('is_done = 0');

    final result = await db.query(
      'reminders',
      where: where.isNotEmpty ? where.join(' AND ') : null,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: 'due_date ASC',
    );

    return result.map((map) => Reminder.fromMap(map)).toList();
  }

  Future<void> markReminderDone(String id) async {
    final db = await database;
    await db.update(
      'reminders',
      {'is_done': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
