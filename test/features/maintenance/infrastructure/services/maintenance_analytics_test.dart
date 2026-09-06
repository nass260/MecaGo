import 'package:flutter_test/flutter_test.dart';
import '../../../../../lib/features/maintenance/infrastructure/services/maintenance_analytics_service.dart';

void main() {
  group('MecaGo Analytics - Tests Unitaires Algorithme d\'Usure', () {
    const MaintenanceAnalyticsService analyticsService = MaintenanceAnalyticsService();

    test('1. Devrait retenir l’usure kilométrique si elle est plus critique que le temps', () {
      // Scénario : Le conducteur roule beaucoup (50% d'usure kilométrique, 25% d'usure temporelle)
      final result = analyticsService.calculateComponentHealth(
        componentName: "Plaquettes de frein",
        kilometersDrivenSinceLastService: 15000,
        maxKilometersLifespan: 30000, // 15 000 / 30 000 = 50% d'usure
        monthsSinceLastService: 6,
        maxMonthsLifespan: 24, // 6 / 24 = 25% d'usure
      );

      // L'algorithme doit retenir les 50% d'usure, il reste donc 50% de santé
      expect(result['health_percentage'], 50);
      expect(result['is_critical'], false);
      expect(result['color_value'], 0xFFFF6A00); // Doit passer en Orange (Entretien requis)
    });

    test('2. Devrait retenir l’usure temporelle si elle est plus critique que les kilomètres', () {
      // Scénario : Le véhicule roule peu mais le temps passe (10% usure km, 75% usure temporelle)
      final result = analyticsService.calculateComponentHealth(
        componentName: "Liquide de frein",
        kilometersDrivenSinceLastService: 2000,
        maxKilometersLifespan: 20000, // 10% d'usure
        monthsSinceLastService: 18,
        maxMonthsLifespan: 24, // 75% d'usure
      );

      // L'algorithme retient les 75% d'usure, il reste donc 25% de santé
      expect(result['health_percentage'], 25);
      expect(result['color_value'], 0xFFFF6A00); // Toujours Orange avant le seuil des 20%
    });

    test('3. Devrait déclencher une alerte critique rouge si la santé passe sous les 20%', () {
      // Scénario : Pièce en fin de vie totale
      final result = analyticsService.calculateComponentHealth(
        componentName: "Filtre Habitacle",
        kilometersDrivenSinceLastService: 27000,
        maxKilometersLifespan: 30000, // 90% d'usure -> 10% de santé restante
        monthsSinceLastService: 12,
        maxMonthsLifespan: 24,
      );

      expect(result['health_percentage'], 10);
      expect(result['is_critical'], true);
      expect(result['color_value'], 0xFFEF4444); // Rouge critique
    });
  });
}
