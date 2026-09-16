// lib/features/garage/presentation/pages/vehicle_result_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/mvdb_service.dart';
import '../../../home/presentation/managers/home_notifier.dart';

class VehicleResultPage extends StatefulWidget {
  final String brand;
  final String model;
  final String engine;
  final int year;

  const VehicleResultPage({
    super.key,
    required this.brand,
    required this.model,
    required this.engine,
    required this.year,
  });

  @override
  State<VehicleResultPage> createState() => _VehicleResultPageState();
}

class _VehicleResultPageState extends State<VehicleResultPage> {
  final HomeNotifier _notifier = HomeNotifier();
  Map<String, dynamic>? _details;
  bool _isLoading = true;
  bool _isAdding = false;
  bool _addToGarage = true;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  @override
  void dispose() {
    _notifier.dispose();
    super.dispose();
  }

  Future<void> _loadDetails() async {
    final details = await MvdbService.getVehicleDetails(
      brand: widget.brand,
      model: widget.model,
      engine: widget.engine,
    );
    setState(() {
      _details = details;
      _isLoading = false;
    });
  }

  String _getVehicleImage() {
    final key =
        '${widget.brand.toLowerCase()}_${widget.model.toLowerCase()}';
    final images = <String, String>{
      'tesla_model 3': 'assets/images/tesla_model_3.jpg',
    };
    return images[key] ?? '';
  }

  Future<void> _addVehicle() async {
    setState(() => _isAdding = true);

    await _notifier.addVehicleFromMvdb(
      brand: widget.brand,
      model: widget.model,
      engine: widget.engine,
      year: widget.year,
    );

    if (!mounted) return;

    setState(() => _isAdding = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '${widget.brand} ${widget.model} ajouté au garage !',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );

    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      context.go('/garage');
    }
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
            : SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // PHOTO PLEIN ÉCRAN
                    Stack(
                      children: [
                        Container(
                          height: 280,
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            gradient: AppGradients.navy,
                          ),
                          child: _getVehicleImage().isNotEmpty
                              ? Image.asset(
                                  _getVehicleImage(),
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Center(
                                    child: Icon(
                                      Icons.directions_car_rounded,
                                      color: Colors.white24,
                                      size: 100,
                                    ),
                                  ),
                                )
                              : const Center(
                                  child: Icon(
                                    Icons.directions_car_rounded,
                                    color: Colors.white24,
                                    size: 100,
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
                                  Colors.black.withOpacity(0.5),
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.5),
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
                        // Titre
                        const Positioned(
                          top: 24,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Text(
                              'Vérifiez votre véhicule',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Nom du véhicule
                          Text(
                            '${widget.brand} ${widget.model}',
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: AppColors.navy,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.engine,
                            style: const TextStyle(
                              fontSize: 15,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // DÉTAILS
                          if (_details != null) ...[
                            _buildDetailRow('Année', '${widget.year}'),
                            _buildDetailRow(
                              'Motorisation',
                              _details!['engine'] ?? '-',
                            ),
                            _buildDetailRow(
                              'Énergie',
                              _details!['fuel'] ?? '-',
                            ),
                            _buildDetailRow(
                              'Puissance',
                              '${_details!['power_hp']} ch',
                            ),
                            _buildDetailRow(
                              'Transmission',
                              _details!['transmission'] ?? '-',
                            ),
                            _buildDetailRow(
                              'Carrosserie',
                              _details!['body'] ?? '-',
                            ),
                          ],

                          const SizedBox(height: 20),

                          // SWITCH
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: AppShadows.card,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: AppColors.orange.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.garage_rounded,
                                    color: AppColors.orange,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Text(
                                    'Ajouter ce véhicule à mon garage',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.navy,
                                    ),
                                  ),
                                ),
                                Switch.adaptive(
                                  value: _addToGarage,
                                  onChanged: (v) =>
                                      setState(() => _addToGarage = v),
                                  activeColor: AppColors.orange,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // BOUTON AJOUTER
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isAdding ? null : _addVehicle,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.orange,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 18),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 0,
                              ),
                              child: _isAdding
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      'Ajouter',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Center(
                            child: TextButton(
                              onPressed: () => context.pop(),
                              child: const Text(
                                'Rechercher un autre véhicule',
                                style: TextStyle(
                                  color: AppColors.orange,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: AppShadows.card,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
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
    );
  }
}