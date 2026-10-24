// lib/features/home/presentation/pages/vehicle_details_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/premium_button.dart';
import '../../data/models/vehicle_model.dart';
import '../managers/home_notifier.dart';
import 'edit_vehicle_page.dart';

class VehicleDetailsPage extends StatefulWidget {
  final String vehicleId;
  const VehicleDetailsPage({super.key, required this.vehicleId});

  @override
  State<VehicleDetailsPage> createState() => _VehicleDetailsPageState();
}

class _VehicleDetailsPageState extends State<VehicleDetailsPage> {
  final HomeNotifier _notifier = HomeNotifier();
  Vehicle? _vehicle;
  bool _isLoading = true;

  // Palette MecaGo
  static const Color cOrange = Color(0xFFFF7417);
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
  static const Color cFieldBg = Color(0xFFF1F5F9);

  final List<Map<String, dynamic>> _maintenanceHistory = [
    {'date': '15 Mars 2026', 'title': 'Vidange moteur', 'cost': 89.00, 'saved': 45.00, 'icon': Icons.opacity_rounded, 'color': cOrange},
    {'date': '02 Janvier 2026', 'title': 'Filtre habitacle HEPA', 'cost': 34.50, 'saved': 20.00, 'icon': Icons.filter_alt_rounded, 'color': cSuccessText},
    {'date': '20 Octobre 2025', 'title': 'Plaquettes de frein', 'cost': 120.00, 'saved': 60.00, 'icon': Icons.car_repair_rounded, 'color': cDanger},
    {'date': '15 Août 2025', 'title': 'Changement pneus', 'cost': 320.00, 'saved': 80.00, 'icon': Icons.tire_repair_rounded, 'color': Colors.purple},
  ];

  @override
  void initState() {
    super.initState();
    _loadVehicleData();
  }

  @override
  void dispose() {
    _notifier.dispose();
    super.dispose();
  }

