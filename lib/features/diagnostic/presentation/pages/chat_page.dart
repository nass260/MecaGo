// lib/features/diagnostic/presentation/pages/chat_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/ai_service.dart';
import '../../../../core/services/global_notifier.dart';
import '../../../../core/services/marque_image_service.dart';
import '../../../../core/services/image_generator_service.dart';

class ChatPage extends StatefulWidget {
  final String vehicleInfo;
  final String? initialQuestion;

  const ChatPage({
    super.key,
    required this.vehicleInfo,
    this.initialQuestion,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  final AiService _aiService = const AiService();
  final MarqueImageService _marqueService = const MarqueImageService();
  final ImageGeneratorService _imageService = const ImageGeneratorService();

  bool _isLoading = false;

  // ✅ Contexte véhicule complet (construit à partir de GlobalNotifier)
  String _vehicleContext = '';
  String _brand = 'Peugeot';
  String _model = '308';
  String _fuel = '';
  int _year = 2020;

  @override
  void initState() {
    super.initState();

    // ✅ Récupérer TOUT le contexte véhicule
    try {
      final vehicle = GlobalNotifier.instance.activeVehicle;
      if (vehicle != null) {
        _brand = vehicle.brand;
        _model = vehicle.model;
        _fuel = vehicle.fuelType.label;
        _year = vehicle.year;
        _vehicleContext = _aiService.buildVehicleContext(
          brand: _brand,
          model: _model,
          year: _year,
          fuel: _fuel,
          plate: vehicle.plate,
        );
      } else {
        // Fallback : parser vehicleInfo
        _vehicleContext = widget.vehicleInfo;
      }
    } catch (e) {
      debugPrint('⚠️ Erreur contexte véhicule : $e');
      _vehicleContext = widget.vehicleInfo;
    }

    _messages.add(ChatMessage(
      text:
          'Bonjour ! Je suis votre assistant MecaGo. Posez-moi toutes vos questions sur votre $_brand $_model.',
      isUser: false,
      type: MessageType.text,
      timestamp: DateTime.now(),
    ));

    if (widget.initialQuestion != null && widget.initialQuestion!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _controller.text = widget.initialQuestion!;
        _sendMessage();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isLoading) return;

    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: true,
        type: MessageType.text,
        timestamp: DateTime.now(),
      ));
      _controller.clear();
      _isLoading = true;
    });
    _scrollToBottom();

    try {
      final response = await _aiService.chat(
        vehicleContext: _vehicleContext,
        question: text,
      );

      final type = response.json['type'] as String? ?? 'procedure';

      if (!mounted) return;
      setState(() {
        if (type == 'reponse_simple') {
          _messages.add(ChatMessage(
            text: '',
            isUser: false,
            type: MessageType.simpleAnswer,
            simpleAnswer: SimpleAnswerData.fromJson(response.json),
            timestamp: DateTime.now(),
          ));
        } else if (type == 'emplacement_piece') {
          _messages.add(ChatMessage(
            text: '',
            isUser: false,
            type: MessageType.emplacement,
            emplacement: EmplacementData.fromJson(response.json),
            timestamp: DateTime.now(),
          ));
        } else {
          _messages.add(ChatMessage(
            text: '',
            isUser: false,
            type: MessageType.procedure,
            procedure: ProcedureData.fromJson(response.json),
            timestamp: DateTime.now(),
          ));
        }
        _isLoading = false;
      });
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _messages.add(ChatMessage(
          text:
              'Désolé, je n\'ai pas pu traiter votre question. Reformulez-la.',
          isUser: false,
          type: MessageType.text,
          timestamp: DateTime.now(),
        ));
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppHeader(context),
            _buildConversationHeader(),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: _messages.length + (_isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _messages.length && _isLoading) {
                    return _buildLoading();
                  }
                  return _buildMessage(_messages[index]);
                },
              ),
            ),
            _buildInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      color: Colors.white,
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.background,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back_rounded,
                  color: AppColors.navyBlue, size: 20),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: AppGradients.orange,
              borderRadius: BorderRadius.circular(12),
              boxShadow: AppShadows.orangeButton,
            ),
            child: const Center(
              child: Text('M',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1,
                  )),
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('MecaGo',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AppColors.navyBlue,
                      letterSpacing: -0.5,
                    )),
                Text('Votre véhicule. Votre autonomie.',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    )),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.orangeMecaGo.withOpacity(0.10),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.orangeMecaGo.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.workspace_premium_rounded,
                    color: AppColors.orangeMecaGo, size: 14),
                SizedBox(width: 4),
                Text('Premium',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.orangeMecaGo,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationHeader() {
    final sujet = widget.initialQuestion != null &&
            widget.initialQuestion!.isNotEmpty
        ? (widget.initialQuestion!.length > 30
            ? '${widget.initialQuestion!.substring(0, 30)}...'
            : widget.initialQuestion!)
        : 'Diagnostic général';

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppShadows.card,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _marqueService.buildMarqueLogo(
            marque: _brand,
            width: 44,
            height: 44,
            borderRadius: 12,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Assistant IA',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: AppColors.navyBlue,
                      letterSpacing: -0.3,
                    )),
                const SizedBox(height: 2),
                Text('Tutoriel pas à pas • $sujet',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _buildVehicleInfoCard(),
        ],
      ),
    );
  }

  Widget _buildVehicleInfoCard() {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderBlue, width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$_brand $_model',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppColors.navyBlue,
                height: 1,
              )),
          if (_fuel.isNotEmpty) ...[
            const SizedBox(height: 3),
            Text(_fuel,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                  height: 1,
                )),
          ],
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBotAvatar(),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(18),
                bottomLeft: Radius.circular(18),
                bottomRight: Radius.circular(18),
              ),
              border: Border.all(color: AppColors.borderBlue, width: 1),
              boxShadow: AppShadows.card,
            ),
            child: Row(
              children: const [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColors.orangeMecaGo),
                  ),
                ),
                SizedBox(width: 10),
                Text('MecaGo réfléchit...',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      fontStyle: FontStyle.italic,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(ChatMessage msg) {
    if (msg.isUser) return _buildUserBubble(msg);
    if (msg.type == MessageType.procedure && msg.procedure != null) {
      return _buildProcedureResponse(msg);
    }
    if (msg.type == MessageType.simpleAnswer && msg.simpleAnswer != null) {
      return _buildSimpleAnswerResponse(msg);
    }
    if (msg.type == MessageType.emplacement && msg.emplacement != null) {
      return _buildEmplacementResponse(msg);
    }
    return _buildBotBubble(msg);
  }

  Widget _buildUserBubble(ChatMessage msg) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.navyBubble,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                  bottomLeft: Radius.circular(18),
                  bottomRight: Radius.circular(4),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.navyBubble.withOpacity(0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(msg.text,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.white,
                        height: 1.4,
                        fontWeight: FontWeight.w500,
                      )),
                  const SizedBox(height: 4),
                  Text(_formatTime(msg.timestamp),
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.white.withOpacity(0.6),
                        fontWeight: FontWeight.w500,
                      )),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.navyBubble,
            ),
            child: const Center(
              child: Icon(Icons.person_rounded,
                  color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBotBubble(ChatMessage msg) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBotAvatar(),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(18),
                  bottomLeft: Radius.circular(18),
                  bottomRight: Radius.circular(18),
                ),
                border: Border.all(color: AppColors.borderBlue, width: 1),
                boxShadow: AppShadows.card,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(msg.text,
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppColors.navyBlue,
                        height: 1.5,
                      )),
                  const SizedBox(height: 6),
                  Text(_formatTime(msg.timestamp),
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textLight,
                        fontWeight: FontWeight.w500,
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // RÉPONSE PROCÉDURE (TYPE B)
  // ============================================

  Widget _buildProcedureResponse(ChatMessage msg) {
    final procedure = msg.procedure!;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBotAvatar(),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ✅ Bandeau de danger (selon niveau)
                if (procedure.niveauDanger == 'critique' ||
                    procedure.niveauDanger == 'eleve')
                  _buildDangerBanner(procedure),

                const SizedBox(height: 8),
                _buildProcedureHeader(procedure),

                if (procedure.avertissementsLegaux.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _buildAvertissementsLegaux(procedure.avertissementsLegaux),
                ],

                if (procedure.avertissementsSecurite.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _buildAvertissementsSection(procedure.avertissementsSecurite),
                ],

                if (procedure.outils.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _buildOutilsSection(procedure.outils),
                ],

                const SizedBox(height: 14),
                ...procedure.etapes.asMap().entries.map((entry) {
                  final isLast = entry.key == procedure.etapes.length - 1;
                  return _buildEtapeCard(
                    entry.value,
                    entry.key,
                    procedure.etapes.length,
                    msg.timestamp,
                    isLast,
                  );
                }),

                if (procedure.pieces.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _buildPiecesSection(procedure.pieces),
                ],

                if (procedure.conseilFinal.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _buildConseilFinal(procedure.conseilFinal),
                ],

                if (procedure.sources.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _buildSources(procedure.sources),
                ],

                const SizedBox(height: 10),
                Text(_formatTime(msg.timestamp),
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textLight,
                      fontWeight: FontWeight.w500,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // BANDEAU DE DANGER (4 niveaux)
  // ============================================

  Widget _buildDangerBanner(ProcedureData p) {
    final isCritique = p.niveauDanger == 'critique';
    final bgColor =
        isCritique ? const Color(0xFFFEF2F2) : const Color(0xFFFFF7ED);
    final borderColor =
        isCritique ? const Color(0xFFFECACA) : const Color(0xFFFED7AA);
    final textColor = isCritique ? AppColors.danger : AppColors.orangeMecaGo;
    final icon = isCritique ? '🚨' : '⚠️';
    final label = isCritique ? 'DANGER CRITIQUE' : 'PROCÉDURE À RISQUE';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: textColor,
                      letterSpacing: 0.5,
                    )),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            p.publicCible == 'professionnel'
                ? '🔧 Procédure réservée aux professionnels formés'
                : '👤 Procédure accessible aux particuliers avertis',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          if (p.formationRequise != 'Aucune') ...[
            const SizedBox(height: 4),
            Text('📚 Formation requise : ${p.formationRequise}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                )),
          ],
        ],
      ),
    );
  }

  Widget _buildProcedureHeader(ProcedureData p) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(4),
          topRight: Radius.circular(18),
          bottomLeft: Radius.circular(18),
          bottomRight: Radius.circular(18),
        ),
        border: Border.all(color: AppColors.borderBlue, width: 1),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(p.titre,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: AppColors.navyBlue,
              )),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildInfoChip(Icons.schedule_rounded, p.duree),
              const SizedBox(width: 8),
              _buildInfoChip(
                Icons.signal_cellular_alt_rounded,
                _difficulteLabel(p.difficulte),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderBlue, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.orangeMecaGo, size: 12),
          const SizedBox(width: 5),
          Text(label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.navyBlue,
              )),
        ],
      ),
    );
  }

  String _difficulteLabel(String difficulte) {
    switch (difficulte.toLowerCase()) {
      case 'facile':
        return 'Facile';
      case 'intermediaire':
        return 'Intermédiaire';
      case 'avance':
        return 'Avancé';
      case 'expert':
        return 'Expert';
      default:
        return difficulte;
    }
  }

  // ============================================
  // AVERTISSEMENTS LÉGAUX
  // ============================================

  Widget _buildAvertissementsLegaux(List<String> avertissements) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F2),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFECDD3), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.gavel_rounded, color: AppColors.danger, size: 18),
              SizedBox(width: 8),
              Text('AVERTISSEMENTS LÉGAUX',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: AppColors.danger,
                    letterSpacing: 0.5,
                  )),
            ],
          ),
          const SizedBox(height: 10),
          ...avertissements.map((a) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(a,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.navyBlue,
                      height: 1.4,
                      fontWeight: FontWeight.w600,
                    )),
              )),
        ],
      ),
    );
  }

  // ============================================
  // AVERTISSEMENTS SÉCURITÉ
  // ============================================

  Widget _buildAvertissementsSection(List<String> avertissements) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFECACA), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.warning_rounded, color: AppColors.danger, size: 18),
              SizedBox(width: 8),
              Text('Avertissements sécurité',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.danger,
                  )),
            ],
          ),
          const SizedBox(height: 10),
          ...avertissements.map((a) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('⚠️ ', style: TextStyle(fontSize: 13)),
                    Expanded(
                      child: Text(a,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.navyBlue,
                            height: 1.4,
                          )),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  // ============================================
  // OUTILS
  // ============================================

  Widget _buildOutilsSection(List<OutilItem> outils) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFBFDBFE), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.build_rounded, color: Color(0xFF3B82F6), size: 18),
              SizedBox(width: 8),
              Text('Outils nécessaires',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E40AF),
                  )),
            ],
          ),
          const SizedBox(height: 10),
          ...outils.map((o) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      o.obligatoire
                          ? Icons.check_circle_rounded
                          : Icons.circle_outlined,
                      color:
                          o.obligatoire ? AppColors.success : AppColors.textLight,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(o.nom,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.navyBlue,
                            height: 1.4,
                            fontWeight: o.obligatoire
                                ? FontWeight.w600
                                : FontWeight.w400,
                          )),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  // ============================================
  // ÉTAPE
  // ============================================

  Widget _buildEtapeCard(
    EtapeItem etape,
    int index,
    int total,
    DateTime timestamp,
    bool isLast,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final imageWidth = screenWidth - 32 - 44 - 8;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderBlue, width: 1),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            child: Stack(
              children: [
                _imageService.buildStepImage(
                  stepTitle: etape.titre,
                  stepDescription: etape.description,
                  width: imageWidth,
                  height: 200,
                  borderRadius: 0,
                ),
                Positioned(
                  top: 14,
                  left: 14,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.orangeMecaGo,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: AppShadows.orangeButton,
                    ),
                    child: Text('Étape ${etape.numero}/$total',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        )),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${etape.numero}. ${etape.titre}',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: AppColors.navyBlue,
                      letterSpacing: -0.3,
                    )),
                const SizedBox(height: 10),
                Text(etape.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.6,
                    )),
                if (etape.couples.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7ED),
                      borderRadius: BorderRadius.circular(10),
                      border:
                          Border.all(color: const Color(0xFFFED7AA), width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.settings_rounded,
                                color: AppColors.orangeMecaGo, size: 14),
                            SizedBox(width: 6),
                            Text('Couples de serrage',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.orangeMecaGo,
                                )),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ...etape.couples.map((c) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(c.boulon,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.navyBlue,
                                        )),
                                  ),
                                  Text(c.valeur,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w900,
                                        color: AppColors.orangeMecaGo,
                                      )),
                                ],
                              ),
                            )),
                      ],
                    ),
                  ),
                ],
                if (etape.outils.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: etape.outils
                        .map((o) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: AppColors.borderBlue, width: 1),
                              ),
                              child: Text(o,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.navyBlue,
                                  )),
                            ))
                        .toList(),
                  ),
                ],
                const SizedBox(height: 10),
                Text(_formatTime(timestamp),
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textLight,
                      fontWeight: FontWeight.w500,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // PIÈCES (MULTI-VARIANTES)
  // ============================================

  Widget _buildPiecesSection(List<PieceItem> pieces) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderBlue, width: 1),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.shopping_cart_rounded,
                  color: AppColors.orangeMecaGo, size: 18),
              SizedBox(width: 8),
              Text('Pièces recommandées',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.navyBlue,
                  )),
            ],
          ),
          const SizedBox(height: 10),
          ...pieces.map((p) => _buildPieceCard(p)),
        ],
      ),
    );
  }

  Widget _buildPieceCard(PieceItem p) {
    // ✅ Si plusieurs variantes → afficher toutes
    if (p.variantes.length > 1) {
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF7ED),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFFED7AA), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.warning_amber_rounded,
                    color: AppColors.orangeMecaGo, size: 16),
                const SizedBox(width: 6),
                Expanded(
                  child: Text('${p.nom} - ${p.variantes.length} variantes',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: AppColors.orangeMecaGo,
                      )),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(p.avertissement,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.navyBlue,
                  height: 1.4,
                )),
            const SizedBox(height: 10),
            ...p.variantes.map((v) => _buildVarianteCard(v)),
            if (p.guideChoix.isNotEmpty) ...[
              const SizedBox(height: 10),
              _buildGuideChoix(p.guideChoix),
            ],
          ],
        ),
      );
    }

    // ✅ Une seule variante → affichage simple
    final v = p.variantes.isNotEmpty ? p.variantes.first : null;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.nom,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.navyBlue,
                    )),
                if (v != null && v.ref.isNotEmpty)
                  Text('Réf : ${v.ref}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      )),
              ],
            ),
          ),
          if (v != null && v.prix.isNotEmpty)
            Text(v.prix,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: AppColors.orangeMecaGo,
                )),
        ],
      ),
    );
  }

  Widget _buildVarianteCard(PieceVariante v) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderBlue, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.orangeMecaGo,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text('Variante ${v.numero}',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    )),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(v.criteres,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.navyBlue,
                    )),
              ),
            ],
          ),
          const SizedBox(height: 6),
          if (v.ref.isNotEmpty)
            Text('Référence : ${v.ref}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.navyBlue,
                )),
          if (v.equivalents.isNotEmpty)
            Text('Équivalents : ${v.equivalents.join(', ')}',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                )),
          if (v.difference.isNotEmpty)
            Text('Différence : ${v.difference}',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                )),
          const SizedBox(height: 4),
          Row(
            children: [
              if (v.prix.isNotEmpty)
                Text(v.prix,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: AppColors.orangeMecaGo,
                    )),
              const Spacer(),
              if (v.source.isNotEmpty)
                Text('Source : ${v.source}',
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textLight,
                    )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGuideChoix(Map<String, String> guide) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFBFDBFE), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.help_outline_rounded,
                  color: Color(0xFF3B82F6), size: 14),
              SizedBox(width: 6),
              Text('Comment choisir',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E40AF),
                  )),
            ],
          ),
          const SizedBox(height: 8),
          ...guide.entries.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF1E40AF),
                        )),
                    Expanded(
                      child: Text(e.value,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.navyBlue,
                            height: 1.4,
                          )),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  // ============================================
  // RÉPONSE SIMPLE (TYPE A)
  // ============================================

  Widget _buildSimpleAnswerResponse(ChatMessage msg) {
    final answer = msg.simpleAnswer!;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBotAvatar(),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(18),
                  bottomLeft: Radius.circular(18),
                  bottomRight: Radius.circular(18),
                ),
                border: Border.all(color: AppColors.borderBlue, width: 1),
                boxShadow: AppShadows.card,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(answer.titre,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: AppColors.navyBlue,
                      )),
                  const SizedBox(height: 10),
                  Text(answer.reponse,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.navyBlue,
                        height: 1.5,
                      )),
                  if (answer.details.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: const Color(0xFFBBF7D0), width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.lightbulb_rounded,
                                  color: AppColors.success, size: 16),
                              SizedBox(width: 6),
                              Text('À savoir',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.success,
                                  )),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ...answer.details.map((d) => Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('• ',
                                        style: TextStyle(fontSize: 13)),
                                    Expanded(
                                      child: Text(d,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: AppColors.navyBlue,
                                            height: 1.4,
                                          )),
                                    ),
                                  ],
                                ),
                              )),
                        ],
                      ),
                    ),
                  ],
                  if (answer.sources.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    _buildSources(answer.sources),
                  ],
                  const SizedBox(height: 8),
                  Text(_formatTime(msg.timestamp),
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textLight,
                        fontWeight: FontWeight.w500,
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // EMPLACEMENT PIÈCE (TYPE C)
  // ============================================

  Widget _buildEmplacementResponse(ChatMessage msg) {
    final e = msg.emplacement!;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBotAvatar(),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(18),
                  bottomLeft: Radius.circular(18),
                  bottomRight: Radius.circular(18),
                ),
                border: Border.all(color: AppColors.borderBlue, width: 1),
                boxShadow: AppShadows.card,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.location_on_rounded,
                          color: AppColors.orangeMecaGo, size: 20),
                      SizedBox(width: 8),
                      Text('Emplacement',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: AppColors.navyBlue,
                          )),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(e.piece,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.orangeMecaGo,
                      )),
                  const SizedBox(height: 10),
                  Text(e.description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.navyBlue,
                        height: 1.5,
                      )),
                  if (e.reperes.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: const Color(0xFFBFDBFE), width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.visibility_rounded,
                                  color: Color(0xFF3B82F6), size: 16),
                              SizedBox(width: 6),
                              Text('Repères visuels',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF1E40AF),
                                  )),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ...e.reperes.map((r) => Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('• ',
                                        style: TextStyle(fontSize: 13)),
                                    Expanded(
                                      child: Text(r,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: AppColors.navyBlue,
                                            height: 1.4,
                                          )),
                                    ),
                                  ],
                                ),
                              )),
                        ],
                      ),
                    ),
                  ],
                  if (e.sources.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    _buildSources(e.sources),
                  ],
                  const SizedBox(height: 8),
                  Text(_formatTime(msg.timestamp),
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textLight,
                        fontWeight: FontWeight.w500,
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // CONSEIL FINAL
  // ============================================

  Widget _buildConseilFinal(String conseil) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFBBF7D0), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.lightbulb_rounded, color: AppColors.success, size: 18),
              SizedBox(width: 8),
              Text('Conseil MecaGo',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.success,
                  )),
            ],
          ),
          const SizedBox(height: 8),
          Text(conseil,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.navyBlue,
                height: 1.5,
              )),
        ],
      ),
    );
  }

  // ============================================
  // SOURCES
  // ============================================

  Widget _buildSources(List<String> sources) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderBlue, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.verified_rounded,
                  color: AppColors.textSecondary, size: 12),
              SizedBox(width: 6),
              Text('Sources',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.5,
                  )),
            ],
          ),
          const SizedBox(height: 6),
          ...sources.map((s) => Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text('• $s',
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                      height: 1.3,
                    )),
              )),
        ],
      ),
    );
  }

  Widget _buildBotAvatar() {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        gradient: AppGradients.orange,
        shape: BoxShape.circle,
        boxShadow: AppShadows.orangeButton,
      ),
      child:
          const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 20),
    );
  }

  // ============================================
  // INPUT
  // ============================================

  Widget _buildInput() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  const Icon(Icons.add_rounded,
                      color: AppColors.textSecondary, size: 22),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      enabled: !_isLoading,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: const InputDecoration(
                        hintText: 'Posez votre question...',
                        hintStyle: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 16),
                      ),
                      style: const TextStyle(fontSize: 15),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _isLoading ? null : _sendMessage,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: AppGradients.orange,
                shape: BoxShape.circle,
                boxShadow: AppShadows.orangeButton,
              ),
              child: const Icon(Icons.send_rounded,
                  color: Colors.white, size: 22),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================
