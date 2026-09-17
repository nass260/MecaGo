// lib/features/garage/presentation/pages/vehicle_result_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/mvdb_service.dart';
import '../../../../core/services/global_notifier.dart';
import '../../../home/data/models/vehicle_model.dart';

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
  final notifier = GlobalNotifier.instance;
  Map<String, dynamic>? _details;
  bool _isLoading = true;
  bool _isAdding = false;
  bool _addToGarage = true;

  @override
  void initState() {
    super.initState();
    _loadDetails();
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

  /// ✅ AJOUTE LE VÉHICULE VIA LE NOTIFIER GLOBAL
  Future<void> _addVehicle() async {
    setState(() => _isAdding = true);

    try {
      final newVehicle = Vehicle(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        brand: widget.brand,
        model: widget.model,
        plate: 'À DÉFINIR',
        year: widget.year,
        mileage: 0,
        fuelType: _getFuelType(widget.engine),
        transmission: _getTransmission(widget.engine),
        progress: 1.0,
        isAlert: false,
        imageUrl: _getVehicleImage(),
      );

      // ✅ Ajout via le notifier global (qui sauvegarde + notifie)
      await notifier.addVehicle(newVehicle);

      debugPrint(
          '✅ Véhicule ajouté via notifier : ${newVehicle.brand} ${newVehicle.model}');

      if (!mounted) return;

      setState(() => _isAdding = false);

      // Message de succès
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

      // Retour au garage
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) {
        context.go('/garage');
      }
    } catch (e) {
      debugPrint('❌ Erreur ajout véhicule : $e');
      setState(() => _isAdding = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erreur : $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  FuelType _getFuelType(String engine) {
    final lower = engine.toLowerCase();
    if (lower.contains('électrique') || lower.contains('electric')) {
      return FuelType.electrique;
    }
    if (lower.contains('hybride')) {
      return FuelType.hybride;
    }
    if (lower.contains('diesel') ||
        lower.contains('dci') ||
        lower.contains('hdi') ||
        lower.contains('tdi') ||
        lower.contains('bluehdi') ||
        lower.contains('ecoblue')) {
      return FuelType.diesel;
    }
    if (lower.contains('gpl')) {
      return FuelType.gpl;
    }
    if (lower.contains('e85')) {
      return FuelType.e85;
    }
    return FuelType.essence;
  }

  TransmissionType _getTransmission(String engine) {
    final lower = engine.toLowerCase();
    if (lower.contains('automatique') ||
        lower.contains('auto') ||
        lower.contains('eat')) {
      return TransmissionType.automatique;
    }
    if (lower.contains('semi')) {
      return TransmissionType.semiAutomatique;
    }
    return TransmissionType.manuelle;
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
                          if (_details != null) ...[
                            _buildDetailRow('Année', '${widget.year}'),
                            _buildDetailRow('Motorisation', widget.engine),
                            _buildDetailRow('Énergie',
                                _getFuelType(widget.engine).label),
                            _buildDetailRow('Transmission',
                                _getTransmission(widget.engine).label),
                          ],
                          const SizedBox(height: 20),
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