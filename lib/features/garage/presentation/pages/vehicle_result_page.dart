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
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.navy),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Résultat',
          style: TextStyle(
            color: AppColors.navy,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.orange),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
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
                    child: Column(
                      children: [
                        Container(
                          height: 180,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFF0F172A),
                                Color(0xFF1E293B),
                              ],
                            ),
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.directions_car_rounded,
                              color: Colors.white24,
                              size: 80,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${widget.brand} ${widget.model}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.navy,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.engine,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
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
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isAdding ? null : _addVehicle,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.orange,
                        padding: const EdgeInsets.symmetric(vertical: 16),
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
                              'Ajouter ce véhicule',
                              style: TextStyle(
                                color: Colors.white,
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

  Widget _buildDetailRow(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
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