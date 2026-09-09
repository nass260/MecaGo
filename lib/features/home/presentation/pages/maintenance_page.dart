// lib/features/home/presentation/pages/maintenance_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/premium_card.dart';
import '../../../../core/widgets/premium_button.dart';
import '../../data/models/vehicle_model.dart';
import '../managers/home_notifier.dart';

class MaintenancePage extends StatefulWidget {
  const MaintenancePage({super.key});

  @override
  State<MaintenancePage> createState() => _MaintenancePageState();
}

class _MaintenancePageState extends State<MaintenancePage> {
  final HomeNotifier _notifier = HomeNotifier();
  Vehicle? _selectedVehicle;
  String? _selectedMaintenanceType;
  bool _isLoading = false;
  double _estimatedCost = 0.0;

  final List<Map<String, dynamic>> _maintenanceTypes = [
    {
      'id': 'oil_change',
      'title': 'Vidange moteur',
      'icon': Icons.opacity_rounded,
      'cost': 89.00,
      'description': 'Huile moteur + filtre',
      'urgency': 'Régulier',
    },
    {
      'id': 'brake_pads',
      'title': 'Plaquettes de frein',
      'icon': Icons.car_repair_rounded,
      'cost': 120.00,
      'description': 'Jeu de plaquettes avant',
      'urgency': 'Urgent',
    },
    {
      'id': 'hepa_filter',
      'title': 'Filtre habitacle HEPA',
      'icon': Icons.filter_alt_rounded,
      'cost': 34.50,
      'description': 'Filtre à air habitacle',
      'urgency': 'À prévoir',
    },
    {
      'id': 'tires',
      'title': 'Changement pneus',
      'icon': Icons.grass_rounded,
      'cost': 320.00,
      'description': 'Jeu de 4 pneus',
      'urgency': 'Saisonnier',
    },
    {
      'id': 'brake_fluid',
      'title': 'Vidange liquide frein',
      'icon': Icons.opacity_rounded,
      'cost': 65.00,
      'description': 'Liquide DOT 4',
      'urgency': 'Régulier',
    },
    {
      'id': 'coolant',
      'title': 'Liquide de refroidissement',
      'icon': Icons.ac_unit_rounded,
      'cost': 55.00,
      'description': 'Liquide moteur',
      'urgency': 'À prévoir',
    },
  ];

  @override
  void initState() {
    super.initState();
    _notifier.loadDashboardData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.navy),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Démarrer un entretien',
          style: TextStyle(
            color: AppColors.navy,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: AnimatedBuilder(
        animation: _notifier,
        builder: (context, _) {
          if (_notifier.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.orange),
              ),
            );
          }

          final vehicles = _notifier.vehicles;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ============================================
                // 1. SÉLECTION DU VÉHICULE
                // ============================================
                const Text(
                  'Choisissez votre véhicule',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),

                if (vehicles.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border.withOpacity(0.4)),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.add_circle_outline_rounded,
                          size: 48,
                          color: AppColors.orange,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Aucun véhicule enregistré',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.navy,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Ajoutez un véhicule dans le garage',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        PremiumButton(
                          text: 'Aller au garage',
                          onPressed: () => context.go('/garage'),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border.withOpacity(0.4)),
                    ),
                    child: Column(
                      children: vehicles.map((vehicle) {
                        final isSelected = _selectedVehicle?.id == vehicle.id;
                        return InkWell(
                          onTap: () {
                            setState(() {
                              _selectedVehicle = vehicle;
                              _selectedMaintenanceType = null;
                              _estimatedCost = 0.0;
                            });
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.orange.withOpacity(0.08)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.orange
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: AppColors.border.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.directions_car_rounded,
                                    color: isSelected
                                        ? AppColors.orange
                                        : AppColors.textSecondary,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${vehicle.brand} ${vehicle.model}',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: isSelected
                                              ? AppColors.orange
                                              : AppColors.navy,
                                        ),
                                      ),
                                      Text(
                                        vehicle.plate,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isSelected)
                                  const Icon(
                                    Icons.check_circle_rounded,
                                    color: AppColors.orange,
                                    size: 24,
                                  ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                const SizedBox(height: 24),

                // ============================================
                // 2. SÉLECTION DU TYPE D'ENTRETIEN
                // ============================================
                if (_selectedVehicle != null) ...[
                  const Text(
                    'Type d\'entretien',
                    style: TextStyle(
                      color: AppColors.navy,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),

                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    children: _maintenanceTypes.map((type) {
                      final isSelected =
                          _selectedMaintenanceType == type['id'];
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedMaintenanceType = type['id'];
                            _estimatedCost = type['cost'];
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.orange.withOpacity(0.08)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.orange
                                  : AppColors.border.withOpacity(0.4),
                              width: isSelected ? 2 : 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.02),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                type['icon'],
                                color: isSelected
                                    ? AppColors.orange
                                    : AppColors.textSecondary,
                                size: 28,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                type['title'],
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: isSelected
                                      ? AppColors.orange
                                      : AppColors.navy,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                type['description'],
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.textSecondary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: type['urgency'] == 'Urgent'
                                      ? Colors.red.withOpacity(0.1)
                                      : AppColors.success.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  type['urgency'],
                                  style: TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.w600,
                                    color: type['urgency'] == 'Urgent'
                                        ? Colors.red
                                        : AppColors.success,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${type['cost'].toStringAsFixed(2)} €',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: isSelected
                                      ? AppColors.orange
                                      : AppColors.navy,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // ============================================
                  // 3. RÉCAPITULATIF ET BOUTON
                  // ============================================
                  if (_selectedMaintenanceType != null) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.orange, Color(0xFFFF8C00)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.orange.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Récapitulatif',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _selectedVehicle != null
                                        ? '${_selectedVehicle!.brand} ${_selectedVehicle!.model}'
                                        : 'Véhicule',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    _maintenanceTypes.firstWhere(
                                      (t) => t['id'] == _selectedMaintenanceType,
                                    )['title'],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text(
                                    'Estimation',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    '${_estimatedCost.toStringAsFixed(2)} €',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          PremiumButton(
                            text: '🛒 Commander sur AUTODOC',
                            onPressed: () => _startMaintenance(),
                          ),
                          const SizedBox(height: 8),
                          Center(
                            child: Text(
                              'Commission reversée à MecaGo : ${(_estimatedCost * 0.05).toStringAsFixed(2)} €',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  void _startMaintenance() {
    if (_selectedVehicle == null || _selectedMaintenanceType == null) return;

    final type = _maintenanceTypes.firstWhere(
      (t) => t['id'] == _selectedMaintenanceType,
    );

    // Simuler l'enregistrement dans l'historique
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('✅ Entretien lancé !'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${_selectedVehicle!.brand} ${_selectedVehicle!.model}',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(type['title']),
            const SizedBox(height: 8),
            Text(
              'Coût estimé : ${_estimatedCost.toStringAsFixed(2)} €',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.orange,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Redirection vers AUTODOC...',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.pop();
            },
            style: TextButton.styleFrom(
              backgroundColor: AppColors.orange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'OK',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _notifier.dispose();
    super.dispose();
  }
}
