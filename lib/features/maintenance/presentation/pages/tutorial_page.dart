import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/premium_card.dart';
import '../../../../core/widgets/premium_button.dart';
import '../../data/models/tutorial_model.dart';
import '../../infrastructure/repositories/maintenance_repository.dart';

class TutorialPage extends StatefulWidget {
  const TutorialPage({super.key});

  @override
  State<TutorialPage> createState() => _TutorialPageState();
}

class _TutorialPageState extends State<TutorialPage> {
  final MaintenanceRepository _repository = const MaintenanceRepository();
  TutorialModel? _enrichedTutorial;
  bool _isLoading = true;
  int _activeStepIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadTutorialContext();
  }

  /// Charge le tutoriel enrichi avec l'intelligence commerciale nationale (PURFLUX / VALEO)
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
                  // 1. TIMELINE HORIZONTALE ÉCHELLE DE ETAPES
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

                  // 2. BLOC CENTRAL DE L'ETAPE ACTIVE ILLUSTREE
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
                          
                          // Badge Recommandation Partenaire Affilié
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
                          
                          // Zone Outils requis
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

                  // 3. BARRE DE COMMANDE BASSE ÉLASTIQUE
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
                          // Clôture de l'atelier et retour au bercail
                          Navigator.of(context).pop();
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
