// lib/core/navigation/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../features/home/presentation/pages/home_page.dart';
import '../../../features/home/presentation/pages/vehicle_details_page.dart';
import '../../../features/home/presentation/pages/maintenance_page.dart';
import '../../../features/home/presentation/pages/reminders_page.dart';
import '../../../features/home/presentation/pages/tutorials_page.dart';
import '../../../features/garage/presentation/pages/garage_page.dart';
import '../../../features/garage/presentation/pages/add_vehicle_page.dart';
import '../../../features/garage/presentation/pages/cascade_search_page.dart';
import '../../../features/garage/presentation/pages/plate_scanner_page.dart';
import '../../../features/garage/presentation/pages/vin_input_page.dart';
import '../../../features/garage/presentation/pages/vehicle_result_page.dart';
import '../../../features/scanner/presentation/pages/scanner_page.dart';
import '../../../features/history/presentation/pages/history_page.dart';
import '../../../features/profile/presentation/pages/profile_page.dart';
import '../../../features/authentication/presentation/pages/paywall_page.dart';

class AppRouter {
  const AppRouter();
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/paywall',
        builder: (context, state) => const PaywallPage(),
      ),
      GoRoute(
        path: '/add-vehicle',
        builder: (context, state) => const AddVehiclePage(),
      ),
      GoRoute(
        path: '/plate-scanner',
        builder: (context, state) => const PlateScannerPage(),
      ),
      GoRoute(
        path: '/vin-input',
        builder: (context, state) => const VinInputPage(),
      ),
      GoRoute(
        path: '/cascade-search',
        builder: (context, state) => const CascadeSearchPage(),
      ),
      GoRoute(
        path: '/vehicle-result',
        builder: (context, state) {
          final brand = state.uri.queryParameters['brand'] ?? '';
          final model = state.uri.queryParameters['model'] ?? '';
          final engine = state.uri.queryParameters['engine'] ?? '';
          final year =
              int.tryParse(state.uri.queryParameters['year'] ?? '') ?? 2020;
          return VehicleResultPage(
            brand: brand,
            model: model,
            engine: engine,
            year: year,
          );
        },
      ),
      GoRoute(
        path: '/vehicle-details/:vehicleId',
        builder: (context, state) {
          final vehicleId = state.pathParameters['vehicleId']!;
          return VehicleDetailsPage(vehicleId: vehicleId);
        },
      ),
      GoRoute(
        path: '/maintenance',
        builder: (context, state) => const MaintenancePage(),
      ),
      GoRoute(
        path: '/reminders',
        builder: (context, state) => const RemindersPage(),
      ),
      GoRoute(
        path: '/tutorials',
        builder: (context, state) => const TutorialsPage(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return Scaffold(
            body: navigationShell,
            bottomNavigationBar: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  )
                ],
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildItem(
                      Icons.home_rounded,
                      'Accueil',
                      navigationShell.currentIndex == 0,
                      () => navigationShell.goBranch(0),
                    ),
                    _buildItem(
                      Icons.home_repair_service_rounded,
                      'Garage',
                      navigationShell.currentIndex == 1,
                      () => navigationShell.goBranch(1),
                    ),
                    Transform.translate(
                      offset: const Offset(0, -16),
                      child: GestureDetector(
                        onTap: () => context.push('/scanner'),
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF6A00),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFF6A00)
                                    .withOpacity(0.35),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              )
                            ],
                          ),
                          child: const Icon(
                            Icons.qr_code_scanner_rounded,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                      ),
                    ),
                    _buildItem(
                      Icons.history_rounded,
                      'Historique',
                      navigationShell.currentIndex == 3,
                      () => navigationShell.goBranch(3),
                    ),
                    _buildItem(
                      Icons.person_rounded,
                      'Profil',
                      navigationShell.currentIndex == 4,
                      () => navigationShell.goBranch(4),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const HomePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/garage',
                builder: (context, state) => const GaragePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/scanner',
                builder: (context, state) => const ScannerPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/history',
                builder: (context, state) => const HistoryPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfilePage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );

  static Widget _buildItem(
    IconData icon,
    String label,
    bool isSelected,
    VoidCallback onTap,
  ) {
    final color =
        isSelected ? const Color(0xFFFF6A00) : const Color(0xFF94A3B8);
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}