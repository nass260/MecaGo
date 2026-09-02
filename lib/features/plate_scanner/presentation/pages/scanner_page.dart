import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../../../../core/theme/app_theme.dart';

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  bool _isProcessing = false;
  final TextRecognizer _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  // Initialisation automatique des capteurs photo du smartphone
  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        // Sélection de la caméra arrière principale du téléphone
        _cameraController = CameraController(
          _cameras![0],
          ResolutionPreset.high,
          enableAudio: false,
        );

        await _cameraController!.initialize();
        if (mounted) {
          setState(() {
            _isInitialized = true;
          });
        }
      }
    } catch (e) {
      debugPrint("Erreur lors de l'initialisation de la caméra : $e");
    }
  }

  // Analyse OCR en temps réel de la plaque via l'IA de Google ML Kit
  Future<void> _scanPlate() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized || _isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      // Capture d'un cliché instantané en mémoire
      final XFile image = await _cameraController!.takePicture();
      final InputImage inputImage = InputImage.fromFilePath(image.path);
      
      // Extraction du texte par Google ML Kit
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
      
      String detectedPlate = "";
      // Regex stricte pour isoler les plaques d'immatriculation européennes / françaises
      final RegExp plateRegex = RegExp(r'[A-Z]{2}[- ]?[0-9]{3}[- ]?[A-Z]{2}|[0-9]{1,4}[- ]?[A-Z]{1,3}[- ]?[0-9]{2,4}');

      for (TextBlock block in recognizedText.blocks) {
        for (TextLine line in block.lines) {
          final String cleanedText = line.text.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9-]'), '');
          if (plateRegex.hasMatch(cleanedText)) {
            detectedPlate = cleanedText;
            break;
          }
        }
      }

      if (mounted) {
        _showResultPopup(detectedPlate.isNotEmpty ? detectedPlate : "Non détectée");
      }
    } catch (e) {
      debugPrint("Erreur d'analyse OCR : $e");
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  // Popup premium de confirmation suite à l'identification de votre Tesla Model 3
  void _showResultPopup(String plate) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
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
              decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(10)),
            ),
            const SizedBox(height: 24),
            Icon(
              plate != "Non détectée" ? Icons.check_circle_rounded : Icons.error_outline_rounded, 
              color: plate != "Non détectée" ? AppColors.success : Colors.red, 
              size: 54
            ),
            const SizedBox(height: 16),
            Text(
              plate != "Non détectée" ? 'Véhicule Identifié !' : 'Plaque introuvable',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.navy),
            ),
            const SizedBox(height: 8),
            Text(
              'Plaque reconnue : $plate',
              style: const TextStyle(fontFamily: 'monospace', fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.blue),
            ),
            const SizedBox(height: 24),
            if (plate != "Non détectée")
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(20)),
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
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _textRecognizer.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.between,
          children: [
            // Barre supérieure premium
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.between,
                children: [
                  const Text('Scanner de Plaque', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.flash_on_rounded, color: Colors.white),
                    onPressed: () {},
                  ),
                ],
              ),
            ),

            // Rendu de la Caméra réelle intégrée dans le design épuré Apple
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: AppColors.blue, width: 2),
                ),
                overflow: ClipRRect(borderRadius: BorderRadius.circular(28)).clipBehavior,
                child: _isInitialized
                    ? CameraPreview(_cameraController!)
                    : const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white))),
              ),
            ),

            // Zone du déclencheur d'action
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32.0),
              child: Column(
                children: [
                  Text(
                    _isProcessing ? 'Analyse OCR Google IA en cours...' : 'Placez la plaque dans le cadre bleu',
                    style: const TextStyle(color: Colors.white60, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: _isProcessing ? null : _scanPlate,
                    child: Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 4)),
                      child: Container(
                        margin: const EdgeInsets.all(6),
                        decoration: BoxDecoration(shape: BoxShape.circle, color: _isProcessing ? Colors.grey : AppColors.orange),
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
