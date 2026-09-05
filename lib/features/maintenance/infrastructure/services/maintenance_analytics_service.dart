import 'package:flutter/material.dart';

class MaintenanceAnalyticsService {
  const MaintenanceAnalyticsService();

  /// Calcule l'usure dynamique et l'indice de santé d'une pièce mécanique
  /// en combinant les kilomètres parcourus et le temps écoulé depuis le dernier entretien.
  Map<String, dynamic> calculateComponentHealth({
    required String componentName,
    required int kilometersDrivenSinceLastService,
    required int monthsSinceLastService,
    required int maxKilometersLifespan,
    required int maxMonthsLifespan,
  }) {
    try {
      // 1. Calcul du taux d'usure basé sur le kilométrage (ex: 15 000 km parcourus sur 30 000 km max = 50% d'usure)
      final double mileageWearRatio = kilometersDrivenSinceLastService / maxKilometersLifespan;

      // 2. Calcul du taux d'usure basé sur le temps (ex: 12 mois écoulés sur 24 mois max = 50% d'usure)
      final double timeWearRatio = monthsSinceLastService / maxMonthsLifespan;

      // 3. Règle de sécurité automobile : On retient toujours l'usure la plus critique des deux facteurs
      final double maximumWearRatio = mileageWearRatio > timeWearRatio ? mileageWearRatio : timeWearRatio;

      // 4. Déduction de la santé restante (en pourcentage de 0 à 100)
      int healthRemaining = ((1.0 - maximumWearRatio) * 100).round();

      if (healthRemaining < 0) healthRemaining = 0;
      if (healthRemaining > 100) healthRemaining = 100;

      // 5. Attribution dynamique de la charte couleur MecaGo officielle selon l'urgence
      int colorValue = 0xFF10B981; // Vert par défaut (Santé optimale)
      String statusMessage = "État optimal";

      if (healthRemaining <= 20) {
        colorValue = 0xFFEF4444; // Rouge (Urgence critique, remplacement immédiat)
        statusMessage = "Remplacement urgent requis";
      } else if (healthRemaining <= 50) {
        colorValue = 0xFFFF6A00; // Orange MecaGo (Alerte d'entretien recommandée)
        statusMessage = "Entretien requis prochainement";
      }

      return {
        'component_name': componentName,
        'health_percentage': healthRemaining,
        'color_value': colorValue,
        'status_message': statusMessage,
        'is_critical': healthRemaining <= 20,
      };
    } catch (e) {
      debugPrint("MecaGo Analytics Error - Échec du calcul de dégradation : $e");
      return {
        'component_name': componentName,
        'health_percentage': 100,
        'color_value': 0xFF10B981,
        'status_message': "Données indisponibles",
        'is_critical': false,
      };
    }
  }
}
