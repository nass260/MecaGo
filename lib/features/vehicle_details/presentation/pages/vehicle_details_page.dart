import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/premium_card.dart';
import '../../../../core/widgets/premium_button.dart';

class VehicleDetailsPage extends StatelessWidget {
  const VehicleDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Fiche Véhicule'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.navy),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              // 1. HEADER DU VÉHICULE (Style Apple minimaliste)
              const Text(
                'Tesla Model 3',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.navy),
              ),
              const SizedBox(height: 4),
              const Text(
                'Autonomie Standard Plus — Électrique (2021)',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),
              
              // Badge d'immatriculation SIV propre
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, py: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.navy, width: 1.5),
                ),
                child: const Text(
                  'AB-123-CD',
                  style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'monospace', fontSize: 14, color: AppColors.navy, letterSpacing: 1.2),
                ),
              ),

              const SizedBox(height: 24),

              // 2. DONNÉES TECHNIQUES ET COUPLES DE SERRAGE (L'utilité AUTODOC)
              const Text(
                'Spécifications de maintenance',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.navy),
              ),
              const SizedBox(height: 12),
              
              PremiumCard(
                child: Column(
                  children: [
                    _buildTechRow('Huile réducteur', 'ATF liquide synthétique spécial'),
                    _buildDivider(),
                    _buildTechRow('Liquide de frein', 'DOT 4 Plus (Remplacement 2 ans)'),
                    _buildDivider(),
                    _buildTechRow('Filtre habitacle', 'Filtre habitacle HEPA anti-allergène'),
                    _buildDivider(),
                    _buildTechRow('Serrage des roues', '175 Nm (Clé dynamométrique)'),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // 3. LISTE DES ENTRETIENS V1 OBLIGATOIRES (Interventions interactives)
              const Text(
                'Entretiens disponibles',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.navy),
              ),
              const SizedBox(height: 12),

              _buildMaintenanceItem(
                context,
                icon: '💨',
                title: 'Filtre Habitacle (HEPA)',
                subtitle: 'Difficulté : Facile • 15 min',
                status: 'À remplacer',
                statusColor: AppColors.orange,
              ),
              _buildMaintenanceItem(
                context,
                icon: '🧪',
                title: 'Liquide de Frein',
                subtitle: 'Difficulté : Expert • 45 min',
                status: 'Recommandé',
                statusColor: AppColors.blue,
              ),
              _buildMaintenanceItem(
                context,
                icon: '❄️',
                title: 'Liquide de Refroidissement',
                subtitle: 'Difficulté : Moyen • 30 min',
                status: 'Excellent état',
                statusColor: AppColors.success,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget d'alignement pour les lignes techniques épurées
  Widget _buildTechRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.between,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14, fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(color: AppColors.navy, fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(color: AppColors.border.withOpacity(0.5), height: 16);
  }

  // Carte interactive haut de gamme pour chaque ligne d'entretien
  Widget _buildMaintenanceItem(
    BuildContext context, {
    required String icon,
    required String title,
    required String subtitle,
    required String status,
    required Color statusColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: PremiumCard(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(16)),
              child: Center(child: Text(icon, style: const TextStyle(fontSize: 22))),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.navy)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, py: 4),
              decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: Text(
                status,
                style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
