// lib/features/home/presentation/pages/vehicle_details_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/premium_button.dart';
import '../../data/models/vehicle_model.dart';
import '../managers/home_notifier.dart';

class VehicleDetailsPage extends StatefulWidget {
  final String vehicleId;
  const VehicleDetailsPage({super.key, required this.vehicleId});

  @override
  State<VehicleDetailsPage> createState() => _VehicleDetailsPageState();
}

class _VehicleDetailsPageState extends State<VehicleDetailsPage> {
  final HomeNotifier _notifier = HomeNotifier();
  Vehicle? _vehicle;
  bool _isLoading = true;

  final List<Map<String, dynamic>> _maintenanceHistory = [
    {
      'date': '15 Mars 2026',
      'title': 'Vidange moteur',
      'cost': 89.00,
      'status': 'Effectué',
      'icon': Icons.opacity_rounded,
    },
    {
      'date': '02 Janvier 2026',
      'title': 'Filtre habitacle HEPA',
      'cost': 34.50,
      'status': 'Effectué',
      'icon': Icons.filter_alt_rounded,
    },
    {
      'date': '20 Octobre 2025',
      'title': 'Plaquettes de frein',
      'cost': 120.00,
      'status': 'Effectué',
      'icon': Icons.car_repair_rounded,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadVehicleData();
  }

  @override
  void dispose() {
    _notifier.dispose();
    super.dispose();
  }

  Future<void> _loadVehicleData() async {
    setState(() => _isLoading = true);
    await _notifier.loadDashboardData();

    try {
      _vehicle = _notifier.vehicles.firstWhere(
        (v) => v.id == widget.vehicleId,
      );
    } catch (e) {
      _vehicle = null;
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.navy),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Détails du véhicule',
          style: TextStyle(
            color: AppColors.navy,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.orange),
              ),
            )
          : _vehicle != null
              ? _buildContent(_vehicle!)
              : _buildEmptyState(),
    );
  }

  Widget _buildContent(Vehicle vehicle) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ============================================
          // 1. CARTE VÉHICULE AVEC IMAGE
          // ============================================
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                // IMAGE DU VÉHICULE
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  child: Stack(
                    children: [
                      // Image de fond
                      Container(
                        height: 200,
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: vehicle.imageUrl.isNotEmpty
                            ? Image.network(
                                vehicle.imageUrl,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: 200,
                                errorBuilder: (context, error, stackTrace) {
                                  return Center(
                                    child: Icon(
                                      Icons.directions_car_rounded,
                                      color: Colors.white.withOpacity(0.3),
                                      size: 64,
                                    ),
                                  );
                                },
                              )
                            : Center(
                                child: Icon(
                                  Icons.directions_car_rounded,
                                  color: Colors.white.withOpacity(0.3),
                                  size: 64,
                                ),
                              ),
                      ),
                      // Overlay gradient en bas
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 100,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.7),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Badge motorisation
                      Positioned(
                        top: 16,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                vehicle.fuelType.icon,
                                style: const TextStyle(fontSize: 12),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                vehicle.fuelType.label,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Badge santé
                      Positioned(
                        top: 16,
                        left: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: (vehicle.isAlert
                                    ? Colors.red
                                    : AppColors.success)
                                .withOpacity(0.9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            vehicle.isAlert ? '⚠️ Alerte' : '✅ En forme',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                      // Infos
                      Positioned(
                        bottom: 16,
                        left: 16,
                        right: 16,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${vehicle.brand} ${vehicle.model}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${vehicle.plate} · ${vehicle.year} · ${vehicle.mileage} km',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Barre de santé
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Santé générale',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${(vehicle.progress * 100).toInt()}%',
                            style: TextStyle(
                              color: vehicle.progress > 0.6
                                  ? AppColors.success
                                  : vehicle.progress > 0.3
                                      ? AppColors.orange
                                      : Colors.red,
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: vehicle.progress,
                          backgroundColor: AppColors.border.withOpacity(0.3),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            vehicle.progress > 0.6
                                ? AppColors.success
                                : vehicle.progress > 0.3
                                    ? AppColors.orange
                                    : Colors.red,
                          ),
                          minHeight: 8,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ============================================
          // 2. INFORMATIONS TECHNIQUES
          // ============================================
          const Text(
            'Informations techniques',
            style: TextStyle(
              color: AppColors.navy,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildInfoTile(
                  icon: Icons.calendar_today_rounded,
                  label: 'Année',
                  value: vehicle.year.toString(),
                  color: AppColors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInfoTile(
                  icon: Icons.speed_rounded,
                  label: 'Kilométrage',
                  value: '${vehicle.mileage} km',
                  color: AppColors.navy,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildInfoTile(
                  icon: Icons.local_gas_station_rounded,
                  label: 'Motorisation',
                  value: vehicle.fuelType.label,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInfoTile(
                  icon: Icons.settings_rounded,
                  label: 'Transmission',
                  value: vehicle.transmission.label,
                  color: Colors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ============================================
          // 3. ENTRETIENS RÉCENTS
          // ============================================
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Entretiens récents',
                style: TextStyle(
                  color: AppColors.navy,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                'Voir tout →',
                style: TextStyle(
                  color: AppColors.orange,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._maintenanceHistory.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _buildMaintenanceItem(item),
              )),
          const SizedBox(height: 24),

          // ============================================
          // 4. BOUTONS D'ACTION
          // ============================================
          PremiumButton(
            text: '🔧 Démarrer un entretien',
            onPressed: () => context.push('/maintenance'),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => context.push('/scanner'),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.border),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              minimumSize: const Size(double.infinity, 56),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(
                  Icons.qr_code_scanner_rounded,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                SizedBox(width: 10),
                Text(
                  'Scanner une pièce',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.navy,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaintenanceItem(Map<String, dynamic> item) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(item['icon'], color: AppColors.orange, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['title'],
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.navy,
                  ),
                ),
                Text(
                  item['date'],
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${item['cost'].toStringAsFixed(2)} €',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.navy,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.directions_car_rounded,
            size: 80,
            color: AppColors.border,
          ),
          const SizedBox(height: 16),
          const Text(
            'Véhicule introuvable',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.navy,
            ),
          ),
          const SizedBox(height: 24),
          PremiumButton(
            text: 'Retour au garage',
            onPressed: () => context.go('/garage'),
          ),
        ],
      ),
    );
  }
}