import 'package:flutter/material.dart';
import 'core/navigation/app_router.dart';
import 'core/services/notification_service.dart'; // <-- 1. Importation du service de notification

void main() async {
  // Garantit que les liaisons natives avec iOS et Android sont initialisées avant le démarrage
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Initialisation et demande d'autorisation des canaux de notifications push
  const NotificationService notificationService = NotificationService();
  await notificationService.initializeNotificationChannels();

  runApp(const MecaGoMasterApp());
}

class MecaGoMasterApp extends StatelessWidget {
  const MecaGoMasterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'MecaGo Premium',
      debugShowCheckedModeBanner: false,
      
      // Configuration du moteur de routage centralisé lié au bouton Scanner et au Paywall
      routerConfig: AppRouter.router,
    );
  }
}
