// lib/features/diagnostic/presentation/pages/diagnostic_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/autodoc_service.dart';

/// Niveau de gravité du diagnostic
enum SeverityLevel {
  critical('CRITIQUE', AppColors.danger, Icons.warning_rounded, '🚨'),
  high('ÉLEVÉ', AppColors.orange, Icons.priority_high_rounded, '⚠️'),
  medium('MOYEN', Colors.blue, Icons.info_rounded, '📌'),
  low('FAIBLE', AppColors.success, Icons.check_circle_rounded, '✅');

  final String label;
  final Color color;
  final IconData icon;
  final String emoji;
  const SeverityLevel(this.label, this.color, this.icon, this.emoji);
}

/// Résultat du diagnostic
class DiagnosisResult {
  final String title;
  final String description;
  final SeverityLevel severity;
  final List<String> symptoms;
  final List<PartCategory> recommendedParts;
  final String estimatedCost;
  final bool urgent;

  const DiagnosisResult({
    required this.title,
    required this.description,
    required this.severity,
    required this.symptoms,
    required this.recommendedParts,
    required this.estimatedCost,
    required this.urgent,
  });
}

class DiagnosticPage extends StatefulWidget {
  const DiagnosticPage({super.key});

  @override
  State<DiagnosticPage> createState() => _DiagnosticPageState();
}

class _DiagnosticPageState extends State<DiagnosticPage> {
  final AutodocService _autodocService = const AutodocService();
  final TextEditingController _symptomController = TextEditingController();

  String _selectedVehicleBrand = 'Peugeot';
  String _selectedVehicleModel = '308';
  DiagnosisResult? _result;
  bool _isAnalyzing = false;
  List<Part> _recommendedParts = [];
  bool _isLoadingParts = false;

  final List<String> _quickSymptoms = [
    'Bruit de sifflement quand je freine',
    'Voyant moteur allumé',
    'Vibrations dans le volant',
    'Difficulté à démarrer',
    'Fumée blanche à l\'échappement',
    'Consommation de carburant élevée',
    'Pédale de frein molle',
    'Climatisation ne refroidit plus',
  ];

