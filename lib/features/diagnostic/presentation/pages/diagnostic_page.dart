// lib/features/diagnostic/presentation/pages/diagnostic_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/ai_service.dart';
import '../../../../core/services/diagnostic_rules.dart';
import '../../../../core/services/global_notifier.dart';
import '../../../../core/services/piece_image_service.dart';
import '../widgets/mecago_chat_widget.dart';

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

  static SeverityLevel fromString(String value) {
    switch (value.toLowerCase()) {
      case 'critical':
        return SeverityLevel.critical;
      case 'high':
        return SeverityLevel.high;
      case 'medium':
        return SeverityLevel.medium;
      case 'low':
        return SeverityLevel.low;
      default:
        return SeverityLevel.medium;
    }
  }
}

/// Statut d'un système
enum SystemStatus { excellent, bon, attention, probleme }

class SystemCheck {
  final String name;
  final String description;
  final IconData icon;
  final Color iconColor;
  final SystemStatus status;

  const SystemCheck({
    required this.name,
    required this.description,
    required this.icon,
    required this.iconColor,
    required this.status,
  });

  String get statusLabel {
    switch (status) {
      case SystemStatus.excellent:
        return 'Excellent';
      case SystemStatus.bon:
        return 'Bon';
      case SystemStatus.attention:
        return 'Attention';
      case SystemStatus.probleme:
        return 'Problème';
    }
  }

  Color get statusColor {
    switch (status) {
      case SystemStatus.excellent:
      case SystemStatus.bon:
        return AppColors.success;
      case SystemStatus.attention:
        return AppColors.orange;
      case SystemStatus.probleme:
        return AppColors.danger;
    }
  }

  Color get statusBgColor {
    switch (status) {
      case SystemStatus.excellent:
      case SystemStatus.bon:
        return AppColors.successLight;
      case SystemStatus.attention:
        return const Color(0xFFFFF7ED);
      case SystemStatus.probleme:
        return const Color(0xFFFEF2F2);
    }
  }
}

class DiagnosisResult {
  final String title;
  final String description;
  final SeverityLevel severity;
  final List<String> symptoms;
  final List<PartSuggestion> parts;
  final String estimatedCost;
  final bool urgent;
  final List<SystemCheck> systems;
  final bool isFromAI;
  final String providerName;

  const DiagnosisResult({
    required this.title,
    required this.description,
    required this.severity,
    required this.symptoms,
    required this.parts,
    required this.estimatedCost,
    required this.urgent,
    required this.systems,
    required this.isFromAI,
    required this.providerName,
  });
}

class PartSuggestion {
  final String name;
  final String category;
  final String priceEstimate;
  final String priority;

  const PartSuggestion({
    required this.name,
    required this.category,
    required this.priceEstimate,
    required this.priority,
  });

  IconData get icon {
    switch (category.toLowerCase()) {
      case 'freinage':
        return Icons.car_repair_rounded;
      case 'filtration':
        return Icons.filter_alt_rounded;
      case 'moteur':
        return Icons.settings_rounded;
      case 'electrique':
        return Icons.electric_bolt_rounded;
      case 'suspension':
        return Icons.linear_scale_rounded;
      default:
        return Icons.build_rounded;
    }
  }

  Color get priorityColor {
    switch (priority.toLowerCase()) {
      case 'urgent':
        return AppColors.danger;
      case 'recommended':
        return AppColors.orange;
      default:
        return AppColors.textSecondary;
    }
  }

  String get priorityLabel {
    switch (priority.toLowerCase()) {
      case 'urgent':
        return 'URGENT';
      case 'recommended':
        return 'RECOMMANDÉ';
      default:
        return 'OPTIONNEL';
    }
  }
}

class DiagnosticPage extends StatefulWidget {
  const DiagnosticPage({super.key});

  @override
  State<DiagnosticPage> createState() => _DiagnosticPageState();
}

