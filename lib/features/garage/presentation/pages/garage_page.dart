// lib/features/garage/presentation/pages/garage_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/premium_button.dart';
import '../../../home/data/models/vehicle_model.dart';
import '../../../home/presentation/managers/home_notifier.dart';

class GaragePage extends StatefulWidget {
  const GaragePage({super.key});

  @override
  State<GaragePage> createState() => _GaragePageState();
}

class _GaragePageState extends State<GaragePage> {
  final HomeNotifier _notifier = HomeNotifier();

  @override
  void initState() {
    super.initState();
    _notifier.loadDashboardData();
  }

  @override
  void dispose() {
    _notifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _notifier,
          builder: (context, _) {
            if (_notifier.isLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.orange),
                ),
              );
            }

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // ============================================
                // EN-TÊTE
                // ============================================
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
                              'Mon Garage',
                              style: TextStyle(
                                color: AppColors.navy,
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.6,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${_notifier.vehicles.length} véhicule${_notifier.vehicles.length > 1 ? 's' : ''} enregistré${_notifier.vehicles.length > 1 ? 's' : ''}',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () => _showAddVehicleSheet(context),
                          child: Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AppColors.orange, Color(0xFFFF8C00)],
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.orange.withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.add_rounded,
                              color: Colors.white,
                              size: 26,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ============================================
                // STATISTIQUES
                // ============================================
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: _buildStats(),
                  ),
                ),

                // ============================================
                // LISTE DES VÉHICULES
                // ============================================
                if (_notifier.vehicles.isEmpty)
                  SliverFillRemaining(
                    child: _buildEmptyState(context),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final vehicle = _notifier.vehicles[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildVehicleCard(context, vehicle),
                          );
                        },
                        childCount: _notifier.vehicles.length,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ============================================
  // WIDGETS
  // ============================================

  Widget _buildStats() {
    final totalVehicles = _notifier.vehicles.length;
    final alertCount = _notifier.vehicles.where((v) => v.isAlert).length;
    final avgHealth = totalVehicles > 0
        ? _notifier.vehicles.fold<double>(0, (sum, v) => sum + v.progress) /
            totalVehicles
        : 0.0;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.directions_car_rounded,
            label: 'Véhicules',
            value: '$totalVehicles',
            color: AppColors.orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.warning_rounded,
            label: 'Alertes',
            value: '$alertCount',
            color: alertCount > 0 ? Colors.red : AppColors.success,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.favorite_rounded,
            label: 'Santé moy.',
            value: '${(avgHealth * 100).toInt()}%',
            color: _getHealthColor(avgHealth),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleCard(BuildContext context, Vehicle vehicle) {
    return GestureDetector(
      onTap: () => context.push('/vehicle-details/${vehicle.id}'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: vehicle.isAlert
                ? Colors.red.withOpacity(0.3)
                : AppColors.border.withOpacity(0.4),
            width: vehicle.isAlert ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: vehicle.isAlert
                  ? Colors.red.withOpacity(0.05)
                  : Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                // Image / Icône
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.border.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(16),
                    image: vehicle.imageUrl.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(vehicle.imageUrl),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: vehicle.imageUrl.isEmpty
                      ? const Icon(
                          Icons.directions_car_rounded,
                          size: 32,
                          color: AppColors.textSecondary,
                        )
                      : null,
                ),
                const SizedBox(width: 14),
                // Infos
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${vehicle.brand} ${vehicle.model}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.navy,
                              ),
                            ),
                          ),
                          Text(
                            vehicle.fuelType.icon,
                            style: const TextStyle(fontSize: 18),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        vehicle.plate,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          _buildTag(
                            '${vehicle.year}',
                            Icons.calendar_today_rounded,
                            AppColors.textSecondary,
                          ),
                          const SizedBox(width: 6),
                          _buildTag(
                            '${vehicle.mileage} km',
                            Icons.speed_rounded,
                            AppColors.textSecondary,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Barre de santé
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: vehicle.progress,
                      backgroundColor: AppColors.border.withOpacity(0.3),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getHealthColor(vehicle.progress),
                      ),
                      minHeight: 5,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '${(vehicle.progress * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: _getHealthColor(vehicle.progress),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Boutons d'action
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.build_rounded,
                    label: 'Entretien',
                    onTap: () => context.push('/maintenance'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.edit_rounded,
                    label: 'Modifier',
                    onTap: () => _showEditVehicleSheet(context, vehicle),
                  ),
                ),
                const SizedBox(width: 8),
                _buildIconButton(
                  icon: Icons.delete_outline_rounded,
                  color: Colors.red,
                  onTap: () => _confirmDelete(context, vehicle),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.orange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: AppColors.orange),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.orange,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.orange.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.garage_rounded,
                size: 48,
                color: AppColors.orange,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Votre garage est vide',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.navy,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Ajoutez votre premier véhicule\npour commencer à suivre son entretien',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            PremiumButton(
              text: 'Ajouter un véhicule',
              onPressed: () => _showAddVehicleSheet(context),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================
  // HELPERS
  // ============================================

  Color _getHealthColor(double progress) {
    if (progress > 0.6) return AppColors.success;
    if (progress > 0.3) return AppColors.orange;
    return Colors.red;
  }

  void _showAddVehicleSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => const _AddVehicleSheet(),
    );
  }

  void _showEditVehicleSheet(BuildContext context, Vehicle vehicle) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _AddVehicleSheet(vehicle: vehicle),
    );
  }

  void _confirmDelete(BuildContext context, Vehicle vehicle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Supprimer le véhicule ?'),
        content: Text(
          'Voulez-vous vraiment supprimer ${vehicle.brand} ${vehicle.model} ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              await _notifier.deleteVehicle(vehicle.id);
              if (context.mounted) Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}

// ============================================
// FORMULAIRE D'AJOUT / MODIFICATION
// ============================================

class _AddVehicleSheet extends StatefulWidget {
  final Vehicle? vehicle;
  const _AddVehicleSheet({this.vehicle});

  @override
  State<_AddVehicleSheet> createState() => _AddVehicleSheetState();
}

class _AddVehicleSheetState extends State<_AddVehicleSheet> {
  final _formKey = GlobalKey<FormState>();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _plateController = TextEditingController();
  final _yearController = TextEditingController();
  final _mileageController = TextEditingController();

  FuelType _fuelType = FuelType.essence;
  TransmissionType _transmission = TransmissionType.manuelle;

  bool get isEditing => widget.vehicle != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      final v = widget.vehicle!;
      _brandController.text = v.brand;
      _modelController.text = v.model;
      _plateController.text = v.plate;
      _yearController.text = v.year.toString();
      _mileageController.text = v.mileage.toString();
      _fuelType = v.fuelType;
      _transmission = v.transmission;
    }
  }

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _plateController.dispose();
    _yearController.dispose();
    _mileageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Poignée
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                Text(
                  isEditing ? 'Modifier le véhicule' : 'Ajouter un véhicule',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.navy,
                  ),
                ),
                const SizedBox(height: 24),

                // Marque
                _buildTextField(
                  controller: _brandController,
                  label: 'Marque',
                  hint: 'Ex: Renault, Tesla, Peugeot...',
                  icon: Icons.business_rounded,
                ),
                const SizedBox(height: 12),

                // Modèle
                _buildTextField(
                  controller: _modelController,
                  label: 'Modèle',
                  hint: 'Ex: Clio 5, Model 3, 208...',
                  icon: Icons.directions_car_rounded,
                ),
                const SizedBox(height: 12),

                // Plaque
                _buildTextField(
                  controller: _plateController,
                  label: 'Immatriculation',
                  hint: 'AB-123-CD',
                  icon: Icons.pin_rounded,
                ),
                const SizedBox(height: 12),

                // Année + Kilométrage
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _yearController,
                        label: 'Année',
                        hint: '2020',
                        icon: Icons.calendar_today_rounded,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTextField(
                        controller: _mileageController,
                        label: 'Kilométrage',
                        hint: '50000',
                        icon: Icons.speed_rounded,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Motorisation
                const Text(
                  'Motorisation',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.navy,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: FuelType.values.map((fuel) {
                    final isSelected = _fuelType == fuel;
                    return GestureDetector(
                      onTap: () => setState(() => _fuelType = fuel),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.orange
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.orange
                                : AppColors.border,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(fuel.icon, style: const TextStyle(fontSize: 14)),
                            const SizedBox(width: 6),
                            Text(
                              fuel.label,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.navy,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Transmission
                const Text(
                  'Transmission',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.navy,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: TransmissionType.values.map((trans) {
                    final isSelected = _transmission == trans;
                    return GestureDetector(
                      onTap: () => setState(() => _transmission = trans),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.orange
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.orange
                                : AppColors.border,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(trans.icon,
                                style: const TextStyle(fontSize: 14)),
                            const SizedBox(width: 6),
                            Text(
                              trans.label,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.navy,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // Bouton
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.orange,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      isEditing ? 'Enregistrer' : 'Ajouter le véhicule',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 20),
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.orange, width: 2),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Champ requis';
        return null;
      },
    );
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final vehicle = Vehicle(
      id: widget.vehicle?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      brand: _brandController.text.trim(),
      model: _modelController.text.trim(),
      plate: _plateController.text.trim().toUpperCase(),
      year: int.tryParse(_yearController.text) ?? DateTime.now().year,
      mileage: int.tryParse(_mileageController.text) ?? 0,
      fuelType: _fuelType,
      transmission: _transmission,
      progress: widget.vehicle?.progress ?? 0.75,
      isAlert: widget.vehicle?.isAlert ?? false,
      imageUrl: widget.vehicle?.imageUrl ?? '',
    );

    if (isEditing) {
      await HomeNotifier().updateVehicle(vehicle);
    } else {
      await HomeNotifier().addVehicle(vehicle);
    }

    if (mounted) Navigator.pop(context);
  }
}
