import '../../data/datasources/history_local_data_source.dart';
import '../../data/models/history_model.dart';

class GetHistoryUseCase {
  final HistoryLocalDataSource _localDataSource;

  // Injection de dépendance de notre source de données historique locale
  const GetHistoryUseCase({
    HistoryLocalDataSource localDataSource = const HistoryLocalDataSource(),
  }) : _localDataSource = localDataSource;

  /// Exécute l'action métier de récupération et de sommation de l'historique financier.
  /// Consomme de manière isolée la couche Data Source SQLite de production.
  Future<HistoryResponse> execute() async {
    try {
      // 1. Extraction des objets typés via notre source de données locale
      final List<HistoryModel> historyItems = await _localDataSource.fetchMaintenanceHistory();

      // 2. Algorithme d'addition automatique des économies cumulées en euros
      int totalCalculatedSavings = 0;
      for (final item in historyItems) {
        totalCalculatedSavings += item.savings;
      }

      return HistoryResponse(
        items: historyItems,
        totalSavings: totalCalculatedSavings, // Totalise dynamiquement les 125 € de la maquette
      );
    } catch (e) {
      // Sécurité anti-crash : renvoie un objet vide en cas d'erreur de lecture
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
