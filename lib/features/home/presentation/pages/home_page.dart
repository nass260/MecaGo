import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/premium_card.dart';
import '../../../../core/widgets/premium_button.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(), // Défilement élastique iOS
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              // 1. EN-TÊTE UTILISATEUR COMPLET WITH AVATAR & CROWNS
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Bonjour Alex 👋',
                        style: TextStyle(color: AppColors.navy, fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: -0.5),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Prêt pour entretenir votre Tesla ?',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  // Avatar Premium Couronne Orange
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 46,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: const DecorationImage(
                            image: NetworkImage('https://unsplash.com'),
                            fit: BoxFit.cover,
                          ),
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                      const Positioned(
                        top: -8,
                        right: -4,
                        child: Text('👑', style: TextStyle(fontSize: 14)),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // 2. DOUBLE COMPTEUR HORIZONTAL (SCORE & ÉCONOMIES)
              Row(
                children: [
                  // Bloc Gauche : MecaGo Score 85
                  Expanded(
                    child: PremiumCard(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text('MecaGo Score™', style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w600)),
                              Icon(Icons.info_outline_rounded, size: 14, color: AppColors.textSecondary),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  SizedBox(
                                    width: 44,
                                    height: 44,
                                    child: CircularProgressIndicator(
                                      value: 0.85,
                                      strokeWidth: 4.5,
                                      backgroundColor: AppColors.border,
                                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.orange),
                                    ),
                                  ),
                                  const Icon(Icons.shield_rounded, size: 18, color: AppColors.orange),
                                ],
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text('85', style: TextStyle(color: AppColors.navy, fontSize: 24, fontWeight: FontWeight.w900)),
                                    Text('Très bon ★', style: TextStyle(color: AppColors.orange, fontSize: 11, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Bloc Droite : Économies Réalisées 125 €
                  Expanded(
                    child: PremiumCard(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Économies réalisées', style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: const BoxDecoration(color: Color(0xFFF0FDF4), shape: BoxShape.circle),
                                child: const Icon(Icons.savings_rounded, color: AppColors.success, size: 22),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text('125 €', style: TextStyle(color: AppColors.navy, fontSize: 24, fontWeight: FontWeight.w900)),
                                    Text('+12 € ce mois-ci', style: TextStyle(color: AppColors.success, fontSize: 11, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // 3. LA GRANDE FICHE CARTE TESLA DU VISUEL AVEC LA JAUGE À 76%
              PremiumCard(
                padding: EdgeInsets.zero,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image et Titre imbriqués
                    Stack(
                      children: [
                        Container(
                          height: 180,
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                            image: DecorationImage(
                              image: NetworkImage('https://unsplash.com'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        // Dégradé sombre linéaire sur l'image pour l'intégration de texte de la maquette
                        Container(
                          height: 180,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.black.withOpacity(0.4), Colors.transparent, Colors.black.withOpacity(0.3)],
                            ),
                          ),
                        ),
                        // Textes superposés
                        Positioned(
                          top: 14,
                          left: 16,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text('Mon véhicule actif', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600)),
                              SizedBox(height: 2),
                              Text('Tesla Model 3', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
                            ],
                          ),
                        ),
                        // Badge Immatriculation
                        Positioned(
                          bottom: 14,
