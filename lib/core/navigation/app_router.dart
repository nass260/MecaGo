import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/home/presentation/pages/home_page.dart';
import '../../features/garage/presentation/pages/garage_page.dart';
import '../../features/plate_scanner/presentation/pages/scanner_page.dart';
import '../../features/history/presentation/pages/history_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/vehicle_details/presentation/pages/vehicle_details_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/maintenance/presentation/pages/tutorial_catalog_page.dart';
import '../../features/maintenance/presentation/pages/tutorial_page.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    // L'application démarre d'abord sur l'Onboarding de bienvenue
    initialLocation: '/onboarding',
    routes: [
      // Route de l'Onboarding
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),
      
      // Structure des 5 onglets principaux de l'application
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainNavigationShell(navigationShell: navigationShell);
        },
        branches: [
          // Onglet 1 : Accueil
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                name: 'home',
                builder: (context, state) => const HomePage(),
              ),
            ],
          ),
          // Onglet 2 : Garage
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/garage',
                name: 'garage',
                builder: (context, state) => const GaragePage(),
              ),
            ],
          ),
          // Onglet 3 : Scanner de Plaque
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/scanner',
                name: 'scanner',
                builder: (context, state) => const ScannerPage(),
                routes: [
                  // Sous-route : Fiche technique du véhicule détecté
                  GoRoute(
                    path: 'vehicle-details',
                    name: 'vehicle-details',
                    builder: (context, state) => const VehicleDetailsPage(),
                    routes: [
                      // Sous-route : Catalogue des tutoriels de la Tesla
                      GoRoute(
                        path: 'tutorials',
                        name: 'tutorials',
                        builder: (context, state) => const TutorialCatalogPage(),
                        routes: [
                          // Sous-route : Un tutoriel interactif étape par étape
                          GoRoute(
                            path: 'detail',
                            name: 'tutorial-detail',
                            builder: (context, state) => const TutorialPage(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          // Onglet 4 : Historique des économies
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/history',
                name: 'history',
                builder: (context, state) => const HistoryPage(),
              ),
            ],
          ),
          // Onglet 5 : Profil Utilisateur
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                name: 'profile',
                builder: (context, state) => const ProfilePage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

class MainNavigationShell extends StatelessWidget {
  const MainNavigationShell({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Accueil',
          ),
          NavigationDestination(
            icon: Icon(Icons.directions_car_outlined),
            selectedIcon: Icon(Icons.directions_car),
            label: 'Garage',
          ),
          NavigationDestination(
            icon: Icon(Icons.document_scanner_outlined),
            selectedIcon: Icon(Icons.document_scanner),
            label: 'Scanner',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history),
            label: 'Historique',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
