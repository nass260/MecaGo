import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/premium_card.dart';
import '../../../../core/widgets/premium_button.dart';
import '../managers/home_notifier.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HomeNotifier _notifier = HomeNotifier();

  @override
  void initState() {
    super.initState();
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
            if (_notifier.isLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.orange),
                ),
              );
            }

            final vehicle = _notifier.activeVehicle;

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. EN-TÊTE UTILISATEUR AVEC LA MAIN ET L'AVATAR PREMIUM
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Text(
                                'Bonjour Alex',
                                style: TextStyle(color: AppColors.navy, fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: -0.6),
                              ),
                              SizedBox(width: 6),
                              Text('👋', style: TextStyle(fontSize: 24)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            vehicle != null ? 'Prêt pour entretenir votre ${vehicle.brand} ?' : 'Prêt pour entretenir votre Tesla ?',
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => context.push('/profile'),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 4))],
                                gradient: const LinearGradient(colors: [Color(0xFF1E293B), Color(0xFF0F172A)]),
                              ),
                              child: const Center(
                                child: Text('AX', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                              ),
                            ),
                            const Positioned(top: -10, right: -4, child: Text('👑', style: TextStyle(fontSize: 16))),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 2. DOUBLE COMPTEUR DANS SON GRAND RECTANGLE BLANC ARRONDI UNIQUE
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.border.withOpacity(0.4)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: const [
                                  Text('MecaGo Score™', style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.bold)),
                                  SizedBox(width: 4),
                                  Icon(Icons.info_outline_rounded, size: 13, color: AppColors.textSecondary),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      SizedBox(
                                        width: 38,
                                        height: 38,
                                        child: CircularProgressIndicator(
                                          value: vehicle != null ? vehicle.progress : 0.85,
                                          strokeWidth: 4.0,
                                          backgroundColor: AppColors.border.withOpacity(0.5),
                                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.orange),
                                        ),
                                      ),
                                      const Icon(Icons.shield_rounded, size: 14, color: AppColors.orange),
                                    ],
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('${_notifier.mecaGoScore}', style: const TextStyle(color: AppColors.navy, fontSize: 22, fontWeight: FontWeight.w900)),
                                        const Text('Très bon ★', style: TextStyle(color: AppColors.orange, fontSize: 10, fontWeight: FontWeight.bold)),
                                        const Text('Continuez comme ça !', style: TextStyle(color: AppColors.textSecondary, fontSize: 9, fontWeight: FontWeight.w500)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(width: 1, height: 70, color: AppColors.border.withOpacity(0.5), margin: const EdgeInsets.symmetric(horizontal: 8)),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Économies réalisées', style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: const BoxDecoration(color: Color(0xFFF0FDF4), shape: BoxShape.circle),
                                    child: const Icon(Icons.savings_rounded, color: AppColors.success, size: 18),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('${_notifier.totalSavings} €', style: const TextStyle(color: AppColors.navy, fontSize: 22, fontWeight: FontWeight.w900)),
                                        const Text('+12 € ce mois-ci', style: TextStyle(color: AppColors.success, fontSize: 10, fontWeight: FontWeight.bold)),
                                        const Text('Bravo !', style: TextStyle(color: AppColors.textSecondary, fontSize: 9, fontWeight: FontWeight.w500)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
