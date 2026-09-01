import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  bool _isScanning = false;

  void _simulateScan() {
    setState(() {
      _isScanning = true;
    });

    // Simulation de l'analyse OCR (2 secondes)
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isScanning = false;
      });
      
      // Popup Premium de confirmation au style Apple
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) => Container(
          padding: const EdgeInsets.all(32),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 24),
              const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 54),
              const SizedBox(height: 16),
              const Text(
                'Véhicule Identifié !',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.navy),
              ),
              const SizedBox(height: 8),
              const Text(
                'Plaque reconnue : AB-123-CD',
                style: TextStyle(fontFamily: 'monospace', fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.blue),
              ),
              const SizedBox(height: 24),
              
              // Fiche d'identification de la Tesla
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.directions_car_filled_rounded, color: AppColors.textSecondary, size: 40),
                    SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Tesla Model 3', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.navy)),
                        Text('Autonomie Standard Plus - Électrique', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy, // Fond sombre immersif pour la caméra
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.between,
          children: [
            // 1. Barre supérieure épurée
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.between,
                children: [
                  const Text(
                    'Scanner de Plaque',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.flash_on_rounded, color: Colors.white),
                    onPressed: () {}, // Simulation activation de la lampe
                  ),
                ],
              ),
            ),

            // 2. Mires de guidage bleu électrique (#2563EB)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 32),
              height: 120,
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.blue, width: 2),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (_isScanning)
                    const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppColors.blue))
                  else
                    Text(
                      'POSITIONNEZ LA PLAQUE ICI',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                ],
              ),
            ),

            // 3. Déclencheur Photo de luxe (Anneau blanc + Cœur Orange)
            Padding(
              padding: const EdgeInsets.bottom(40.0),
              child: Column(
                children: [
                  const Text(
                    'Analyse automatique via Google ML Kit',
                    style: TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: _isScanning ? null : _simulateScan,
                    child: Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                      ),
                      child: Container(
                        margin: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.orange, // Cœur Orange officiel
                        ),
                        child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 28),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
