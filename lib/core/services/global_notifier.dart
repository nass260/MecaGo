// lib/core/services/global_notifier.dart
import '../../features/home/presentation/managers/home_notifier.dart';

/// Instance globale unique de HomeNotifier
/// Permet de partager l'état entre toutes les pages
class GlobalNotifier {
  static final HomeNotifier _instance = HomeNotifier();

  static HomeNotifier get instance => _instance;
}