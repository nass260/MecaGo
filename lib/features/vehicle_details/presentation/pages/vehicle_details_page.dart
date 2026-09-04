import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.navy),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Fiche Technique',
          style: TextStyle(
            color: AppColors.navy,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. BLOC IDENTIFICATION DU VÉHICULE SCANNE
                    const Text(
                      'VÉHICULE IDENTIFIÉ',
                      style: TextStyle(color: AppColors.orange, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Tesla Model 3',
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: AppColors.navy, letterSpacing: -0.6),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Dual Motor Grande Autonomie — Électrique (2021)',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 18),
                    
                    // Plaque d'immatriculation SIV rétro-éclairée
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.navy, width: 1.5),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
                      ),
                      child: const Text(
                        'AB-123-CD',
                        style: TextStyle(fontWeight: FontWeight.extrabold, fontFamily: 'monospace', fontSize: 14, color: AppColors.navy, letterSpacing: 1.5),
                      ),
                    ),
                    
                    const SizedBox(height: 28),
                    
                    // 2. SPÉCIFICATIONS TECHNIQUES D'ORIGINE CONSTRUCTEUR
                    const Text(
                      'Données de maintenance d’origine',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.navy, letterSpacing: -0.4),
                    ),
                    const SizedBox(height: 12),
                    PremiumCard(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      child: Column(
                        children: [
                          _buildTechRow('Filtre habitacle', 'HEPA anti-allergène charbon'),
                          _buildDivider(),
                          _buildTechRow('Liquide de frein', 'DOT 4 Haute Performance'),
                          _buildDivider(),
                          _buildTechRow('Serrage des roues', '175 Nm (Clé dynamométrique)'),
                          _buildDivider(),
                          _buildTechRow('Pneumatiques AV/AR', '235/45 R18 98Y'),
                          _buildDivider(),
                          _buildTechRow('Huile réducteur', 'ATF Fluide Synthétique Tesla'),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 28),
                    
                    // 3. ALERTES COMPATIBILITÉ ET ÉTAT DES ÉCHÉANCES
                    const Text(
                      'Alertes de l’ordinateur de bord',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.navy, letterSpacing: -0.4),
                    ),
                    const SizedBox(height: 12),
                    _buildStatusAlert(
                      icon: '💨',
                      title: 'Filtre Habitacle HEPA',
                      subtitle: 'Usure estimée à 82% — Prochainement requis',
                      status: 'À surveiller',
                      color: AppColors.orange,
                    ),
                    _buildStatusAlert(
                      icon: '🧪',
                      title: 'Liquide de Frein',
                      subtitle: 'Échéance des 2 ans atteinte (15% de santé)',
                      status: 'Urgent',
                      color: Colors.red,
                    ),
                  ],
                ),
              ),
            ),
            
            // 4. ACTION BASSE DE CONVERSION VERS LES TUTORIELS COMPATIBLES
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: PremiumButton(
                text: 'Accéder aux tutoriels compatibles',
                onPressed: () {
                  context.push('/tutorials'); // Navigue vers le catalogue d'entretien
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildTechRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14, fontWeight: FontWeight.w600)),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(color: AppColors.navy, fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildDivider() {
    return Divider(color: AppColors.border.withOpacity(0.4), height: 1);
  }

  static Widget _buildStatusAlert({
    required String icon,
    required String title,
    required String subtitle,
    required String status,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: PremiumCard(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(14)),
              child: Center(child: Text(icon, style: const TextStyle(fontSize: 20))),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.navy)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
              child: Text(
                status,
                style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.extrabold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
