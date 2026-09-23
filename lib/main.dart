// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/navigation/app_router.dart';
import 'core/services/database_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/sync_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // ✅ 1. Initialiser la base de données
  try {
    await DatabaseService().initialize();
    debugPrint('✅ DatabaseService initialisé');
  } catch (e) {
    debugPrint('❌ Erreur DatabaseService : $e');
  }

  // ✅ 2. Initialiser les notifications
  try {
    const notificationService = NotificationService();
    await notificationService.initializeNotificationChannels();
    debugPrint('✅ Notifications initialisées');

    // Demander la permission (sur mobile)
    await notificationService.requestPermission();
  } catch (e) {
    debugPrint('⚠️ Notifications : $e');
  }

  // ✅ 3. Initialiser SyncManager
  try {
    await SyncManager().initialize();
    debugPrint('✅ SyncManager initialisé');
  } catch (e) {
    debugPrint('⚠️ SyncManager : $e');
  }

  runApp(const MecaGoMasterApp());
}

class MecaGoMasterApp extends StatelessWidget {
  const MecaGoMasterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'MecaGo Premium',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light,
      routerConfig: AppRouter.router,
    );
  }
}