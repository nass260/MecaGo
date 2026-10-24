// lib/core/services/image_generator_service.dart
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../theme/app_theme.dart';

/// Génère des illustrations d'étapes de réparation via l'Edge Function
/// Supabase (qui appelle Pollinations).
///
/// Principe : on lit le titre + la description de l'étape, on repère
///   1. l'ACTION (retirer, serrer, nettoyer...)
///   2. la PIÈCE (plaquette, courroie, turbo...) et où elle se trouve
///   3. l'OUTIL (cliquet, clé dynamométrique...)
/// puis on fabrique un prompt anglais précis.
class ImageGeneratorService {
  const ImageGeneratorService();

  static const String _proxyUrl =
      'https://rpuhqomualtsfwpldtdw.supabase.co/functions/v1/pollinations-proxy';

  // ============================================
  // OUTILS (mot français -> description anglaise)
  // ============================================
  static final List<MapEntry<String, String>> _tools = _prepare({
    'cle dynamometrique': 'a torque wrench',
    'cle a molette': 'an adjustable wrench',
    'cle a filtre': 'an oil filter wrench',
    'cle plate': 'an open-end wrench',
    'cle a bougie': 'a spark plug socket',
    'cle': 'a wrench',
    'cliquet': 'a ratchet wrench',
    'douille': 'a socket wrench',
    'tournevis': 'a screwdriver',
    'pince': 'pliers',
    'brosse metallique': 'a steel wire brush',
    'brosse': 'a small cleaning brush',
    'pinceau': 'a small cleaning brush',
    'repousse-piston': 'a brake piston tool',
    'repousse piston': 'a brake piston tool',
    'cric': 'a hydraulic car jack',
    'chandelle': 'axle stands',
    'entonnoir': 'a plastic funnel',
    'bac de vidange': 'an oil drain pan',
    'bac': 'an oil drain pan',
    'multimetre': 'a digital multimeter',
    'jauge': 'a dipstick',
    'pied a coulisse': 'a caliper gauge',
    'valise diagnostic': 'an OBD diagnostic scanner',
    'obd': 'an OBD diagnostic scanner',
    'graisse': 'a grease tube',
    'nettoyant frein': 'a brake cleaner spray can',
  });

