import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/premium_card.dart';
import '../../../../core/widgets/premium_button.dart';
import '../managers/garage_notifier.dart';

class GaragePage extends StatefulWidget {
  const GaragePage({super.key});

  @override
  State<GaragePage> createState() => _GaragePageState();
}

class _GaragePageState extends State<GaragePage> {
  final GarageNotifier _notifier = GarageNotifier();

  @override
  void initState() {
    super.initState();
    _notifier.loadGarageVehicles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Mon Garage',
          style: TextStyle(
            color: AppColors.navy,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _notifier,
          builder: (context, _) {
            if (_notifier.isLoading && _notifier.vehicles.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppColors.orange)),
              );
            }

            if (_notifier.errorMessage != null && _notifier.vehicles.isEmpty) {
              return Center(
                child: Text(
                  _notifier.errorMessage!,
                  style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                ),
              );
            }

            final vehicles = _notifier.vehicles;

            // 1. INCORPORATION DU REFRESH INDICATOR EN TÊTE DE LISTE MOBILE
            return RefreshIndicator(
              color: AppColors.orange,
              backgroundColor: Colors.white,
              onRefresh: () async {
                // Force la ré-interrogation asynchrone instantanée de la base SQLite
                await _notifier.loadGarageVehicles();
              },
              child: Column(
                children: [
                  // Carte de synthèse dynamique du Garage
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: PremiumCard(
                      child: Row(
                        children: [
                          Container(
                            width: 54,
                            height: 54,
                            decoration: BoxDecoration(
                              color: AppColors.orange.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(Icons.garage_rounded, color: AppColors.orange, size: 28),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  vehicles.isEmpty ? 'Aucun véhicule' : '${vehicles.length} véhicules enregistrés',
                                  style: const TextStyle(color: AppColors.navy, fontSize: 18, fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 4),
                                const Text('Tirez vers le bas pour actualiser les données.', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Liste défilante réactive
                  Expanded(
                    child: vehicles.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: const [
                              SizedBox(height: 80),
                              Center(child: Text("Votre garage est vide. Scannez une plaque !", style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600))),
                            ],
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                            itemCount: vehicles.length,
                            physics: const AlwaysScrollableScrollPhysics(), // Indispensable pour le Pull-to-Refresh
                            separatorBuilder: (_, __) => const SizedBox(height: 18),
                            itemBuilder: (context, index) {
                              final vehicle = vehicles[index];

                              return PremiumCard(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(18),
                                      child: AspectRatio(
                                        aspectRatio: 16 / 9,
                                        child: Image.network(
                                          vehicle.imageUrl ?? 'https://unsplash.com',
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 18),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${vehicle.brand} ${vehicle.model}',
                                                style: const TextStyle(color: AppColors.navy, fontSize: 22, fontWeight: FontWeight.w800),
                                              ),
                                              const SizedBox(height: 6),
                                              Row(
                                                children: [
                                                  const Icon(Icons.credit_card_rounded, size: 18, color: AppColors.textSecondary),
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    vehicle.plate,
                                                    style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                          decoration: BoxDecoration(
                                            color: vehicle.isAlert ? const Color(0xFFFFF7ED) : const Color(0xFFF0FDF4),
                                            borderRadius: BorderRadius.circular(999),
                                          ),
                                          child: Text(
                                            vehicle.isAlert ? 'Entretien requis' : 'À jour',
                                            style: TextStyle(
                                              color: vehicle.isAlert ? AppColors.orange : AppColors.success,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 18),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text('Santé du véhicule', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                                        Text('${(vehicle.progress * 100).round()}%', style: const TextStyle(color: AppColors.navy, fontWeight: FontWeight.w800)),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: LinearProgressIndicator(
                                        value: vehicle.progress,
                                        minHeight: 10,
                                        backgroundColor: const Color(0xFFE5E7EB),
