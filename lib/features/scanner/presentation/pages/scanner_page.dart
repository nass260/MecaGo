import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/premium_card.dart';
import '../../../../core/widgets/premium_button.dart';
import '../../../../core/services/photo_analysis_service.dart';

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  final PhotoAnalysisService _analysisService = const PhotoAnalysisService();
  bool _isAnalyzing = false;
  Map<String, dynamic>? _analysisResult;

  /// Simule la capture photo et lance l'analyse visuelle par l'IA
  void _captureAndAnalyze(String simulatedComponent) {
    setState(() {
      _isAnalyzing = true;
      _analysisResult = null;
    });

    _analysisService.analyzeComponentPhoto(simulatedComponent).then((result) {
      if (!mounted) return;
      setState(() {
        _isAnalyzing = false;
        _analysisResult = result;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Fond noir style appareil photo immersif
      appBar: AppBar(
        title: const Text('Scanner MecaGo', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 1. LE VISEUR GÉOMÉTRIQUE DE LA CAMÉRA D'ATELIER
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white30, width: 1),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Indicateur de scan au centre
                      if (_isAnalyzing)
                        const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppColors.orange))
                      else if (_analysisResult == null)
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.center_focus_strong_rounded, color: Colors.white.withOpacity(0.4), size: 56),
                            const SizedBox(height: 12),
                            Text('Placez la pièce dans le cadre', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13, fontWeight: FontWeight.w500)),
                          ],
                        )
                      else
                        // RECTANGLE DE BILAN VISUEL PREMIUM INSÉRÉ DANS LE VISEUR
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: PremiumCard(
                            padding: const EdgeInsets.all(18),
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(_analysisResult!['component'] as String, style: const TextStyle(color: AppColors.navy, fontWeight: FontWeight.w900, fontSize: 16)),
                                      Text(_analysisResult!['status'] as String, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                  const Divider(height: 20),
                                  Text('USURE CONSTATÉE : ${_analysisResult!['wearPercent']}%', style: const TextStyle(color: AppColors.orange, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                                  const SizedBox(height: 6),
                                  Text(_analysisResult!['verdict'] as String, style: const TextStyle(color: AppColors.navy, fontSize: 13, height: 1.35, fontWeight: FontWeight.w500)),
                                  const SizedBox(height: 12),
                                  Text('💡 ${_analysisResult!['recommendation']}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // 2. BARRE DE COMMANDE INFERIEURE AVEC CHOIX DES SIMULATIONS PHOTO
            Container(
              color: Colors.black,
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
              child: Column(
                children: [
                  if (!_isAnalyzing && _analysisResult == null) ...[
                    const Text('SIMULER UNE CAPTURE PHOTO :', style: TextStyle(color: Colors.white55, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.circle_outlined, size: 14),
                            label: const Text('Prendre un Pneu'),
                            style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Colors.white30), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                            onPressed: () => _captureAndAnalyze('pneu_tesla.jpg'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.album_outlined, size: 14),
                            label: const Text('Prendre un Frein'),
                            style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Colors.white30), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                            onPressed: () => _captureAndAnalyze('disque_frein.jpg'),
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (_analysisResult != null) ...[
                    PremiumButton(
                      text: 'Recommencer le scan',
                      onPressed: () => setState(() => _analysisResult = null),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
