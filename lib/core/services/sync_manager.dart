// lib/core/services/sync_manager.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// État de la connexion
enum NetworkStatus {
  online('En ligne', Icons.cloud_done_rounded, Colors.green),
  offline('Mode atelier', Icons.cloud_off_rounded, Color(0xFFFF6A00)),
  unknown('Inconnu', Icons.cloud_queue_rounded, Colors.grey);

  final String label;
  final IconData icon;
  final Color color;
  const NetworkStatus(this.label, this.icon, this.color);
}

class SyncManager {
  static final SyncManager _instance = SyncManager._internal();
  factory SyncManager() => _instance;
  SyncManager._internal();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  NetworkStatus _status = NetworkStatus.unknown;
  final _statusController = StreamController<NetworkStatus>.broadcast();

  // Getters
  NetworkStatus get status => _status;
  Stream<NetworkStatus> get statusStream => _statusController.stream;
  bool get isOnline => _status == NetworkStatus.online;
  bool get isOffline => _status == NetworkStatus.offline;

  /// Initialise la détection réseau
  Future<void> initialize() async {
    try {
      // Vérification initiale
      final result = await _connectivity.checkConnectivity();
      _updateStatus(result);

      // Écoute des changements
      _subscription = _connectivity.onConnectivityChanged.listen(
        _updateStatus,
        onError: (error) {
          debugPrint('❌ Erreur connexion : $error');
          _setStatus(NetworkStatus.unknown);
        },
      );

      debugPrint('✅ SyncManager initialisé · Statut : ${_status.label}');
    } catch (e) {
      debugPrint('❌ Erreur init SyncManager : $e');
      _setStatus(NetworkStatus.unknown);
    }
  }

  /// Arrête l'écoute
  void dispose() {
    _subscription?.cancel();
    _statusController.close();
  }

  /// Met à jour le statut depuis le résultat de connectivité
  void _updateStatus(List<ConnectivityResult> results) {
    if (results.isEmpty || results.contains(ConnectivityResult.none)) {
      _setStatus(NetworkStatus.offline);
    } else if (results.contains(ConnectivityResult.mobile) ||
        results.contains(ConnectivityResult.wifi) ||
        results.contains(ConnectivityResult.ethernet)) {
      _setStatus(NetworkStatus.online);
    } else {
      _setStatus(NetworkStatus.unknown);
    }
  }

  /// Change le statut et notifie les listeners
  void _setStatus(NetworkStatus newStatus) {
    if (_status == newStatus) return;
    _status = newStatus;
    _statusController.add(newStatus);
    debugPrint('🔄 Statut réseau : ${newStatus.label}');
  }

  /// Vérifie si la connexion est suffisante pour une action
  Future<bool> canPerformOnlineAction() async {
    if (isOnline) return true;
    // Re-vérifie au cas où
    final result = await _connectivity.checkConnectivity();
    _updateStatus(result);
    return isOnline;
  }

  /// Affiche un message à l'utilisateur
  String getStatusMessage() {
    switch (_status) {
      case NetworkStatus.online:
        return 'Connecté · Toutes les fonctionnalités disponibles';
      case NetworkStatus.offline:
        return 'Mode atelier · Fonctionne sans internet';
      case NetworkStatus.unknown:
        return 'Vérification de la connexion...';
    }
  }
}
