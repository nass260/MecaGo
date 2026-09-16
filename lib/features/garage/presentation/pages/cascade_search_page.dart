// lib/features/garage/presentation/pages/cascade_search_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/mvdb_service.dart';
import '../../../../core/widgets/year_selector.dart';

class CascadeSearchPage extends StatefulWidget {
  const CascadeSearchPage({super.key});

  @override
  State<CascadeSearchPage> createState() => _CascadeSearchPageState();
}

class _CascadeSearchPageState extends State<CascadeSearchPage> {
  String? _brand;
  String? _model;
  String? _engine;
  int? _year;

  List<String> _brands = [];
  List<String> _models = [];
  List<String> _engines = [];
  List<int> _years = [];

  bool _loadingBrands = true;
  bool _loadingModels = false;
  bool _loadingEngines = false;

  @override
  void initState() {
    super.initState();
    _loadBrands();
  }

  Future<void> _loadBrands() async {
    final brands = await MvdbService.getBrands();
    setState(() {
      _brands = brands;
      _loadingBrands = false;
    });
  }

  Future<void> _onBrandChanged(String? brand) async {
    if (brand == null) return;
    setState(() {
      _brand = brand;
      _model = null;
      _engine = null;
      _year = null;
      _models = [];
      _engines = [];
      _years = [];
      _loadingModels = true;
    });
    final models = await MvdbService.getModels(brand);
    setState(() {
      _models = models;
      _loadingModels = false;
    });
  }

  Future<void> _onModelChanged(String? model) async {
    if (model == null || _brand == null) return;
    setState(() {
      _model = model;
      _engine = null;
      _year = null;
      _engines = [];
      _years = [];
      _loadingEngines = true;
    });

    final engines = await MvdbService.getEngines(_brand!, model);
    final years = await MvdbService.getYears(_brand!, model);

    setState(() {
      _engines = engines;
      _years = years;
      _loadingEngines = false;
    });
  }

  void _onEngineChanged(String? engine) {
    setState(() => _engine = engine);
  }

  void _onYearChanged(int year) {
    setState(() => _year = year);
  }

  bool get _canSearch =>
      _brand != null && _model != null && _engine != null && _year != null;

  void _search() {
    if (!_canSearch) return;
    context.push(
      '/vehicle-result?brand=$_brand&model=$_model&engine=$_engine&year=$_year',
    );
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
          'Rechercher par véhicule',
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
              'Sélectionnez votre véhicule en quelques étapes',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),

            // Marque
            _buildDropdownCard(
              icon: Icons.business_rounded,
              label: 'Marque',
              value: _brand,
              items: _brands,
              isLoading: _loadingBrands,
              onChanged: _onBrandChanged,
            ),
            const SizedBox(height: 12),

            // Modèle
            _buildDropdownCard(
              icon: Icons.directions_car_rounded,
              label: 'Modèle',
              value: _model,
              items: _models,
              isLoading: _loadingModels,
              enabled: _brand != null,
              onChanged: _onModelChanged,
            ),
            const SizedBox(height: 12),

            // Motorisation
            _buildDropdownCard(
              icon: Icons.settings_rounded,
              label: 'Motorisation',
              value: _engine,
              items: _engines,
              isLoading: _loadingEngines,
              enabled: _model != null,
              onChanged: _onEngineChanged,
            ),
            const SizedBox(height: 20),

            // Année
            if (_years.isNotEmpty) ...[
              const Text(
                'Année',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.navy,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Choisissez l\'année de votre véhicule',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              YearSelector(
                years: _years,
                selectedYear: _year,
                onChanged: _onYearChanged,
              ),
            ],

            const SizedBox(height: 24),

            // Bouton
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _canSearch ? _search : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _canSearch ? AppColors.orange : AppColors.border,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Voir les résultats',
                  style: TextStyle(
                    color: _canSearch ? Colors.white : AppColors.textSecondary,
                    fontSize: 15,
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

  Widget _buildDropdownCard({
    required IconData icon,
    required String label,
    required String? value,
    required List<String> items,
    required bool isLoading,
    required Function(String?) onChanged,
    bool enabled = true,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: enabled ? Colors.white : const Color(0xFFE8ECF1),
        borderRadius: BorderRadius.circular(16),
        boxShadow: enabled ? AppShadows.card : null,
      ),
      child: Row(
        children: [
          // Logo de la marque si sélectionnée
          if (label == 'Marque' && value != null)
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color: AppColors.orange.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Icon(
                  Icons.business_rounded,
                  color: AppColors.orange,
                  size: 18,
                ),
              ),
            )
          else
            Icon(
              icon,
              color: enabled ? AppColors.orange : AppColors.textSecondary,
              size: 22,
            ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                isLoading
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: SizedBox(
                          height: 14,
                          width: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.orange,
                            ),
                          ),
                        ),
                      )
                    : DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: value,
                          isExpanded: true,
                          hint: Text(
                            enabled ? 'Sélectionner' : 'Choisir $label',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          items: items.map((item) {
                            return DropdownMenuItem<String>(
                              value: item,
                              child: Text(
                                item,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.navy,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: enabled ? onChanged : null,
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}