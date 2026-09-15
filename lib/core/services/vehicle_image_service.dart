// lib/core/services/vehicle_image_service.dart

/// Service qui fournit les images des véhicules
/// Utilise des URLs directes qui fonctionnent sur Flutter Web
class VehicleImageService {
  /// Retourne l'URL de l'image pour un véhicule donné
  static String getVehicleImage(String brand, String model) {
    final key = '${brand.toLowerCase()}_${model.toLowerCase()}';

    final images = _getImageDatabase();

    if (images.containsKey(key)) {
      return images[key]!;
    }

    final brandKey = brand.toLowerCase();
    if (images.containsKey(brandKey)) {
      return images[brandKey]!;
    }

    return _getGenericImage(brand, model);
  }

  /// Base de données d'images (Unsplash - URLs directes qui fonctionnent)
  static Map<String, String> _getImageDatabase() {
    return {
      // ===== TESLA =====
      'tesla_model 3':
          'https://images.unsplash.com/photo-1560958089-b8a1929cea89?w=800&q=80',
      'tesla_model y':
          'https://images.unsplash.com/photo-1617788138017-80ad40651399?w=800&q=80',
      'tesla_model s':
          'https://images.unsplash.com/photo-1571987502227-9231b837d92a?w=800&q=80',

      // ===== RENAULT =====
      'renault_clio 5':
          'https://images.unsplash.com/photo-1541899481282-d53bffe3c35d?w=800&q=80',
      'renault_clio':
          'https://images.unsplash.com/photo-1541899481282-d53bffe3c35d?w=800&q=80',
      'renault_megane':
          'https://images.unsplash.com/photo-1609521263047-f8f205293f24?w=800&q=80',
      'renault_captur':
          'https://images.unsplash.com/photo-1494976388531-d1058494cdd8?w=800&q=80',
      'renault_zoe':
          'https://images.unsplash.com/photo-1593941707882-a5bba14938c7?w=800&q=80',
      'renault_twingo':
          'https://images.unsplash.com/photo-1552519507-da3b142c6e3d?w=800&q=80',

      // ===== PEUGEOT =====
      'peugeot_208':
          'https://images.unsplash.com/photo-1609521263047-f8f205293f24?w=800&q=80',
      'peugeot_308':
          'https://images.unsplash.com/photo-1503376780353-7e6692767b70?w=800&q=80',
      'peugeot_2008':
          'https://images.unsplash.com/photo-1552519507-da3b142c6e3d?w=800&q=80',
      'peugeot_3008':
          'https://images.unsplash.com/photo-1494976388531-d1058494cdd8?w=800&q=80',
      'peugeot_boxer':
          'https://images.unsplash.com/photo-1570129477492-45c003edd2be?w=800&q=80',
      'peugeot_508':
          'https://images.unsplash.com/photo-1541899481282-d53bffe3c35d?w=800&q=80',
      'peugeot_partner':
          'https://images.unsplash.com/photo-1570129477492-45c003edd2be?w=800&q=80',

      // ===== CITROEN =====
      'citroen_c3':
          'https://images.unsplash.com/photo-1552519507-da3b142c6e3d?w=800&q=80',
      'citroen_c4':
          'https://images.unsplash.com/photo-1494976388531-d1058494cdd8?w=800&q=80',
      'citroen_berlingo':
          'https://images.unsplash.com/photo-1570129477492-45c003edd2be?w=800&q=80',
      'citroen_jumpy':
          'https://images.unsplash.com/photo-1570129477492-45c003edd2be?w=800&q=80',

      // ===== DACIA =====
      'dacia_sandero':
          'https://images.unsplash.com/photo-1541899481282-d53bffe3c35d?w=800&q=80',
      'dacia_duster':
          'https://images.unsplash.com/photo-1494976388531-d1058494cdd8?w=800&q=80',
      'dacia_logan':
          'https://images.unsplash.com/photo-1552519507-da3b142c6e3d?w=800&q=80',

      // ===== VOLKSWAGEN =====
      'volkswagen_golf':
          'https://images.unsplash.com/photo-1609521263047-f8f205293f24?w=800&q=80',
      'volkswagen_polo':
          'https://images.unsplash.com/photo-1552519507-da3b142c6e3d?w=800&q=80',
      'volkswagen_tiguan':
          'https://images.unsplash.com/photo-1494976388531-d1058494cdd8?w=800&q=80',

      // ===== TOYOTA =====
      'toyota_yaris':
          'https://images.unsplash.com/photo-1552519507-da3b142c6e3d?w=800&q=80',
      'toyota_corolla':
          'https://images.unsplash.com/photo-1609521263047-f8f205293f24?w=800&q=80',
      'toyota_rav4':
          'https://images.unsplash.com/photo-1494976388531-d1058494cdd8?w=800&q=80',

      // ===== FORD =====
      'ford_fiesta':
          'https://images.unsplash.com/photo-1552519507-da3b142c6e3d?w=800&q=80',
      'ford_focus':
          'https://images.unsplash.com/photo-1609521263047-f8f205293f24?w=800&q=80',
      'ford_transit':
          'https://images.unsplash.com/photo-1570129477492-45c003edd2be?w=800&q=80',

      // ===== MERCEDES =====
      'mercedes_classe a':
          'https://images.unsplash.com/photo-1618843479313-40f8afb4b4d8?w=800&q=80',
      'mercedes_classe c':
          'https://images.unsplash.com/photo-1618843479313-40f8afb4b4d8?w=800&q=80',

      // ===== BMW =====
      'bmw_serie 1':
          'https://images.unsplash.com/photo-1555215695-3004980ad54e?w=800&q=80',
      'bmw_serie 3':
          'https://images.unsplash.com/photo-1555215695-3004980ad54e?w=800&q=80',

      // ===== AUDI =====
      'audi_a3':
          'https://images.unsplash.com/photo-1606664515524-ed2f786a0bd6?w=800&q=80',
      'audi_a4':
          'https://images.unsplash.com/photo-1606664515524-ed2f786a0bd6?w=800&q=80',

      // ===== FIAT =====
      'fiat_500':
          'https://images.unsplash.com/photo-1552519507-da3b142c6e3d?w=800&q=80',
      'fiat_panda':
          'https://images.unsplash.com/photo-1552519507-da3b142c6e3d?w=800&q=80',
      'fiat_ducato':
          'https://images.unsplash.com/photo-1570129477492-45c003edd2be?w=800&q=80',

      // ===== OPEL =====
      'opel_corsa':
          'https://images.unsplash.com/photo-1552519507-da3b142c6e3d?w=800&q=80',
      'opel_astra':
          'https://images.unsplash.com/photo-1609521263047-f8f205293f24?w=800&q=80',

      // ===== SEAT =====
      'seat_ibiza':
          'https://images.unsplash.com/photo-1552519507-da3b142c6e3d?w=800&q=80',
      'seat_leon':
          'https://images.unsplash.com/photo-1609521263047-f8f205293f24?w=800&q=80',

      // ===== SKODA =====
      'skoda_octavia':
          'https://images.unsplash.com/photo-1609521263047-f8f205293f24?w=800&q=80',
      'skoda_fabia':
          'https://images.unsplash.com/photo-1552519507-da3b142c6e3d?w=800&q=80',
    };
  }

  /// Image générique par défaut
  static String _getGenericImage(String brand, String model) {
    return 'https://images.unsplash.com/photo-1503376780353-7e6692767b70?w=800&q=80';
  }

  /// Récupère l'icône pour un type de carburant
  static String getFuelIcon(String fuelType) {
    switch (fuelType.toLowerCase()) {
      case 'electrique':
        return '⚡';
      case 'hybride':
        return '🔋';
      case 'diesel':
        return '🛢️';
      case 'essence':
        return '⛽';
      case 'gpl':
        return '💨';
      case 'e85':
        return '🌱';
      default:
        return '⛽';
    }
  }
}