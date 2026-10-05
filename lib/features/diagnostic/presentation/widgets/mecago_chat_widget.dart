// lib/features/diagnostic/presentation/widgets/mecago_chat_widget.dart
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/ai_service.dart';

/// Widget de chat MecaGo (IA cachée derrière)
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
        ));
      });
      return;
    }

    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _controller.clear();
      _isLoading = true;
      _messageCount++;
    });

    try {
      final response = await _getMecaGoResponse(text);
      if (!mounted) return;
      setState(() {
        _messages.add(ChatMessage(text: response, isUser: false));
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _messages.add(ChatMessage(
          text: _getFallbackResponse(text),
          isUser: false,
        ));
        _isLoading = false;
      });
    }
  }

  Future<String> _getMecaGoResponse(String question) async {
    // On essaie l'IA (Gemini → Groq) cachée derrière MecaGo
    try {
      final response = await _aiService.diagnose(
        vehicleInfo: widget.vehicleInfo,
        symptoms: question,
      );
      // On reformule la réponse pour qu'elle semble venir de MecaGo
      final description = response.json['description'] as String?;
      if (description != null && description.isNotEmpty) {
        return description;
      }
      return _getFallbackResponse(question);
    } catch (e) {
      return _getFallbackResponse(question);
    }
  }

  /// Réponses détaillées et professionnelles (fallback IA)
  String _getFallbackResponse(String question) {
    final lower = question.toLowerCase();

    // ============================================
    // FREINS - VÉRIFICATION
    // ============================================
    if (lower.contains('frein') &&
        (lower.contains('vérifi') || lower.contains('contrôl'))) {
      return '''Pour vérifier l'état de vos plaquettes de frein, vous devez mesurer l'épaisseur restante de la garniture, qui doit être supérieure à 3 mm (contre environ 15 mm à l'état neuf).

📐 **Méthodes de vérification**

• **Contrôle visuel direct (sans démontage)** : Si vos jantes sont suffisamment ouvertes, observez l'étrier de frein à l'aide d'une lampe torche. Vous apercevrez la tranche de la plaquette et l'épaisseur de la matière de friction contre le disque.

• **Démontage de la roue** : Pour un contrôle précis, desserrez les écrous, surélevez le véhicule en toute sécurité et déposez la roue. Utilisez une règle ou un pied à coulisse pour mesurer l'épaisseur exacte.

• **Vérification du témoin d'usure** : De nombreux véhicules possèdent un voyant lumineux ou un témoin acoustique (sifflement métallique aigu) qui se déclenche dès que le seuil critique est atteint.

⚠️ **Signes d'alerte d'usure avancée**

• Un bruit de grincement métallique lors du freinage
• Une pédale de frein plus molle ou un allongement de la distance de freinage
• Des vibrations dans le volant ou la pédale
• L'allumage du témoin d'usure sur votre tableau de bord

💡 **Recommandation**

Si vous remarquez une épaisseur inférieure à 3 mm ou des bruits anormaux, planifiez un remplacement rapide.

**Souhaitez-vous savoir comment changer vos plaquettes vous-même ou préférez-vous des conseils pour reconnaître l'usure de vos disques ?**''';
    }

    // ============================================
    // FREINS - CHANGEMENT
    // ============================================
    if (lower.contains('frein') &&
        (lower.contains('chang') || lower.contains('remplac'))) {
      return '''Voici les étapes pour changer vos plaquettes de frein :

🔧 **Matériel nécessaire**
• Cric + chandelles
• Clé à chocs ou clé plate (16-18mm)
• Repousse-piston
• Nettoyant frein
• Plaquettes neuves

📋 **Étapes**

1. **Desserrez les écrous** de la roue (sans les enlever)
2. **Levez le véhicule** avec le cric et posez les chandelles
3. **Retirez la roue**
4. **Démontez l'étrier** (2 boulons généralement)
5. **Retirez les anciennes plaquettes**
6. **Repoussez le piston** avec le repousse-piston
7. **Nettoyez** l'étrier avec le nettoyant frein
8. **Posez les nouvelles plaquettes**
9. **Remontez l'étrier** et serrez au couple (25-35 Nm)
10. **Remontez la roue** et serrez les écrous
11. **Pompez la pédale** de frein plusieurs fois avant de rouler

⚠️ **Important**
• Roulez doucement les 200 premiers km
• Évitez les freinages brusques
• Vérifiez le niveau de liquide de frein

**Voulez-vous que je vous explique comment purger le liquide de frein ?**''';
    }

    // ============================================
    // FREINS - GÉNÉRAL
    // ============================================
    if (lower.contains('frein')) {
      return '''Pour un problème de freins, voici les points à vérifier :

🔍 **Diagnostic rapide**
• Épaisseur des plaquettes (min. 3 mm)
• Niveau de liquide de frein (entre MIN et MAX)
• État des disques (pas de rayures profondes)
• Témoin d'usure allumé au tableau de bord

⚠️ **Signes d'alerte**
• Sifflement aigu au freinage → plaquettes usées
• Pédale molle → liquide bas ou purge nécessaire
• Vibrations → disques voilés
• Bruit métallique → plaquettes mortes (URGENT)

💡 **Recommandation**

Si vous avez un sifflement ou un bruit métallique, faites vérifier vos freins rapidement. Un remplacement coûte 35-150 EUR selon le véhicule.

**Voulez-vous que je vous aide à identifier le problème exact ? Décrivez-moi le bruit ou le symptôme.**''';
    }

    // ============================================
    // MOTEUR - VOYANT
    // ============================================
    if (lower.contains('moteur') && lower.contains('voyant')) {
      return '''Le voyant moteur allumé indique une anomalie détectée par le calculateur. Voici comment procéder :

🔍 **Étapes à suivre**

1. **Vérifiez le bouchon de carburant** (cause n°1 des voyants !)
2. **Vérifiez le niveau d'huile** (jauge à froid)
3. **Vérifiez le liquide de refroidissement**
4. **Notez le comportement** : perte de puissance ? à-coups ? consommation ?

⚠️ **Types de voyants**
• **Voyant fixe** → anomalie mineure, peut attendre
• **Voyant clignotant** → ARRÊTEZ-VOUS immédiatement (risque moteur)

🔧 **Diagnostic OBD**

Un boîtier OBD2 (15-30 EUR) permet de lire les codes défaut. C'est la méthode la plus fiable.

💡 **Recommandation**

Si le voyant est fixe et le moteur tourne normalement, vous pouvez rouler prudemment jusqu'à un garage. Si le voyant clignote ou si vous perdez de la puissance, arrêtez-vous.

**Souhaitez-vous la liste des codes OBD les plus courants ?**''';
    }

    // ============================================
    // MOTEUR - GÉNÉRAL
    // ============================================
    if (lower.contains('moteur') || lower.contains('bougie')) {
      return '''Pour un problème moteur, voici les points à vérifier :

🔍 **Causes fréquentes**
• Bougies d'allumage usées (à changer tous les 30 000 km)
• Filtre à air encrassé (tous les 20 000 km)
• Bobines d'allumage défaillantes
• Injecteurs encrassés

⚠️ **Symptômes à surveiller**
• Perte de puissance
• À-coups à l'accélération
• Consommation élevée
• Ralenti instable

💡 **Recommandation**

Un entretien régulier (bougies + filtres) résout 70% des problèmes moteur. Coût : 50-150 EUR.

**Voulez-vous que je vous indique comment changer vos bougies ?**''';
    }

    // ============================================
    // BATTERIE / DÉMARRAGE
    // ============================================
    if (lower.contains('batterie') ||
        lower.contains('démarre') ||
        lower.contains('démarrage')) {
      return '''Les difficultés de démarrage sont souvent liées à la batterie. Voici comment diagnostiquer :

🔍 **Test de la batterie**

• **Tension à l'arrêt** : doit être entre 12,4V et 12,7V
• **Tension moteur tournant** : doit être entre 13,5V et 14,5V
• **Test de charge** : dans un garage (gratuit chez Norauto/Feu Vert)

⚠️ **Signes de batterie faible**
• Démarrage difficile le matin
• Phares qui faiblissent
• Bruit de "clic" au démarrage
• Voyant batterie allumé

🔧 **Solution temporaire**

Si vous êtes bloqué, un booster de batterie (30-80 EUR) permet de redémarrer. Mais la batterie devra être changée.

💡 **Recommandation**

Une batterie dure 4-5 ans. Si la vôtre a plus de 5 ans et que les démarrages sont difficiles, remplacez-la (90-150 EUR).

**Voulez-vous savoir comment changer votre batterie vous-même ?**''';
    }

    // ============================================
    // CLIMATISATION
    // ============================================
    if (lower.contains('clim') || lower.contains('froid')) {
      return '''Pour une climatisation qui ne refroidit plus, voici les causes possibles :

🔍 **Causes fréquentes**

1. **Manque de gaz réfrigérant** (le plus courant)
   → Recharge nécessaire tous les 2-3 ans
   → Coût : 60-120 EUR

2. **Filtre habitacle encrassé**
   → À changer tous les 15 000 km
   → Coût : 15-30 EUR

3. **Compresseur défaillant**
   → Bruit anormal à l'allumage
   → Coût : 400-1000 EUR

4. **Fuite dans le circuit**
   → Recharge fréquente nécessaire
   → Diagnostic d'étanchéité : 40-80 EUR

⚠️ **Signes d'alerte**
• Air tiède au lieu de froid
• Mauvaise odeur dans l'habitacle
• Bruit de compresseur
• Clim qui s'arrête toute seule

💡 **Recommandation**

Commencez par vérifier le filtre habitacle (accessible derrière la boîte à gants). Si l'air est tiède malgré tout, faites recharger la clim.

**Voulez-vous savoir où se trouve votre filtre habitacle ?**''';
    }

    // ============================================
    // PHARES / AMPOULES
    // ============================================
    if (lower.contains('phare') || lower.contains('ampoule')) {
      return '''Pour un problème de phare ou d'ampoule :

🔧 **Changer une ampoule**

1. Ouvrez le capot
2. Localisez le bloc optique (derrière le phare)
3. Débranchez le connecteur
4. Retirez le cache en caoutchouc
5. Déclipsez l'ampoule (attention : ne touchez pas le verre !)
6. Posez la nouvelle ampoule
7. Rebranchez le connecteur
8. Testez

⚠️ **Types d'ampoules**
• **H4, H7, H11** → halogènes classiques (5-15 EUR)
• **Xénon D2S, D4S** → à faire en garage (50-150 EUR)
• **LED** → remplacement complet souvent

💡 **Recommandation**

Achetez toujours par paire (les ampoules s'usent en même temps). Coût : 10-30 EUR la paire.

**Voulez-vous que je vous aide à identifier le type d'ampoule de votre véhicule ?**''';
    }

    // ============================================
    // AMORTISSEURS / SUSPENSION
    // ============================================
    if (lower.contains('amortisseur') ||
        lower.contains('suspension') ||
        lower.contains('rebond')) {
      return '''Pour un problème de suspension ou d'amortisseurs :

🔍 **Symptômes d'amortisseurs usés**
• La voiture rebondit sur les bosses
• Tenue de route dégradée
• Usure irrégulière des pneus
• Bruit sourd dans les virages

📏 **Test rapide**

Appuyez fortement sur l'aile de votre voiture et relâchez. Si la voiture rebondit plus d'1-2 fois, les amortisseurs sont usés.

⚠️ **Durée de vie**
• Amortisseurs : 80 000 - 120 000 km
• À remplacer par paire (avant ou arrière)

💡 **Recommandation**

Un changement d'amortisseurs coûte 200-450 EUR par paire. C'est un investissement important pour votre sécurité et votre confort.

**Voulez-vous savoir comment tester vos amortisseurs vous-même ?**''';
    }

    // ============================================
    // EMBRAYAGE
    // ============================================
    if (lower.contains('embrayage') || lower.contains('patine')) {
      return '''Pour un problème d'embrayage :

🔍 **Symptômes d'embrayage usé**
• Le moteur monte en régime mais la voiture n'accélère pas (patinage)
• Pédale d'embrayage qui devient dure ou molle
• Point de patinage très haut
• Odeur de brûlé après une côte

📏 **Durée de vie**
• Embrayage : 100 000 - 200 000 km
• Dépend de votre conduite

⚠️ **Coût de remplacement**
• Kit embrayage : 150-400 EUR
• Main d'œuvre : 200-500 EUR
• Total : 400-900 EUR

💡 **Recommandation**

Si l'embrayage patine, faites-le remplacer rapidement. Rouler avec un embrayage mort peut endommager le volant moteur (coût x2).

**Voulez-vous connaître les signes précis d'un embrayage mort ?**''';
    }

    // ============================================
    // PNEUS
    // ============================================
    if (lower.contains('pneu') || lower.contains('roue')) {
      return '''Pour un problème de pneus :

🔍 **Vérifications essentielles**

• **Pression** : vérifiez tous les mois (à froid)
  → Valeur sur l'étiquette de la portière
• **Usure** : profondeur minimale 1,6 mm (recommandé 3 mm)
• **Usure irrégulière** : signe de problème de géométrie

⚠️ **Signes d'alerte**
• Pneu qui se dégonfle souvent → crevaison lente
• Vibrations dans le volant → équilibrage nécessaire
• Usure sur les bords → sous-gonflage
• Usure au centre → sur-gonflage

💡 **Recommandation**

Un pneu dure 40 000 - 60 000 km. Vérifiez la pression tous les mois pour économiser du carburant et prolonger leur durée de vie.

**Voulez-vous savoir comment changer une roue ?**''';
    }

    // ============================================
    // RÉPONSE PAR DÉFAUT
    // ============================================
    return '''Merci pour votre question sur votre ${widget.vehicleInfo}.

Pour vous aider précisément, j'aurais besoin de quelques informations :

🔍 **Questions à me préciser**

• Quel est le symptôme exact ? (bruit, voyant, comportement)
• Depuis quand cela dure-t-il ?
• Est-ce permanent ou intermittent ?
• À quelle vitesse cela se produit-il ?

💡 **En attendant, voici mes recommandations générales**

• Vérifiez les niveaux (huile, liquide de refroidissement, liquide de frein)
• Notez les voyants allumés au tableau de bord
• Écoutez les bruits anormaux (sifflement, claquement, grincement)

**Décrivez-moi plus précisément votre problème et je vous donnerai un diagnostic personnalisé.**''';
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: AppGradients.orange,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.support_agent_rounded,
                      color: Colors.white, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Demander un conseil à MecaGo',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.navy,
                        ),
                      ),
                      Text(
                        '$_messageCount/$_maxMessages questions',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_messages.isNotEmpty)
            Container(
              constraints: const BoxConstraints(maxHeight: 400),
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  return _buildMessageBubble(msg);
                },
              ),
            ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColors.orange),
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(24),
                    ),
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
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _isLoading ? null : _sendMessage,
                  child: Container(
                    width: 42,
                    height: 42,
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
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: msg.isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!msg.isUser) ...[
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                gradient: AppGradients.orange,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.support_agent_rounded,
                  color: Colors.white, size: 16),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: msg.isUser ? AppColors.orange : AppColors.background,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                msg.text,
                style: TextStyle(
                  fontSize: 12,
                  color: msg.isUser ? Colors.white : AppColors.navy,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  const ChatMessage({required this.text, required this.isUser});
}