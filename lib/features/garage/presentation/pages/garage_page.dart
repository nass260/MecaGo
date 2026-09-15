// lib/features/garage/presentation/pages/garage_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/premium_button.dart';
import '../../../home/data/models/vehicle_model.dart';
import '../../../home/presentation/managers/home_notifier.dart';

class GaragePage extends StatefulWidget {
  const GaragePage({super.key});

  @override
  State<GaragePage> createState() => _GaragePageState();
}

class _GaragePageState extends State<GaragePage> {
  final HomeNotifier _notifier = HomeNotifier();

  @override
  void initState() {
    super.initState();
    _notifier.loadDashboardData();
  }

  @override
  void dispose() {
    _notifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _notifier,
          builder: (context, _) {
            if (_notifier.isLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.orange),
                ),
              );
            }

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // EN-TÊTE
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Mon Garage',
                              style: TextStyle(
                                color: AppColors.navy,
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.6,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${_notifier.vehicles.length} véhicule${_notifier.vehicles.length > 1 ? 's' : ''} enregistré${_notifier.vehicles.length > 1 ? 's' : ''}',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () => context.push('/add-vehicle'),
                          child: Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AppColors.orange, Color(0xFFFF8C00)],
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.orange.withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.add_rounded,
                              color: Colors.white,
                              size: 26,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // STATISTIQUES
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: _buildStats(),
                  ),
                ),

                // LISTE
                if (_notifier.vehicles.isEmpty)
                  SliverFillRemaining(
                    child: _buildEmptyState(context),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final vehicle = _notifier.vehicles[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildVehicleCard(context, vehicle),
                          );
                        },
                        childCount: _notifier.vehicles.length,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildStats() {
    final totalVehicles = _notifier.vehicles.length;
    final alertCount = _notifier.vehicles.where((v) => v.isAlert).length;
    final avgHealth = totalVehicles > 0
        ? _notifier.vehicles.fold<double>(0, (sum, v) => sum + v.progress) /
            totalVehicles
        : 0.0;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.directions_car_rounded,
            label: 'Véhicules',
            value: '$totalVehicles',
            color: AppColors.orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.warning_rounded,
            label: 'Alertes',
            value: '$alertCount',
            color: alertCount > 0 ? Colors.red : AppColors.success,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.favorite_rounded,
            label: 'Santé moy.',
            value: '${(avgHealth * 100).toInt()}%',
            color: _getHealthColor(avgHealth),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
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
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
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

  Widget _buildVehicleCard(BuildContext context, Vehicle vehicle) {
    return GestureDetector(
      onTap: () => context.push('/vehicle-details/${vehicle.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              child: Stack(
                children: [
                  Container(
                    height: 140,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                      ),
                    ),
                    child: vehicle.imageUrl.isNotEmpty
                        ? Image.network(
                            vehicle.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Center(
                              child: Icon(
                                Icons.directions_car_rounded,
                                color: Colors.white24,
                                size: 64,
                              ),
                            ),
                          )
                        : const Center(
                            child: Icon(
                              Icons.directions_car_rounded,
                              color: Colors.white24,
                              size: 64,
                            ),
                          ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getHealthColor(vehicle.progress)
                            .withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${(vehicle.progress * 100).toInt()}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${vehicle.brand} ${vehicle.model}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.navy,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${vehicle.plate} · ${vehicle.year} · ${vehicle.mileage} km',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textSecondary,
                    size: 22,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.orange.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.garage_rounded,
                size: 48,
                color: AppColors.orange,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Votre garage est vide',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.navy,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Ajoutez votre premier véhicule\npour commencer à suivre son entretien',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            PremiumButton(
              text: 'Ajouter un véhicule',
              onPressed: () => context.push('/add-vehicle'),
            ),
          ],
        ),
      ),
    );
  }

  Color _getHealthColor(double progress) {
    if (progress > 0.6) return AppColors.success;
    if (progress > 0.3) return AppColors.orange;
    return Colors.red;
  }
}