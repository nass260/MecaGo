import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/premium_card.dart';
import '../../../../core/services/notification_service.dart'; // Importation du service push

class GaragePage extends StatefulWidget {
  const GaragePage({super.key});

  @override
  State<GaragePage> createState() => _GaragePageState();
}

class _GaragePageState extends State<GaragePage> {
  final NotificationService _notificationService = const NotificationService();

  // Simulation des données de parc automobile lues depuis SQLite (Sprint 3)
  final List<Map<String, dynamic>> _mockVehicles = [
    {
      'brand': 'Tesla',
      'model': 'Model 3',
      'plate': 'AB-123-CD',
      'progress': 0.76, // 76% de santé générale
      'isAlert': true,
      'component': 'Filtre habitacle HEPA',
    },
    {
      'brand': 'Renault',
      'model': 'Clio 5',
      'plate': 'EE-987-ZZ',
      'progress': 0.95, // 95% de santé générale
      'isAlert': false,
      'component': 'Bougies d’allumage',
    }
  ];

  @override
  void initState() {
    super.initState();
    _triggerAutomatedWearAnalysis();
  }

  /// Déclenche l'analyse en tâche de fond de l'état d'usure de chaque véhicule
  Future<void> _triggerAutomatedWearAnalysis() async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Boucle d'analyse prédictive sur l'intégralité du parc automobile
    for (var vehicle in _mockVehicles) {
      await _notificationService.scheduleMaintenanceAlert(
        vehicleName: '${vehicle['brand']} ${vehicle['model']}',
        componentName: vehicle['component'] as String,
        currentProgress: vehicle['progress'] as double,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Mon Garage',
          style: TextStyle(color: AppColors.navy, fontWeight: FontWeight.w900, fontSize: 20, letterSpacing: -0.5),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        itemCount: _mockVehicles.length,
        itemBuilder: (context, index) {
          final vehicle = _mockVehicles[index];
          final bool isAlert = vehicle['isAlert'] as bool;
          final double progress = vehicle['progress'] as double;

          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: PremiumCard(
              padding: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Bandeau supérieur texturé (Style Apple)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                      gradient: LinearGradient(
                        colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${vehicle['brand']} ${vehicle['model']}',
                              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: isAlert ? const Color(0xFFFFF7ED) : const Color(0xFFF0FDF4),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                isAlert ? 'Entretien requis' : 'À jour 🎉',
                                style: TextStyle(
                                  color: isAlert ? AppColors.orange : AppColors.success,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        // Plaque SIV avec l'Eurobande bleue certifiée conforme
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.navy, width: 1),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 14,
                                height: 24,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF003399),
                                  borderRadius: BorderRadius.only(topLeft: Radius.circular(5), bottomLeft: Radius.circular(5)),
                                ),
                                child: const Center(
                                  child: Text('F', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                vehicle['plate'] as String,
                                style: const TextStyle(
                                  color: AppColors.navy,
                                  fontSize: 14,
                                  fontWeight: FontWeight.extrabold,
                                  letterSpacing: 1.5,
                                  fontFamily: 'monospace',
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Section du bas dédiée aux jauges de santé SQLite
                  Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Santé générale du véhicule',
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '${(progress * 100).round()}%',
                              style: const TextStyle(color: AppColors.navy, fontSize: 18, fontWeight: FontWeight.w900),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 8,
                            backgroundColor: AppColors.border,
                            valueColor: AlwaysStoppedAnimation<Color>(isAlert ? AppColors.orange : AppColors.success),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
