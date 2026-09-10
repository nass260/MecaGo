// lib/core/services/autodoc_service.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../features/home/data/models/vehicle_model.dart';

/// Catégories de pièces détachées
enum PartCategory {
  plaquettesFrein('Plaquettes de frein', 'freinage', Icons.car_repair_rounded),
  disquesFrein('Disques de frein', 'freinage', Icons.album_rounded),
  filtreHuile('Filtre à huile', 'filtration', Icons.filter_alt_rounded),
  filtreAir('Filtre à air', 'filtration', Icons.air_rounded),
  filtreHabitable('Filtre habitacle', 'filtration', Icons.filter_alt_rounded),
  filtreGasoil('Filtre à gasoil', 'filtration', Icons.opacity_rounded),
  huileMoteur('Huile moteur', 'lubrifiants', Icons.opacity_rounded),
  bougies('Bougies d\'allumage', 'allumage', Icons.electric_bolt_rounded),
  batterie('Batterie', 'electrique', Icons.battery_charging_full_rounded),
  amortisseurs('Amortisseurs', 'suspension', Icons.linear_scale_rounded),
  courroie('Courroie de distribution', 'distribution', Icons.settings_rounded),
  pneus('Pneus', 'pneumatiques', Icons.grass_rounded);

  final String label;
  final String category;
  final IconData icon;
  const PartCategory(this.label, this.category, this.icon);
}

/// Pièce détachée avec prix et lien
class Part {
  final String id;
  final String name;
  final String brand;
  final double price;
  final String reference;
  final PartCategory category;
  final bool inStock;
  final double? originalPrice;
  final int? discountPercent;

  const Part({
    required this.id,
    required this.name,
    required this.brand,
    required this.price,
    required this.reference,
    required this.category,
    this.inStock = true,
    this.originalPrice,
    this.discountPercent,
  });

  /// Prix formaté
  String get formattedPrice => '${price.toStringAsFixed(2)} €';

  /// Prix barré formaté
  String? get formattedOriginalPrice =>
      originalPrice != null ? '${originalPrice!.toStringAsFixed(2)} €' : null;

  /// Réduction en euros
  double get savings => (originalPrice ?? price) - price;
}

class AutodocService {
  const AutodocService();

  // Configuration affiliation
  static const String _affiliateId = 'mecago';
  static const String _baseUrl = 'https://www.autodoc.fr';

  /// Recherche les pièces compatibles avec un véhicule
  Future<List<Part>> searchParts({
    required Vehicle vehicle,
    required PartCategory category,
    int limit = 10,
  }) async {
    try {
      debugPrint(
        '🔍 Recherche ${category.label} pour ${vehicle.brand} ${vehicle.model}',
      );

      // Simulation d'appel API (à remplacer par le vrai appel)
      await Future.delayed(const Duration(milliseconds: 800));

      // Données simulées par catégorie
      final parts = _getMockParts(category, vehicle);

      return parts.take(limit).toList();
    } catch (e) {
      debugPrint('❌ Erreur recherche pièces : $e');
      return [];
    }
  }

  /// Recherche multi-catégories (pour un diagnostic complet)
  Future<Map<PartCategory, List<Part>>> searchMultipleCategories({
    required Vehicle vehicle,
    required List<PartCategory> categories,
  }) async {
    final results = <PartCategory, List<Part>>{};

    for (final category in categories) {
      results[category] = await searchParts(
        vehicle: vehicle,
        category: category,
        limit: 5,
      );
    }

    return results;
  }

  /// Ouvre le lien d'achat avec tracking affilié
  Future<bool> openPartLink({
    required Part part,
    required Vehicle vehicle,
  }) async {
    try {
      final url = _buildAffiliateUrl(part: part, vehicle: vehicle);

      debugPrint('🛒 Ouverture lien : $url');

      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('❌ Erreur ouverture lien : $e');
      return false;
    }
  }

  /// Construit l'URL d'affiliation avec tracking UTM
  String _buildAffiliateUrl({
    required Part part,
    required Vehicle vehicle,
  }) {
    final params = {
      'utm_source': 'mecago',
      'utm_medium': 'app',
      'utm_campaign': 'affiliation',
      'utm_content': '${vehicle.brand}_${vehicle.model}',
      'affiliate_id': _affiliateId,
      'ref': 'mecago_premium',
    };

    final queryString = params.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');

    return '$_baseUrl/recherche?q=${Uri.encodeComponent(part.reference)}&$queryString';
  }

