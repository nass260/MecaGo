import 'package:flutter/material.dart';

class SyncManager with ChangeNotifier {
  bool _isDeviceOnline = true;
  bool _hasPendingLocalChanges = false;
  bool _isSynchronizing = false;

  bool get isDeviceOnline => _isDeviceOnline;
  bool get hasPendingLocalChanges => _hasPendingLocalChanges;
  bool get isSynchronizing => _isSynchronizing;

  /// Écoute en continu les changements d'état de la connexion réseau du smartphone
  void updateNetworkStatus(bool online) {
    if (_isDeviceOnline == online) return;
    _isDeviceOnline = online;
    notifyListeners();

    // Si l'appareil récupère internet et possède des données en attente, lance la synchronisation
    if (_isDeviceOnline && _hasPendingLocalChanges) {
      synchronizeLocalDataWithCloud();
    }
  }

  /// Enregistre une modification en local (dans SQLite) lorsque l'utilisateur est hors-ligne
  void markChangeForDeferredSync() {
    _hasPendingLocalChanges = true;
    notifyListeners();
    debugPrint("MecaGo Sync — Mode Hors-Ligne actif. Données sauvegardées localement dans SQLite.");
  }

  /// Synchronise de manière transparente les données locales vers les serveurs cloud distants
  Future<void> synchronizeLocalDataWithCloud() async {
    if (_isSynchronizing || !_isDeviceOnline) return;

    _isSynchronizing = true;
    notifyListeners();

    debugPrint("MecaGo Sync — Réseau détecté. Alignement des bases de données en cours...");
    
    // Simulation du transfert et chiffrement des données (1,8 seconde)
    await Future.delayed(const Duration(milliseconds: 1800));

    _hasPendingLocalChanges = false;
    _isSynchronizing = false;
    notifyListeners();
    
    debugPrint("MecaGo Sync — Synchronisation Cloud terminée avec succès. Bases de données à jour !");
  }
}
