import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/premium_card.dart';

class GarageModePage extends StatefulWidget {
  const GarageModePage({super.key});

  @override
  State<GarageModePage> createState() => _GarageModePageState();
}

class _GarageModePageState extends State<GarageModePage> {
  bool _isTorchOn = false;
  bool _isTimerRunning = false;
  int _secondsElapsed = 0;
  Timer? _timer;

  // Liste des étapes pour la vidange de la Tesla Model 3
  final List<Map<String, dynamic>> _checklist = [
    {'task': 'Placer les tampons de levage (Jack Pads)', 'done': false},
    {'task': 'Retirer le carter de protection inférieur', 'done': false},
    {'task': 'Dévisser le bouchon de vidange', 'done': false},
    {'task': 'Remplacer le filtre à huile', 'done': false},
    {'task': 'Resserrer au couple : 25 Nm', 'done': false},
  ];

  void _toggleTimer() {
    setState(() {
      _isTimerRunning = !_isTimerRunning;
    });

    if (_isTimerRunning) {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          _secondsElapsed++;
        });
      });
    } else {
      _timer?.cancel();
    }
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isTimerRunning = false;
      _secondsElapsed = 0;
    });
  }

  String _formatTime(int totalSeconds) {
    int minutes = totalSeconds ~/ 60;
    int seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              // 1. EN-TÊTE ÉPURÉ
              Row(
                mainAxisAlignment: MainAxisAlignment.between,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'MODE GARAGE ACTIVE',
                        style: TextStyle(color: AppColors.orange, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Vidange Moteur',
                        style: TextStyle(color: AppColors.navy, fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, py: 6),
                    decoration: BoxDecoration(
                      color: AppColors.navy,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      '🔒 Écran verrouillé allumé',
                      style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // 2. ENCART TECHNIQUE TRÈS LISIBLE (Style Autodoc Premium)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.navy,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Text('⚠️', style: TextStyle(fontSize: 24)),
                    SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        'Attention : Attendre 15 minutes que le moteur refroidisse avant de dévisser le bouchon.',
                        style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 3. LES DEUX BOUTONS GÉANTS (Outils Rapides Mains Sales)
              Row(
                children: [
                  // BOUTON LAMPE DE POCHE
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isTorchOn = !_isTorchOn;
                        });
                      },
                      child: Container(
                        height: 110,
                        decoration: BoxDecoration(
                          color: _isTorchOn ? AppColors.blue : Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: _isTorchOn ? Colors.transparent : AppColors.border, width: 1.5),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.flashlight_on_rounded, color: _isTorchOn ? Colors.white : AppColors.blue, size: 36),
                            const SizedBox(height: 8),
                            Text(
                              'Lampe',
                              style: TextStyle(color: _isTorchOn ? Colors.white : AppColors.navy, fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // BOUTON MINUTEUR DE VIDANGE
                  Expanded(
                    child: GestureDetector(
                      onTap: _toggleTimer,
                      onLongPress: _resetTimer,
                      child: Container(
                        height: 110,
                        decoration: BoxDecoration(
                          color: _isTimerRunning ? AppColors.orange : Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: _isTimerRunning ? Colors.transparent : AppColors.border, width: 1.5),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _formatTime(_secondsElapsed),
                              style: TextStyle(color: _isTimerRunning ? Colors.white : AppColors.navy, fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _isTimerRunning ? 'Pause (Appui)' : 'Minuteur (Appui)',
                              style: TextStyle(color: _isTimerRunning ? Colors.white70 : AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // 4. CHECKLIST GÉANTE INTERACTIVE (Utilisable au poing ou doigt sale)
              const Text(
                'Étapes de l\'intervention',
                style: TextStyle(color: AppColors.navy, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 14),
              
              Expanded(
                child: ListView.builder(
                  itemCount: _checklist.length,
                  itemBuilder: (context, index) {
                    final item = _checklist[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _checklist[index]['done'] = !_checklist[index]['done'];
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: item['done'] ? const Color(0xFFEFFFEE) : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: item['done'] ? AppColors.success.withOpacity(0.4) : AppColors.border,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                item['done'] ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                                color: item['done'] ? AppColors.success : AppColors.textSecondary,
                                size: 28, // Très grand pour ne pas rater la case
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  item['task'],
                                  style: TextStyle(