  // ============================================
  // PIÈCES (mot français -> pièce + emplacement)
  // Les mots les plus longs sont testés EN PREMIER (tri automatique).
  // ============================================
  static final List<MapEntry<String, String>> _components = _prepare({
    // --- Freinage
    'plaquette': 'brake pads inside a brake caliper, next to the wheel',
    'etrier': 'a brake caliper on the wheel hub',
    'disque de frein': 'a brake disc on the wheel hub',
    'disque': 'a brake disc on the wheel hub',
    'liquide de frein': 'brake fluid reservoir in the engine bay',
    'purge': 'a brake bleeder valve on the caliper',
    'frein a main': 'a handbrake cable under the car',
    'frein': 'a brake assembly behind the wheel',
    'chape': 'a brake caliper bracket',
    'piston': 'a brake caliper piston',
    // --- Huile / lubrification
    'filtre a huile': 'an oil filter on the engine block',
    'bouchon de vidange': 'an oil drain plug on the oil pan under the car',
    'bouchon': 'an oil drain plug on the oil pan under the car',
    'carter': 'an engine oil pan under the car',
    'vidange': 'an oil drain plug and oil pan under the car',
    'jauge': 'an oil dipstick in the engine bay',
    'huile': 'an engine oil filler cap on top of the engine',
    // --- Filtres
    'filtre a air': 'an air filter box in the engine bay',
    'filtre a gasoil': 'a diesel fuel filter in the engine bay',
    'filtre a carburant': 'a fuel filter under the car',
    'filtre d\'habitacle': 'a cabin air filter behind the glove box',
    'filtre habitacle': 'a cabin air filter behind the glove box',
    'filtre a pollen': 'a cabin air filter behind the glove box',
    'filtre': 'a car filter',
    // --- Distribution / courroies
    'kit de distribution': 'a timing belt kit with pulleys on the engine side',
    'courroie de distribution': 'a timing belt and pulleys on the engine side',
    'courroie d\'accessoires': 'an accessory serpentine belt on the engine',
    'courroie': 'a drive belt and pulleys on the engine',
    'distribution': 'a timing belt and pulleys on the engine side',
    'galet': 'a belt tensioner pulley on the engine',
    'pompe a eau': 'a water pump on the engine',
    // --- Allumage / injection / diesel
    'bougie de prechauffage': 'a diesel glow plug on the cylinder head',
    'bougie': 'a spark plug on the cylinder head',
    'bobine': 'an ignition coil on the engine',
    'injecteur': 'a fuel injector on the engine',
    'turbo': 'a turbocharger on the engine',
    'vanne egr': 'an EGR valve on the engine',
    'egr': 'an EGR valve on the engine',
    'fap': 'a diesel particulate filter under the car',
    'catalyseur': 'a catalytic converter under the car',
    'echappement': 'an exhaust pipe and muffler under the car',
    'pot d\'echappement': 'an exhaust muffler under the car',
    'sonde lambda': 'an oxygen sensor on the exhaust',
    'debitmetre': 'an air mass flow sensor in the intake duct',
    // --- Refroidissement / clim
    'liquide de refroidissement': 'a coolant reservoir in the engine bay',
    'refroidissement': 'a coolant reservoir and hoses in the engine bay',
    'radiateur': 'a car radiator at the front of the engine bay',
    'thermostat': 'a thermostat housing on the engine',
    'durite': 'a coolant hose on the engine',
    'climatisation': 'an A/C compressor and hoses in the engine bay',
    'clim': 'an A/C compressor and hoses in the engine bay',
    'compresseur': 'an A/C compressor on the engine',
    // --- Transmission / embrayage
    'embrayage': 'a clutch disc and flywheel',
    'boite de vitesses': 'a manual gearbox under the car',
    'boite de vitesse': 'a manual gearbox under the car',
    'cardan': 'a drive shaft with rubber boot near the wheel',
    'transmission': 'a drive shaft under the car',
    // --- Suspension / direction / roues
    'amortisseur': 'a shock absorber and coil spring near the wheel',
    'ressort': 'a coil spring near the wheel',
    'suspension': 'a suspension strut near the wheel',
    'rotule': 'a ball joint on the suspension arm',
    'biellette': 'an anti-roll bar link near the wheel',
    'triangle': 'a suspension control arm under the car',
    'rotule de direction': 'a steering tie rod end near the wheel',
    'direction': 'a steering rack and tie rods under the car',
    'roulement': 'a wheel bearing hub',
    'pneu': 'a car tire mounted on a wheel',
    'jante': 'a car alloy wheel',
    'roue': 'a car wheel and lug nuts',
    'geometrie': 'a car wheel on an alignment machine',
    // --- Électrique
    'batterie': 'a car battery in the engine bay with terminals',
    'alternateur': 'an alternator on the engine',
    'demarreur': 'a starter motor on the engine',
    'fusible': 'a fuse box with fuses',
    'ampoule': 'a car headlight bulb behind the headlight',
    'phare': 'a car headlight assembly at the front',
    'essuie-glace': 'a windshield wiper blade on a car windshield',
    'balai': 'a windshield wiper blade on a car windshield',
    'capteur': 'a sensor on the engine',
    'calculateur': 'a car ECU electronic control unit',
    // --- Divers
    'carburant': 'a fuel tank and fuel lines under the car',
    'reservoir': 'a fluid reservoir in the engine bay',
    'moteur': 'a car engine in the engine bay',
    'capot': 'an open car hood showing the engine bay',
  });

  // ============================================
  // ACTIONS (verbe -> scène)
  // ============================================
  static final List<_Rule> _actions = [
    _Rule(['preparer', 'securiser', 'lever', 'caler', 'securite', 'stationner'],
        'a car safely raised on axle stands in a bright home garage, tools nearby'),
    _Rule(['vidanger', 'ecouler', 'drainer'],
        'a mechanic draining fluid from a car into a drain pan'),
    _Rule(['serrer', 'visser', 'bloquer', 'couple'],
        'a mechanic tightening a bolt with a torque wrench'),
    _Rule(['retirer', 'enlever', 'deposer', 'devisser', 'oter', 'sortir', 'demonter', 'desserrer'],
        'a mechanic removing a car part by hand with a tool'),
    _Rule(['nettoyer', 'brosser', 'degraisser', 'laver', 'purger', 'depoussierer'],
        'a mechanic cleaning a car part'),
    _Rule(['installer', 'poser', 'monter', 'remettre', 'fixer', 'remplacer', 'changer', 'neuf', 'inserer'],
        'a mechanic installing a new car part'),
    _Rule(['mesurer', 'epaisseur', 'dimension', 'jeu'],
        'a mechanic measuring a car part with a gauge'),
    _Rule(['remplir', 'ajouter', 'niveau', 'verser', 'completer'],
        'a mechanic pouring fluid into a car'),
    _Rule(['verifier', 'controler', 'examiner', 'inspecter', 'observer', 'etat', 'usure', 'fuite'],
        'a mechanic inspecting a car part with a flashlight'),
    _Rule(['brancher', 'debrancher', 'deconnecter', 'connecter'],
        'a mechanic connecting or disconnecting a car connector'),
    _Rule(['tester', 'essayer', 'demarrer', 'fonctionnement', 'rouler'],
        'a mechanic checking a running car'),
    _Rule(['terminer', 'finaliser', 'remonter', 'ranger'],
        'a mechanic finishing work on a car, tools put away'),
  ];

