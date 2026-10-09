// lib/features/diagnostic/presentation/widgets/mecago_chat_widget.dart
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/ai_service.dart';

/// Widget de chat MecaGo (design premium)
class MecaGoChatWidget extends StatefulWidget {
  final String vehicleInfo;

  const MecaGoChatWidget({
    super.key,
    required this.vehicleInfo,
  });

  @override
  State<MecaGoChatWidget> createState() => _MecaGoChatWidgetState();
}

class _MecaGoChatWidgetState extends State<MecaGoChatWidget> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [];
  final AiService _aiService = const AiService();
  bool _isLoading = false;
  int _messageCount = 0;
  static const int _maxMessages = 5;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isLoading) return;

    if (_messageCount >= _maxMessages) {
      setState(() {
        _messages.add(ChatMessage(
          text: 'Vous avez atteint la limite de $_maxMessages questions. '
              'Passez à MecaGo Premium pour un accès illimité.',
          isUser: false,
          type: MessageType.text,
        ));
      });
      return;
    }

    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: true,
        type: MessageType.text,
      ));
      _controller.clear();
      _isLoading = true;
      _messageCount++;
    });

    try {
      final response = await _aiService.chat(
        vehicleInfo: widget.vehicleInfo,
        question: text,
      );

      final steps = _extractStepsWithDescriptions(response.text);

      if (!mounted) return;
      setState(() {
        _messages.add(ChatMessage(
          text: response.text,
          isUser: false,
          type: MessageType.steps,
          steps: steps,
        ));
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _messages.add(ChatMessage(
          text: _getFallbackResponse(text),
          isUser: false,
          type: MessageType.text,
        ));
        _isLoading = false;
      });
    }
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

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ HEADER "ASSISTANT IA"
          _buildHeader(),
          // ✅ MESSAGES
          if (_messages.isNotEmpty)
            Container(
              constraints: const BoxConstraints(maxHeight: 600),
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  return _buildMessage(msg);
                },
              ),
            ),
          // ✅ LOADING
          if (_isLoading) _buildLoading(),
          // ✅ INPUT
          _buildInput(),
        ],
      ),
    );
  }

  // ============================================
  // HEADER
  // ============================================

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Icône MecaGo
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: AppGradients.orange,
              shape: BoxShape.circle,
              boxShadow: AppShadows.orangeButton,
            ),
            child: const Icon(Icons.support_agent_rounded,
                color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          // Titre
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Assistant IA',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: AppColors.navy,
                    letterSpacing: -0.3,
                  ),
                ),
                Text(
                  widget.vehicleInfo,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Badge Premium
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.orange.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.workspace_premium_rounded,
                    color: AppColors.orange, size: 11),
                SizedBox(width: 3),
                Text(
                  'Premium',
                  style: TextStyle(
                    fontSize: 9,
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

  // ============================================
  // LOADING
  // ============================================

  Widget _buildLoading() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: AppGradients.orange,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.support_agent_rounded,
                color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColors.orange),
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'MecaGo réfléchit...',
                  style: TextStyle(
                    fontSize: 12,
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
  // MESSAGE
  // ============================================

  Widget _buildMessage(ChatMessage msg) {
    if (msg.isUser) {
      return _buildUserBubble(msg);
    }

    if (msg.type == MessageType.steps) {
      return _buildStepsResponse(msg);
    }

    return _buildBotBubble(msg);
  }

  /// Bulle utilisateur (bleu, à droite)
  Widget _buildUserBubble(ChatMessage msg) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                gradient: AppGradients.orange,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(4),
                ),
                boxShadow: AppShadows.orangeButton,
              ),
              child: Text(
                msg.text,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.white,
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Avatar utilisateur
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFF1E293B), Color(0xFF0A0F1C)],
              ),
            ),
            child: const Center(
              child: Text(
                'A',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Bulle MecaGo simple (blanc, à gauche)
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
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                border: Border.all(
                  color: AppColors.border.withOpacity(0.5),
                  width: 1,
                ),
                boxShadow: AppShadows.card,
              ),
              child: Text(
                msg.text,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.navy,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Réponse avec étapes (design premium)
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
                // ✅ Texte d'introduction (avant les étapes)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                    border: Border.all(
                      color: AppColors.border.withOpacity(0.5),
                      width: 1,
                    ),
                    boxShadow: AppShadows.card,
                  ),
                  child: Text(
                    _getIntroductionText(msg.text),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.navy,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // ✅ Étapes une par une
                ...msg.steps.asMap().entries.map((entry) {
                  final index = entry.key;
                  final step = entry.value;
                  return _buildStepCard(step, index, msg.steps.length);
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getIntroductionText(String fullText) {
    // Extraire le texte avant la première étape
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

  /// Carte d'une étape (numéro + titre + placeholder image + description + bouton)
  Widget _buildStepCard(ChatStep step, int index, int totalSteps) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border.withOpacity(0.5),
          width: 1,
        ),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ PHOTO (placeholder pour l'instant)
          ClipRRect(
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(16)),
            child: Container(
              height: 160,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: AppGradients.navy,
              ),
              child: Stack(
                children: [
                  // Placeholder image (en attendant Pollinations)
                  const Center(
                    child: Icon(
                      Icons.image_rounded,
                      color: Colors.white24,
                      size: 60,
                    ),
                  ),
                  // Badge "Étape X/Y"
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.orange,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: AppShadows.orangeButton,
                      ),
                      child: Text(
                        'Étape ${step.numero}/$totalSteps',
                        style: const TextStyle(
                          fontSize: 10,
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
          ),
          // ✅ CONTENU
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Titre en gras
                Text(
                  '${step.numero}. ${step.titre}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: AppColors.navy,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 8),
                // Description
                if (step.description.isNotEmpty)
                  Text(
                    step.description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBotAvatar() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        gradient: AppGradients.orange,
        shape: BoxShape.circle,
        boxShadow: AppShadows.orangeButton,
      ),
      child: const Icon(Icons.support_agent_rounded,
          color: Colors.white, size: 18),
    );
  }

  // ============================================
  // INPUT
  // ============================================

  Widget _buildInput() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        border: Border(
          top: BorderSide(
            color: Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
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
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      enabled:
                          !_isLoading && _messageCount < _maxMessages,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: const InputDecoration(
                        hintText: 'Posez votre question...',
                        hintStyle: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 14),
                      ),
                      style: const TextStyle(fontSize: 13),
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
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                gradient: AppGradients.orange,
                shape: BoxShape.circle,
                boxShadow: AppShadows.orangeButton,
              ),
              child: const Icon(Icons.send_rounded,
                  color: Colors.white, size: 20),
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

  const ChatMessage({
    required this.text,
    required this.isUser,
    required this.type,
    this.steps = const [],
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