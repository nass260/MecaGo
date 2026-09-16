// lib/features/home/presentation/pages/tutorials_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';

class TutorialsPage extends StatefulWidget {
  const TutorialsPage({super.key});

  @override
  State<TutorialsPage> createState() => _TutorialsPageState();
}

class _TutorialsPageState extends State<TutorialsPage> {
  String _selectedCategory = 'Tous';

  final List<String> _categories = [
    'Tous',
    'Moteur',
    'Freins',
    'Pneus',
    'Distribution',
    'Électrique',
    'Filtres',
    'Allumage',
    'Refroidissement',
    'Échappement',
    'Climatisation',
    'Transmission',
    'Direction',
    'Carrosserie',
    'Diagnostic',
    'Éclairage',
  ];

  final List<Map<String, dynamic>> _tutorials = [
    // ===== FREINS =====
    {
      'title': 'Changer ses plaquettes de frein',
      'duration': '12 min',
      'level': 'Intermédiaire',
      'views': '12.4K',
      'icon': Icons.car_repair_rounded,
      'color': AppColors.orange,
      'category': 'Freins',
    },
    {
      'title': 'Remplacer les disques de frein',
      'duration': '25 min',
      'level': 'Avancé',
      'views': '8.2K',
      'icon': Icons.album_rounded,
      'color': AppColors.danger,
      'category': 'Freins',
    },
    {
      'title': 'Purger le liquide de frein',
      'duration': '18 min',
      'level': 'Intermédiaire',
      'views': '5.6K',
      'icon': Icons.water_drop_rounded,
      'color': AppColors.danger,
      'category': 'Freins',
    },
    // ===== MOTEUR =====
    {
      'title': 'Vidange moteur étape par étape',
      'duration': '8 min',
      'level': 'Débutant',
      'views': '8.7K',
      'icon': Icons.opacity_rounded,
      'color': AppColors.navy,
      'category': 'Moteur',
    },
    {
      'title': 'Changer la courroie d\'accessoire',
      'duration': '20 min',
      'level': 'Intermédiaire',
      'views': '4.5K',
      'icon': Icons.settings_rounded,
      'color': AppColors.navy,
      'category': 'Moteur',
    },
    // ===== DISTRIBUTION =====
    {
      'title': 'Changer le kit de distribution',
      'duration': '4h',
      'level': 'Expert',
      'views': '15.2K',
      'icon': Icons.settings_rounded,
      'color': Colors.purple,
      'category': 'Distribution',
    },
    {
      'title': 'Remplacer la pompe à eau',
      'duration': '2h',
      'level': 'Avancé',
      'views': '6.8K',
      'icon': Icons.water_rounded,
      'color': Colors.purple,
      'category': 'Distribution',
    },
    {
      'title': 'Changer les galets tendeurs',
      'duration': '1h30',
      'level': 'Avancé',
      'views': '3.2K',
      'icon': Icons.settings_rounded,
      'color': Colors.purple,
      'category': 'Distribution',
    },
    // ===== FILTRES =====
    {
      'title': 'Changer son filtre habitacle HEPA',
      'duration': '5 min',
      'level': 'Débutant',
      'views': '5.2K',
      'icon': Icons.filter_alt_rounded,
      'color': AppColors.success,
      'category': 'Filtres',
    },
    {
      'title': 'Remplacer le filtre à air',
      'duration': '6 min',
      'level': 'Débutant',
      'views': '7.1K',
      'icon': Icons.air_rounded,
      'color': AppColors.success,
      'category': 'Filtres',
    },
    {
      'title': 'Changer le filtre à gasoil',
      'duration': '15 min',
      'level': 'Intermédiaire',
      'views': '4.3K',
      'icon': Icons.opacity_rounded,
      'color': AppColors.success,
      'category': 'Filtres',
    },
    {
      'title': 'Changer le filtre à huile',
      'duration': '10 min',
      'level': 'Débutant',
      'views': '6.5K',
      'icon': Icons.filter_alt_rounded,
      'color': AppColors.success,
      'category': 'Filtres',
    },
    // ===== ALLUMAGE =====
    {
      'title': 'Changer les bougies d\'allumage',
      'duration': '20 min',
      'level': 'Débutant',
      'views': '9.8K',
      'icon': Icons.electric_bolt_rounded,
      'color': Colors.orange,
      'category': 'Allumage',
    },
    {
      'title': 'Remplacer les bobines d\'allumage',
      'duration': '30 min',
      'level': 'Intermédiaire',
      'views': '5.4K',
      'icon': Icons.flash_on_rounded,
      'color': Colors.orange,
      'category': 'Allumage',
    },
    {
      'title': 'Changer le démarreur',
      'duration': '1h30',
      'level': 'Avancé',
      'views': '3.9K',
      'icon': Icons.play_circle_rounded,
      'color': Colors.orange,
      'category': 'Allumage',
    },
    // ===== ÉLECTRIQUE =====
    {
      'title': 'Entretenir sa batterie électrique',
      'duration': '10 min',
      'level': 'Intermédiaire',
      'views': '6.1K',
      'icon': Icons.battery_charging_full_rounded,
      'color': Colors.blue,
      'category': 'Électrique',
    },
    {
      'title': 'Changer la batterie 12V',
      'duration': '15 min',
      'level': 'Débutant',
      'views': '7.8K',
      'icon': Icons.battery_std_rounded,
      'color': Colors.blue,
      'category': 'Électrique',
    },
    {
      'title': 'Changer l\'alternateur',
      'duration': '2h',
      'level': 'Avancé',
      'views': '4.2K',
      'icon': Icons.flash_on_rounded,
      'color': Colors.blue,
      'category': 'Électrique',
    },
    {
      'title': 'Vérifier les fusibles',
      'duration': '5 min',
      'level': 'Débutant',
      'views': '11.2K',
      'icon': Icons.electrical_services_rounded,
      'color': Colors.blue,
      'category': 'Électrique',
    },
    // ===== PNEUS =====
    {
      'title': 'Changer ses pneus en toute sécurité',
      'duration': '18 min',
      'level': 'Intermédiaire',
      'views': '9.3K',
      'icon': Icons.tire_repair_rounded,
      'color': Colors.purple,
      'category': 'Pneus',
    },
    {
      'title': 'Réparer une crevaison',
      'duration': '15 min',
      'level': 'Intermédiaire',
      'views': '8.1K',
      'icon': Icons.build_rounded,
      'color': Colors.purple,
      'category': 'Pneus',
    },
    {
      'title': 'Vérifier la pression des pneus',
      'duration': '3 min',
      'level': 'Débutant',
      'views': '15.6K',
      'icon': Icons.speed_rounded,
      'color': Colors.purple,
      'category': 'Pneus',
    },
    // ===== REFROIDISSEMENT =====
    {
      'title': 'Vidanger le liquide de refroidissement',
      'duration': '45 min',
      'level': 'Intermédiaire',
      'views': '5.2K',
      'icon': Icons.ac_unit_rounded,
      'color': Colors.cyan,
      'category': 'Refroidissement',
    },
    {
      'title': 'Changer le thermostat',
      'duration': '1h',
      'level': 'Avancé',
      'views': '4.1K',
      'icon': Icons.thermostat_rounded,
      'color': Colors.cyan,
      'category': 'Refroidissement',
    },
    {
      'title': 'Remplacer le radiateur',
      'duration': '2h',
      'level': 'Expert',
      'views': '2.9K',
      'icon': Icons.whatshot_rounded,
      'color': Colors.cyan,
      'category': 'Refroidissement',
    },
    // ===== ÉCHAPPEMENT =====
    {
      'title': 'Nettoyer la vanne EGR',
      'duration': '1h30',
      'level': 'Avancé',
      'views': '6.2K',
      'icon': Icons.settings_rounded,
      'color': Colors.brown,
      'category': 'Échappement',
    },
    {
      'title': 'Changer le silencieux',
      'duration': '1h',
      'level': 'Intermédiaire',
      'views': '4.8K',
      'icon': Icons.volume_off_rounded,
      'color': Colors.brown,
      'category': 'Échappement',
    },
    {
      'title': 'Remplacer le catalyseur',
      'duration': '2h30',
      'level': 'Expert',
      'views': '3.5K',
      'icon': Icons.filter_alt_rounded,
      'color': Colors.brown,
      'category': 'Échappement',
    },
    {
      'title': 'Régénérer le filtre FAP',
      'duration': '30 min',
      'level': 'Avancé',
      'views': '7.9K',
      'icon': Icons.cleaning_services_rounded,
      'color': Colors.brown,
      'category': 'Échappement',
    },
    // ===== CLIMATISATION =====
    {
      'title': 'Recharger la climatisation',
      'duration': '45 min',
      'level': 'Intermédiaire',
      'views': '5.5K',
      'icon': Icons.ac_unit_rounded,
      'color': Colors.lightBlue,
      'category': 'Climatisation',
    },
    {
      'title': 'Changer le compresseur de clim',
      'duration': '3h',
      'level': 'Expert',
      'views': '2.1K',
      'icon': Icons.ac_unit_rounded,
      'color': Colors.lightBlue,
      'category': 'Climatisation',
    },
    // ===== TRANSMISSION =====
    {
      'title': 'Vidange boîte de vitesses',
      'duration': '1h',
      'level': 'Intermédiaire',
      'views': '6.7K',
      'icon': Icons.settings_rounded,
      'color': Colors.indigo,
      'category': 'Transmission',
    },
    {
      'title': 'Changer l\'embrayage',
      'duration': '4h',
      'level': 'Expert',
      'views': '8.9K',
      'icon': Icons.car_repair_rounded,
      'color': Colors.indigo,
      'category': 'Transmission',
    },
    {
      'title': 'Remplacer un cardan',
      'duration': '2h',
      'level': 'Avancé',
      'views': '4.6K',
      'icon': Icons.settings_rounded,
      'color': Colors.indigo,
      'category': 'Transmission',
    },
    // ===== DIRECTION =====
    {
      'title': 'Changer les rotules de direction',
      'duration': '1h30',
      'level': 'Avancé',
      'views': '3.7K',
      'icon': Icons.swap_horiz_rounded,
      'color': Colors.teal,
      'category': 'Direction',
    },
    {
      'title': 'Remplacer les biellettes',
      'duration': '1h',
      'level': 'Avancé',
      'views': '2.8K',
      'icon': Icons.swap_horiz_rounded,
      'color': Colors.teal,
      'category': 'Direction',
    },
    // ===== CARROSSERIE =====
    {
      'title': 'Changer un essuie-glace',
      'duration': '5 min',
      'level': 'Débutant',
      'views': '14.2K',
      'icon': Icons.cleaning_services_rounded,
      'color': Colors.grey,
      'category': 'Carrosserie',
    },
    {
      'title': 'Remplacer un rétroviseur',
      'duration': '30 min',
      'level': 'Intermédiaire',
      'views': '5.9K',
      'icon': Icons.visibility_rounded,
      'color': Colors.grey,
      'category': 'Carrosserie',
    },
    {
      'title': 'Changer une ampoule de phare',
      'duration': '10 min',
      'level': 'Débutant',
      'views': '13.5K',
      'icon': Icons.lightbulb_rounded,
      'color': Colors.grey,
      'category': 'Carrosserie',
    },
    // ===== DIAGNOSTIC =====
    {
      'title': 'Diagnostiquer un voyant moteur',
      'duration': '15 min',
      'level': 'Avancé',
      'views': '3.8K',
      'icon': Icons.build_circle_rounded,
      'color': AppColors.danger,
      'category': 'Diagnostic',
    },
    {
      'title': 'Utiliser un scanner OBD2',
      'duration': '12 min',
      'level': 'Intermédiaire',
      'views': '8.4K',
      'icon': Icons.developer_board_rounded,
      'color': AppColors.danger,
      'category': 'Diagnostic',
    },
    {
      'title': 'Lire les codes défaut',
      'duration': '8 min',
      'level': 'Débutant',
      'views': '10.1K',
      'icon': Icons.article_rounded,
      'color': AppColors.danger,
      'category': 'Diagnostic',
    },
    // ===== ÉCLAIRAGE =====
    {
      'title': 'Régler ses phares',
      'duration': '15 min',
      'level': 'Débutant',
      'views': '7.2K',
      'icon': Icons.highlight_rounded,
      'color': Colors.amber,
      'category': 'Éclairage',
    },
    {
      'title': 'Changer un feu arrière',
      'duration': '20 min',
      'level': 'Débutant',
      'views': '9.1K',
      'icon': Icons.light_rounded,
      'color': Colors.amber,
      'category': 'Éclairage',
    },
  ];

  List<Map<String, dynamic>> get _filteredTutorials {
    if (_selectedCategory == 'Tous') return _tutorials;
    return _tutorials
        .where((t) => t['category'] == _selectedCategory)
        .toList();
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
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${_filteredTutorials.length} tutoriel${_filteredTutorials.length > 1 ? 's' : ''} disponible${_filteredTutorials.length > 1 ? 's' : ''}',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: _categories.map((cat) {
                  final isSelected = _selectedCategory == cat;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategory = cat),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.orange : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.orange
                              : AppColors.border,
                        ),
                        boxShadow: isSelected
                            ? AppShadows.orangeButton
                            : AppShadows.card,
                      ),
                      child: Center(
                        child: Text(
                          cat,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : AppColors.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),
            ..._filteredTutorials.map((tutorial) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: AppShadows.card,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: (tutorial['color'] as Color)
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          tutorial['icon'] as IconData,
                          color: tutorial['color'] as Color,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tutorial['title'] as String,
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
                                    color: (tutorial['color'] as Color)
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    tutorial['level'] as String,
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w600,
                                      color: tutorial['color'] as Color,
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
                                  tutorial['duration'] as String,
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
                                  tutorial['views'] as String,
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
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}