// MODÈLES
// ============================================

enum MessageType { text, procedure, simpleAnswer, emplacement }

class ChatMessage {
  final String text;
  final bool isUser;
  final MessageType type;
  final ProcedureData? procedure;
  final SimpleAnswerData? simpleAnswer;
  final EmplacementData? emplacement;
  final DateTime timestamp;

  const ChatMessage({
    required this.text,
    required this.isUser,
    required this.type,
    this.procedure,
    this.simpleAnswer,
    this.emplacement,
    required this.timestamp,
  });
}

/// Réponse simple (TYPE A)
class SimpleAnswerData {
  final String titre;
  final String reponse;
  final List<String> details;
  final List<String> sources;

  const SimpleAnswerData({
    required this.titre,
    required this.reponse,
    required this.details,
    required this.sources,
  });

  factory SimpleAnswerData.fromJson(Map<String, dynamic> json) {
    return SimpleAnswerData(
      titre: json['titre'] as String? ?? 'Réponse',
      reponse: json['reponse'] as String? ?? '',
      details: (json['details'] as List<dynamic>?)
              ?.map((d) => d.toString())
              .toList() ??
          [],
      sources: (json['sources'] as List<dynamic>?)
              ?.map((s) => s.toString())
              .toList() ??
          [],
    );
  }
}

