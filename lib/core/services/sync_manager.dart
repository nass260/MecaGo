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
  StreamSubscription<ConnectivityResult>? _subscription;

  NetworkStatus _status = NetworkStatus.unknown;
  final _statusController = StreamController<NetworkStatus>.broadcast();

  NetworkStatus get status => _status;
  Stream<NetworkStatus> get statusStream => _statusController.stream;
  bool get isOnline => _status == NetworkStatus.online;
  bool get isOffline => _status == NetworkStatus.offline;

  Future<void> initialize() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _updateStatus(result);

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

  void dispose() {
    _subscription?.cancel();
    _statusController.close();
  }

  void _updateStatus(ConnectivityResult result) {
    if (result == ConnectivityResult.none) {
      _setStatus(NetworkStatus.offline);
    } else {
      _setStatus(NetworkStatus.online);
    }
  }

  void _setStatus(NetworkStatus newStatus) {
    if (_status == newStatus) return;
    _status = newStatus;
    _statusController.add(newStatus);
    debugPrint('🔄 Statut réseau : ${newStatus.label}');
  }

  Future<bool> canPerformOnlineAction() async {
    if (isOnline) return true;
    final result = await _connectivity.checkConnectivity();
    _updateStatus(result);
    return isOnline;
  }

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