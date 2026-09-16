// lib/features/home/presentation/pages/maintenance_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';

class MaintenancePage extends StatefulWidget {
  const MaintenancePage({super.key});

  @override
  State<MaintenancePage> createState() => _MaintenancePageState();
}

class _MaintenancePageState extends State<MaintenancePage> {
  String? _selectedCategory;
  String? _selectedTask;
  String _selectedVehicle = 'Tesla Model 3';
  String _selectedVehicleImage = 'assets/images/tesla_model_3.jpg';

  final List<Map<String, dynamic>> _categories = [
    {
      'id': 'vidange',
      'title': 'Vidange',
      'subtitle': 'Huile + filtre',
      'duration': '45 min',
      'level': 'Débutant',
      'price': '~50 €',
      'icon': Icons.opacity_rounded,
      'color': AppColors.orange,
      'tasks': [
        {'name': 'Vidange moteur complète', 'time': '30 min', 'price': '35 €'},
        {'name': 'Changement filtre à huile', 'time': '15 min', 'price': '15 €'},
        {'name': 'Contrôle niveau huile', 'time': '5 min', 'price': 'Gratuit'},
      ],
    },
    {
      'id': 'freins',
      'title': 'Freins',
      'subtitle': 'Plaquettes + disques',
      'duration': '1h30',
      'level': 'Intermédiaire',
      'price': '~120 €',
      'icon': Icons.car_repair_rounded,
      'color': AppColors.danger,
      'tasks': [
        {'name': 'Changement plaquettes avant', 'time': '1h', 'price': '80 €'},
        {'name': 'Changement plaquettes arrière', 'time': '1h', 'price': '70 €'},
        {'name': 'Changement disques', 'time': '2h', 'price': '150 €'},
        {'name': 'Purge liquide de frein', 'time': '30 min', 'price': '40 €'},
      ],
    },
    {
      'id': 'filtres',
      'title': 'Filtres',
      'subtitle': 'Air + habitacle',
      'duration': '20 min',
      'level': 'Débutant',
      'price': '~30 €',
      'icon': Icons.filter_alt_rounded,
      'color': AppColors.success,
      'tasks': [
        {'name': 'Filtre à air', 'time': '10 min', 'price': '15 €'},
        {'name': 'Filtre habitacle', 'time': '15 min', 'price': '25 €'},
        {'name': 'Filtre à gasoil', 'time': '30 min', 'price': '35 €'},
      ],
    },
    {
      'id': 'pneus',
      'title': 'Pneus',
      'subtitle': 'Changement + pression',
      'duration': '1h',
      'level': 'Intermédiaire',
      'price': '~320 €',
      'icon': Icons.tire_repair_rounded,
      'color': Colors.purple,
      'tasks': [
        {'name': 'Changement pneus', 'time': '1h', 'price': '320 €'},
        {'name': 'Rotation pneus', 'time': '30 min', 'price': '20 €'},
        {'name': 'Équilibrage', 'time': '45 min', 'price': '40 €'},
        {'name': 'Contrôle pression', 'time': '5 min', 'price': 'Gratuit'},
      ],
    },
    {
      'id': 'batterie',
      'title': 'Batterie',
      'subtitle': 'Contrôle + changement',
      'duration': '30 min',
      'level': 'Débutant',
      'price': '~120 €',
      'icon': Icons.battery_charging_full_rounded,
      'color': Colors.blue,
      'tasks': [
        {'name': 'Contrôle batterie', 'time': '10 min', 'price': 'Gratuit'},
        {'name': 'Changement batterie', 'time': '30 min', 'price': '120 €'},
        {'name': 'Nettoyage cosses', 'time': '15 min', 'price': '10 €'},
      ],
    },
    {
      'id': 'distribution',
      'title': 'Distribution',
      'subtitle': 'Courroie + galets',
      'duration': '4h',
      'level': 'Expert',
      'price': '~600 €',
      'icon': Icons.settings_rounded,
      'color': Colors.teal,
      'tasks': [
        {'name': 'Changement kit distribution', 'time': '4h', 'price': '600 €'},
        {'name': 'Changement courroie accessoire', 'time': '1h', 'price': '80 €'},
        {'name': 'Changement pompe à eau', 'time': '2h', 'price': '200 €'},
      ],
    },
    {
      'id': 'clim',
      'title': 'Climatisation',
      'subtitle': 'Recharge + filtre',
      'duration': '1h',
      'level': 'Intermédiaire',
      'price': '~80 €',
      'icon': Icons.ac_unit_rounded,
      'color': Colors.cyan,
      'tasks': [
        {'name': 'Recharge clim', 'time': '45 min', 'price': '80 €'},
        {'name': 'Contrôle étanchéité', 'time': '30 min', 'price': '40 €'},
        {'name': 'Changement filtre', 'time': '15 min', 'price': '25 €'},
      ],
    },
    {
      'id': 'eclairage',
      'title': 'Éclairage',
      'subtitle': 'Ampoules + phares',
      'duration': '15 min',
      'level': 'Débutant',
      'price': '~20 €',
      'icon': Icons.lightbulb_rounded,
      'color': Colors.amber,
      'tasks': [
        {'name': 'Changement ampoule phare', 'time': '10 min', 'price': '20 €'},
        {'name': 'Changement feu arrière', 'time': '20 min', 'price': '35 €'},
        {'name': 'Réglage phares', 'time': '15 min', 'price': 'Gratuit'},
      ],
    },
  ];

