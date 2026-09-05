import '../../../../core/services/database_helper.dart';
import '../../data/models/history_model.dart';

class GetHistoryUseCase {
  const GetHistoryUseCase();

  /// Exécute l'action métier de récupération et de sommation de l'historique.
  /// Renvoie un objet de réponse contenant la liste typée et le total des économies.
  Future<HistoryResponse> execute() async {
    try {
      // 1. Extraction des lignes brutes stockées dans SQLite
      final List<Map<String, dynamic>> rawRows = await DatabaseHelper.instance.getAllVehicles();
      
      // Simulation temporaire du mapping de la table historique initialisée par le Seeder
      // (Sera branchée sur db.query('maintenance_history') en production finale)
      final List<HistoryModel> typedItems = [
        const HistoryModel(title: "Remplacement filtre d'habitacle HEPA", date: "18 août 2026", mileage: "42 150 km", savings: 35, iconCodePoint: 0xe056),
        const HistoryModel(title: "Rotation des pneumatiques", date: "02 juillet 2026", mileage: "39 800 km", savings: 40, iconCodePoint: 0xf0244),
        const HistoryModel(title: "Remplissage liquide lave-glace", date: "12 mai 2026", mileage: "37 100 km", savings: 10, iconCodePoint: 0xe6e4),
        const HistoryModel(title: "Contrôle pression des pneus", date: "28 mars 2026", mileage: "34 600 km", savings: 15, iconCodePoint: 0xe5d9),
        const HistoryModel(title: "Nettoyage capteurs d'assistance", date: "09 février 2026", mileage: "32 900 km", savings: 25, iconCodePoint: 0xe14c),
      ];

      // 2. Algorithme d'addition automatique des économies cumulées en euros
      int totalCalculatedSavings = 0;
      for (final item in typedItems) {
        totalCalculatedSavings += item.savings;
      }

      return HistoryResponse(
        items: typedItems,
        totalSavings: totalCalculatedSavings, // Fournit exactement les 125 € de la maquette
      );
    } catch (e) {
      return const HistoryResponse(items: [], totalSavings: 0);
    }
  }
}

/// Objet de transfert de données épuré pour la vue d'historique
class HistoryResponse {
  final List<HistoryModel> items;
  final int totalSavings;

  const HistoryResponse({
    required this.items,
    required this.totalSavings,
  });
}
