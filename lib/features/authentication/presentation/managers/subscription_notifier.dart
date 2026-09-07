import 'package:flutter/material.dart';
import '../../../../core/services/subscription_service.dart';

class SubscriptionNotifier extends ChangeNotifier {
  final SubscriptionService _subscriptionService;

  bool _isPremiumActive = false;
  bool _isProcessing = false;
  String? _billingErrorMessage;

  // Injection de dépendance du service de facturation cloud
  SubscriptionNotifier({
    SubscriptionService subscriptionService = const SubscriptionService(),
  }) : _subscriptionService = subscriptionService;

  // Getters sécurisés pour exposer l'état commercial aux interfaces graphiques
  bool get isPremiumActive => _isPremiumActive;
  bool get isProcessing => _isProcessing;
  String? get billingErrorMessage => _billingErrorMessage;

  /// Interroge les serveurs du store pour rafraîchir le droit d'accès aux fonctionnalités
  Future<void> syncSubscriptionStatus(String userId) async {
    _billingErrorMessage = null;
    try {
      _isPremiumActive = await _subscriptionService.checkPremiumStatus(userId);
    } catch (e) {
      _isPremiumActive = false;
    }
    notifyListeners(); // Force la mise à jour des badges 👑 sur l'application
  }

  /// Déclenche le tunnel d'achat in-app pour l'abonnement MecaGo Premium (4,99 €)
  Future<bool> executePremiumPurchase() async {
    if (_isProcessing) return false;

    _isProcessing = true;
    _billingErrorMessage = null;
    notifyListeners(); // Active le chargement visuel de paiement

    try {
      final bool purchaseSuccess = await _subscriptionService.purchaseMonthlyPremium();
      if (purchaseSuccess) {
        _isPremiumActive = true;
        _billingErrorMessage = null;
        return true;
      } else {
        _billingErrorMessage = "La transaction a été interrompue ou refusée par votre banque.";
        return false;
      }
    } catch (e) {
      _billingErrorMessage = "Erreur de connexion avec les serveurs de paiement App Store.";
      return false;
    } finally {
      _isProcessing = false;
      notifyListeners(); // Désactive le chargement et applique les accès premiums
    }
  }
}
