import 'package:flutter/material.dart';

class TyreMaintenanceService {
  const TyreMaintenanceService();

  /// Calcule l'usure théorique des pneumatiques selon le kilométrage parcouru 
  /// et applique un coefficient d'usure selon le type de propulsion (Thermique / Électrique).
  Map<String, dynamic> evaluateTyreWear({
    required String tyreBrand, // Ex: "Michelin Primacy 4", "Continental"
    required int kilometersDriven,
    required bool isElectricVehicle, // Les Tesla usent 20% plus de gomme à cause du couple immédiat
  }) {
    try {
      // Durée de vie moyenne d'un pneumatique premium en France : 40 000 km
      const int maxTyreLifespan = 40000;
      
      // Application du coefficient multiplicateur de friction de l'écosystème électrique
      final double drivetrainMultiplier = isElectricVehicle ? 1.25 : 1.0;
      
      final double calculatedWear = (kilometersDriven / maxTyreLifespan) * drivetrainMultiplier;
      int healthRemaining = ((1.0 - calculatedWear) * 100).round();

      if (healthRemaining < 0) healthRemaining = 0;
      if (healthRemaining > 100) healthRemaining = 100;

      String recommendation = "Pression et parallélisme conformes.";
      int urgencyColor = 0xFF10B981; // Vert

      if (healthRemaining <= 20) {
        recommendation = "Remplacement immédiat requis. Risque d'aquaplaning élevé.";
        urgencyColor = 0xFFEF4444; // Rouge
      } else if (healthRemaining <= 50) {
        recommendation = "Inversion AV/AR préconisée pour homogénéiser l'usure.";
        urgencyColor = 0xFFFF6A00; // Orange
      }

      return {
        'tyre_brand': tyreBrand,
        'health_percentage': healthRemaining,
        'recommendation': recommendation,
        'color_value': urgencyColor,
        'required_pressure_bar': isElectricVehicle ? 2.9 : 2.3, // Les Tesla nécessitent une pression plus haute
      };
    } catch (e) {
      debugPrint("MecaGo Tyre Service Error - Échec du calcul d'usure : $e");
      return {
        'tyre_brand': 'Générique',
        'health_percentage': 100,
        'recommendation': "Inspection visuelle requise.",
        'color_value': 0xFF10B981,
        'required_pressure_bar': 2.4,
      };
    }
  }
}