/// Emplacement pièce (TYPE C)
class EmplacementData {
  final String piece;
  final String vehicule;
  final String description;
  final List<String> reperes;
  final List<String> outils;
  final List<String> sources;

  const EmplacementData({
    required this.piece,
    required this.vehicule,
    required this.description,
    required this.reperes,
    required this.outils,
    required this.sources,
  });

  factory EmplacementData.fromJson(Map<String, dynamic> json) {
    return EmplacementData(
      piece: json['piece'] as String? ?? '',
      vehicule: json['vehicule'] as String? ?? '',
      description: json['description'] as String? ?? '',
      reperes: (json['reperes'] as List<dynamic>?)
              ?.map((r) => r.toString())
              .toList() ??
          [],
      outils: (json['outils'] as List<dynamic>?)
              ?.map((o) => o.toString())
              .toList() ??
          [],
      sources: (json['sources'] as List<dynamic>?)
              ?.map((s) => s.toString())
              .toList() ??
          [],
    );
  }
}

/// Procédure complète (TYPE B)
class ProcedureData {
  final String titre;
  final String vehicule;
  final String duree;
  final String difficulte;
  final String niveauDanger;
  final String publicCible;
  final String formationRequise;
  final List<OutilItem> outils;
  final List<PieceItem> pieces;
  final List<String> avertissementsSecurite;
  final List<String> avertissementsLegaux;
  final List<EtapeItem> etapes;
  final String conseilFinal;
  final List<String> sources;