class _DiagnosticPageState extends State<DiagnosticPage> {
  final AiService _aiService = const AiService();
  final PieceImageService _pieceImageService = const PieceImageService();
  final TextEditingController _symptomController = TextEditingController();

  String _selectedVehicleBrand = 'Peugeot';
  String _selectedVehicleModel = '308';
  String _selectedVehicleFuel = 'Essence';
  int _selectedVehicleYear = 2020;
  DiagnosisResult? _result;
  bool _isAnalyzing = false;
  String? _errorMessage;

  final List<String> _quickSymptoms = [
    'Bruit de sifflement quand je freine',
    'Voyant moteur allumé',
    'Vibrations dans le volant',
    'Difficulté à démarrer',
    'Fumée blanche à l\'échappement',
    'Consommation de carburant élevée',
    'Pédale de frein molle',
    'Climatisation ne refroidit plus',
    'Bruit métallique au freinage',
    'Ralenti instable',
    'Voyant ABS allumé',
    'Direction dure',
  ];

  @override
  void initState() {
    super.initState();
    final notifier = GlobalNotifier.instance;
    final activeVehicle = notifier.activeVehicle;
    if (activeVehicle != null) {
      _selectedVehicleBrand = activeVehicle.brand;
      _selectedVehicleModel = activeVehicle.model;
      _selectedVehicleFuel = activeVehicle.fuelType.label;
      _selectedVehicleYear = activeVehicle.year;
    }
    _symptomController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _symptomController.removeListener(_onTextChanged);
    _symptomController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _result != null
                  ? _buildResultView()
                  : _buildInputView(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: AppShadows.card,
              ),
              child: const Icon(Icons.arrow_back_rounded,
                  color: AppColors.navy, size: 20),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.monitor_heart_rounded,
                        color: AppColors.orange, size: 20),
                    const SizedBox(width: 6),
                    const Text(
                      'Diagnostic',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: AppColors.navy,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                const Text(
                  'Analyse complète de votre véhicule par IA',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.orange.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.orange.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.workspace_premium_rounded,
                    color: AppColors.orange, size: 14),
                SizedBox(width: 4),
                Text(
                  'Premium',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.orange,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputView() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildVehicleCard(),
          const SizedBox(height: 20),
          const Text(
            'Décrivez votre problème',
            style: TextStyle(
              color: AppColors.navy,
              fontSize: 15,
              fontWeight: FontWeight.w800,
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
              onChanged: (value) => setState(() {}),
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
          const SizedBox(height: 20),
          const Text(
            'Ou choisissez un symptôme courant',
            style: TextStyle(
              color: AppColors.navy,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
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
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
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
          if (_errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.danger.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.danger.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline_rounded,
                      color: AppColors.danger, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(
                        color: AppColors.danger,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          _buildAnalyzeButton(),
        ],
      ),
    );
  }

  Widget _buildVehicleCard() {
    final imageUrl = GlobalNotifier.instance.activeVehicle?.imageUrl ?? '';
    final hasPhoto = imageUrl.isNotEmpty;

    return Container(
      height: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: AppGradients.navy,
        boxShadow: AppShadows.hero,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Positioned.fill(
              child: hasPhoto
                  ? Image.asset(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildDefaultCarImage(),
                    )
                  : _buildDefaultCarImage(),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      AppColors.navy.withOpacity(0.95),
                      AppColors.navy.withOpacity(0.4),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 18,
              top: 18,
              right: 18,
              bottom: 18,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.check_circle_rounded,
                                color: Colors.white, size: 10),
                            SizedBox(width: 4),
                            Text(
                              '100%',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$_selectedVehicleBrand $_selectedVehicleModel',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$_selectedVehicleFuel · $_selectedVehicleYear',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultCarImage() {
    return Center(
      child: Image.asset(
        'assets/images/car_neon.png',
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => Container(
          decoration: const BoxDecoration(
            gradient: AppGradients.navy,
          ),
          child: const Center(
            child: Icon(
              Icons.directions_car_rounded,
              color: Colors.white24,
              size: 80,
            ),
          ),
        ),
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

  Widget _buildResultView() {
    final result = _result!;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildVehicleCard(),
          const SizedBox(height: 16),
          _buildGlobalStatusCard(result),
          const SizedBox(height: 16),
          _buildAnalysisCard(result),
          const SizedBox(height: 20),
          Row(
            children: [
              const Text(
                'Détails du diagnostic',
                style: TextStyle(
                  color: AppColors.navy,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.successLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.check_circle_rounded,
                        color: AppColors.success, size: 12),
                    SizedBox(width: 4),
                    Text(
                      'Tout est OK',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...result.systems.map((system) => _buildSystemCard(system)),
          const SizedBox(height: 20),
          if (result.parts.isNotEmpty) ...[
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
            ...result.parts.map((part) => _buildPartCard(part)),
            const SizedBox(height: 20),
          ],
          MecaGoChatWidget(
            vehicleInfo:
                '$_selectedVehicleBrand $_selectedVehicleModel, $_selectedVehicleFuel, $_selectedVehicleYear',
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                setState(() {
                  _result = null;
                  _symptomController.clear();
                  _errorMessage = null;
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

  Widget _buildGlobalStatusCard(DiagnosisResult result) {
    final score = _calculateGlobalScore(result);
    final color = score >= 80
        ? AppColors.success
        : score >= 50
            ? AppColors.orange
            : AppColors.danger;
    final statusText = score >= 80
        ? 'Excellent'
        : score >= 50
            ? 'Moyen'
            : 'Critique';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppShadows.card,
      ),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 90,
                height: 90,
                child: CircularProgressIndicator(
                  value: score / 100,
                  strokeWidth: 8,
                  backgroundColor: AppColors.border.withOpacity(0.4),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$score',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: color,
                      height: 1,
                    ),
                  ),
                  const Text(
                    '/100',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'État général',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.navy,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: color,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  result.urgent
                      ? 'Une intervention est recommandée.'
                      : 'Aucun problème critique détecté.',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  int _calculateGlobalScore(DiagnosisResult result) {
    switch (result.severity) {
      case SeverityLevel.critical:
        return 25;
      case SeverityLevel.high:
        return 55;
      case SeverityLevel.medium:
        return 75;
      case SeverityLevel.low:
        return 95;
    }
  }

  Widget _buildAnalysisCard(DiagnosisResult result) {
    final isAI = result.isFromAI;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isAI
              ? [const Color(0xFFEEF2FF), const Color(0xFFE0E7FF)]
              : [const Color(0xFFFFF7ED), const Color(0xFFFFEDD5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isAI
              ? const Color(0xFFC7D2FE)
              : const Color(0xFFFED7AA),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isAI ? const Color(0xFF4F46E5) : AppColors.orange,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isAI ? Icons.auto_awesome_rounded : Icons.science_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isAI
                          ? 'Analyse ${result.providerName}'
                          : 'Analyse locale',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: isAI
                            ? const Color(0xFF4F46E5)
                            : AppColors.orange,
                      ),
                    ),
                    Text(
                      isAI ? 'IA avancée' : 'Base de données MecaGo',
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isAI)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.orange.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'HORS LIGNE',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: AppColors.orange,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            result.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: AppColors.navy,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            result.description,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.navy,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemCard(SystemCheck system) {
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
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: system.iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(system.icon, color: system.iconColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  system.name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.navy,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  system.description,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: system.statusBgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              system.statusLabel,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: system.statusColor,
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right_rounded,
              color: AppColors.textLight, size: 20),
        ],
      ),
    );
  }

  // ============================================
  // CARTE PIÈCE (avec image Supabase)
  // ============================================

  Widget _buildPartCard(PartSuggestion part) {
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
          // ✅ Image de la pièce depuis Supabase
          _pieceImageService.buildPieceImage(
            marque: _selectedVehicleBrand,
            modele: _selectedVehicleModel,
            motorisation: _selectedVehicleFuel,
            nomPieceIa: part.name.toLowerCase().replaceAll(' ', '_'),
            width: 44,
            height: 44,
            borderRadius: 12,
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
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: part.priorityColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        part.priorityLabel,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: part.priorityColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      part.category,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                part.priceEstimate,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: AppColors.orange,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => _openTutorial(part),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.orange,
                          width: 1,
                        ),
                      ),
                      child: const Text(
                        '📚 Tutoriel',
                        style: TextStyle(
                          color: AppColors.orange,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () => _orderPart(part),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
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
        ],
      ),
    );
  }

  // ============================================
  // LOGIQUE
  // ============================================

  Future<void> _analyze() async {
    setState(() {
      _isAnalyzing = true;
      _errorMessage = null;
    });

    final symptom = _symptomController.text.trim();
    final vehicleInfo = '$_selectedVehicleBrand $_selectedVehicleModel';

    try {
      final response = await _aiService.diagnose(
        vehicleInfo: vehicleInfo,
        symptoms: symptom,
      );
      final result = _mapJsonToResult(
        response.json,
        isFromAI: true,
        providerName: response.providerName,
      );
      if (!mounted) return;
      setState(() {
        _result = result;
        _isAnalyzing = false;
      });
      return;
    } catch (e) {
      debugPrint('⚠️ IA indisponible : $e');
    }

    await Future.delayed(const Duration(milliseconds: 500));
    final rule = DiagnosticRules.findRule(symptom);
    final result = _mapRuleToResult(rule, symptom);
    if (!mounted) return;
    setState(() {
      _result = result;
      _isAnalyzing = false;
    });
  }

  DiagnosisResult _mapJsonToResult(
    Map<String, dynamic> json, {
    required bool isFromAI,
    required String providerName,
  }) {
    final partsJson = json['parts'] as List<dynamic>? ?? [];
    final parts = partsJson.map((p) {
      final map = p as Map<String, dynamic>;
      return PartSuggestion(
        name: map['name'] as String? ?? 'Pièce',
        category: map['category'] as String? ?? 'général',
        priceEstimate: map['price_estimate'] as String? ?? 'N/A',
        priority: map['priority'] as String? ?? 'recommended',
      );
    }).toList();

    final symptomsJson = json['symptoms'] as List<dynamic>? ?? [];
    final symptoms = symptomsJson.map((s) => s.toString()).toList();

    final severityStr = json['severity'] as String? ?? 'medium';
    final severity = SeverityLevel.fromString(severityStr);

    return DiagnosisResult(
      title: json['title'] as String? ?? 'Diagnostic',
      description: json['description'] as String? ?? '',
      severity: severity,
      symptoms: symptoms,
      parts: parts,
      estimatedCost: json['estimated_cost'] as String? ?? 'Variable',
      urgent: json['urgent'] as bool? ?? false,
      systems: _buildSystemsFromSeverity(
          severity, json['title'] as String? ?? ''),
      isFromAI: isFromAI,
      providerName: providerName,
    );
  }

  DiagnosisResult _mapRuleToResult(DiagnosticRule? rule, String symptom) {
    if (rule == null) {
      return DiagnosisResult(
        title: 'Diagnostic général',
        description:
            'Votre problème nécessite un examen plus approfondi. '
            'Nous vous recommandons de consulter un professionnel '
            'ou de faire un scan OBD.',
        severity: SeverityLevel.medium,
        symptoms: [
          'Symptôme non spécifique',
          'Analyse complémentaire nécessaire'
        ],
        parts: const [],
        estimatedCost: 'Variable',
        urgent: false,
        systems: _buildSystemsFromSeverity(
            SeverityLevel.medium, 'Diagnostic général'),
        isFromAI: false,
        providerName: 'Local',
      );
    }

    final parts = rule.parts.map((p) {
      return PartSuggestion(
        name: p['name'] ?? 'Pièce',
        category: p['category'] ?? 'général',
        priceEstimate: p['price_estimate'] ?? 'N/A',
        priority: p['priority'] ?? 'recommended',
      );
    }).toList();

    return DiagnosisResult(
      title: rule.title,
      description: rule.description,
      severity: SeverityLevel.fromString(rule.severity),
      symptoms: rule.symptoms,
      parts: parts,
      estimatedCost: rule.estimatedCost,
      urgent: rule.urgent,
      systems: _buildSystemsFromSeverity(
          SeverityLevel.fromString(rule.severity), rule.title),
      isFromAI: false,
      providerName: 'Local',
    );
  }

  List<SystemCheck> _buildSystemsFromSeverity(
      SeverityLevel severity, String title) {
    final lower = title.toLowerCase();

    SystemCheck battery = const SystemCheck(
      name: 'Batterie',
      description: 'Niveau de santé : 98%',
      icon: Icons.battery_charging_full_rounded,
      iconColor: AppColors.success,
      status: SystemStatus.excellent,
    );
    SystemCheck engine = const SystemCheck(
      name: 'Moteur & Transmission',
      description: 'Aucun défaut détecté',
      icon: Icons.settings_rounded,
      iconColor: Color(0xFF3B82F6),
      status: SystemStatus.excellent,
    );
    SystemCheck brakes = const SystemCheck(
      name: 'Freins',
      description: 'Usure : 12%',
      icon: Icons.car_repair_rounded,
      iconColor: Color(0xFFF97316),
      status: SystemStatus.bon,
    );
    SystemCheck climate = const SystemCheck(
      name: 'Climatisation',
      description: 'Fonctionnement optimal',
      icon: Icons.ac_unit_rounded,
      iconColor: Color(0xFF8B5CF6),
      status: SystemStatus.excellent,
    );

    if (lower.contains('frein') ||
        lower.contains('plaquette') ||
        lower.contains('disque')) {
      brakes = SystemCheck(
        name: 'Freins',
        description: severity == SeverityLevel.critical
            ? 'Usure critique détectée'
            : 'Usure : 65%',
        icon: Icons.car_repair_rounded,
        iconColor: AppColors.danger,
        status: severity == SeverityLevel.critical
            ? SystemStatus.probleme
            : SystemStatus.attention,
      );
    } else if (lower.contains('batterie') ||
        lower.contains('démarre') ||
        lower.contains('alternateur')) {
      battery = SystemCheck(
        name: 'Batterie',
        description: 'Batterie faible',
        icon: Icons.battery_charging_full_rounded,
        iconColor: AppColors.danger,
        status: SystemStatus.probleme,
      );
    } else if (lower.contains('moteur') ||
        lower.contains('bougie') ||
        lower.contains('injection')) {
      engine = SystemCheck(
        name: 'Moteur & Transmission',
        description: 'Anomalie détectée',
        icon: Icons.settings_rounded,
        iconColor: AppColors.orange,
        status: SystemStatus.attention,
      );
    } else if (lower.contains('clim') ||
        lower.contains('refroidissement')) {
      climate = SystemCheck(
        name: 'Climatisation',
        description: 'Entretien recommandé',
        icon: Icons.ac_unit_rounded,
        iconColor: AppColors.orange,
        status: SystemStatus.attention,
      );
    }

    return [battery, engine, brakes, climate];
  }

  Future<void> _orderPart(PartSuggestion part) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🛒 Recherche AUTODOC : "${part.name}"'),
        backgroundColor: AppColors.orange,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // ✅ CÂBLAGE DU BOUTON TUTORIEL → Ouvre TutorialPage
  void _openTutorial(PartSuggestion part) {
    context.push(
      '/tutorial?part=${Uri.encodeComponent(part.name)}',
    );
  }
}