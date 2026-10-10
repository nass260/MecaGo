// lib/features/diagnostic/presentation/pages/chat_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/ai_service.dart';
import '../../../../core/services/global_notifier.dart';
import '../../../../core/services/marque_image_service.dart';
import '../../../../core/services/image_generator_service.dart';

/// Page de chat dédiée à l'Assistant IA MecaGo
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

  // ✅ Motorisation récupérée depuis le véhicule actif
  String _fuel = '';

  String get _brand {
    final parts = widget.vehicleInfo.split(' ');
    return parts.isNotEmpty ? parts.first : 'Peugeot';
  }

  String get _model {
    final parts = widget.vehicleInfo.split(' ');
    if (parts.length >= 2) {
      final modelPart = parts[1].replaceAll(',', '');
      return modelPart;
    }
    return '308';
  }

  String get _vehicleDisplay => '$_brand $_model';

  String get _motorisationDisplay => _fuel.trim();

  bool get _hasMotorisation => _fuel.trim().isNotEmpty;

  String get _sujet {
    if (widget.initialQuestion != null &&
        widget.initialQuestion!.isNotEmpty) {
      final q = widget.initialQuestion!;
      if (q.length > 30) {
        return '${q.substring(0, 30)}...';
      }
      return q;
    }
    return 'Diagnostic général';
  }

  @override
  void initState() {
    super.initState();

    try {
      final vehicle = GlobalNotifier.instance.activeVehicle;
      if (vehicle != null) {
        _fuel = vehicle.fuelType.label;
      }
    } catch (e) {
      debugPrint('⚠️ Impossible de récupérer la motorisation : $e');
    }

    _messages.add(ChatMessage(
      text:
          'Bonjour ! Je suis votre assistant MecaGo. Posez-moi toutes vos questions sur votre ${widget.vehicleInfo}.',
      isUser: false,
      type: MessageType.text,
      timestamp: DateTime.now(),
    ));

    if (widget.initialQuestion != null &&
        widget.initialQuestion!.isNotEmpty) {
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
        vehicleInfo: widget.vehicleInfo,
        question: text,
      );

      final steps = _extractStepsWithDescriptions(response.text);
      final hasMaterielList = _hasMaterielList(response.text);

      if (!mounted) return;
      setState(() {
        _messages.add(ChatMessage(
          text: response.text,
          isUser: false,
          type: steps.isNotEmpty ? MessageType.steps : MessageType.text,
          steps: steps,
          timestamp: DateTime.now(),
          hasMaterielList: hasMaterielList,
        ));
        _isLoading = false;
      });
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _messages.add(ChatMessage(
          text: _getFallbackResponse(text),
          isUser: false,
          type: MessageType.text,
          timestamp: DateTime.now(),
        ));
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  bool _hasMaterielList(String text) {
    final lines = text.split('\n');
    int checkboxCount = 0;
    for (final line in lines) {
      if (line.contains('✅')) checkboxCount++;
    }
    return checkboxCount >= 3;
  }

  List<ChatStep> _extractStepsWithDescriptions(String text) {
    final steps = <ChatStep>[];
    final lines = text.split('\n');

    String? currentNumero;
    String? currentTitre;
    final currentDescription = <String>[];

    for (final line in lines) {
      final match = RegExp(
              r'(?:🔧|📋|⚠️|🔩|🛠️|🔨|⚙️)\s*\*?\*?Étape\s*(\d+)\s*:\s*(.+?)\*?\*?$')
          .firstMatch(line);

      if (match != null) {
        if (currentNumero != null && currentTitre != null) {
          steps.add(ChatStep(
            numero: currentNumero,
            titre: _cleanText(currentTitre),
            description: _cleanText(currentDescription.join(' ').trim()),
          ));
        }

        currentNumero = match.group(1);
        currentTitre = match.group(2);
        currentDescription.clear();
      } else if (currentNumero != null && line.trim().isNotEmpty) {
        if (!line.contains('Conseil final') && !line.contains('💡')) {
          currentDescription.add(line.trim());
        }
      }
    }

    if (currentNumero != null && currentTitre != null) {
      steps.add(ChatStep(
        numero: currentNumero,
        titre: _cleanText(currentTitre),
        description: _cleanText(currentDescription.join(' ').trim()),
      ));
    }

    return steps;
  }

  String _cleanText(String text) {
    return text
        .replaceAll('**', '')
        .replaceAll('*', '')
        .replaceAll('🔧', '')
        .replaceAll('📋', '')
        .replaceAll('⚠️', '')
        .trim();
  }

  String _getFallbackResponse(String question) {
    return '''Merci pour votre question.

Pour vous aider précisément, décrivez-moi :
• Le symptôme exact
• Depuis quand cela dure
• Si c'est permanent ou intermittent''';
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
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                itemCount: _messages.length + (_isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _messages.length && _isLoading) {
                    return _buildLoading();
                  }
                  final msg = _messages[index];
                  return _buildMessage(msg);
                },
              ),
            ),
            _buildInput(),
          ],
        ),
      ),
    );
  }

  // ============================================
  // HEADER APP
  // ============================================

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
              child: const Icon(
                Icons.arrow_back_rounded,
                color: AppColors.navyBlue,
                size: 20,
              ),
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
              child: Text(
                'M',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MecaGo',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppColors.navyBlue,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  'Votre véhicule. Votre autonomie.',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
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
                Text(
                  'Premium',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.orangeMecaGo,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // HEADER CONVERSATION
  // ============================================

  Widget _buildConversationHeader() {
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
                const Text(
                  'Assistant IA',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: AppColors.navyBlue,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Tutoriel pas à pas • $_sujet',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
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
        border: Border.all(
          color: AppColors.borderBlue,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _vehicleDisplay,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppColors.navyBlue,
              height: 1,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (_hasMotorisation) ...[
            const SizedBox(height: 3),
            Text(
              _motorisationDisplay,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
                height: 1,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  // ============================================
  // LOADING
  // ============================================

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
              border: Border.all(
                color: AppColors.borderBlue,
                width: 1,
              ),
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
                Text(
                  'MecaGo réfléchit...',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // MESSAGES
  // ============================================

  Widget _buildMessage(ChatMessage msg) {
    if (msg.isUser) {
      return _buildUserBubble(msg);
    }
    if (msg.type == MessageType.steps && msg.steps.isNotEmpty) {
      return _buildStepsResponse(msg);
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
                  Text(
                    msg.text,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.white,
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(msg.timestamp),
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white.withOpacity(0.6),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
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
              child: Icon(
                Icons.person_rounded,
                color: Colors.white,
                size: 20,
              ),
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
                border: Border.all(
                  color: AppColors.borderBlue,
                  width: 1,
                ),
                boxShadow: AppShadows.card,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    msg.text,
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppColors.navyBlue,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _formatTime(msg.timestamp),
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textLight,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // RÉPONSE AVEC ÉTAPES
  // ============================================

  Widget _buildStepsResponse(ChatMessage msg) {
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
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(18),
                      bottomLeft: Radius.circular(18),
                      bottomRight: Radius.circular(18),
                    ),
                    border: Border.all(
                      color: AppColors.borderBlue,
                      width: 1,
                    ),
                    boxShadow: AppShadows.card,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getIntroductionText(msg.text),
                        style: const TextStyle(
                          fontSize: 15,
                          color: AppColors.navyBlue,
                          height: 1.5,
                        ),
                      ),
                      if (msg.hasMaterielList) ...[
                        const SizedBox(height: 12),
                        _buildMaterielButton(),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                ...msg.steps.asMap().entries.map((entry) {
                  final isLast = entry.key == msg.steps.length - 1;
                  return _buildStepCard(
                    entry.value,
                    entry.key,
                    msg.steps.length,
                    msg.timestamp,
                    isLast,
                    msg.steps,
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaterielButton() {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('📋 Liste complète du matériel'),
            backgroundColor: AppColors.orangeMecaGo,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF6FF),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: const Color(0xFFBFDBFE),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.checklist_rounded,
                color: Color(0xFF3B82F6), size: 16),
            SizedBox(width: 8),
            Text(
              'Voir la liste complète du matériel',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF3B82F6),
              ),
            ),
            SizedBox(width: 4),
            Icon(Icons.chevron_right_rounded,
                color: Color(0xFF3B82F6), size: 16),
          ],
        ),
      ),
    );
  }

  String _getIntroductionText(String fullText) {
    final lines = fullText.split('\n');
    final intro = <String>[];
    for (final line in lines) {
      if (line.contains('Étape') || line.contains('🔧')) break;
      if (line.trim().isNotEmpty) {
        intro.add(_cleanText(line.trim()));
      }
    }
    if (intro.isEmpty) {
      return 'Voici les étapes pour réaliser cette opération :';
    }
    return intro.join(' ');
  }

  Widget _buildStepCard(
    ChatStep step,
    int index,
    int totalSteps,
    DateTime timestamp,
    bool isLast,
    List<ChatStep> allSteps,
  ) {
    final description = step.description;
    final items = _extractListItems(description);

    // ✅ Largeur disponible réelle pour l'image
    // (écran - padding horizontal du ListView (32) - padding du Row bot (44))
    final screenWidth = MediaQuery.of(context).size.width;
    final imageWidth = screenWidth - 32 - 44 - 8;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.borderBlue,
          width: 1,
        ),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ IMAGE GÉNÉRÉE PAR POLLINATIONS
          ClipRRect(
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(18)),
            child: Stack(
              children: [
                _imageService.buildStepImage(
                  stepTitle: step.titre,
                  stepDescription: description,
                  width: imageWidth, // ✅ Largeur réelle (pas Infinity)
                  height: 200,
                  borderRadius: 0,
                ),
                // ✅ Badge "Étape X/Y"
                Positioned(
                  top: 14,
                  left: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.orangeMecaGo,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: AppShadows.orangeButton,
                    ),
                    child: Text(
                      'Étape ${step.numero}/$totalSteps',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
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
                Text(
                  '${step.numero}. ${step.titre}',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: AppColors.navyBlue,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 12),
                if (items.isNotEmpty)
                  ...items.asMap().entries.map((e) {
                    return _buildNumberedItem(e.key + 1, e.value);
                  })
                else if (description.isNotEmpty)
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.6,
                    ),
                  ),
                const SizedBox(height: 14),
                Text(
                  _formatTime(timestamp),
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (allSteps.length > 1) ...[
                  const SizedBox(height: 14),
                  _buildNextButton(index, allSteps),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberedItem(int number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 22,
            child: Text(
              '$number.',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppColors.navyBlue,
              ),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextButton(int currentIndex, List<ChatStep> allSteps) {
    if (currentIndex >= allSteps.length - 1) {
      return GestureDetector(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('✅ Tutoriel terminé !'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            gradient: AppGradients.orange,
            borderRadius: BorderRadius.circular(14),
            boxShadow: AppShadows.orangeButton,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text(
                'Terminer le tutoriel',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(width: 6),
              Icon(Icons.check_rounded, color: Colors.white, size: 18),
            ],
          ),
        ),
      );
    }

    final nextStep = allSteps[currentIndex + 1];
    final nextTitle = nextStep.titre.length > 25
        ? '${nextStep.titre.substring(0, 25)}...'
        : nextStep.titre;

    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('➡️ Étape suivante : $nextTitle'),
            backgroundColor: AppColors.orangeMecaGo,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: AppGradients.orange,
          borderRadius: BorderRadius.circular(14),
          boxShadow: AppShadows.orangeButton,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                'Suivant : $nextTitle',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right_rounded,
                color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }

  List<String> _extractListItems(String text) {
    final items = <String>[];
    final lines = text.split('\n');
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;

      String cleaned = trimmed;
      if (cleaned.startsWith('- ')) cleaned = cleaned.substring(2);
      if (cleaned.startsWith('• ')) cleaned = cleaned.substring(2);
      if (cleaned.startsWith('✅ ')) cleaned = cleaned.substring(2);
      cleaned = cleaned.replaceFirst(RegExp(r'^\d+\.\s*'), '');

      if (cleaned.isNotEmpty) {
        items.add(_cleanText(cleaned));
      }
    }
    return items;
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
      child: const Icon(Icons.smart_toy_rounded,
          color: Colors.white, size: 20),
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
                  const Icon(
                    Icons.add_rounded,
                    color: AppColors.textSecondary,
                    size: 22,
                  ),
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
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 16),
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

enum MessageType { text, steps }

class ChatMessage {
  final String text;
  final bool isUser;
  final MessageType type;
  final List<ChatStep> steps;
  final DateTime timestamp;
  final bool hasMaterielList;

  const ChatMessage({
    required this.text,
    required this.isUser,
    required this.type,
    this.steps = const [],
    required this.timestamp,
    this.hasMaterielList = false,
  });
}

class ChatStep {
  final String numero;
  final String titre;
  final String description;

  const ChatStep({
    required this.numero,
    required this.titre,
    required this.description,
  });
}