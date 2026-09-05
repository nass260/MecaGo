import 'package:flutter/material.dart';

class AutodocShopService {
  const AutodocShopService();

  /// Calcule le prix et recommande la marque la plus vendue en France
  /// en fonction du véhicule détecté (Renault, Peugeot, Tesla...).
  Future<Map<String, dynamic>> fetchCompatiblePartPricing({
    required String vehicleBrand,
    required String partCategory,
  }) async {
    try {
      // Simulation de la requête de tarification
      await Future.delayed(const Duration(milliseconds: 900));

      double averagePrice = 19.90;
      String recommendedBrand = "VALEO"; // Référence n°1 de l'essuie-glace et freinage en France
      final String category = partCategory.toLowerCase();
      final String brand = vehicleBrand.toUpperCase();

      // 1. AJUSTEMENT STRATÉGIQUE POUR LES MARQUES LES PLUS VENDUES EN FRANCE (Renault, Peugeot, Citroën)
      if (brand == "RENAULT" || brand == "PEUGEOT" || brand == "CITROEN") {
        if (category.contains("filtre")) {
          recommendedBrand = "PURFLUX"; // Le leader historique et n°1 des ventes de filtres en France
          averagePrice = 18.50;
        } else if (category.contains("frein")) {
          recommendedBrand = "VALEO Tech"; // Marque française ultra-dominante
          averagePrice = 45.00;
        } else {
          recommendedBrand = "BOSCH";
          averagePrice = 22.00;
        }
      } 
      // 2. AJUSTEMENT POUR LA GAMME TESLA
      else if (brand == "TESLA") {
        recommendedBrand = category.contains("filtre") ? "BOSCH FILTER HEPA" : "BOSCH Aerotwin";
        averagePrice = category.contains("frein") ? 74.90 : 34.10;
      }

      return {
        'recommended_brand': recommendedBrand,
        'estimated_price': '${averagePrice.toStringAsFixed(2)} €',
        'in_stock': true,
        'compatibility_token': 'SIV-FR-$brand-MATCHED',
      };
    } catch (e) {
      debugPrint("MecaGo Shop Error - Échec du calcul France AUTODOC: $e");
      return {
        'recommended_brand': 'Générique',
        'estimated_price': '--,-- €',
        'in_stock': false,
        'compatibility_token': 'UNKNOWN',
      };
    }
  }
}
