import 'package:flutter/material.dart';
import '../../infrastructure/services/fluid_specification_service.dart';

class GetFluidSpecUseCase {
  final FluidSpecificationService _fluidService;

  // Injection de dépendance du service technique d'infrastructure
  const GetFluidSpecUseCase({
    FluidSpecificationService fluidService = const FluidSpecificationService(),
  }) : _fluidService = fluidService;

  /// Exécute la règle métier de récupération des huiles et fluides certifiés constructeurs.
  Future<Map<String, dynamic>> execute(String vehicleBrand) async {
    try {
      // 1. Simulation du traitement asynchrone du dictionnaire de viscosité
      await Future.delayed(const Duration(milliseconds: 300));

      // 2. Interrogation du service de spécification technique
      final Map<String, dynamic> fluidSpecs = _fluidService.getRequiredFluids(vehicleBrand);

      return {
        ...fluidSpecs,
        'calculated_at_timestamp': DateTime.now().toIso8601String(),
        'validation_status': 'APPROVED',
      };
    } catch (e) {
      debugPrint("MecaGo Domain Error - Échec du traitement métier des fluides : $e");
      return {
        'fluid_type': "Huile Générique",
        'specification': "Standard multi-constructeurs",
        'capacity_liters': 4.0,
        'viscosity': "10W-40",
        'change_interval': "Vérification visuelle immédiate requise",
        'coolant_spec': "Liquide universel",
        'washer_fluid': "Standard",
        'validation_status': 'FAILED',
      };
    }
  }
}
