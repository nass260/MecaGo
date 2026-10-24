// lib/features/home/presentation/pages/edit_vehicle_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/vehicle_model.dart';
import '../managers/home_notifier.dart';

class EditVehiclePage extends StatefulWidget {
  final Vehicle vehicle;
  const EditVehiclePage({super.key, required this.vehicle});

  @override
  State<EditVehiclePage> createState() => _EditVehiclePageState();
}

class _EditVehiclePageState extends State<EditVehiclePage> {
  final _formKey = GlobalKey<FormState>();
  final HomeNotifier _notifier = HomeNotifier();

  // Palette MecaGo
  static const Color cOrange = Color(0xFFFF7417);
  static const Color cOrangeLight = Color(0xFFFF8A32);
  static const Color cNavy = Color(0xFF10213B);
  static const Color cSlate = Color(0xFF344B68);
  static const Color cGreyText = Color(0xFF6F89AD);
  static const Color cGreyDesc = Color(0xFF8198B8);
  static const Color cBg = Color(0xFFF6F9FC);
  static const Color cBorder = Color(0xFFE1EAF4);
  static const Color cIconBg = Color(0xFFF0F4F8);
  static const Color cSuccessBg = Color(0xFFE2F9ED);
  static const Color cSuccessText = Color(0xFF07864B);
  static const Color cDanger = Color(0xFFFF5A52);
  static const Color cValueText = Color(0xFF14243D);
  
  // ✅ NOUVELLE COULEUR POUR LES CHAMPS (Fond secondaire de ta palette)
  static const Color cFieldBg = Color(0xFFF1F5F9);

  // Contrôleurs
  late TextEditingController _mileageController;
  late TextEditingController _powerController;
  late TextEditingController _fiscalPowerController;
  late TextEditingController _engineSizeController;
  late TextEditingController _engineCodeController;
  late TextEditingController _notesController;

  // Valeurs sélectionnées
  late int _selectedYear;
  late FuelType _selectedFuel;
  late TransmissionType _selectedTransmission;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _mileageController = TextEditingController(text: widget.vehicle.mileage.toString());
    _powerController = TextEditingController(text: widget.vehicle.power ?? '');
    _fiscalPowerController = TextEditingController(text: widget.vehicle.fiscalPower ?? '');
    _engineSizeController = TextEditingController(text: widget.vehicle.engineSize ?? '');
    _engineCodeController = TextEditingController(text: widget.vehicle.engineCode ?? '');
    _notesController = TextEditingController(text: widget.vehicle.notes ?? '');
    