  @override
  void dispose() {
    _symptomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.navy),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Diagnostic IA',
          style: TextStyle(
            color: AppColors.navy,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: _result != null ? _buildResultView() : _buildInputView(),
    );
  }

  // ============================================
  // VUE DE SAISIE
  // ============================================

  Widget _buildInputView() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bandeau IA
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppGradients.navy,
              borderRadius: BorderRadius.circular(20),
              boxShadow: AppShadows.hero,
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: AppGradients.orange,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.orange.withOpacity(0.5),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.psychology_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Assistant IA MecaGo',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Décrivez votre panne, l\'IA identifie la cause',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Véhicule
          const Text(
            'Véhicule concerné',
            style: TextStyle(
              color: AppColors.navy,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppShadows.card,
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.directions_car_rounded,
                    color: AppColors.orange,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$_selectedVehicleBrand $_selectedVehicleModel',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.navy,
                        ),
                      ),
                      const Text(
                        'Essence · Manuelle',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Description
          const Text(
            'Décrivez votre problème',
            style: TextStyle(
              color: AppColors.navy,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Plus vous êtes précis, meilleur sera le diagnostic',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppShadows.card,
            ),
            child: TextField(
              controller: _symptomController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText:
                    'Ex: J\'entends un bruit de sifflement quand je freine...',
                hintStyle: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(16),
              ),
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.navy,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Symptômes rapides
          const Text(
            'Ou choisissez un symptôme courant',
            style: TextStyle(
              color: AppColors.navy,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _quickSymptoms.map((symptom) {
              return GestureDetector(
                onTap: () {
                  _symptomController.text = symptom;
                  setState(() {});
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border:
                        Border.all(color: AppColors.border.withOpacity(0.6)),
                  ),
                  child: Text(
                    symptom,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.navy,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Bouton analyse
          _buildAnalyzeButton(),
        ],
      ),
    );
  }

  Widget _buildAnalyzeButton() {
    final canAnalyze =
        _symptomController.text.trim().isNotEmpty && !_isAnalyzing;

    return GestureDetector(
      onTap: canAnalyze ? _analyze : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          gradient: canAnalyze ? AppGradients.orange : null,
          color: canAnalyze ? null : AppColors.border,
          borderRadius: BorderRadius.circular(18),
          boxShadow: canAnalyze ? AppShadows.orangeButton : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isAnalyzing)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 2,
                ),
              )
            else
              const Icon(
                Icons.auto_awesome_rounded,
                color: Colors.white,
                size: 20,
              ),
            const SizedBox(width: 10),
            Text(
              _isAnalyzing ? 'Analyse en cours...' : 'Lancer le diagnostic',
              style: TextStyle(
                color: canAnalyze ? Colors.white : AppColors.textSecondary,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================
  // VUE DE RÉSULTAT
  // ============================================

  Widget _buildResultView() {
    final result = _result!;
    final severity = result.severity;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Carte gravité
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [severity.color, severity.color.withOpacity(0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: severity.color.withOpacity(0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      severity.emoji,
                      style: const TextStyle(fontSize: 32),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Gravité ${severity.label}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            result.urgent
                                ? 'Intervention recommandée'
                                : 'À surveiller',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  result.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  result.description,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.95),
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.euro_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Coût estimé : ${result.estimatedCost}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Symptômes détectés
          const Text(
            'Symptômes détectés',
            style: TextStyle(
              color: AppColors.navy,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppShadows.card,
            ),
            child: Column(
              children: result.symptoms.map((s) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: severity.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          s,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.navy,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),

          // Pièces recommandées
          if (_isLoadingParts)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.orange),
                ),
              ),
            )
          else if (_recommendedParts.isNotEmpty) ...[
            const Text(
              '🛒 Pièces recommandées',
              style: TextStyle(
                color: AppColors.navy,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Commandez sur AUTODOC en 1 clic',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 12),
            ..._recommendedParts.map((part) => _buildPartCard(part)),
            const SizedBox(height: 24),
          ],

          // Bouton nouveau diagnostic
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                setState(() {
                  _result = null;
                  _recommendedParts = [];
                  _symptomController.clear();
                });
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: AppColors.border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Nouveau diagnostic',
                style: TextStyle(
                  color: AppColors.navy,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPartCard(Part part) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.card,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              part.category.icon,
              color: AppColors.orange,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  part.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.navy,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  part.brand,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (part.originalPrice != null) ...[
                Text(
                  part.formattedOriginalPrice!,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              ],
              Text(
                part.formattedPrice,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: AppColors.orange,
                ),
              ),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: () => _orderPart(part),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.orange,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Commander',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================
  // LOGIQUE
  // ============================================

  void _analyze() async {
    setState(() {
      _isAnalyzing = true;
      _isLoadingParts = true;
    });

    await Future.delayed(const Duration(seconds: 2));

    final symptom = _symptomController.text.toLowerCase();
    final result = _analyzeSymptom(symptom);

    final parts = await _autodocService.getRecommendedParts(
      brand: _selectedVehicleBrand,
      model: _selectedVehicleModel,
      diagnosis: symptom,
    );

    if (!mounted) return;

    setState(() {
      _result = result;
      _recommendedParts = parts;
      _isAnalyzing = false;
      _isLoadingParts = false;
    });
  }

  DiagnosisResult _analyzeSymptom(String symptom) {
    if (symptom.contains('frein') || symptom.contains('sifflement')) {
      return const DiagnosisResult(
        title: 'Usure des plaquettes de frein',
        description:
            'Les plaquettes de frein avant présentent une usure avancée. '
            'Le sifflement est caractéristique du témoin d\'usure. '
            'Un remplacement est recommandé pour votre sécurité.',
        severity: SeverityLevel.critical,
        symptoms: [
          'Bruit de sifflement au freinage',
          'Usure > 80% détectée',
          'Témoin d\'usure atteint',
        ],
        recommendedParts: [PartCategory.plaquettesFrein],
        estimatedCost: '35 - 45 EUR',
        urgent: true,
      );
    }

    if (symptom.contains('voyant') || symptom.contains('moteur')) {
      return const DiagnosisResult(
        title: 'Anomalie moteur détectée',
        description:
            'Le voyant moteur indique une anomalie. '
            'Un diagnostic électronique (OBD) est nécessaire '
            'pour identifier précisément la cause.',
        severity: SeverityLevel.high,
        symptoms: [
          'Voyant moteur allumé',
          'Possible perte de puissance',
          'Consommation potentiellement augmentée',
        ],
        recommendedParts: [PartCategory.bougies],
        estimatedCost: '30 - 100 EUR',
        urgent: true,
      );
    }

    if (symptom.contains('vibration') || symptom.contains('volant')) {
      return const DiagnosisResult(
        title: 'Déséquilibre des roues',
        description:
            'Les vibrations dans le volant indiquent probablement '
            'un déséquilibre des roues avant ou un problème '
            'd\'amortisseurs. Un équilibrage est recommandé.',
        severity: SeverityLevel.medium,
        symptoms: [
          'Vibrations dans le volant',
          'Apparition à vitesse élevée',
          'Usure irrégulière des pneus',
        ],
        recommendedParts: [PartCategory.pneus, PartCategory.amortisseurs],
        estimatedCost: '80 - 160 EUR',
        urgent: false,
      );
    }

    if (symptom.contains('démarr') || symptom.contains('démarre')) {
      return const DiagnosisResult(
        title: 'Batterie faible',
        description:
            'Les difficultés de démarrage sont souvent liées '
            'à une batterie faible ou en fin de vie. '
            'Un test de batterie est recommandé.',
        severity: SeverityLevel.high,
        symptoms: [
          'Démarrage difficile',
          'Phares faibles',
          'Bruit de clic au démarrage',
        ],
        recommendedParts: [PartCategory.batterie],
        estimatedCost: '90 - 130 EUR',
        urgent: true,
      );
    }

    if (symptom.contains('fumée') || symptom.contains('blanche')) {
      return const DiagnosisResult(
        title: 'Joint de culasse possible',
        description:
            'La fumée blanche à l\'échappement peut indiquer '
            'un problème de joint de culasse. '
            'Une vérification urgente est nécessaire.',
        severity: SeverityLevel.critical,
        symptoms: [
          'Fumée blanche épaisse',
          'Perte de liquide de refroidissement',
          'Surchauffe moteur',
        ],
        recommendedParts: [PartCategory.courroie],
        estimatedCost: '500 - 1500 EUR',
        urgent: true,
      );
    }

    if (symptom.contains('consommation') || symptom.contains('carburant')) {
      return const DiagnosisResult(
        title: 'Filtre à air encrassé',
        description:
            'Une consommation élevée peut être causée par '
            'un filtre à air encrassé ou des bougies usées. '
            'Un remplacement améliorera la consommation.',
        severity: SeverityLevel.medium,
        symptoms: [
          'Consommation augmentée',
          'Perte de puissance',
          'Fumée noire possible',
        ],
        recommendedParts: [PartCategory.filtreAir, PartCategory.bougies],
        estimatedCost: '15 - 50 EUR',
        urgent: false,
      );
    }

    if (symptom.contains('pédale') || symptom.contains('molle')) {
      return const DiagnosisResult(
        title: 'Niveau de liquide de frein bas',
        description:
            'Une pédale de frein molle indique généralement '
            'un niveau bas de liquide de frein ou une purge '
            'nécessaire. Vérification urgente.',
        severity: SeverityLevel.critical,
        symptoms: [
          'Pédale de frein molle',
          'Freinage moins efficace',
          'Possible fuite',
        ],
        recommendedParts: [PartCategory.plaquettesFrein],
        estimatedCost: '50 - 200 EUR',
        urgent: true,
      );
    }

    if (symptom.contains('clim') || symptom.contains('froid')) {
      return const DiagnosisResult(
        title: 'Recharge de climatisation nécessaire',
        description:
            'La climatisation qui ne refroidit plus nécessite '
            'probablement une recharge de gaz. '
            'Un filtre habitacle neuf est aussi recommandé.',
        severity: SeverityLevel.low,
        symptoms: [
          'Air moins froid',
          'Mauvaise odeur',
          'Compresseur bruyant',
        ],
        recommendedParts: [PartCategory.filtreHabitable],
        estimatedCost: '30 - 80 EUR',
        urgent: false,
      );
    }

    return const DiagnosisResult(
      title: 'Diagnostic général',
      description:
          'Votre problème nécessite un examen plus approfondi. '
          'Nous vous recommandons de consulter un professionnel '
          'ou de faire un scan OBD.',
      severity: SeverityLevel.medium,
      symptoms: [
        'Symptôme non spécifique',
        'Analyse complémentaire nécessaire',
      ],
      recommendedParts: [],
      estimatedCost: 'Variable',
      urgent: false,
    );
  }

  void _orderPart(Part part) async {
    final success = await _autodocService.openPartLink(
      part: part,
      brand: _selectedVehicleBrand,
      model: _selectedVehicleModel,
    );

    if (!mounted) return;

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Impossible d\'ouvrir AUTODOC'),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }
}