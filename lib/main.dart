import 'package:flutter/material.dart';
import 'core/navigation/app_router.dart';
import 'core/services/database_helper.dart';

void main() async {
  // 1. Verrouille l'initialisation des liaisons Flutter natives (Obligatoire pour l'asynchrone)
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Initialisation asynchrone sécurisée de notre base de données locale SQLite
  await DatabaseHelper.instance.initializeDatabase();

  // 3. Lancement officiel de l'écosystème de l'application MecaGo
  runApp(const MecaGoApp());
}

class MecaGoApp extends StatelessWidget {
  const MecaGoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'MecaGo',
      debugShowCheckedModeBanner: false, // Désactive la bannière "Debug" pour le rendu investisseur
      
      // Configuration de notre routeur global connecté configuré au Sprint 2
      routerConfig: AppRouter.router,
      
      // Configuration du thème de base épuré
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'SF Pro Display', // Utilisation de la police officielle Apple
      ),
    );
  }
}
