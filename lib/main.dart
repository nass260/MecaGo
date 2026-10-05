// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
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

  // ✅ Initialiser Firebase (c'est TOUT)
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('✅ Firebase initialisé');
  } catch (e) {
    debugPrint('❌ Erreur Firebase : $e');
  }

  // ✅ Le reste
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
    await notificationService.requestPermission();
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