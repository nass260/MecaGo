import 'dart:async';
import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart'; // <-- L'importation ajoutée ici

void main() {
  runApp(const MecaGoApp());
}

class MecaGoApp extends StatelessWidget {
  const MecaGoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MecaGo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light, // <-- Le thème lié ici
      home: const SplashPage(),
    );
  }
}

// ... Tout le reste du code (SplashPage, OnboardingPage) reste exactement le même en dessous !


/// =======================
/// SPLASH SCREEN
/// =======================

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _logoScale;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _logoScale = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );

    _controller.forward();

    Timer(const Duration(seconds: 2), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const OnboardingPage(),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Color(0xFFF3F7FB),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(),

              ScaleTransition(
                scale: _logoScale,
                child: Container(
                  width: 82,
                  height: 82,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2563EB).withOpacity(.15),
                        blurRadius: 28,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.build_rounded,
                      size: 38,
                      color: Color(0xFFFF6A00),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 26),

              RichText(
                text: const TextSpan(
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -.8,
                    color: Color(0xFF111827),
                  ),
                  children: [
                    TextSpan(text: 'Meca'),
                    TextSpan(
                      text: 'Go',
                      style: TextStyle(color: Color(0xFFFF6A00)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                "Le GPS de l'entretien automobile",
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 70),

              // Placeholder voiture (sera remplacé par le rendu 3D)
              Container(
                width: 310,
                height: 170,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFF8FAFC),
                      Color(0xFFEFF5FB),
                    ],
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.directions_car_filled_rounded,
                    size: 110,
                    color: Color(0xFFCBD5E1),
                  ),
                ),
              ),

              const Spacer(),

              Column(
                children: [
                  const SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: Color(0xFFFF6A00),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Chargement...",
                    style: TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 34),
            ],
          ),
        ),
      ),
    );
  }
}

/// =======================
/// ONBOARDING (Temporaire)
/// =======================

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Spacer(),

            const Text(
              "Entretenez votre voiture comme un pro",
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w800,
                height: 1.1,
                color: Color(0xFF111827),
              ),
            ),

            const SizedBox(height: 18),

            const Text(
              "Des tutoriels adaptés à votre véhicule pour économiser du temps et de l'argent.",
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF64748B),
                height: 1.5,
              ),
            ),

            const SizedBox(height: 40),

            Expanded(
              child: Center(
                child: Container(
                  width: 310,
                  height: 180,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFF7FAFC),
                        Color(0xFFEAF2FB),
                      ],
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.directions_car_filled_rounded,
                      size: 120,
                      color: Color(0xFFD1D5DB),
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(
              width: double.infinity,
              height: 58,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6A00),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                onPressed: () {},
                child: const Text(
                  "Suivant",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 36),
          ],
        ),
      ),
    );
  }
}