  const ProcedureData({
    required this.titre,
    required this.vehicule,
    required this.duree,
    required this.difficulte,
    required this.niveauDanger,
    required this.publicCible,
    required this.formationRequise,
    required this.outils,
    required this.pieces,
    required this.avertissementsSecurite,
    required this.avertissementsLegaux,
    required this.etapes,
    required this.conseilFinal,
    required this.sources,
  });

  factory ProcedureData.fromJson(Map<String, dynamic> json) {
    return ProcedureData(
      titre: json['titre'] as String? ?? 'Procédure MecaGo',
      vehicule: json['vehicule'] as String? ?? '',
      duree: json['duree_estimee'] as String? ?? 'Non communiquée',
      difficulte: json['difficulte'] as String? ?? 'intermediaire',
      niveauDanger: json['niveau_danger'] as String? ?? 'faible',
      publicCible: json['public_cible'] as String? ?? 'tous',
      formationRequise: json['formation_requise'] as String? ?? 'Aucune',
      outils: (json['outils'] as List<dynamic>?)
              ?.map((o) => OutilItem.fromJson(o as Map<String, dynamic>))
              .toList() ??
          [],
      pieces: (json['pieces'] as List<dynamic>?)
              ?.map((p) => PieceItem.fromJson(p as Map<String, dynamic>))
              .toList() ??
          [],
      avertissementsSecurite:
          (json['avertissements_securite'] as List<dynamic>?)
                  ?.map((a) => a.toString())
                  .toList() ??
              [],
      avertissementsLegaux: (json['avertissements_legaux'] as List<dynamic>?)
                  ?.map((a) => a.toString())
                  .toList() ??
              [],
      etapes: (json['etapes'] as List<dynamic>?)
              ?.map((e) => EtapeItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      conseilFinal: json['conseil_final'] as String? ?? '',
      sources: (json['sources'] as List<dynamic>?)
              ?.map((s) => s.toString())
              .toList() ??
          [],
    );
  }
}

class OutilItem {
  final String nom;
  final bool obligatoire;

