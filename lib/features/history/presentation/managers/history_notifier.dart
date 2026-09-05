import 'package:flutter/material.dart';
import '../../domain/usecases/get_history_usecase.dart';
import '../../data/models/history_model.dart';

class HistoryNotifier extends ChangeNotifier {
  final GetHistoryUseCase _getHistoryUseCase;

  List<HistoryModel> _historyItems = [];
  int _totalSavings = 0;
  bool _isLoading = false;
  String? _errorMessage;

  // Injection de dépendance du cas d'utilisation financier
  HistoryNotifier({
    GetHistoryUseCase getHistoryUseCase = const GetHistoryUseCase(),
  }) : _getHistoryUseCase = getHistoryUseCase;

  // Getters épurés pour exposer l'état de manière sécurisée à la vue d'historique
  List<HistoryModel> get historyItems => _historyItems;
  int get totalSavings => _totalSavings;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Charge de manière asynchrone l'historique et agrège les économies depuis SQLite
  Future<void> loadMaintenanceHistory() async {
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners(); // Avertit la vue d'afficher l'indicateur de chargement

    try {
      // Exécution de l'action métier et récupération de la réponse agrégée
      final HistoryResponse response = await _getHistoryUseCase.execute();
      
      _historyItems = response.items;
      _totalSavings = response.totalSavings; // Restitue dynamiquement les 125 €
      _errorMessage = null;
    } catch (e) {
      _errorMessage = "Impossible de charger votre historique financier. Veuillez réessayer.";
      _historyItems = [];
      _totalSavings = 0;
    } finally {
      _isLoading = false;
      notifyListeners(); // Avertit la vue de rafraîchir les compteurs et la chronologie
    }
  }
}