  List<Map<String, dynamic>> get _tasks {
    if (_selectedCategory == null) return [];
    final cat = _categories.firstWhere((c) => c['id'] == _selectedCategory);
    return (cat['tasks'] as List).cast<Map<String, dynamic>>();
  }

  bool get _canStart => _selectedCategory != null && _selectedTask != null;

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
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SÉLECTION VÉHICULE (avec photo GRANDE)
            const Text(
              'Véhicule',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.navy,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: AppShadows.card,
              ),
              child: Row(
                children: [
                  // PHOTO VÉHICULE 70x70
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: AppGradients.navy,
                      image: _selectedVehicleImage.isNotEmpty
                          ? DecorationImage(
                              image: AssetImage(_selectedVehicleImage),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: _selectedVehicleImage.isEmpty
                        ? const Icon(Icons.directions_car_rounded,
                            color: Colors.white24, size: 32)
                        : null,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedVehicle,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.navy,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'AB-123-CD · 2024',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.successLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            '✅ En bon état',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.success,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_down_rounded,
                      color: AppColors.textSecondary, size: 28),
                ],
              ),
            ),
            const SizedBox(height: 26),

            // TYPE D'ENTRETIEN
            const Text(
              'Type d\'entretien',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.navy,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Choisissez une catégorie',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 14),

            // GRILLE CATÉGORIES (icônes GRANDES)
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.85,
              children: _categories.map((cat) {
                final isSelected = _selectedCategory == cat['id'];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategory = cat['id'];
                      _selectedTask = null;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (cat['color'] as Color).withOpacity(0.08)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? cat['color'] as Color
                            : AppColors.border.withOpacity(0.5),
                        width: isSelected ? 2.5 : 1,
                      ),
                      boxShadow: AppShadows.card,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ICÔNE 60x60
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: (cat['color'] as Color).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            cat['icon'] as IconData,
                            color: cat['color'] as Color,
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          cat['title'] as String,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            color: AppColors.navy,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          cat['subtitle'] as String,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        // DURÉE
                        Row(
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              size: 14,
                              color: cat['color'] as Color,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              cat['duration'] as String,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: cat['color'] as Color,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        // NIVEAU
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: (cat['color'] as Color).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            cat['level'] as String,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: cat['color'] as Color,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        // PRIX
                        Text(
                          cat['price'] as String,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: AppColors.orange,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),

            // TÂCHES
            if (_selectedCategory != null) ...[
              const SizedBox(height: 26),
              const Text(
                'Tâche à réaliser',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.navy,
                ),
              ),
              const SizedBox(height: 12),
              ..._tasks.map((task) {
                final isSelected = _selectedTask == task['name'];
                return GestureDetector(
                  onTap: () =>
                      setState(() => _selectedTask = task['name'] as String),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.orange : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? AppColors.orange : AppColors.border,
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: AppShadows.card,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected
                                ? Colors.white
                                : Colors.transparent,
                            border: Border.all(
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.border,
                              width: 2.5,
                            ),
                          ),
                          child: isSelected
                              ? const Icon(Icons.check_rounded,
                                  color: AppColors.orange, size: 16)
                              : null,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                task['name'] as String,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.navy,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time_rounded,
                                    size: 13,
                                    color: isSelected
                                        ? Colors.white70
                                        : AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    task['time'] as String,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected
                                          ? Colors.white70
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Icon(
                                    Icons.euro_rounded,
                                    size: 13,
                                    color: isSelected
                                        ? Colors.white70
                                        : AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    task['price'] as String,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: isSelected
                                          ? Colors.white
                                          : AppColors.orange,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],

            const SizedBox(height: 24),

            // BOUTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _canStart
                    ? () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                '✅ Entretien "$_selectedTask" démarré !'),
                            backgroundColor: AppColors.success,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _canStart ? AppColors.orange : AppColors.border,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Démarrer l\'entretien',
                  style: TextStyle(
                    color: _canStart ? Colors.white : AppColors.textSecondary,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}