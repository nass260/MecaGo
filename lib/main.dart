import 'dart:async';
import 'package:flutter/material.dart';
import 'core/navigation/app_router.dart'; // <-- L'importation du router
import 'core/theme/app_theme.dart';      // <-- L'importation du thème

void main() {
  runApp(const MecaGoApp());
}

class MecaGoApp extends StatelessWidget {
  const MecaGoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router( // <-- Notez le ".router" ajouté ici
      title: 'MecaGo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: AppRouter.router, // <-- Le router est branché ici
    );
  }
}

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

    // Note : Plus tard, nous lierons la fin du chrono à une redirection go_router
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