  // ============================================
  // OUTILS DE TEXTE
  // ============================================

  /// Trie du mot le plus long au plus court, et enlève les accents des clés.
  /// Ainsi « filtre à huile » est testé avant « huile ».
  static List<MapEntry<String, String>> _prepare(Map<String, String> map) {
    final list = map.entries
        .map((e) => MapEntry(_norm(e.key), e.value))
        .toList()
      ..sort((a, b) => b.key.length.compareTo(a.key.length));
    return list;
  }

  /// Minuscules, sans accents, apostrophes simples.
  static String _norm(String s) {
    const from = 'àâäéèêëîïôöùûüçœ’';
    const to = 'aaaeeeeiioouuuco\'';
    final buf = StringBuffer();
    for (final ch in s.toLowerCase().split('')) {
      final i = from.indexOf(ch);
      if (i == -1) {
        buf.write(ch);
      } else if (ch == 'œ') {
        buf.write('oe');
      } else {
        buf.write(to[i]);
      }
    }
    return buf.toString();
  }

  String? _findAction(String normText) {
    for (final rule in _actions) {
      for (final k in rule.keywords) {
        if (normText.contains(k)) return rule.scene;
      }
    }
    return null;
  }

  String? _findIn(List<MapEntry<String, String>> list, String normText) {
    for (final e in list) {
      if (normText.contains(e.key)) return e.value;
    }
    return null;
  }

