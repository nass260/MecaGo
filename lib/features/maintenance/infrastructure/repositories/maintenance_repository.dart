import '../../data/datasources/maintenance_local_data_source.dart';
import '../../data/models/reminder_model.dart';
import '../../data/models/tutorial_model.dart';
import '../services/autodoc_shop_service.dart';

class MaintenanceRepository {
  final MaintenanceLocalDataSource _localDataSource;
  final AutodocShopService _shopService;
  
  // Injection de dépendances complète des sources de données locales et commerciales
  const MaintenanceRepository({
    MaintenanceLocalDataSource localDataSource = const MaintenanceLocalDataSource(),
    AutodocShopService shopService = const AutodocShopService(),
  })  : _localDataSource = localDataSource,
        _shopService = shopService;

  /// Récupère l'intégralité des rappels kilométriques d'un véhicule depuis la Data Source SQLite
  Future<List<ReminderModel>> getVehicleReminders(int vehicleId) async {
    // Consomme de manière propre la couche Data Source de production
    return await _localDataSource.fetchMaintenanceReminders();
  }

  /// Charge un tutoriel pas à pas et y injecte la tarification et la marque n°1 en France
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