  const OutilItem({required this.nom, required this.obligatoire});

  factory OutilItem.fromJson(Map<String, dynamic> json) {
    return OutilItem(
      nom: json['nom'] as String? ?? '',
      obligatoire: json['obligatoire'] as bool? ?? true,
    );
  }
}

/// Pièce avec multi-variantes
class PieceItem {
  final String nom;
  final List<PieceVariante> variantes;
  final Map<String, String> guideChoix;
  final String avertissement;

  const PieceItem({
    required this.nom,
    required this.variantes,
    required this.guideChoix,
    required this.avertissement,
  });

  factory PieceItem.fromJson(Map<String, dynamic> json) {
    final variantesJson = json['variantes'] as List<dynamic>?;

    // Si structure multi-variantes
    if (variantesJson != null) {
      return PieceItem(
        nom: json['nom'] as String? ?? '',
        variantes: variantesJson
            .map((v) => PieceVariante.fromJson(v as Map<String, dynamic>))
            .toList(),
        guideChoix: (json['guide_choix'] as Map<String, dynamic>?)
                ?.map((k, v) => MapEntry(k, v.toString())) ??
            {},
        avertissement: json['avertissement'] as String? ?? '',
      );
    }

    // Structure simple (fallback) : nom, ref, prix
    return PieceItem(
      nom: json['nom'] as String? ?? '',
      variantes: [
        PieceVariante(
          numero: 1,
          ref: json['ref'] as String? ?? '',
          equivalents: [],
          criteres: '',
          difference: '',
          prix: json['prix'] as String? ?? '',
          source: json['source'] as String? ?? '',
          confiance: 'moyenne',
        ),
      ],
      guideChoix: {},
      avertissement: '',
    );
  }
}

class PieceVariante {
  final int numero;
  final String ref;
  final List<String> equivalents;
  final String criteres;
  final String difference;
  final String prix;
  final String source;
  final String confiance;

