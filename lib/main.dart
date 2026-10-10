// lib/main.dart
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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

  // ✅ 1. Initialiser Supabase (pour les images de pièces)
  try {
    await Supabase.initialize(
      url: 'https://rpuhqomualtsfwpldtdw.supabase.co',
      // ⚠️ REMPLACE PAR TA CLÉ COMPLÈTE (anon public)
      anonKey: 'sb_publishable_Pnoa31QZWalX2gufPXYEAg_Yy3dphZj',
    );
    debugPrint('✅ Supabase initialisé');
  } catch (e) {
    debugPrint('❌ Erreur Supabase : $e');
  }

  // ✅ 2. Initialiser Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('✅ Firebase initialisé');
  } catch (e) {
    debugPrint('❌ Erreur Firebase : $e');
  }

  // ✅ 2bis. Activer Firebase App Check (UNIQUEMENT sur mobile)
  if (!kIsWeb) {
    try {
      await FirebaseAppCheck.instance.activate(
        androidProvider: AndroidProvider.playIntegrity,
        appleProvider: AppleProvider.deviceCheck,
      );
      debugPrint('✅ Firebase App Check activé (mobile)');
    } catch (e) {
      debugPrint('⚠️ App Check non activé : $e');
    }
  } else {
    debugPrint('ℹ️ App Check ignoré sur Web (non supporté)');
  }

  // ✅ 3. Initialiser le reste
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