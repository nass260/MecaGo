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
      'saved': 45.00,
      'status': 'Effectué',
      'icon': Icons.opacity_rounded,
      'color': AppColors.orange,
    },
    {
      'date': '02 Janvier 2026',
      'title': 'Filtre habitacle HEPA',
      'cost': 34.50,
      'saved': 20.00,
      'status': 'Effectué',
      'icon': Icons.filter_alt_rounded,
      'color': AppColors.success,
    },
    {
      'date': '20 Octobre 2025',
      'title': 'Plaquettes de frein',
      'cost': 120.00,
      'saved': 60.00,
      'status': 'Effectué',
      'icon': Icons.car_repair_rounded,
      'color': AppColors.danger,
    },
    {
      'date': '15 Août 2025',
      'title': 'Changement pneus',
      'cost': 320.00,
      'saved': 80.00,
      'status': 'Effectué',
      'icon': Icons.tire_repair_rounded,
      'color': Colors.purple,
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
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.orange),
                ),
              )
            : _vehicle != null
                ? _buildContent(_vehicle!)
                : _buildEmptyState(),
      ),
    );
  }

  Widget _buildContent(Vehicle vehicle) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // PHOTO PLEIN ÉCRAN
        SliverToBoxAdapter(
          child: Stack(
            children: [
              Container(
                height: 300,
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: AppGradients.navy,
                ),
                // ✅ Chemin corrigé : ressources/ au lieu de assets/
                child: vehicle.imageUrl.isNotEmpty
                    ? Image.asset(
                        vehicle.imageUrl
                            .replaceAll('assets/', 'ressources/'),
                        fit: BoxFit.cover,
                        alignment: Alignment.center,
                        errorBuilder: (_, __, ___) => const Center(
                          child: Icon(
                            Icons.directions_car_rounded,
                            color: Colors.white24,
                            size: 120,
                          ),
                        ),
                      )
                    : const Center(
                        child: Icon(
                          Icons.directions_car_rounded,
                          color: Colors.white24,
                          size: 120,
                        ),
                      ),
              ),
              // Dégradé sombre
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.4),
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              ),
              // Bouton retour
              Positioned(
                top: 16,
                left: 16,
                child: GestureDetector(
                  onTap: () => context.pop(),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_back_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ),
              // Bouton modifier
              Positioned(
                top: 16,
                right: 16,
                child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.edit_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
              // Badge santé
              Positioned(
                top: 74,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getHealthColor(vehicle.progress),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle_rounded,
                          color: Colors.white, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        vehicle.isAlert ? '⚠️ Alerte' : 'En bon état',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Infos en bas
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${vehicle.brand} ${vehicle.model}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${vehicle.plate} · ${vehicle.year}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // STATS RAPIDES
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.speed_rounded,
                      label: 'Kilométrage',
                      value: '${vehicle.mileage} km',
                      color: AppColors.orange,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.favorite_rounded,
                      label: 'Santé',
                      value: '${(vehicle.progress * 100).toInt()}%',
                      color: _getHealthColor(vehicle.progress),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.build_rounded,
                      label: 'Entretiens',
                      value: '${_maintenanceHistory.length}',
                      color: AppColors.navy,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // INFORMATIONS TECHNIQUES
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Informations techniques',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.navy,
                  ),
                ),
                const SizedBox(height: 12),
                _buildInfoTile(
                  icon: Icons.calendar_today_rounded,
                  label: 'Année',
                  value: '${vehicle.year}',
                  color: AppColors.orange,
                ),
                const SizedBox(height: 8),
                _buildInfoTile(
                  icon: Icons.local_gas_station_rounded,
                  label: 'Motorisation',
                  value: vehicle.fuelType.label,
                  color: AppColors.success,
                ),
                const SizedBox(height: 8),
                _buildInfoTile(
                  icon: Icons.settings_rounded,
                  label: 'Transmission',
                  value: vehicle.transmission.label,
                  color: Colors.purple,
                ),
                const SizedBox(height: 8),
                _buildInfoTile(
                  icon: Icons.directions_car_rounded,
                  label: 'Carrosserie',
                  value: 'Berline',
                  color: Colors.blue,
                ),
              ],
            ),
          ),
        ),

        // HISTORIQUE
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'Historique des entretiens',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.navy,
                  ),
                ),
                Text(
                  'Voir tout →',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.orange,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),

        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final item = _maintenanceHistory[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _buildMaintenanceCard(item),
                );
              },
              childCount: _maintenanceHistory.length,
            ),
          ),
        ),

        // BOUTONS
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
            child: Column(
              children: [
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
          ),
        ),
      ],
    );
  }

  // ============================================
  // WIDGETS
  // ============================================

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
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
        borderRadius: BorderRadius.circular(14),
        boxShadow: AppShadows.card,
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.navy,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaintenanceCard(Map<String, dynamic> item) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.card,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: (item['color'] as Color).withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              item['icon'] as IconData,
              color: item['color'] as Color,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['title'] as String,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.navy,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item['date'] as String,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${(item['cost'] as double).toStringAsFixed(2)} €',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.navy,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.successLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '−${(item['saved'] as double).toStringAsFixed(0)} €',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppColors.success,
                  ),
                ),
              ),
            ],
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

  Color _getHealthColor(double progress) {
    if (progress > 0.6) return AppColors.success;
    if (progress > 0.3) return AppColors.orange;
    return AppColors.danger;
  }
}