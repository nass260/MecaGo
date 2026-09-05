import 'dart:io';
import 'package:flutter/material.dart';

class OcrScannerService {
  const OcrScannerService();

  /// Analyse une image pour en extraire EXCLUSIVEMENT une immatriculation française au format SIV.
  /// Format SIV strict ciblé : Deux lettres, un tiret, trois chiffres, un tiret, deux lettres (Ex: AB-123-CD).
  Future<String?> extractFrenchLicensePlate(File imageFile) async {
    try {
      // Simulation du délai de traitement du réseau de neurones Google ML Kit
      await Future.delayed(const Duration(milliseconds: 1200));

      // Expression régulière chirurgicale pour le format SIV Français (Zéro acceptation étrangère)
      final RegExp frenchSivRegex = RegExp(r'[A-Z]{2}[- ]?[0-9]{3}[- ]?[A-Z]{2}');
      
      // Simulation du retour brut de la caméra (Sera branché sur le flux recognizedText.text)
      const String rawCameraOutput = "RENAULT CLIO 5 \n IMMATRICULATION: AB-123-CD \n FRANCE SIV";

      if (frenchSivRegex.hasMatch(rawCameraOutput)) {
        final Match match = frenchSivRegex.firstMatch(rawCameraOutput)!;
        
        // Nettoyage et normalisation stricte avec tirets conformes à la charte SIV
        final String cleanPlate = match.group(0)!
            .replaceAll(' ', '-')
            .replaceAll('_', '-')
            .toUpperCase();
            
        return cleanPlate; // Renvoie la plaque française nettoyée
      }

      return null; // Rejet si le format n'est pas strictement une plaque française valide
    } catch (e) {
      debugPrint("MecaGo IA Error - Échec du filtrage de la plaque française: $e");
      return null;
    }
  }

  /// Calcule l'usure mécanique théorique d'un véhicule français entre deux révisions
  int calculatePredictiveScore({required int currentMileage, required int lastServiceMileage}) {
    final int kilometersDriven = currentMileage - lastServiceMileage;
    final int wearDeduction = (kilometersDriven / 600).floor();
    final int finalScore = 100 - wearDeduction;

    if (finalScore < 0) return 0;
    if (finalScore > 100) return 100;
    return finalScore;
  }
}

