import 'package:flutter/material.dart';

class FluidSpecificationService {
  const FluidSpecificationService();

  /// Extrait les spécifications de fluides d'origine constructeur adaptées
  /// à la marque du véhicule français identifié par le scanner de plaque.
  Map<String, dynamic> getRequiredFluids(String vehicleBrand) {
    try {
      final String brand = vehicleBrand.toUpperCase();

      // 1. Spécifications pour un Véhicule Électrique (Ex: Tesla Model 3)
      if (brand == "TESLA") {
        return {
          'fluid_type': "Huile de réducteur / Transmission",
          'specification': "Tesla ATF Fluid (Fluide 100% Synthétique)",
          'capacity_liters': 2.1,
          'viscosity': "N/A (Électrique)",
          'change_interval': "Contrôle tous les 80 000 km",
          'coolant_spec': "Liquide de refroidissement G48 (Haute tension)",
          'washer_fluid': "Lave-glace hiver anti-gel certifié",
        };
      }

      // 2. Spécifications pour une marque française dominante (Ex: Renault, Peugeot, Citroën)
      if (brand == "RENAULT" || brand == "PEUGEOT" || brand == "CITROEN") {
        return {
          'fluid_type': "Huile Moteur Thermique",
          'specification': brand == "RENAULT" ? "Norme RN17 / ACEA C3" : "Norme PSA B71 2312",
          'capacity_liters': brand == "RENAULT" ? 4.5 : 3.6, // Capacité carter standard Clio / 208
          'viscosity': "5W-30 LongLife",
          'change_interval': "Changement tous les 15 000 km ou 12 mois",
          'coolant_spec': "Liquide de refroidissement Type D (Universel)",
          'washer_fluid': "Lave-glace toutes saisons anti-trace",
        };
      }

      // 3. Spécifications de secours par défaut
      return {
        'fluid_type': "Huile Moteur Générique",
        'specification': "Norme Standard ACEA C3",
        'capacity_liters': 4.0,
        'viscosity': "5W-40 Multigrade",
        'change_interval': "Changement conseillé tous les 10 000 km",
        'coolant_spec': "Liquide universel prêt à l'emploi",
        'washer_fluid': "Lave-glace standard",
      };
    } catch (e) {
      debugPrint("MecaGo Fluid Service Error - Échec du calcul des fluides : $e");
      return {
        'fluid_type': "Inconnu",
        'specification': "Consulter le manuel constructeur",
        'capacity_liters': 0.0,
        'viscosity': "Inconnue",
        'change_interval': "Inspection immédiate requise",
        'coolant_spec': "Inconnu",
        'washer_fluid': "Standard",
      };
    }
  }
}
