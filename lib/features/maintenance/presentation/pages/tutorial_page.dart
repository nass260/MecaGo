import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/premium_card.dart';
import '../../../../core/widgets/premium_button.dart';
import '../../../history/domain/usecases/log_intervention_usecase.dart'; // <-- 1. Importation du Use Case d'archivage
import '../../data/models/tutorial_model.dart';
import '../../infrastructure/repositories/maintenance_repository.dart';

class TutorialPage extends StatefulWidget {
  const TutorialPage({super.key});

  @override
  State<TutorialPage> createState() => _TutorialPageState();
}

class _TutorialPageState extends State<TutorialPage> {
  final MaintenanceRepository _repository = const MaintenanceRepository();
  final LogInterventionUseCase _logUseCase = const LogInterventionUseCase(); // <-- Initialisation du Use Case
  
  TutorialModel? _enrichedTutorial;
  bool _isLoading = true;
  int _activeStepIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadTutorialContext();
  }

  Future<void> _loadTutorialContext() async {
    final TutorialModel tutorial = await _repository.loadEnrichedTutorial(
      vehicleBrand: "RENAULT",
      tutorialTitle: "Remplacement filtre d'habitacle HEPA",
    );

    if (mounted) {
      setState(() {
        _enrichedTutorial = tutorial;
        _isLoading = false;
      });
    }
  }

  /// Déclenche l'archivage physique du gain en euros dans la base SQLite à la fin de l'atelier
  Future<void> _finalizeIntervention() async {
    if (_enrichedTutorial == null) return;

    setState(() => _isLoading = true);

    // Persiste les 35€ d'économies dans l'historique avec la bonne icône
    final bool success = await _logUseCase.execute(
      title: _enrichedTutorial!.title,
      savingsAmount: _enrichedTutorial!.savings,
      vehicleMileage: "42 150 km",
      iconMaterialCodePoint: 0xe056, // Icons.air_rounded
    );

    if (mounted) {
      setState(() => _isLoading = false);
      // Ferme l'écran d'atelier pour revenir au tableau de bord actualisé
      Navigator.of(context).pop();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? "Intervention validée ! +35 € ajoutés à vos économies." : "Erreur d'écriture SQLite."),
          backgroundColor: success ? AppColors.success : Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppColors.navy),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          _isLoading ? 'Chargement guide...' : _enrichedTutorial!.title,
          style: const TextStyle(color: AppColors.navy, fontWeight: FontWeight.w800, fontSize: 16, letterSpacing: -0.3),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppColors.orange)))
            : Column(
                children: [
                  // TIMELINE HORIZONTALE DE PROGRES
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                    child: Row(
                      children: List.generate(_enrichedTutorial!.steps.length, (index) {
                        final bool isDone = index <= _activeStepIndex;
                        return Expanded(
                          child: Container(
                            height: 6,
                            margin: const EdgeInsets.symmetric(horizontal: 2.0),
                            decoration: BoxDecoration(
                              color: isDone ? AppColors.orange : AppColors.border,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),

                  // BLOC CENTRAL ILLUSTRÉ
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 200,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              image: DecorationImage(
                                image: NetworkImage(_enrichedTutorial!.steps[_activeStepIndex].imageUrl),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(color: const Color(0xFFFFF7ED), borderRadius: BorderRadius.circular(8)),
                            child: Text(
                              _enrichedTutorial!.tag,
                              style: const TextStyle(color: AppColors.orange, fontWeight: FontWeight.bold, fontSize: 11),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _enrichedTutorial!.steps[_activeStepIndex].title,
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.navy, letterSpacing: -0.5),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _enrichedTutorial!.steps[_activeStepIndex].description,
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 15, height: 1.5, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 20),
                          PremiumCard(
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              children: [
                                const Icon(Icons.handyman_rounded, color: AppColors.navy, size: 20),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Outillage requis : ${_enrichedTutorial!.steps[_activeStepIndex].toolsRequired}',
                                    style: const TextStyle(color: AppColors.navy, fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (_enrichedTutorial!.steps[_activeStepIndex].warning != null) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(16)),
                              child: Row(
                                children: [
                                  const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 20),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      _enrichedTutorial!.steps[_activeStepIndex].warning!,
                                      style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 13),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  // COMMANDES BASSES CONNECTÉES AU USE CASE D'ARCHIVAGE
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: PremiumButton(
                      text: _activeStepIndex == _enrichedTutorial!.steps.length - 1 ? "Valider l'intervention (+35€)" : "Étape suivante",
                      onPressed: () {
                        if (_activeStepIndex < _enrichedTutorial!.steps.length - 1) {
                          setState(() {
                            _activeStepIndex++;
                          });
                        } else {
                          _finalizeIntervention(); // Appelle le pipeline de stockage persistant
                        }
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
