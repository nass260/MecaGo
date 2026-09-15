// lib/features/garage/presentation/pages/add_vehicle_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';

class AddVehiclePage extends StatelessWidget {
  const AddVehiclePage({super.key});

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
          'Ajouter un véhicule',
          style: TextStyle(
            color: AppColors.navy,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Comment souhaitez-vous ajouter votre véhicule ?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.navy,
              ),
            ),
            const SizedBox(height: 20),

            // Méthode 1 : Scanner la plaque
            _buildMethodCard(
              icon: Icons.qr_code_scanner_rounded,
              iconColor: AppColors.orange,
              title: 'Scanner la plaque',
              subtitle: 'Reconnaissance automatique de votre plaque',
              onTap: () => context.push('/plate-scanner'),
            ),
            const SizedBox(height: 12),

            // Méthode 2 : Saisir le VIN
            _buildMethodCard(
              icon: Icons.vpn_key_rounded,
              iconColor: AppColors.navy,
              title: 'Saisir le VIN',
              subtitle: '17 caractères',
              onTap: () => context.push('/vin-input'),
            ),
            const SizedBox(height: 12),

            // Méthode 3 : Recherche en cascade
            _buildMethodCard(
              icon: Icons.directions_car_rounded,
              iconColor: Colors.purple,
              title: 'Rechercher par véhicule',
              subtitle: 'Marque, modèle, motorisation, année',
              onTap: () => context.push('/cascade-search'),
            ),
            const SizedBox(height: 24),

            // Bandeau info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.orange.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.orange.withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.orange.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.info_rounded,
                      color: AppColors.orange,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Base de données MecaGo',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AppColors.navy,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          '80+ marques · 8 000+ modèles · 2005 → 2026',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMethodCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
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
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: iconColor, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.navy,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
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
    );
  }
}