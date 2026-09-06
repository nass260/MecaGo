import 'package:flutter/material.dart';

class ObdDiagnosticService {
  const ObdDiagnosticService();

  /// Analyse un code erreur standard OBD2 (Format standardisé international : P0XXX)
  /// Récupéré par la prise diagnostic connectée au bus CAN du véhicule.
  Map<String, dynamic> decodeObdCode(String rawObdCode) {
    try {
      final String cleanCode = rawObdCode.trim().toUpperCase();
      
      String description = "Code défaut inconnu ou spécifique au constructeur.";
      String systemAffected = "Système électronique général";
      String actionRequired = "Veuillez effectuer un contrôle visuel de vos capteurs.";
      int riskLevel = 1; // 1 = Mineur (Vert), 2 = Modéré (Orange), 3 = Critique (Rouge)
      int colorValue = 0xFF10B981;

      // 1. Décodage du code P0101 (Débitmètre d'air - Injection)
      if (cleanCode == "P0101") {
        description = "Défaut de performance du circuit du débitmètre d'air massique.";
        systemAffected = "Admission d'air / Injection essence ou diesel";
        actionRequired = "Nettoyez le capteur de débit d'air ou remplacez votre filtre à air encrassé.";
        riskLevel = 2;
        colorValue = 0xFFFF6A00;
      }
      // 2. Décodage du code P0300 (Ratés d'allumage cylindres)
      else if (cleanCode.startsWith("P030")) {
        description = "Ratés d'allumage aléatoires détectés sur les cylindres du bloc moteur.";
        systemAffected = "Allumage et combustion interne";
        actionRequired = "Arrêt conseillé. Vérifiez l'état de vos bougies d'allumage ou bobines de feux.";
        riskLevel = 3;
        colorValue = 0xFFEF4444;
      }
      // 3. Décodage du code P0420 (Efficacité système catalyseur sous le seuil)
      else if (cleanCode == "P0420") {
        description = "Rendement du système de catalyseur inférieur au seuil de tolérance (Ligne 1).";
        systemAffected = "Échappement et dépollution anti-pollution";
        actionRequired = "Contrôlez l'étanchéité de la ligne d'échappement et les sondes lambda.";
        riskLevel = 2;
        colorValue = 0xFFFF6A00;
      }

      return {
        'obd_code': cleanCode,
        'description': description,
        'system_affected': systemAffected,
        'action_required': actionRequired,
        'risk_level': riskLevel,
        'color_value': colorValue,
        'is_clearable': riskLevel < 3, // On interdit l'effacement logiciel si le défaut est trop destructeur
      };
    } catch (e) {
      debugPrint("MecaGo OBD Service Error - Échec du décodage du bus CAN : $e");
      return {
        'obd_code': rawObdCode,
        'description': "Erreur lors de l'extraction logicielle du code défaut.",
        'system_affected': "Inconnu",
        'action_required': "Veuillez reconnecter votre adaptateur OBD2.",
        'risk_level': 1,
        'color_value': 0xFF64748B,
        'is_clearable': false,
      };
    }
  }
}
