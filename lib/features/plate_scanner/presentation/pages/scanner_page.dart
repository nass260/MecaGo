import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/database_helper.dart';
import '../../infrastructure/services/ocr_scanner_service.dart';

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  final OcrScannerService _ocrService = const OcrScannerService();
  bool _isProcessing = false;

  /// Gère l'acquisition d'image et déclenche l'analyse OCR France IA
  Future<void> _handleCapture() async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    // Appel du service OCR ciblé France (Simule l'extraction de la plaque SIV : AB-123-CD)
    final String? detectedFrenchPlate = await _ocrService.extractFrenchLicensePlate(File(''));

    if (detectedFrenchPlate != null) {
      // Insertion automatique et persistance dans la base de données locale SQLite (Ex: Renault Clio 5)
      await DatabaseHelper.instance.insertVehicle({
        'brand': 'Renault',
        'model': 'Clio 5',
        'plate': detectedFrenchPlate,
        'progress': 0.95,
        'isAlert': 0,
      });

      if (mounted) {
        // Redirection chirurgicale immédiate vers la fiche technique du véhicule identifié
        context.push('/vehicle-details');
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Format invalide : Veuillez scanner une plaque d'immatriculation française."),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    if (mounted) {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy, // Mode atelier sombre protecteur
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 1. BARRE DE TITRE BANDEAU HAUT
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Scanner de Plaque',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: -0.5),
                  ),
                  IconButton(
                    icon: const Icon(Icons.flash_on_rounded, color: Colors.white),
                    onPressed: () {},
                  ),
                ],
              ),
            ),

            // 2. CADRE DE VISÉE DE LA MAQUETTE POUR PLAQUES SIV
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: _isProcessing ? AppColors.orange : AppColors.orange.withOpacity(0.4),
                    width: 2.5,
                  ),
                ),
                child: Center(
                  child: _isProcessing
                      ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppColors.orange))
                      : const Icon(Icons.center_focus_weak_rounded, color: Colors.white30, size: 64),
                ),
              ),
            ),

            // 3. TEXTE DE GUIDAGE ET DÉCLENCHEUR BAS (MODE MAINS SALES)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32.0),
              child: Column(
                children: [
                  Text(
                    _isProcessing ? 'Analyse OCR France IA en cours...' : 'Placez la plaque française dans le cadre',
                    style: const TextStyle(color: Colors.white60, fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 18),
                  
                  // Gros bouton de capture circulaire tactile
                  GestureDetector(
                    onTap: _handleCapture,
                    child: Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                      ),
                      child: Container(
                        margin: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _isProcessing ? Colors.grey : AppColors.orange,
                        ),
                        child: const Icon(Icons.center_focus_strong_rounded, color: Colors.white, size: 28),
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