  /// Calcule la commission MecaGo sur une pièce
  double calculateCommission(Part part) {
    // 5% de commission sur le prix
    return part.price * 0.05;
  }

  /// Récupère les pièces recommandées selon le diagnostic
  Future<List<Part>> getRecommendedParts({
    required Vehicle vehicle,
    required String diagnosis,
  }) async {
    // Détecte la catégorie depuis le diagnostic
    final category = _detectCategoryFromDiagnosis(diagnosis);

    if (category == null) return [];

    return searchParts(vehicle: vehicle, category: category);
  }

  // ============================================
  // HELPERS PRIVÉS
  // ============================================

  PartCategory? _detectCategoryFromDiagnosis(String diagnosis) {
    final lower = diagnosis.toLowerCase();

    if (lower.contains('frein') || lower.contains('plaquette')) {
      return PartCategory.plaquettesFrein;
    }
    if (lower.contains('disque')) {
      return PartCategory.disquesFrein;
    }
    if (lower.contains('huile') || lower.contains('vidange')) {
      return PartCategory.filtreHuile;
    }
    if (lower.contains('habitacle') || lower.contains('hepa')) {
      return PartCategory.filtreHabitable;
    }
    if (lower.contains('air')) {
      return PartCategory.filtreAir;
    }
    if (lower.contains('gasoil') || lower.contains('diesel')) {
      return PartCategory.filtreGasoil;
    }
    if (lower.contains('batterie')) {
      return PartCategory.batterie;
    }
    if (lower.contains('amortisseur')) {
      return PartCategory.amortisseurs;
    }
    if (lower.contains('courroie')) {
      return PartCategory.courroie;
    }
    if (lower.contains('pneu')) {
      return PartCategory.pneus;
    }
    if (lower.contains('bougie')) {
      return PartCategory.bougies;
    }

    return null;
  }

