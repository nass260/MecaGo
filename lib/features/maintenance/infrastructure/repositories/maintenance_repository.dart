import '../../../../core/services/database_helper.dart';
import '../../data/models/reminder_model.dart';
import '../../data/models/tutorial_model.dart';
import '../services/autodoc_shop_service.dart';

class MaintenanceRepository {
  final AutodocShopService _shopService;
  
  const MaintenanceRepository({
    AutodocShopService shopService = const AutodocShopService(),
  }) : _shopService = shopService;

  /// Récupère l'intégralité des rappels kilométriques d'un véhicule depuis la base SQLite
  Future<List<ReminderModel>> getVehicleReminders(int vehicleId) async {
    // Appel à notre DatabaseHelper global configuré au Sprint 3
    final List<Map<String, dynamic>> rawRows = await DatabaseHelper.instance.getAllVehicles();
    
    // Simulation du filtrage et de la conversion brute SQLite vers nos Objets Typés ReminderModel
    return rawRows.map((row) {
      final bool isTesla = (row['brand'] as String).toUpperCase() == 'TESLA';
      return ReminderModel(
        id: row['id'] as int,
        title: isTesla ? "Filtre habitacle HEPA" : "Filtre d'habitacle Habituel",
        subtitle: "Prochain remplacement estimé constructeur",
        remaining: isTesla ? 82 : 45,
        mileage: isTesla ? "58 000 / 72 000 km" : "15 000 / 30 000 km",
        colorValue: isTesla ? 0xFFFF6A00 : 0xFF22C55E, // Orange ou Vert selon l'urgence
      );
    }).toList();
  }

  /// Charge un tutoriel pas à pas et y injecte dynamiquement la tarification et la marque n°1 en France
  Future<TutorialModel> loadEnrichedTutorial({
    required String vehicleBrand,
    required String tutorialTitle,
  }) async {
    // 1. Récupération des tarifs auprès du service commercial national (PURFLUX / VALEO)
    final Map<String, dynamic> pricingData = await _shopService.fetchCompatiblePartPricing(
      vehicleBrand: vehicleBrand,
      partCategory: tutorialTitle,
    );

    final String brandRecommended = pricingData['recommended_brand'] as String;
    final String priceEstimated = pricingData['estimated_price'] as String;

    // 2. Génération de l'objet de données enrichi prêt pour l'affichage de l'atelier
    return TutorialModel(
      id: 1,
      title: tutorialTitle,
      duration: "15 min",
      difficulty: "Facile",
      savings: 35, // 35€ économisés
      tag: "Recommandé : $brandRecommended ($priceEstimated)",
      steps: [
        TutorialStepModel(
          title: "Initialisation atelier",
          description: "Installez votre véhicule sur une zone plane et sécurisée. Préparez votre pièce neuve certifiée d'origine $brandRecommended d'une valeur de $priceEstimated.",
          imageUrl: "https://unsplash.com",
          toolsRequired: "Gants de protection",
          warning: "Attendez l'arrêt complet de la ventilation avant ouverture.",
        ),
      ],
    );
  }
}