    _selectedYear = widget.vehicle.year;
    _selectedFuel = widget.vehicle.fuelType;
    _selectedTransmission = widget.vehicle.transmission;
  }

  @override
  void dispose() {
    _mileageController.dispose();
    _powerController.dispose();
    _fiscalPowerController.dispose();
    _engineSizeController.dispose();
    _engineCodeController.dispose();
    _notesController.dispose();
    _notifier.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      final updatedVehicle = widget.vehicle.copyWith(
        mileage: int.tryParse(_mileageController.text.trim()) ?? widget.vehicle.mileage,
        year: _selectedYear,
        fuelType: _selectedFuel,
        transmission: _selectedTransmission,
        power: _powerController.text.trim().isEmpty ? null : _powerController.text.trim(),
        fiscalPower: _fiscalPowerController.text.trim().isEmpty ? null : _fiscalPowerController.text.trim(),
        engineSize: _engineSizeController.text.trim().isEmpty ? null : _engineSizeController.text.trim(),
        engineCode: _engineCodeController.text.trim().isEmpty ? null : _engineCodeController.text.trim(),
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      );
      await _notifier.updateVehicle(updatedVehicle);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Véhicule mis à jour avec succès'), backgroundColor: cSuccessText, behavior: SnackBarBehavior.floating),
        );
        context.pop(); 
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : $e'), backgroundColor: cDanger, behavior: SnackBarBehavior.floating),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Widget _buildBrandLogo({double size = 24}) {
    final brand = widget.vehicle.brand.toLowerCase();
    final assetPath = 'assets/images/brands/$brand.png';
    
    return Image.asset(
      assetPath,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => Icon(Icons.directions_car_rounded, size: size, color: cSlate),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: cNavy),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Modifier le véhicule',
          style: TextStyle(color: cNavy, fontSize: 18, fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: cDanger),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderCard(),
                const SizedBox(height: 24),

                _buildSectionTitle(
                  icon: Icons.directions_car_filled_rounded,
                  title: 'Informations générales',
                  subtitle: 'Modifiez les informations principales de votre véhicule.',
                ),
                const SizedBox(height: 12),
                
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: cBorder),
                    boxShadow: [BoxShadow(color: cNavy.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 5))],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(child: _buildDropdownTile(
                            label: 'Marque',
                            value: widget.vehicle.brand,
                            icon: _buildBrandLogo(size: 20),
                            items: [widget.vehicle.brand],
                            onChanged: (v) {},
                          )),
                          const SizedBox(width: 12),
                          Expanded(child: _buildDropdownTile(
                            label: 'Modèle',
                            value: widget.vehicle.model,
                            icon: const Icon(Icons.directions_car_filled_rounded, size: 20, color: cSlate),
                            items: [widget.vehicle.model],
                            onChanged: (v) {},
                          )),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: _buildDropdownTile(
                            label: 'Année',
                            value: _selectedYear.toString(),
                            icon: const Icon(Icons.calendar_today_rounded, size: 20, color: cSlate),
                            items: List.generate(30, (i) => (DateTime.now().year - i).toString()),
                            onChanged: (v) => setState(() => _selectedYear = int.parse(v!)),
                          )),
                          const SizedBox(width: 12),
                          Expanded(child: _buildTextFieldTile(
                            controller: _mileageController,
                            label: 'Kilométrage',
                            icon: const Icon(Icons.speed_rounded, size: 20, color: cSlate),
                            keyboardType: TextInputType.number,
                            suffix: 'km',
                          )),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: _buildDropdownTile(
                            label: 'Carburant',
                            value: _selectedFuel.label,
                            icon: const Icon(Icons.local_gas_station_rounded, size: 20, color: cSlate),
                            items: FuelType.values.map((e) => e.label).toList(),
                            onChanged: (v) => setState(() => _selectedFuel = FuelType.values.firstWhere((e) => e.label == v)),
                          )),
                          const SizedBox(width: 12),
                          Expanded(child: _buildDropdownTile(
                            label: 'Boîte de vitesse',
                            value: _selectedTransmission.label,
                            icon: const Icon(Icons.settings_rounded, size: 20, color: cSlate),
                            items: TransmissionType.values.map((e) => e.label).toList(),
                            onChanged: (v) => setState(() => _selectedTransmission = TransmissionType.values.firstWhere((e) => e.label == v)),
                          )),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                _buildSectionTitle(
                  icon: Icons.settings_suggest_rounded,
                  title: 'Spécifications techniques',
                  subtitle: 'Détails techniques de votre véhicule.',
                ),
                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: cBorder),
                    boxShadow: [BoxShadow(color: cNavy.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 5))],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(child: _buildTextFieldTile(
                            controller: _powerController,
                            label: 'Puissance',
                            icon: const Icon(Icons.bolt_rounded, size: 20, color: cSlate),
                            suffix: 'ch',
                          )),
                          const SizedBox(width: 12),
                          Expanded(child: _buildTextFieldTile(
                            controller: _fiscalPowerController,
                            label: 'Puissance fiscale',
                            icon: const Icon(Icons.description_rounded, size: 20, color: cSlate),
                            suffix: 'CV',
                          )),
                          const SizedBox(width: 12),
                          Expanded(child: _buildTextFieldTile(
                            controller: _engineSizeController,
                            label: 'Cylindrée',
                            icon: const Icon(Icons.settings_rounded, size: 20, color: cSlate),
                            suffix: 'cm³',
                          )),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: _buildTextFieldTile(
                            controller: _engineCodeController,
                            label: 'Code moteur',
                            icon: const Icon(Icons.qr_code_rounded, size: 20, color: cSlate),
                            hint: 'Ex : D4, D5...',
                          )),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                _buildSectionTitle(
                  icon: Icons.sticky_note_2_rounded,
                  title: 'Notes personnelles',
                  subtitle: 'Ajoutez des informations utiles (numéro de série, historique, etc.).',
                ),
                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: cBorder),
                    boxShadow: [BoxShadow(color: cNavy.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 5))],
                  ),
                  child: TextFormField(
                    controller: _notesController,
                    maxLines: 4,
                    maxLength: 500,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: cValueText),
                    decoration: const InputDecoration(
                      hintText: 'Ex : VIN, remarques, historique d\'entretien...',
                      hintStyle: TextStyle(color: Color(0xFF9BAFCB), fontSize: 14),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [cOrangeLight, cOrange]),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: cOrange.withOpacity(0.2), blurRadius: 12, offset: const Offset(0, 5))],
                    ),
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveChanges,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: _isSaving
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.save_rounded, color: Colors.white, size: 20),
                                SizedBox(width: 8),
                                Text('Enregistrer les modifications', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
                              ],
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cBorder),
        boxShadow: [BoxShadow(color: cNavy.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        children: [
          Container(
            height: 100,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFFF1F5F9),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Center(
              child: _buildBrandLogo(size: 60),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${widget.vehicle.brand} ${widget.vehicle.model}',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: cNavy),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_selectedFuel.label} · ${_selectedTransmission.label}',
                        style: const TextStyle(fontSize: 13, color: cGreyText, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(color: cSuccessBg, borderRadius: BorderRadius.circular(20)),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle_rounded, color: cSuccessText, size: 14),
                      SizedBox(width: 4),
                      Text('Dans le garage', style: TextStyle(color: cSuccessText, fontSize: 11, fontWeight: FontWeight.w800)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle({required IconData icon, required String title, required String subtitle}) {
    return Row(
      children: [
        Icon(icon, color: cOrange, size: 32),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: cNavy)),
              Text(subtitle, style: const TextStyle(fontSize: 12, color: cGreyDesc)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIconCircle(Widget child) {
    return Container(
      width: 36,
      height: 36,
      decoration: const BoxDecoration(
        color: cIconBg,
        shape: BoxShape.circle,
      ),
      child: Center(child: child),
    );
  }

  Widget _buildDropdownTile({
    required String label,
    required String value,
    required Widget icon,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: cFieldBg, // ✅ Le fond gris clair
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.transparent), // ✅ Bordure invisible pour l'instant
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButtonFormField<String>(
          value: value,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: cGreyText, size: 20),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(color: cGreyText, fontSize: 11, fontWeight: FontWeight.w600),
            prefixIcon: _buildIconCircle(icon),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
            isDense: true,
          ),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: cValueText)))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildTextFieldTile({
    required TextEditingController controller,
    required String label,
    required Widget icon,
    String? hint,
    String? suffix,
    TextInputType? keyboardType,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: cFieldBg, // ✅ Le fond gris clair
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.transparent), // ✅ Bordure invisible
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: cValueText),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          suffixText: suffix,
          suffixStyle: const TextStyle(color: cGreyText, fontWeight: FontWeight.w600, fontSize: 12),
          labelStyle: const TextStyle(color: cGreyText, fontSize: 11, fontWeight: FontWeight.w600),
          hintStyle: const TextStyle(color: Color(0xFF9BAFCB), fontSize: 12),
          prefixIcon: _buildIconCircle(icon),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
          isDense: true,
        ),
      ),
    );
  }
}