  /// Données simulées (à remplacer par la vraie API)
  List<Part> _getMockParts(PartCategory category, Vehicle vehicle) {
    switch (category) {
      case PartCategory.plaquettesFrein:
        return [
          Part(
            id: 'bp-001',
            name: 'Plaquettes de frein avant',
            brand: 'BOSCH',
            price: 34.99,
            originalPrice: 49.99,
            discountPercent: 30,
            reference: 'BP-${vehicle.brand}-${vehicle.model}-AV',
            category: category,
          ),
          Part(
            id: 'bp-002',
            name: 'Plaquettes de frein avant',
            brand: 'VALEO',
            price: 42.50,
            reference: 'BP-${vehicle.brand}-${vehicle.model}-AV-V',
            category: category,
          ),
          Part(
            id: 'bp-003',
            name: 'Plaquettes de frein arrière',
            brand: 'TRW',
            price: 28.90,
            reference: 'BP-${vehicle.brand}-${vehicle.model}-AR',
            category: category,
          ),
          Part(
            id: 'bp-004',
            name: 'Kit plaquettes + disques avant',
            brand: 'BREMBO',
            price: 124.99,
            originalPrice: 159.99,
            discountPercent: 22,
            reference: 'KIT-${vehicle.brand}-${vehicle.model}',
            category: category,
          ),
        ];

      case PartCategory.disquesFrein:
        return [
          Part(
            id: 'df-001',
            name: 'Disque de frein ventilé avant',
            brand: 'BOSCH',
            price: 52.99,
            reference: 'DF-${vehicle.brand}-${vehicle.model}-AV',
            category: category,
          ),
          Part(
            id: 'df-002',
            name: 'Disque de frein arrière',
            brand: 'VALEO',
            price: 38.50,
            reference: 'DF-${vehicle.brand}-${vehicle.model}-AR',
            category: category,
          ),
        ];

      case PartCategory.filtreHuile:
        return [
          Part(
            id: 'fh-001',
            name: 'Filtre à huile',
            brand: 'PURFLUX',
            price: 8.99,
            originalPrice: 12.99,
            discountPercent: 30,
            reference: 'FH-${vehicle.brand}-${vehicle.model}',
            category: category,
          ),
          Part(
            id: 'fh-002',
            name: 'Filtre à huile premium',
            brand: 'MANN-FILTER',
            price: 12.50,
            reference: 'FH-${vehicle.brand}-${vehicle.model}-P',
            category: category,
          ),
        ];

      case PartCategory.filtreAir:
        return [
          Part(
            id: 'fa-001',
            name: 'Filtre à air',
            brand: 'PURFLUX',
            price: 14.99,
            reference: 'FA-${vehicle.brand}-${vehicle.model}',
            category: category,
          ),
        ];

      case PartCategory.filtreHabitable:
        return [
          Part(
            id: 'fhab-001',
            name: 'Filtre habitacle HEPA',
            brand: 'BOSCH',
            price: 24.99,
            originalPrice: 34.99,
            discountPercent: 28,
            reference: 'FHP-${vehicle.brand}-${vehicle.model}',
            category: category,
          ),
          Part(
            id: 'fhab-002',
            name: 'Filtre habitacle charbon actif',
            brand: 'MANN-FILTER',
            price: 19.99,
            reference: 'FHC-${vehicle.brand}-${vehicle.model}',
            category: category,
          ),
        ];

      case PartCategory.filtreGasoil:
        return [
          Part(
            id: 'fg-001',
            name: 'Filtre à gasoil',
            brand: 'PURFLUX',
            price: 18.99,
            reference: 'FG-${vehicle.brand}-${vehicle.model}',
            category: category,
          ),
        ];

      case PartCategory.huileMoteur:
        return [
          Part(
            id: 'hm-001',
            name: 'Huile moteur 5W30 5L',
            brand: 'TOTAL',
            price: 39.99,
            originalPrice: 49.99,
            discountPercent: 20,
            reference: 'HM-5W30-5L',
            category: category,
          ),
          Part(
            id: 'hm-002',
            name: 'Huile moteur 5W40 5L',
            brand: 'CASTROL',
            price: 44.99,
            reference: 'HM-5W40-5L',
            category: category,
          ),
        ];

      case PartCategory.bougies:
        return [
          Part(
            id: 'bo-001',
            name: 'Bougie d\'allumage (x4)',
            brand: 'NGK',
            price: 32.99,
            reference: 'BO-${vehicle.brand}-${vehicle.model}',
            category: category,
          ),
        ];

      case PartCategory.batterie:
        return [
          Part(
            id: 'bat-001',
            name: 'Batterie 12V 60Ah',
            brand: 'BOSCH',
            price: 89.99,
            originalPrice: 119.99,
            discountPercent: 25,
            reference: 'BAT-60AH',
            category: category,
          ),
          Part(
            id: 'bat-002',
            name: 'Batterie 12V 70Ah Start&Stop',
            brand: 'VARTA',
            price: 129.99,
            reference: 'BAT-70AH-SS',
            category: category,
          ),
        ];

      case PartCategory.amortisseurs:
        return [
          Part(
            id: 'am-001',
            name: 'Amortisseur avant (x2)',
            brand: 'MONROE',
            price: 124.99,
            reference: 'AM-${vehicle.brand}-${vehicle.model}-AV',
            category: category,
          ),
        ];

      case PartCategory.courroie:
        return [
          Part(
            id: 'co-001',
            name: 'Kit courroie de distribution',
            brand: 'GATES',
            price: 89.99,
            originalPrice: 119.99,
            discountPercent: 25,
            reference: 'CO-${vehicle.brand}-${vehicle.model}',
            category: category,
          ),
        ];

      case PartCategory.pneus:
        return [
          Part(
            id: 'pn-001',
            name: 'Pneu 205/55 R16 91V',
            brand: 'MICHELIN',
            price: 89.99,
            reference: 'PN-205-55-16',
            category: category,
          ),
          Part(
            id: 'pn-002',
            name: 'Pneu 205/55 R16 91V',
            brand: 'CONTINENTAL',
            price: 79.99,
            originalPrice: 99.99,
            discountPercent: 20,
            reference: 'PN-205-55-16-C',
            category: category,
          ),
        ];
    }
  }
}
