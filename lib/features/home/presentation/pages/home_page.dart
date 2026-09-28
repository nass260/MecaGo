// lib/features/home/presentation/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/premium_card.dart';
import '../../../../core/services/global_notifier.dart';
import '../../data/models/vehicle_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    GlobalNotifier.instance.addListener(_onNotifierChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      GlobalNotifier.instance.loadDashboardData();
    });
  }

  @override
  void dispose() {
    GlobalNotifier.instance.removeListener(_onNotifierChanged);
    super.dispose();
  }

  void _onNotifierChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final notifier = GlobalNotifier.instance;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: notifier,
          builder: (context, _) {
            if (notifier.isLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.orange),
                ),
              );
            }

            final vehicle = notifier.activeVehicle;

            return RefreshIndicator(
              onRefresh: () => notifier.refresh(),
              color: AppColors.orange,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                // ✅ CORRECTION 2 : padding bottom réduit de 100 à 30
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context),
                    // ✅ CORRECTION 1 : espace réduit de 18 à 8
                    const SizedBox(height: 8),
                    _buildGreeting(),
                    const SizedBox(height: 16),
                    _buildHeroCard(context, vehicle),
                    const SizedBox(height: 16),
                    _buildScoreCard(notifier),
                    const SizedBox(height: 14),
                    _buildQuickActions(context),
                    const SizedBox(height: 14),
                    _buildNextMission(context),
                    const SizedBox(height: 14),
                    _buildMainButton(context),
                    const SizedBox(height: 14),
                    _buildEstimationCard(context),
                    const SizedBox(height: 20),
                    _buildRecentActivity(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ============================================
  // HEADER COMPACT
  // ============================================

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(
            'assets/images/mecago_logo.jpg',
            width: 42,
            height: 42,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                gradient: AppGradients.orange,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.directions_car_filled_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'MecaGo',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.navy,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: 1),
              Text(
                'Votre véhicule. Votre autonomie.',
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.orange.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.orange.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.workspace_premium_rounded,
                  color: AppColors.orange, size: 14),
              SizedBox(width: 4),
              Text(
                'Premium',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.orange,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: () => context.go('/profile'),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E293B), Color(0xFF0A0F1C)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'AX',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: -4,
                right: -2,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: AppColors.orange,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.workspace_premium_rounded,
                    color: Colors.white,
                    size: 10,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================
  // GREETING
  // ============================================

  Widget _buildGreeting() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'BONJOUR',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: AppColors.textSecondary,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 2),
        Row(
          children: const [
            Text(
              'Alex',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: AppColors.navy,
                letterSpacing: -1,
              ),
            ),
            SizedBox(width: 8),
            Text('👋', style: TextStyle(fontSize: 26)),
          ],
        ),
      ],
    );
  }

  // ============================================
  // HERO CARD
  // ============================================

  Widget _buildHeroCard(BuildContext context, Vehicle? vehicle) {
    final brand = vehicle?.brand ?? 'Tesla';
    final model = vehicle?.model ?? 'Model 3';
    final plate = vehicle?.plate ?? 'AB-123-CD';

    return GestureDetector(
      onTap: () {
        if (vehicle != null) {
          context.push('/vehicle-details/${vehicle.id}');
        }
      },
      child: Container(
        height: 280,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Container(
                width: double.infinity,
                height: 280,
                decoration: const BoxDecoration(gradient: AppGradients.navy),
                child: Image.asset(
                  'assets/images/tesla_model_3.jpg',
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                  errorBuilder: (_, __, ___) => const Center(
                    child: Icon(Icons.directions_car_rounded,
                        color: Colors.white24, size: 80),
                  ),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.35),
                    Colors.transparent,
                    Colors.black.withOpacity(0.75),
                  ],
                  stops: const [0.0, 0.45, 1.0],
                ),
              ),
            ),
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.45),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.25),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.directions_car_rounded,
                        color: Colors.white, size: 12),
                    SizedBox(width: 5),
                    Text(
                      'VÉHICULE ACTIF',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.success,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.check_circle_rounded,
                        color: Colors.white, size: 12),
                    SizedBox(width: 4),
                    Text(
                      'En bon état',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 18,
              left: 18,
              right: 18,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$brand $model',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 14,
                          height: 18,
                          decoration: const BoxDecoration(
                            color: Color(0xFF003399),
                            borderRadius:
                                BorderRadius.all(Radius.circular(2)),
                          ),
                          child: const Center(
                            child: Text(
                              'F',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          plate,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: AppColors.navy,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${vehicle?.year ?? 2024} · ${vehicle?.fuelType.label ?? 'Électrique'} · ${vehicle?.transmission.label ?? 'Automatique'}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 11),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text(
                          'Voir les détails',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(width: 6),
                        Icon(Icons.chevron_right_rounded,
                            color: Colors.white, size: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================
  // SCORE CARD
  // ============================================

  Widget _buildScoreCard(dynamic notifier) {
    return PremiumCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 70,
                    height: 70,
                    child: CircularProgressIndicator(
                      value: 0.85,
                      strokeWidth: 6,
                      backgroundColor: AppColors.border.withOpacity(0.4),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.orange,
                      ),
                    ),
                  ),
                  const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '85',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: AppColors.navy,
                          height: 1,
                        ),
                      ),
                      Text(
                        '/100',
                        style: TextStyle(
                          fontSize: 8,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Text(
                          'MecaGo Score™',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AppColors.navy,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.info_outline_rounded,
                            size: 12, color: AppColors.textSecondary),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Excellent',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: AppColors.orange,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Votre véhicule est en très bon état.',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(height: 1, color: AppColors.border.withOpacity(0.5)),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: AppColors.successLight,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.savings_rounded,
                          color: AppColors.success, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Économies',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '125 €',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            color: AppColors.navy,
                          ),
                        ),
                        Text(
                          '+12 € ce mois-ci',
                          style: TextStyle(
                            fontSize: 9,
                            color: AppColors.success,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 50,
                color: AppColors.border.withOpacity(0.5),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.orange.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.star_rounded,
                          color: AppColors.orange, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Niveau',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Row(
                          children: const [
                            Text(
                              'Premium',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                color: AppColors.orange,
                              ),
                            ),
                            SizedBox(width: 3),
                            Text('👑', style: TextStyle(fontSize: 12)),
                          ],
                        ),
                        const Text(
                          'Avantages exclusifs',
                          style: TextStyle(
                            fontSize: 9,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================
  // QUICK ACTIONS
  // ============================================

  Widget _buildQuickActions(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _buildQuickAction(
              icon: Icons.qr_code_scanner_rounded,
              label: 'Scanner',
              subtitle: 'Plaque / VIN',
              badge: null,
              onTap: () => context.push('/scanner'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildQuickAction(
              icon: Icons.menu_book_rounded,
              label: 'Tutoriels',
              subtitle: 'Apprendre',
              badge: null,
              onTap: () => context.push('/tutorials'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildQuickAction(
              icon: Icons.notifications_active_rounded,
              label: 'Rappels',
              subtitle: 'À venir',
              badge: '3',
              onTap: () => context.push('/reminders'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildQuickAction(
              icon: Icons.directions_car_rounded,
              label: 'Garage',
              subtitle: 'Mes véhicules',
              badge: null,
              onTap: () => context.go('/garage'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required String subtitle,
    required String? badge,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: AppColors.orange, size: 22),
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.navy,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 1),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            if (badge != null)
              Positioned(
                top: 0,
                right: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.orange,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Text(
                    badge,
                    style: const TextStyle(
                      fontSize: 8,
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ============================================
  // PROCHAINE MISSION
  // ============================================

  Widget _buildNextMission(BuildContext context) {
    return PremiumCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Votre prochaine mission',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.navy,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => context.push('/maintenance'),
                child: Row(
                  children: const [
                    Text(
                      'Voir tout',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.orange,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(width: 2),
                    Icon(Icons.chevron_right_rounded,
                        color: AppColors.orange, size: 14),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(
                      value: 0.82,
                      strokeWidth: 5,
                      backgroundColor: AppColors.border.withOpacity(0.4),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.orange,
                      ),
                    ),
                  ),
                  const Text(
                    '82%',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: AppColors.navy,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Filtre habitacle HEPA',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.navy,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: const [
                        Icon(Icons.electric_car_rounded,
                            size: 12, color: AppColors.textSecondary),
                        SizedBox(width: 4),
                        Text(
                          'Tesla Model 3',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: const [
                        Icon(Icons.calendar_today_rounded,
                            size: 12, color: AppColors.textSecondary),
                        SizedBox(width: 4),
                        Text(
                          'Dans 8 500 km',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'assets/images/activity_filter.jpg',
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.filter_alt_rounded,
                        color: AppColors.orange, size: 24),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================
  // BOUTON PRINCIPAL
  // ============================================

  Widget _buildMainButton(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/maintenance'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: AppGradients.orange,
          borderRadius: BorderRadius.circular(18),
          boxShadow: AppShadows.orangeButton,
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.22),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.search_rounded,
                  color: Colors.white, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Démarrer un entretien',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Trouvez le bon tutoriel pour votre véhicule',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: Colors.white, size: 22),
          ],
        ),
      ),
    );
  }

  // ============================================
  // ESTIMATION
  // ============================================

  Widget _buildEstimationCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.orange.withOpacity(0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              'assets/images/estimation_car.jpg',
              width: 52,
              height: 52,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: AppGradients.orange,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.euro_rounded,
                    color: Colors.white, size: 24),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Combien vaut votre véhicule ?',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.navy,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2),
                Text(
                  'Estimation gratuite en 30 secondes',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('🚧 Estimation bientôt disponible !'),
                  backgroundColor: AppColors.orange,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                gradient: AppGradients.orange,
                borderRadius: BorderRadius.circular(18),
                boxShadow: AppShadows.orangeButton,
              ),
              child: const Text(
                'Estimer',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // ACTIVITÉ RÉCENTE
  // ============================================

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Text(
              'Activité récente',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppColors.navy,
              ),
            ),
            Spacer(),
            Text(
              'Voir tout',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.orange,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 110,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            children: const [
              _ActivityCard(
                image: 'assets/images/activity_filter.jpg',
                title: 'Remplacement HEPA',
                subtitle: 'Tesla Model 3',
                date: '12 avr. 2025',
              ),
              SizedBox(width: 10),
              _ActivityCard(
                image: 'assets/images/activity_washer.jpg',
                title: 'Liquide lave-glace',
                subtitle: 'Tesla Model 3',
                date: '28 fév. 2025',
              ),
              SizedBox(width: 10),
              _ActivityCard(
                image: 'assets/images/activity_tire.jpg',
                title: 'Rotation pneus',
                subtitle: 'Tesla Model 3',
                date: '15 jan. 2025',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ============================================
// ACTIVITY CARD
// ============================================

class _ActivityCard extends StatelessWidget {
  final String image;
  final String title;
  final String subtitle;
  final String date;

  const _ActivityCard({
    required this.image,
    required this.title,
    required this.subtitle,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              image,
              width: 56,
              height: 56,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.build_rounded,
                    color: AppColors.orange, size: 24),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppColors.navy,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check_rounded,
                          color: Colors.white, size: 10),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 9,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  date,
                  style: const TextStyle(
                    fontSize: 8,
                    color: AppColors.textLight,
                    fontWeight: FontWeight.w600,
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