  Future<void> _loadVehicleData() async {
    setState(() => _isLoading = true);
    await _notifier.loadDashboardData();
    try {
      _vehicle = _notifier.vehicles.firstWhere((v) => v.id == widget.vehicleId);
    } catch (e) {
      _vehicle = null;
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Widget _buildBrandLogo({double size = 24}) {
    if (_vehicle == null) return const SizedBox();
    final brand = _vehicle!.brand.toLowerCase();
    final assetPath = 'assets/images/brands/$brand.png';
    return Image.asset(
      assetPath,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => Icon(Icons.directions_car_rounded, size: size, color: cSlate),
    );
  }

  void _showOptionsMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Material(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 40, height: 4, decoration: BoxDecoration(color: cBorder, borderRadius: BorderRadius.circular(2))),
                const SizedBox(height: 20),
                ListTile(
                  leading: const Icon(Icons.edit_rounded, color: cNavy),
                  title: const Text('Modifier le véhicule', style: TextStyle(fontWeight: FontWeight.w700)),
                  onTap: () {
                    Navigator.pop(context);
                    if (_vehicle != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => EditVehiclePage(vehicle: _vehicle!)),
                      ).then((_) => _loadVehicleData());
                    }
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.delete_rounded, color: cDanger),
                  title: const Text('Supprimer le véhicule', style: TextStyle(fontWeight: FontWeight.w700, color: cDanger)),
                  onTap: () {
                    Navigator.pop(context);
                    _confirmDelete();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Supprimer ce véhicule ?', style: TextStyle(fontWeight: FontWeight.w800)),
        content: const Text('Cette action est irréversible. Toutes les données liées à ce véhicule seront perdues.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler', style: TextStyle(color: cGreyText))),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: cDanger, elevation: 0),
            child: const Text('Supprimer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true && _vehicle != null) {
      await _notifier.deleteVehicle(_vehicle!.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Véhicule supprimé'), backgroundColor: cSuccessText));
        context.go('/garage');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cBg,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(cOrange)))
            : _vehicle != null
                ? _buildContent(_vehicle!)
                : _buildEmptyState(),
      ),
    );
  }

  Widget _buildContent(Vehicle vehicle) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // --- EN-TÊTE ---
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded, color: cNavy),
                      onPressed: () => context.pop(),
                    ),
                    IconButton(
                      icon: const Icon(Icons.more_horiz_rounded, color: cNavy),
                      onPressed: _showOptionsMenu,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
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
                        child: Center(child: _buildBrandLogo(size: 60)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${vehicle.brand} ${vehicle.model}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: cNavy)),
                                  const SizedBox(height: 4),
                                  Text('${vehicle.fuelType.label} · ${vehicle.transmission.label}', style: const TextStyle(fontSize: 13, color: cGreyText, fontWeight: FontWeight.w600)),
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
                ),
              ],
            ),
          ),
        ),

        // --- STATS RAPIDES (AJUSTÉES) ---
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: _buildStatCard(icon: Icons.speed_rounded, label: 'Kilométrage', value: '${vehicle.mileage} km', color: cOrange)),
                  const SizedBox(width: 10),
                  Expanded(child: _buildStatCard(icon: Icons.favorite_rounded, label: 'Santé', value: '${(vehicle.progress * 100).toInt()}%', color: cSuccessText)),
                  const SizedBox(width: 10),
                  Expanded(child: _buildStatCard(icon: Icons.build_rounded, label: 'Entretiens', value: '${_maintenanceHistory.length}', color: cNavy)),
                ],
              ),
            ),
          ),
        ),

        // --- INFORMATIONS GÉNÉRALES ---
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 32, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle(icon: Icons.directions_car_filled_rounded, title: 'Informations générales', subtitle: 'Détails de votre véhicule.'),
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
                          Expanded(child: _buildInfoTile(label: 'Marque', value: vehicle.brand, icon: _buildBrandLogo(size: 20))),
                          const SizedBox(width: 12),
                          Expanded(child: _buildInfoTile(label: 'Modèle', value: vehicle.model, icon: const Icon(Icons.directions_car_filled_rounded, size: 20, color: cSlate))),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: _buildInfoTile(label: 'Année', value: vehicle.year.toString(), icon: const Icon(Icons.calendar_today_rounded, size: 20, color: cSlate))),
                          const SizedBox(width: 12),
                          Expanded(child: _buildInfoTile(label: 'Kilométrage', value: '${vehicle.mileage} km', icon: const Icon(Icons.speed_rounded, size: 20, color: cSlate))),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: _buildInfoTile(label: 'Carburant', value: vehicle.fuelType.label, icon: const Icon(Icons.local_gas_station_rounded, size: 20, color: cSlate))),
                          const SizedBox(width: 12),
                          Expanded(child: _buildInfoTile(label: 'Boîte de vitesse', value: vehicle.transmission.label, icon: const Icon(Icons.settings_rounded, size: 20, color: cSlate))),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // --- SPÉCIFICATIONS TECHNIQUES ---
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 32, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle(icon: Icons.settings_suggest_rounded, title: 'Spécifications techniques', subtitle: 'Détails techniques de votre véhicule.'),
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
                          Expanded(child: _buildInfoTile(label: 'Puissance', value: vehicle.power ?? '-', icon: const Icon(Icons.bolt_rounded, size: 20, color: cSlate))),
                          const SizedBox(width: 12),
                          Expanded(child: _buildInfoTile(label: 'Puissance fiscale', value: vehicle.fiscalPower ?? '-', icon: const Icon(Icons.description_rounded, size: 20, color: cSlate))),
                          const SizedBox(width: 12),
                          Expanded(child: _buildInfoTile(label: 'Cylindrée', value: vehicle.engineSize ?? '-', icon: const Icon(Icons.settings_rounded, size: 20, color: cSlate))),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: _buildInfoTile(label: 'Code moteur', value: vehicle.engineCode ?? '-', icon: const Icon(Icons.qr_code_rounded, size: 20, color: cSlate))),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // --- NOTES PERSONNELLES ---
        if (vehicle.notes != null && vehicle.notes!.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 32, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle(icon: Icons.sticky_note_2_rounded, title: 'Notes personnelles', subtitle: 'Vos remarques et informations.'),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: cBorder),
                      boxShadow: [BoxShadow(color: cNavy.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 5))],
                    ),
                    child: Text(vehicle.notes!, style: const TextStyle(fontSize: 14, color: cValueText, height: 1.5)),
                  ),
                ],
              ),
            ),
          ),

        // --- HISTORIQUE ---
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 32, 20, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('Historique des entretiens', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: cNavy)),
                Text('Voir tout →', style: TextStyle(fontSize: 12, color: cOrange, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _buildMaintenanceCard(_maintenanceHistory[index]),
              ),
              childCount: _maintenanceHistory.length,
            ),
          ),
        ),

        // --- BOUTONS ---
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
            child: Column(
              children: [
                PremiumButton(text: '🔧 Démarrer un entretien', onPressed: () => context.push('/maintenance')),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => context.push('/scanner'),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: cBorder),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    minimumSize: const Size(double.infinity, 56),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.qr_code_scanner_rounded, color: cGreyText, size: 20),
                      SizedBox(width: 10),
                      Text('Scanner une pièce', style: TextStyle(color: cGreyText, fontSize: 16, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ============================================
  // WIDGETS DE LA VITRINE
  // ============================================

  // ✅ WIDGET AJUSTÉ POUR PLUS DE FINESSE
  Widget _buildStatCard({required IconData icon, required String label, required String value, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cBorder),
        boxShadow: [BoxShadow(color: cNavy.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(color: cIconBg, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: color)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: cGreyText), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
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
      width: 36, height: 36,
      decoration: const BoxDecoration(color: cIconBg, shape: BoxShape.circle),
      child: Center(child: child),
    );
  }

  Widget _buildInfoTile({required String label, required String value, required Widget icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: cFieldBg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _buildIconCircle(icon),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: cGreyText)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: cValueText), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaintenanceCard(Map<String, dynamic> item) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cBorder),
        boxShadow: [BoxShadow(color: cNavy.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(color: (item['color'] as Color).withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
            child: Icon(item['icon'] as IconData, color: item['color'] as Color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['title'] as String, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: cNavy)),
                const SizedBox(height: 2),
                Text(item['date'] as String, style: const TextStyle(fontSize: 11, color: cGreyText)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${(item['cost'] as double).toStringAsFixed(2)} €', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: cNavy)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: cSuccessBg, borderRadius: BorderRadius.circular(8)),
                child: Text('−${(item['saved'] as double).toStringAsFixed(0)} €', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: cSuccessText)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.directions_car_rounded, size: 80, color: cBorder),
          const SizedBox(height: 16),
          const Text('Véhicule introuvable', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: cNavy)),
          const SizedBox(height: 24),
          PremiumButton(text: 'Retour au garage', onPressed: () => context.go('/garage')),
        ],
      ),
    );
  }
}