# 📂 MecaGo — Spécifications de l'Architecture Technique (V1)

Ce document répertorie l'organisation structurelle, le cycle de vie et les algorithmes de l'application **MecaGo** développée en **Clean Architecture** sous Flutter.

---

## 🏗️ 1. Structure du Projet

L'application est découpée de manière étanche pour garantir l'indépendance de la logique métier vis-à-vis des frameworks externes.

### 📁 Core (Noyau Central Shared)
* `core/theme/` : Centralisation graphique des codes couleurs de marque (`#FF6A00` Orange, `#111827` Navy, `#F8FAFC` Background).
* `core/widgets/` : Composants signatures premiums réutilisables (`PremiumCard`, `PremiumButton` élastique).
* `core/navigation/app_router.dart` : Routeur central `go_router` gérant l'interconnexion asynchrone globale.
* `core/services/` : Moteurs de persistance (`DatabaseHelper` SQLite et `CloudSyncService` Firebase).

### 📁 Features (Modules Fonctionnels)
Chaque fonctionnalité est scindée en trois couches étanches :
1. **Data (Données)** : Modèles de données (`vehicle_model.dart`, `history_model.dart`) et sources physiques.
2. **Domain (Métier)** : Cas d'utilisation indépendants (`GetVehiclesUseCase`, `GetHistoryUseCase`).
3. **Presentation (Interface)** : Vues UI premium et gestionnaires d'état (`HomeNotifier`, `GarageNotifier`).

---

## 🧠 2. Algorithmes Stratégiques de Télémétrie

### 🔍 Filtrage SIV Français Stricte
Le module `OcrScannerService` intègre un protocole d'analyse par expression régulière pour isoler exclusivement les plaques françaises réglementaires au format `AA-123-AA`. Tout texte ou plaque non conforme est automatiquement rejeté.

### ⚡ Intelligence Prédictive d'Usure
Le module `MaintenanceAnalyticsService` calcule la dégradation des composants en temps réel. Règle mécanique embarquée : L'algorithme retient systématiquement la valeur la plus critique entre les kilomètres parcourus et le temps écoulé depuis la dernière révision.

### 🛠️ Localisation Commerciale France
Le module `AutodocShopService` simule l'estimation des coûts de remplacement en priorisant de façon dynamique les équipementiers leaders du marché français (**PURFLUX** pour la filtration et **VALEO** pour les composants d'usure et de freinage).

---

## ⏱️ 3. Cycle de Vie et Initialisation au Boot (`main.dart`)
Au démarrage, l'application exécute une séquence asynchrone stricte avant de dessiner le premier écran :
1. Verrouillage des liaisons natives Flutter.
2. Initialisation et ouverture du fichier SQLite global.
3. Exécution du `DatabaseSeeder` (Uniquement si la base est vide) pour injecter les véhicules de démonstration.
4. Contrôle de santé réseau et synchronisation asynchrone en arrière-plan vers **Firebase Cloud Firestore**.
5. Allumage du routeur et lancement du carrousel de bienvenue.
