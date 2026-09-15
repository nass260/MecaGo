// lib/features/garage/presentation/pages/plate_scanner_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';

class PlateScannerPage extends StatefulWidget {
  const PlateScannerPage({super.key});

  @override
  State<PlateScannerPage> createState() => _PlateScannerPageState();
}

class _PlateScannerPageState extends State<PlateScannerPage> {
  bool _isScanning = false;
  String? _detectedPlate;

  void _simulateScan() async {
    setState(() => _isScanning = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _isScanning = false;
      _detectedPlate = 'AB-123-CD';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Viseur
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [Colors.grey.shade900, Colors.black],
                  ),
                ),
              ),
            ),

            // Barre supérieure
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                    const Spacer(),
                    const Text(
                      'Scanner la plaque',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(width: 44),
                  ],
                ),
              ),
            ),

            // Cadre de scan
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Positionnez la plaque d\'immatriculation\ndans le cadre',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  Container(
                    width: 280,
                    height: 140,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.orange, width: 3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: _isScanning
                        ? const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.orange,
                              ),
                            ),
                          )
                        : _detectedPlate != null
                            ? Center(
                                child: Text(
                                  _detectedPlate!,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 2,
                                  ),
                                ),
                              )
                            : null,
                  ),
                ],
              ),
            ),

            // Bouton caméra
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: _detectedPlate == null ? _simulateScan : null,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      color: _detectedPlate == null
                          ? AppColors.orange
                          : AppColors.success,
                    ),
                    child: Icon(
                      _detectedPlate == null
                          ? Icons.camera_alt_rounded
                          : Icons.check_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
              ),
            ),

            // Bouton continuer
            if (_detectedPlate != null)
              Positioned(
                bottom: 140,
                left: 20,
                right: 20,
                child: ElevatedButton(
                  onPressed: () => context.push('/add-vehicle'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.orange,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Continuer',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}