  const PieceVariante({
    required this.numero,
    required this.ref,
    required this.equivalents,
    required this.criteres,
    required this.difference,
    required this.prix,
    required this.source,
    required this.confiance,
  });

  factory PieceVariante.fromJson(Map<String, dynamic> json) {
    return PieceVariante(
      numero: json['numero'] as int? ?? 1,
      ref: json['ref'] as String? ?? '',
      equivalents: (json['equivalents'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      criteres: json['criteres'] as String? ?? '',
      difference: json['difference'] as String? ?? '',
      prix: json['prix'] as String? ?? '',
      source: json['source'] as String? ?? '',
      confiance: json['confiance'] as String? ?? 'moyenne',
    );
  }
}

class EtapeItem {
  final int numero;
  final String titre;
  final String description;
  final List<String> outils;
  final List<CoupleItem> couples;

  const EtapeItem({
    required this.numero,
    required this.titre,
    required this.description,
    required this.outils,
    required this.couples,
  });

  factory EtapeItem.fromJson(Map<String, dynamic> json) {
    return EtapeItem(
      numero: json['numero'] as int? ?? 1,
      titre: json['titre'] as String? ?? '',
      description: json['description'] as String? ?? '',
      outils: (json['outils'] as List<dynamic>?)
              ?.map((o) => o.toString())
              .toList() ??
          [],
      couples: (json['couples'] as List<dynamic>?)
              ?.map((c) => CoupleItem.fromJson(c as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class CoupleItem {
  final String boulon;
  final String valeur;

  const CoupleItem({required this.boulon, required this.valeur});

  factory CoupleItem.fromJson(Map<String, dynamic> json) {
    return CoupleItem(
      boulon: json['boulon'] as String? ?? '',
      valeur: json['valeur'] as String? ?? '',
    );
  }
}