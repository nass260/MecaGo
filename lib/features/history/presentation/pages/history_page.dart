// lib/features/history/presentation/pages/history_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  String _selectedPeriod = 'Tout';
  String? _selectedVehicleId;

  final List<String> _periods = ['Tout', '3 mois', '6 mois', '1 an'];

  // Données de test
  final List<Map<String, dynamic>> _allLogs = [
    {
      'id': '1',
      'title': 'Remplacement HEPA',
      'brand': 'Tesla',
      'model': 'Model 3',
      'date': '15 Mars 2025',
      'mileage': 8500,
      'cost': 34.50,
      'saved': 20.00,
      'icon': Icons.filter_alt_rounded,
    },
    {
      'id': '2',
      'title': 'Vidange moteur',
      'brand': 'Tesla',
      'model': 'Model 3',
      'date': '02 Janvier 2025',
      'mileage': 7200,
      'cost': 89.00,
      'saved': 45.00,
      'icon': Icons.opacity_rounded,
    },
    {
      'id': '3',
      'title': 'Plaquettes de frein',
      'brand': 'Renault',
      'model': 'Clio 5',
      'date': '20 Octobre 2024',
      'mileage': 5000,
      'cost': 120.00,
      'saved': 60.00,
      'icon': Icons.car_repair_rounded,
    },
    {
      'id': '4',
      'title': 'Liquide lave-glace',
      'brand': 'Tesla',
      'model': 'Model 3',
      'date': '28 Février 2025',
      'mileage': 7200,
      'cost': 12.50,
      'saved': 5.00,
      'icon': Icons.water_drop_rounded,
    },
  ];

  // Véhicules disponibles
  final List<Map<String, String>> _vehicles = [
    {'id': '1', 'name': 'Tesla Model 3'},
    {'id': '2', 'name': 'Renault Clio 5'},
  ];

  @override
  Widget build(BuildContext context) {
    final totalCost =
        _allLogs.fold<double>(0, (sum, log) => sum + (log['cost'] as double));
    final totalSaved =
        _allLogs.fold<double>(0, (sum, log) => sum + (log['saved'] as double));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
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
                          'Historique',
                          style: TextStyle(
                            color: AppColors.navy,
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.6,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_allLogs.length} intervention${_allLogs.length > 1 ? 's' : ''}',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: _exportPDF,
                      child: Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          gradient: AppGradients.orange,
                          shape: BoxShape.circle,
                          boxShadow: AppShadows.orangeButton,
                        ),
                        child: const Icon(
                          Icons.picture_as_pdf_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // CARTE ÉCONOMIES
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: _buildSavingsCard(totalCost, totalSaved),
              ),
            ),

            // FILTRES
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: _buildFilters(),
              ),
            ),

            // LISTE
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final log = _allLogs[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _buildLogCard(log),
                    );
                  },
                  childCount: _allLogs.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================
  // CARTE ÉCONOMIES
  // ============================================

  Widget _buildSavingsCard(double totalCost, double totalSaved) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppGradients.navy,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppShadows.hero,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.savings_rounded,
                  color: AppColors.success,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Économies totales',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Grâce à MecaGo',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '${totalSaved.toStringAsFixed(2)} €',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.w900,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatMini(
                  'Dépensé',
                  '${totalCost.toStringAsFixed(0)} €',
                  Colors.white70,
                ),
              ),
              Container(
                width: 1,
                height: 30,
                color: Colors.white.withOpacity(0.2),
              ),
              Expanded(
                child: _buildStatMini(
                  'Interventions',
                  '${_allLogs.length}',
                  Colors.white70,
                ),
              ),
              Container(
                width: 1,
                height: 30,
                color: Colors.white.withOpacity(0.2),
              ),
              Expanded(
                child: _buildStatMini(
                  'Économisé',
                  '${totalCost > 0 ? ((totalSaved / totalCost) * 100).toInt() : 0}%',
                  AppColors.success,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatMini(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ============================================
  // FILTRES
  // ============================================

  Widget _buildFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Filtre véhicule
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildFilterChip(
                'Tous',
                _selectedVehicleId == null,
                () => setState(() => _selectedVehicleId = null),
              ),
              ..._vehicles.map((vehicle) {
                return _buildFilterChip(
                  vehicle['name']!,
                  _selectedVehicleId == vehicle['id'],
                  () => setState(() => _selectedVehicleId = vehicle['id']),
                );
              }).toList(),
            ],
          ),
        ),
        const SizedBox(height: 10),
        // Filtre période
        SizedBox(
          height: 36,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: _periods.map((period) {
              return _buildPeriodChip(
                period,
                _selectedPeriod == period,
                () => setState(() => _selectedPeriod = period),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.orange : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.orange : AppColors.border,
          ),
          boxShadow: isSelected ? AppShadows.orangeButton : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.navy,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.navy : AppColors.border.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // ============================================
  // LOG CARD
  // ============================================

  Widget _buildLogCard(Map<String, dynamic> log) {
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
              color: AppColors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              log['icon'] as IconData,
              color: AppColors.orange,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  log['title'] as String,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.navy,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${log['brand']} ${log['model']} · ${log['mileage']} km',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  log['date'] as String,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${(log['cost'] as double).toStringAsFixed(2)} €',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.navy,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.successLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '−${(log['saved'] as double).toStringAsFixed(0)} €',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
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

  // ============================================
  // EXPORT PDF
  // ============================================

  void _exportPDF() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.picture_as_pdf_rounded, color: AppColors.orange),
            SizedBox(width: 10),
            Text('Export PDF'),
          ],
        ),
        content: const Text(
          'Votre carnet d\'entretien va être généré et exporté en PDF.\n\n'
          'Vous pourrez le partager avec un acheteur en cas de revente.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('✅ PDF généré avec succès !'),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.orange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Générer',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}