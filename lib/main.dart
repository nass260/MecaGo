// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/navigation/app_router.dart';
import 'core/services/notification_service.dart';
import 'core/services/database_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configuration de la barre de statut
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Orientation portrait uniquement
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialisation Firebase
  try {
    await Firebase.initializeApp();
    debugPrint('✅ Firebase initialisé');
  } catch (e) {
    debugPrint('⚠️ Firebase non configuré : $e');
  }

  // Initialisation SQLite (création des tables)
  try {
    await DatabaseService().database;
    debugPrint('✅ SQLite initialisé');
  } catch (e) {
    debugPrint('❌ Erreur SQLite : $e');
  }

  // Initialisation des notifications
  try {
    const notificationService = NotificationService();
    await notificationService.initializeNotificationChannels();
    debugPrint('✅ Notifications initialisées');
  } catch (e) {
    debugPrint('⚠️ Notifications non configurées : $e');
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
      builder: (context, child) {
        // Limiter la taille du texte pour l'accessibilité
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(
              MediaQuery.of(context).textScaler.scale(1.0).clamp(0.8, 1.2),
            ),
          ),
          child: child!,
        );
      },
    );
  }
}
