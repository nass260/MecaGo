import 'package:flutter/material.dart';
import 'core/navigation/app_router.dart';
import 'core/services/database_helper.dart';
import 'core/services/database_seeder.dart';
import 'core/services/cloud_sync_service.dart'; // <-- 1. Importation du service Cloud ajoutée

void main() async {
  // Verrouille l'initialisation des liaisons Flutter natives (Obligatoire pour l'asynchrone)
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisation asynchrone sécurisée de notre base de données locale SQLite
  await DatabaseHelper.instance.initializeDatabase();

  // Déclenchement automatique du peuplement des données de la maquette (Tesla, Clio, 125€)
  await DatabaseSeeder.seedInitialData();

  // 2. Vérification chirurgicale de la connectivité avec les serveurs Google Firebase
  const CloudSyncService cloudService = CloudSyncService();
  await cloudService.checkCloudHealth();

  // Lancement officiel de l'écosystème de l'application MecaGo
  runApp(const MecaGoApp());
}

class MecaGoApp extends StatelessWidget {
  const MecaGoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      child: MaterialApp.router(
        title: 'MecaGo',
        debugShowCheckedModeBanner: false, // Désactive la bannière "Debug" pour le rendu investisseur
        
        // Configuration de notre routeur global connecté configuré au Sprint 2
        routerConfig: AppRouter.router,
        
        // Configuration du thème de base épuré Apple Style
        theme: ThemeData(
          useMaterial3: true,
          fontFamily: 'SF Pro Display',
        ),
      ),
    );
  }
}
