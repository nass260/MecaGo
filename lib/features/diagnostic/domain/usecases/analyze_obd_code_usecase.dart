import 'package:flutter/material.dart';
import '../../infrastructure/services/obd_diagnostic_service.dart';

class AnalyzeObdCodeUseCase {
  final ObdDiagnosticService _obdService;

  // Injection de dépendance du service décodeur d'infrastructure
  const AnalyzeObdCodeUseCase({
    ObdDiagnosticService obdService = const ObdDiagnosticService(),
  }) : _obdService = obdService;

  /// Exécute l'action métier de décodage et de mise en forme du rapport de panne électronique bus CAN
  Future<Map<String, dynamic>> execute(String rawCode) async {
    try {
      // 1. Simulation du temps de lecture et d'interrogation de la mémoire électronique (ECU)
      await Future.delayed(const Duration(milliseconds: 1100));

      // 2. Appel au service d'infrastructure physique OBD2
      final Map<String, dynamic> decodedReport = _obdService.decodeObdCode(rawCode);

      // 3. Ajout de métadonnées temporelles métiers pour l'archivage du journal des pannes
      final DateTime now = DateTime.now();
      final String formattedTimestamp = "${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

      return {
        ...decodedReport,
        'timestamp': formattedTimestamp,
        'execution_status': 'SUCCESS',
      };
    } catch (e) {
      debugPrint("MecaGo Domain Error - Échec du traitement métier du code OBD2 : $e");
      return {
        'obd_code': rawCode,
        'description': "Impossible de finaliser l'analyse métier de ce code défaut.",
        'system_affected': "Inconnu",
        'action_required': "Veuillez vérifier les branchements physiques de votre boîtier.",
        'risk_level': 1,
        'color_value': 0xFF64748B,
        'is_clearable': false,
        'timestamp': "Indisponible",
        'execution_status': 'FAILED',
      };
    }
  }
}
