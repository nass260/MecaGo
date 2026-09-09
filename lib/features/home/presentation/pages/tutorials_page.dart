// lib/features/home/presentation/pages/tutorials_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/premium_card.dart';

class TutorialsPage extends StatelessWidget {
  const TutorialsPage({super.key});

  final List<Map<String, dynamic>> _tutorials = const [
    {
      'id': '1',
      'title': 'Comment changer ses plaquettes de frein',
      'duration': '12 min',
      'level': 'Intermédiaire',
      'icon': Icons.car_repair_rounded,
      'views': '12.4K',
      'color': Color(0xFFFF6A00),
    },
    {
      'id': '2',
      'title': 'Vidange moteur étape par étape',
      'duration': '8 min',
      'level': 'Débutant',
      'icon': Icons.opacity_rounded,
      'views': '8.7K',
      'color': Color(0xFF0F172A),
    },
    {
      'id': '3',
      'title': 'Changer son filtre habitacle HEPA',
      'duration': '5 min',
      'level': 'Débutant',
      'icon': Icons.filter_alt_rounded,
      'views': '5.2K',
      'color': Colors.green,
    },
    {
      'id': '4',
      'title': 'Diagnostiquer un voyant moteur',
      'duration': '15 min',
      'level': 'Avancé',
      'icon': Icons.diagnosis_rounded,
      'views': '3.8K',
      'color': Colors.red,
    },
    {
      'id': '5',
      'title': 'Entretenir sa batterie électrique',
      'duration': '10 min',
      'level': 'Intermédiaire',
      'icon': Icons.battery_charging_full_rounded,
      'views': '6.1K',
      'color': Colors.blue,
    },
    {
      'id': '6',
      'title': 'Changer ses pneus en toute sécurité',
      'duration': '18 min',
      'level': 'Intermédiaire',
      'icon': Icons.grass_rounded,
      'views': '9.3K',
      'color': Colors.purple,
    },
  ];

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
          'Tutoriels',
          style: TextStyle(
            color: AppColors.navy,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded, color: AppColors.navy),
            onPressed: () {
              // Recherche de tutoriels
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ============================================
            // 1. CATÉGORIES
            // ============================================
            const Text(
              'Catégories',
              style: TextStyle(
                color: AppColors.navy,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),

            SizedBox(
              height: 70,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildCategory('Tous', Icons.all_inclusive_rounded, true),
                  _buildCategory('Moteur', Icons.settings_rounded, false),
                  _buildCategory('Freins', Icons.car_repair_rounded, false),
                  _buildCategory('Pneus', Icons.grass_rounded, false),
                  _buildCategory('Électrique', Icons.electrical_services_rounded, false),
                  _buildCategory('Filtres', Icons.filter_alt_rounded, false),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ============================================
            // 2. TUTORIELS EN VEDETTE
            // ============================================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'En vedette',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
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

            // Tutoriel vedette
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.navy, Color(0xFF1E293B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.navy.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.play_circle_filled_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '📹 Comment changer ses plaquettes de frein',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.orange.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'Intermédiaire',
                                    style: TextStyle(
                                      color: AppColors.orange,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.access_time_rounded,
                                  color: Colors.white60,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  '12 min',
                                  style: TextStyle(
                                    color: Colors.white60,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.play_circle_outline_rounded,
                            color: Colors.white.withOpacity(0.3),
                            size: 48,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Cliquez pour visionner',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.3),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ============================================
            // 3. TOUS LES TUTORIELS
            // ============================================
            const Text(
              'Tous les tutoriels',
              style: TextStyle(
                color: AppColors.navy,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),

            ..._tutorials.map((tutorial) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildTutorialCard(tutorial),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildCategory(String label, IconData icon, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.orange : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? AppColors.orange : AppColors.border.withOpacity(0.4),
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: AppColors.orange.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: isSelected ? Colors.white : AppColors.textSecondary,
            size: 18,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTutorialCard(Map<String, dynamic> tutorial) {
    final color = tutorial['color'] as Color;
    final isHighlighted = tutorial['id'] == '1';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isHighlighted
            ? color.withOpacity(0.05)
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isHighlighted
              ? color.withOpacity(0.3)
              : AppColors.border.withOpacity(0.4),
          width: isHighlighted ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icône
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              tutorial['icon'],
              color: color,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          // Contenu
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tutorial['title'],
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.navy,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        tutorial['level'],
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.access_time_rounded,
                      size: 12,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      tutorial['duration'],
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.visibility_rounded,
                      size: 12,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      tutorial['views'],
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Icon(
            Icons.play_circle_outline_rounded,
            color: AppColors.orange,
            size: 28,
          ),
        ],
      ),
    );
  }
}