  String _cleanForPrompt(String text) {
    return text
        .replaceAll(RegExp(r'[\u{1F300}-\u{1F9FF}]', unicode: true), '')
        .replaceAll(RegExp(r'[\u{2600}-\u{27BF}]', unicode: true), '')
        .replaceAll('**', '')
        .replaceAll('*', '')
        .replaceAll('"', '')
        .replaceAll('\n', ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  // ============================================
  // CONSTRUCTION DU PROMPT
  // ============================================

  String buildRepairPrompt({
    required String stepTitle,
    required String stepDescription,
  }) {
    final title = _norm(_cleanForPrompt(stepTitle));
    final full = _norm(_cleanForPrompt('$stepTitle $stepDescription'));

    // Le TITRE décide en priorité (il dit l'action et la pièce principale),
    // la description sert de secours.
    final action = _findAction(title) ??
        _findAction(full) ??
        'a mechanic working on a car';

    final component = _findIn(_components, title) ??
        _findIn(_components, full) ??
        'car parts being worked on';

    final tool = _findIn(_tools, title) ?? _findIn(_tools, full);

    final toolPart = tool != null ? ', using $tool' : '';

    return 'Realistic automotive repair photo, $action$toolPart, '
        'the focus is $component, '
        'medium shot showing the whole part and its surroundings, '
        'bright clean workshop lighting, sharp focus, photorealistic, no text';
  }

  // ============================================
  // URL
  // ============================================

  String buildImageUrl({
    required String description,
    int width = 800,
    int height = 400,
    String model = 'flux',
  }) {
    final encoded = Uri.encodeComponent(description);
    return '$_proxyUrl?prompt=$encoded&width=$width&height=$height'
        '&model=$model&seed=${_stableSeed(description)}';
  }

  /// Même texte = même seed = même image (donc cache efficace).
  int _stableSeed(String s) {
    var h = 2166136261;
    for (final c in s.codeUnits) {
      h = ((h ^ c) * 16777619) & 0x7fffffff;
    }
    return h % 1000000;
  }

  String buildStepImageUrl({
    required String stepTitle,
    required String stepDescription,
    int width = 800,
    int height = 400,
  }) {
    final prompt = buildRepairPrompt(
      stepTitle: stepTitle,
      stepDescription: stepDescription,
    );
    return buildImageUrl(description: prompt, width: width, height: height);
  }

  // ============================================
  // WIDGETS
  // ============================================

  Widget buildGeneratedImage({
    required String description,
    double width = 400,
    double height = 200,
    double borderRadius = 12,
  }) {
    final url = buildImageUrl(description: description);
    return _FetchedImage(
      url: url,
      width: width,
      height: height,
      borderRadius: borderRadius,
    );
  }

  Widget buildStepImage({
    required String stepTitle,
    required String stepDescription,
    double width = 400,
    double height = 200,
    double borderRadius = 18,
  }) {
    final prompt = buildRepairPrompt(
      stepTitle: stepTitle,
      stepDescription: stepDescription,
    );
    debugPrint('🖼️ Prompt : $prompt');
    return buildGeneratedImage(
      description: prompt,
      width: width,
      height: height,
      borderRadius: borderRadius,
    );
  }
}

class _Rule {
  final List<String> keywords;
  final String scene;
  const _Rule(this.keywords, this.scene);
}

// ============================================
// Téléchargeur : 2 à la fois, mémoire, nouvel essai si surcharge
// ============================================

class _ImageQueue {
  static final Map<String, Uint8List> _cache = {};
  static final List<Completer<void>> _waiting = [];
  static int _running = 0;
  static const int _maxParallel = 2;

  static Future<Uint8List> load(String url) async {
    final cached = _cache[url];
    if (cached != null) return cached;

    if (_running >= _maxParallel) {
      final c = Completer<void>();
      _waiting.add(c);
      await c.future;
    }
    _running++;
    try {
      Object? lastError;
      for (var attempt = 0; attempt < 3; attempt++) {
        try {
          final res = await http
              .get(Uri.parse(url))
              .timeout(const Duration(seconds: 90));
          if (res.statusCode == 200) {
            _cache[url] = res.bodyBytes;
            return res.bodyBytes;
          }
          // 402 = plus de crédit : inutile de réessayer
          if (res.statusCode == 402) {
            throw Exception('HTTP 402 (plus de crédit Pollinations)');
          }
          lastError = Exception('HTTP ${res.statusCode}');
          // 429 (trop de demandes) ou erreur serveur : on réessaie
          if (res.statusCode != 429 && res.statusCode < 500) throw lastError;
        } on TimeoutException catch (e) {
          lastError = e;
        }
        await Future.delayed(Duration(seconds: 4 * (attempt + 1)));
      }
      throw lastError ?? Exception('Image indisponible');
    } finally {
      _running--;
      if (_waiting.isNotEmpty) _waiting.removeAt(0).complete();
    }
  }
}

class _FetchedImage extends StatefulWidget {
  final String url;
  final double width;
  final double height;
  final double borderRadius;

  const _FetchedImage({
    required this.url,
    required this.width,
    required this.height,
    required this.borderRadius,
  });

  @override
  State<_FetchedImage> createState() => _FetchedImageState();
}

class _FetchedImageState extends State<_FetchedImage> {
  late Future<Uint8List> _future = _ImageQueue.load(widget.url);

  Widget _box(Widget child) {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: const BoxDecoration(gradient: AppGradients.navy),
      child: Center(child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List>(
      future: _future,
      builder: (context, snap) {
        if (snap.hasError) {
          debugPrint('❌ Image échouée : ${snap.error}');
          // Toucher l'image = réessayer
          return GestureDetector(
            onTap: () =>
                setState(() => _future = _ImageQueue.load(widget.url)),
            child: _box(const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.refresh_rounded, color: Colors.white38, size: 40),
                SizedBox(height: 6),
                Text(
                  'Toucher pour réessayer',
                  style: TextStyle(fontSize: 11, color: Colors.white54),
                ),
              ],
            )),
          );
        }
        if (!snap.hasData) {
          return _box(const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppColors.orangeMecaGo),
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Génération de l\'illustration...',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ));
        }
        return ClipRRect(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: Image.memory(
            snap.data!,
            width: widget.width,
            height: widget.height,
            fit: BoxFit.cover,
          ),
        );
      },
    );
  }
}