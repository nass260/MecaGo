#!/bin/bash

# ==============================================================================
# 🚀 MecaGo — Script d'Automatisation de Compilation et Déploiement Production
# ==============================================================================

echo "🤖 SÉQUENCE : Initialisation du pipeline de build MecaGo V1..."
echo "----------------------------------------------------------------------"

# 1. Nettoyage strict des caches système pour éviter les conflits d'assets
echo "🧹 Étape 1 : Nettoyage complet des builds précédents..."
flutter clean

# 2. Restauration et installation des dépendances certifiées SQLite et Firebase
echo "📦 Étape 2 : Résolution et téléchargement des packages du pubspec.yaml..."
flutter pub get

# 3. Validation de l'intégrité de l'arborescence et analyse statique des types Dart
echo "🔍 Étape 3 : Analyse du code de la Clean Architecture..."
flutter analyze

# 4. Déclenchement de la compilation native Android optimisée (Release)
echo "🤖 Étape 4 : Compilation du livrable universel Android (APK Release)..."
flutter build apk --release --obfuscate --split-debug-info=build/app/outputs/symbols

# 5. Déclenchement de la compilation native iOS (Préparation Xcode)
echo "🍏 Étape 5 : Compilation de l'archive de production iOS..."
flutter build ios --release --no-codesign

echo "----------------------------------------------------------------------"
echo "🏆 SUCCESS : Séquence terminée ! Vos fichiers de production sont prêts."
