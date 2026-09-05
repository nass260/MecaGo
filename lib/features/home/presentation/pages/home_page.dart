import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/premium_card.dart';
import '../managers/home_notifier.dart'; // <-- 1. Importation du gestionnaire d'état

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Initialisation du contrôleur connecté du Sprint 4
  final HomeNotifier _notifier = HomeNotifier();

  @override
  void initState() {
    super.initState();
    // Déclenche le chargement global de la base SQLite à l'ouverture de l'application
    _notifier.loadDashboardData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _notifier,
          builder: (context, _) {
            // Indicateur de chargement premium iOS Style pendant l'agrégation
            if (_notifier.isLoading) {
              return const Center(
                child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppColors.orange)),
              );
            }

            final vehicle = _notifier.activeVehicle;

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                  // 1. EN-TÊTE UTILISATEUR COMPLET DE LA MAQUETTE
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Bonjour Alex 👋',
                            style: TextStyle(color: AppColors.navy, fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: -0.5),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            vehicle != null ? 'Prêt pour entretenir votre ${vehicle.brand} ?' : 'Prêt pour entretenir votre véhicule ?',
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 46,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: const DecorationImage(
                                image: NetworkImage('https://unsplash.com'),
                                fit: BoxFit.cover,
                              ),
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                          const Positioned(
                            top: -8,
                            right: -4,
                            child: Text('👑', style: TextStyle(fontSize: 14)),
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // 2. DOUBLE COMPTEUR AUTOMATISÉ (SCORE & ÉCONOMIES REELLES)
                  Row(
                    children: [
                      Expanded(
                        child: PremiumCard(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: const [
                                  Text('MecaGo Score™', style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w600)),
                                  Icon(Icons.info_outline_rounded, size: 14, color: AppColors.textSecondary),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      SizedBox(
                                        width: 44,
                                        height: 44,
                                        child: CircularProgressIndicator(
                                          value: vehicle != null ? vehicle.progress : 0.85,
                                          strokeWidth: 4.5,
                                          backgroundColor: AppColors.border,
                                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.orange),
                                        ),
                                      ),
                                      const Icon(Icons.shield_rounded, size: 18, color: AppColors.orange),
                                    ],
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('${_notifier.mecaGoScore}', style: const TextStyle(color: AppColors.navy, fontSize: 24, fontWeight: FontWeight.w900)),
                                        const Text('Très bon ★', style: TextStyle(color: AppColors.orange, fontSize: 11, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: PremiumCard(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Économies réalisées', style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: const BoxDecoration(color: Color(0xFFF0FDF4), shape: BoxShape.circle),
                                    child: const Icon(Icons.savings_rounded, color: AppColors.success, size: 22),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('${_notifier.totalSavings} €', style: const TextStyle(color: AppColors.navy, fontSize: 24, fontWeight: FontWeight.w900)),
                                        const Text('+12 € ce mois-ci', style: TextStyle(color: AppColors.success, fontSize: 11, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // 3. LA CARTE TESLA DYNAMIQUE AVEC DONNÉES DU SEEDER
                  if (vehicle != null) ...[
                    PremiumCard(
                      padding: EdgeInsets.zero,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            children: [
                              Container(
                                height: 180,
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                                  image: DecorationImage(
                                    image: NetworkImage(vehicle.imageUrl ?? 'https://unsplash.com'),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Container(
