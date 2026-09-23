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

  // ✅ Initialiser la base de données (Hive sur mobile, localStorage sur Web)
  try {
    await DatabaseService().initialize();
    debugPrint('✅ DatabaseService initialisé');
  } catch (e) {
    debugPrint('❌ Erreur DatabaseService : $e');
  }

  try {
    const notificationService = NotificationService();
    await notificationService.initializeNotificationChannels();
    debugPrint('✅ Notifications initialisées');
  } catch (e) {
    debugPrint('⚠️ Notifications : $e');
  }

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