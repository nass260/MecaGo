// lib/core/services/procedure_service.dart
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ============================================
// OUTILS DE TEXTE (partagés)
// ============================================

/// Minuscules, sans accents, apostrophes simples.
String _norm(String s) {
  const from = 'àâäéèêëîïôöùûüçœ’';
  const to = "aaaeeeeiioouuuco'";
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

/// Petits mots sans intérêt pour la recherche
const Set<String> _stopWords = {
  'les', 'une', 'des', 'aux', 'mais', 'donc', 'car', 'pas', 'plus', 'dans',
  'sur', 'sous', 'par', 'pour', 'avec', 'sans', 'chez', 'vers', 'mon', 'mes',
  'ton', 'tes', 'son', 'ses', 'notre', 'votre', 'leur', 'leurs', 'ces', 'cet',
  'cette', 'elle', 'nous', 'vous', 'ils', 'elles', 'que', 'qui', 'quoi',
  'quand', 'comment', 'pourquoi', 'quel', 'quelle', 'quels', 'quelles', 'est',
  'suis', 'sommes', 'etes', 'sont', 'etait', 'ete', 'etre', 'avoir', 'avons',
  'avez', 'ont', 'fait', 'faire', 'tout', 'tous', 'toute', 'toutes', 'tres',
  'bien', 'mal', 'comme', 'meme', 'aussi', 'lorsque', 'alors', 'apres',
  'avant', 'pendant', 'depuis', 'encore', 'deja', 'toujours', 'jamais', 'rien',
  'seul', 'seule', 'voiture', 'vehicule', 'auto', 'entends', 'entend', 'sens',
  'sent', 'remarque', 'constate', 'moins', 'peu', 'trop', 'beaucoup', 'cela',
  'ceci', 'faut', 'peut', 'peux', 'dois', 'doit', 'veux', 'veut', 'voudrais',
  'besoin', 'svp', 'merci', 'bonjour', 'salut', 'lors',
};

/// Découpe un texte en mots utiles (sans accents, sans petits mots)
List<String> _tokens(String text) {
  final words = _norm(text)
      .replaceAll("'", ' ')
      .split(RegExp(r'[^a-z0-9]+'))
      .where((w) => w.isNotEmpty)
      .toList();

  final out = <String>[];
  for (var i = 0; i < words.length; i++) {
    final w = words[i];

    // "sans freiner" devient UN seul mot ("sans_freiner") :
    // il ne doit pas être confondu avec "freiner"
    if (w == 'sans' && i + 1 < words.length && words[i + 1].length >= 3) {
      out.add('sans_${words[i + 1]}');
      i++;
      continue;
    }

    if (w.length >= 3 && !_stopWords.contains(w)) out.add(w);
  }
  return out;
}

/// Deux mots sont "les mêmes" s'ils sont égaux ou presque
/// (pluriel, conjugaison : frein / freine / freinage, vibre / vibrations...)
bool _same(String a, String b) {
  if (a == b) return true;
  final minLen = a.length < b.length ? a.length : b.length;
  if (minLen < 4) return false; // les mots très courts doivent être identiques
  var i = 0;
  while (i < minLen && a.codeUnitAt(i) == b.codeUnitAt(i)) {
    i++;
  }
  final need = (minLen * 0.75).ceil();
  return i >= (need < 4 ? 4 : need);
}

/// Quelques équivalences pour les réparations
const Map<String, List<String>> _synonyms = {
  'huile': ['vidange'],
  'gazole': ['carburant'],
  'gasoil': ['carburant'],
  'accessoire': ['courroie'],
  'accessoires': ['courroie'],
  'volant': ['direction'],
  'etrier': ['freinage'],
  'clim': ['climatisation'],
  // "changement de distribution" = "Remplacement ... distribution"
  'changement': ['remplacement'],
  'changer': ['remplacement'],
  'change': ['remplacement'],
  'changez': ['remplacement'],
};

// ============================================
// INDEX LÉGER DES FICHES (titre + mots-clés)
// ============================================

class _IndexEntry {
  final String id;
  final String titre;
  final String normTitre;
  final String type;
  final List<String> carburantsExclus;
  final List<String> titleTokens;
  final List<String> keyTokens;

  /// Si renseigné : cette fiche est une VERSION PRÉCISE de la fiche générique
  /// dont c'est l'identifiant (ex : kit distribution Clio Blue dCi 85)
  final String? parentId;

  _IndexEntry({
    required this.id,
    required this.titre,
    required this.normTitre,
    required this.type,
    required this.carburantsExclus,
    required this.titleTokens,
    required this.keyTokens,
    this.parentId,
  });

  bool matches(String token) =>
      titleTokens.any((t) => _same(t, token)) ||
      keyTokens.any((t) => _same(t, token));
}

class _Scored {
  final _IndexEntry entry;
  final double score;
  final double coverage;
  final double precision;

  /// Fiche reliée à la voiture exacte de l'utilisateur (ex : kit distribution
  /// du moteur K9K pour une Clio V diesel)
  final bool dedicated;

  _Scored(this.entry, this.score, this.coverage, this.precision,
      {this.dedicated = false});

  /// Classement : le score, plus un petit bonus pour la fiche dont le titre
  /// ressemble le plus à la question (départage les égalités),
  /// plus un gros bonus pour la fiche faite pour la voiture exacte
  double get rank => score + 0.5 * precision + (dedicated ? 2.0 : 0.0);
}

/// Une ligne du catalogue vehicules qui correspond à la voiture de l'utilisateur
class _Cand {
  final String id;
  final String moteur;
  final String generation;
  const _Cand(this.id, this.moteur, this.generation);
}

class ProcedureService {
  const ProcedureService();

  static List<_IndexEntry> _index = [];

  /// fiche -> véhicules liés (table procedures_vehicules).
  /// Sert UNIQUEMENT à choisir parmi les versions précises d'une fiche.
  static Map<String, Set<String>> _targets = {};

  /// Fiches qui ont au moins UN lien "verifie" : ce sont des fiches générales
  /// (avec des notes par véhicule), elles restent visibles pour tout le monde.
  /// Les fiches qui n'ont que des liens "brouillon" sont RÉSERVÉES à leurs moteurs.
  static Set<String> _verifiedLinked = {};
  static DateTime? _indexAt;

  /// Charge (et garde 5 minutes en mémoire) la liste des fiches VÉRIFIÉES,
  /// et les liens fiche -> véhicules.
  Future<List<_IndexEntry>> _loadIndex() async {
    final now = DateTime.now();
    if (_index.isNotEmpty &&
        _indexAt != null &&
        now.difference(_indexAt!).inMinutes < 5) {
      return _index;
    }

    final supabase = Supabase.instance.client;

    List<Map<String, dynamic>> rows;
    try {
      rows = await supabase
          .from('procedures')
          .select('id, titre, type, mots_cles, carburants_exclus, parent_id')
          .eq('statut', 'verifie');
    } catch (e) {
      debugPrint('⚠️ Colonne parent_id absente (pas encore créée ?) : $e');
      rows = await supabase
          .from('procedures')
          .select('id, titre, type, mots_cles, carburants_exclus')
          .eq('statut', 'verifie');
    }

    final list = <_IndexEntry>[];
    for (final r in rows) {
      final titre = (r['titre'] ?? '').toString();
      if (titre.isEmpty) continue;

      final mots = r['mots_cles'] is List
          ? (r['mots_cles'] as List).map((e) => e.toString()).toList()
          : <String>[];
      final exclus = r['carburants_exclus'] is List
          ? (r['carburants_exclus'] as List).map((e) => e.toString()).toList()
          : <String>[];

      list.add(_IndexEntry(
        id: r['id'].toString(),
        titre: titre,
        normTitre: _norm(titre).replaceAll(RegExp(r'\s+'), ' ').trim(),
        type: (r['type'] ?? 'reparation').toString(),
        carburantsExclus: exclus,
        titleTokens: _tokens(titre),
        keyTokens: mots.expand((m) => _tokens(m)).toList(),
        parentId: r['parent_id']?.toString(),
      ));
    }

    // Liens fiche -> véhicules (table procedures_vehicules)
    final targets = <String, Set<String>>{};
    final verifiedLinked = <String>{};
    try {
      var from = 0;
      while (true) {
        final page = await supabase
            .from('procedures_vehicules')
            .select('procedure_id, vehicule_id, statut')
            .order('procedure_id')
            .range(from, from + 999);
        for (final r in page) {
          final p = r['procedure_id']?.toString();
          final v = r['vehicule_id']?.toString();
          if (p == null || v == null) continue;
          targets.putIfAbsent(p, () => <String>{}).add(v);
          if ((r['statut'] ?? '').toString() == 'verifie') {
            verifiedLinked.add(p);
          }
        }
        if (page.length < 1000) break;
        from += 1000;
      }
    } catch (e) {
      debugPrint('ℹ️ Table procedures_vehicules illisible : $e');
    }

    _index = list;
    _targets = targets;
    _verifiedLinked = verifiedLinked;
    _indexAt = now;
    debugPrint(
        '📇 Index chargé : ${list.length} fiches vérifiées, ${targets.length} fiches avec des véhicules liés');
    return list;
  }

  Future<Map<String, dynamic>?> findProcedure({
    required String question,
    required String marque,
    required String modele,
    String? moteur,
    String? carburant,
    int? annee,
  }) async {
    try {
      final index = await _loadIndex();
      if (index.isEmpty) {
        debugPrint('ℹ️ Aucune fiche vérifiée dans Supabase → IA');
        return null;
      }

      // 1. TITRE EXACT (clic sur un bouton : diagnostic, réparation, motorisation)
      final cleaned = question
          .trim()
          .replaceFirst(RegExp(r'^diagnostic\s*:\s*', caseSensitive: false), '');
      final nq = _norm(cleaned).replaceAll(RegExp(r'\s+'), ' ').trim();
      for (final e in index) {
        if (e.normTitre == nq) {
          debugPrint('🎯 Titre exact trouvé : "${e.titre}"');
          return await _loadFull(e.id, marque, modele, carburant, annee, null);
        }
      }

      // 2. INTENTION (simple bonus, ne bloque plus la recherche)
      final intent = _detectIntent(question);
      debugPrint('🎯 Intention détectée : $intent');

      // 3. LA VOITURE DE L'UTILISATEUR DANS TON CATALOGUE
      var cand = <_Cand>[];
      if (_targets.isNotEmpty) {
        cand = await _candidateVehicles(marque, modele, carburant, annee);
        debugPrint(
            '🚗 Véhicules du catalogue correspondants : ${cand.map((c) => "${c.generation} ${c.moteur}").toList()}');
      }
      final candIds = cand.map((c) => c.id).toSet();

      // Une fiche réservée à certains moteurs (liens en brouillon seulement)
      // n'est proposée que si elle vise la voiture de l'utilisateur.
      // Une fiche sans lien, ou avec des liens vérifiés (notes par véhicule),
      // est une fiche générale : proposée à tout le monde.
      bool eligible(_IndexEntry e) {
        final t = _targets[e.id];
        if (t != null && t.isNotEmpty) {
          if (_verifiedLinked.contains(e.id)) return true;
          return t.any(candIds.contains);
        }
        // Aucun lien : fiche générale... sauf si son titre vise un moteur ou
        // une marque précise (ex : "... - Moteur DMTA (VW 2.0 TDI)").
        // Dans ce cas, elle n'est proposée que si le titre cite la marque
        // ou le modèle de la voiture.
        if (!e.titre.contains(' - ')) return true;
        return _titleTargetsCar(e, marque, modele);
      }

      // Les versions précises (parentId) ne sont pas cherchées directement :
      // on passe par leur fiche générale, puis on choisit selon la voiture.
      final pool =
          index.where((e) => e.parentId == null && eligible(e)).toList();
      if (pool.isEmpty) return null;

      // 4. MOTS DE LA QUESTION
      final raw = _tokens(question);
      if (intent == 'reparation') {
        final hasFrein = raw.any((t) => t.startsWith('frein'));
        for (final t in List<String>.from(raw)) {
          final extra = _synonyms[t];
          if (extra == null) continue;
          if (t == 'huile' && hasFrein) continue;
          raw.addAll(extra);
        }
      }
      final qTokens = <String>[];
      for (final t in raw) {
        if (!qTokens.any((e) => _same(e, t))) qTokens.add(t);
      }

      // 5. POIDS DES MOTS : un mot rare dans ta base compte plus qu'un mot courant
      final n = pool.length;
      final weights = <String, double>{};
      final unknown = <String>[];
      for (final t in qTokens) {
        final df = pool.where((e) => e.matches(t)).length;
        if (df == 0) {
          unknown.add(t);
          continue;
        }
        weights[t] = math.log(1 + n / df);
      }
      debugPrint('🧩 Mots compris : ${weights.keys.toList()} | inconnus : $unknown');

      if (weights.isEmpty) {
        debugPrint('ℹ️ Aucun mot de la question ne correspond à ta base → IA');
        return null;
      }

      final total = weights.values.fold<double>(0, (a, b) => a + b);
      final floor = 0.45 * math.log(1 + n);

      // 6. SCORE DE CHAQUE FICHE (+ sécurité carburant)
      final fuel = _fuelKey(carburant ?? '');
      final scored = <_Scored>[];
      for (final e in pool) {
        if (fuel.isNotEmpty && e.carburantsExclus.contains(fuel)) continue;

        var score = 0.0;
        var covered = 0.0;
        final matchedTitleTokens = <String>{};
        weights.forEach((t, w) {
          final inTitle = e.titleTokens.where((x) => _same(x, t)).toList();
          if (inTitle.isNotEmpty) {
            score += w;
            covered += w;
            matchedTitleTokens.addAll(inTitle);
          } else if (e.keyTokens.any((x) => _same(x, t))) {
            score += w * 0.8;
            covered += w;
          }
        });
        if (covered == 0) continue;
        if (e.type == intent) score *= 1.1;

        // Part des mots du titre qui se retrouvent dans la question
        final titleSize = e.titleTokens.toSet().length;
        final precision =
            titleSize == 0 ? 0.0 : matchedTitleTokens.length / titleSize;

        final links = _targets[e.id];
        final dedicated = links != null &&
            links.isNotEmpty &&
            !_verifiedLinked.contains(e.id) &&
            links.any(candIds.contains);

        scored.add(_Scored(e, score, covered / total, precision,
            dedicated: dedicated));
      }

      if (scored.isEmpty) {
        debugPrint('ℹ️ Aucune fiche ne correspond → IA');
        return null;
      }

      scored.sort((a, b) => b.rank.compareTo(a.rank));
      for (var i = 0; i < scored.length && i < 3; i++) {
        final s = scored[i];
        debugPrint(
            '🏆 ${i + 1}. "${s.entry.titre}" (${s.entry.type}) score=${s.score.toStringAsFixed(1)} couverture=${(s.coverage * 100).round()}% precision=${(s.precision * 100).round()}%');
      }

      final best = scored.first;
      // Fiche très sûre : tous les mots de la question sont dans la fiche
      // ET la question reprend au moins 60 % des mots de son titre.
      // Une fiche faite pour la voiture exacte est aussi acceptée dès que
      // tous les mots de la question sont dedans.
      final sure =
          best.coverage >= 0.99 && (best.precision >= 0.6 || best.dedicated);
      if (!sure && (best.coverage < 0.6 || best.score < floor)) {
        debugPrint('ℹ️ Meilleure fiche trop incertaine → IA prendra le relais');
        return null;
      }

      // 7. VERSION PRÉCISE POUR LA VOITURE DE L'UTILISATEUR ?
      final variants = index.where((e) => e.parentId == best.entry.id).toList();
      if (variants.isNotEmpty && candIds.isNotEmpty) {
        final eligibleVariants = variants.where((v) {
          final t = _targets[v.id];
          final excluded = fuel.isNotEmpty && v.carburantsExclus.contains(fuel);
          return !excluded && t != null && t.any(candIds.contains);
        }).toList();

        if (eligibleVariants.length == 1) {
          debugPrint(
              '🎯 Version précise trouvée : "${eligibleVariants.first.titre}"');
          return await _loadFull(eligibleVariants.first.id, marque, modele,
              carburant, annee, cand);
        }

        if (eligibleVariants.length > 1) {
          debugPrint(
              '❓ ${eligibleVariants.length} versions possibles → on demande la motorisation');
          return _buildChoice(
            generic: best.entry,
            variants: eligibleVariants,
            cand: cand,
            marque: marque,
            modele: modele,
          );
        }
      }

      return await _loadFull(
          best.entry.id, marque, modele, carburant, annee, cand);
    } catch (e) {
      debugPrint('❌ Erreur ProcedureService : $e');
      return null;
    }
  }

  // ============================================
  // CHOIX DE LA MOTORISATION
  // ============================================

  Map<String, dynamic> _buildChoice({
    required _IndexEntry generic,
    required List<_IndexEntry> variants,
    required List<_Cand> cand,
    required String marque,
    required String modele,
  }) {
    final options = <Map<String, String>>[];
    final usedLabels = <String>{};

    for (final v in variants) {
      final ids = _targets[v.id] ?? <String>{};
      final moteurs = cand
          .where((c) => ids.contains(c.id))
          .map((c) => c.moteur)
          .where((m) => m.isNotEmpty)
          .toSet()
          .toList()
        ..sort();

      var label = moteurs.join(' / ');
      if (label.isEmpty) {
        final i = v.titre.indexOf(' - ');
        label = i >= 0 ? v.titre.substring(i + 3) : v.titre;
      }
      if (!usedLabels.add(label)) label = '$label (${v.titre})';

      options.add({'label': label, 'target_titre': v.titre});
    }

    options.sort((a, b) => a['label']!.compareTo(b['label']!));
    options.add({
      'label': 'Je ne connais pas ma motorisation',
      'target_titre': generic.titre,
    });

    return <String, dynamic>{
      'type': 'procedure',
      'titre': 'Quelle est votre motorisation ?',
      'vehicule': '$marque $modele',
      'duree_estimee': '',
      'difficulte': '',
      'niveau_danger': 'faible',
      'public_cible': 'tous',
      'formation_requise': 'Aucune',
      'outils': [],
      'pieces': [],
      'avertissements_securite': [],
      'avertissements_legaux': [],
      'etapes': [],
      'conseil_final':
          "Plusieurs versions de votre $marque $modele existent pour « ${generic.titre} » et les opérations changent d'une motorisation à l'autre. Choisissez la vôtre. Si vous n'êtes pas sûr, vérifiez dans votre carnet d'entretien ou dans les documents du véhicule.",
      'sources': ['MecaGo'],
      'notes_specifiques': null,
      'options_diagnostic': options,
      'actions_reparation': null,
      'pieges_constructeur': null,
    };
  }

  // ============================================
  // LA VOITURE DE L'UTILISATEUR DANS LE CATALOGUE
  // ============================================

  /// Retrouve les lignes du catalogue vehicules qui correspondent à la voiture
  /// (marque, modèle, génération, carburant, année). Plusieurs lignes possibles
  /// quand le moteur n'est pas connu (ex : Clio V diesel = Blue dCi 85 ou 115).
  Future<List<_Cand>> _candidateVehicles(
    String marque,
    String modele,
    String? carburant,
    int? annee,
  ) async {
    if (marque.isEmpty || modele.isEmpty) return [];

    try {
      final supabase = Supabase.instance.client;
      const columns = 'id, moteur, generation, annee_min, annee_max, carburant';

      // On essaie d'abord le nom complet ("Clio V"), puis sans la génération
      // ("Clio" + génération V)
      String? generation;
      var rows = await supabase
          .from('vehicules')
          .select(columns)
          .ilike('marque', _loose(marque))
          .ilike('modele', _loose(modele.trim()));

      if (rows.isEmpty) {
        final m = RegExp(r'^(.*?)\s+(I|II|III|IV|V|VI|VII|VIII|IX|X)$',
                caseSensitive: false)
            .firstMatch(modele.trim());
        if (m != null) {
          generation = m.group(2)!.toUpperCase();
          rows = await supabase
              .from('vehicules')
              .select(columns)
              .ilike('marque', _loose(marque))
              .ilike('modele', _loose(m.group(1)!.trim()));
        }
      }

      final fuel = _fuelKey(carburant ?? '');
      final out = <_Cand>[];
      for (final r in rows) {
        final gen = (r['generation'] ?? '').toString().trim();

        if (generation != null && gen.toUpperCase() != generation) continue;

        if (fuel.isNotEmpty &&
            _fuelKey((r['carburant'] ?? '').toString()) != fuel) {
          continue;
        }

        if (annee != null) {
          final mn = int.tryParse((r['annee_min'] ?? '').toString());
          final mx = int.tryParse((r['annee_max'] ?? '').toString());
          if (mn != null && annee < mn - 1) continue;
          if (mx != null && annee > mx + 1) continue;
        }

        out.add(_Cand(r['id'].toString(), (r['moteur'] ?? '').toString(), gen));
      }
      return out;
    } catch (e) {
      debugPrint('⚠️ Recherche du véhicule dans le catalogue impossible : $e');
      return [];
    }
  }

  // ============================================
  // CHARGEMENT DE LA FICHE COMPLÈTE
  // ============================================

  Future<Map<String, dynamic>?> _loadFull(
    String id,
    String marque,
    String modele,
    String? carburant,
    int? annee,
    List<_Cand>? cand,
  ) async {
    final supabase = Supabase.instance.client;

    final row =
        await supabase.from('procedures').select().eq('id', id).maybeSingle();
    if (row == null) return null;
    final proc = Map<String, dynamic>.from(row);

    String? notes;
    if ((proc['type'] ?? 'reparation') == 'reparation' &&
        marque.isNotEmpty &&
        modele.isNotEmpty) {
      notes = await _loadNotes(
          proc['id'].toString(), marque, modele, carburant, annee, cand);
    }

    return <String, dynamic>{
      'type': proc['type'] ?? 'reparation',
      'titre': proc['titre'],
      'vehicule': '$marque $modele',
      'duree_estimee': proc['duree_estimee'] ?? 'Non communiquée',
      'difficulte': proc['difficulte'] ?? 'intermediaire',
      'niveau_danger': proc['niveau_danger'] ?? 'faible',
      'public_cible': proc['public_cible'] ?? 'tous',
      'formation_requise': proc['formation_requise'] ?? 'Aucune',
      'outils': proc['outils'] ?? [],
      'pieces': proc['pieces'] ?? [],
      'avertissements_securite': proc['avertissements_securite'] ?? [],
      'avertissements_legaux': proc['avertissements_legaux'] ?? [],
      'etapes': proc['etapes'] ?? [],
      'conseil_final': proc['conseil_final'] ?? '',
      'sources': proc['sources'] ?? ['MecaGo'],
      'notes_specifiques': notes,
      'options_diagnostic': proc['options_diagnostic'],
      'actions_reparation': proc['actions_reparation'],
      'pieges_constructeur': proc['pieges_constructeur'],
    };
  }

  /// Notes propres au véhicule (uniquement celles marquées "verifie").
  ///
  /// SÉCURITÉ : on n'affiche une note que si on est sûr qu'elle correspond à
  /// la voiture. Si plusieurs notes DIFFÉRENTES sont possibles (moteur inconnu),
  /// on n'affiche rien plutôt que de risquer un mauvais couple de serrage.
  Future<String?> _loadNotes(
    String procedureId,
    String marque,
    String modele,
    String? carburant,
    int? annee,
    List<_Cand>? cand,
  ) async {
    try {
      final supabase = Supabase.instance.client;

      var candidates = cand ?? <_Cand>[];
      if (candidates.isEmpty) {
        candidates = await _candidateVehicles(marque, modele, carburant, annee);
      }
      var ids = candidates.map((c) => c.id).toSet();
      if (ids.isEmpty) return null;

      // Si la fiche est liée à des véhicules précis, on ne garde que ceux-là
      final linked = _targets[procedureId];
      if (linked != null && linked.isNotEmpty) {
        final inter = ids.where(linked.contains).toSet();
        if (inter.isNotEmpty) ids = inter;
      }

      final rows = await supabase
          .from('procedures_vehicules')
          .select('notes_specifiques')
          .eq('procedure_id', procedureId)
          .eq('statut', 'verifie')
          .inFilter('vehicule_id', ids.toList());

      final notes = <String>{};
      for (final r in rows) {
        final v = r['notes_specifiques'];
        if (v == null) continue;
        final s = v is String ? v : jsonEncode(v);
        if (s.trim().isEmpty || s.trim() == 'null') continue;
        notes.add(s);
      }

      if (notes.isEmpty) return null;
      if (notes.length > 1) {
        debugPrint(
            'ℹ️ ${notes.length} notes différentes possibles (moteur incertain) → aucune affichée');
        return null;
      }

      debugPrint('✅ Notes spécifiques constructeur vérifiées trouvées !');
      return notes.first;
    } catch (e) {
      debugPrint('⚠️ Erreur récupération notes_specifiques : $e');
      return null;
    }
  }

  // ============================================
  // INTENTION : DIAGNOSTIC (symptôme) OU RÉPARATION (je veux faire X)
  // Sert seulement de petit bonus au classement.
  // ============================================

  String _detectIntent(String question) {
    final text = _norm(question);
    final words =
        text.split(RegExp(r'[^a-z0-9]+')).where((w) => w.isNotEmpty).toList();

    bool start(String p) => words.any((w) => w.startsWith(p));
    bool exact(String w) => words.contains(w);
    bool phrase(String p) => text.contains(p);

    final strong = start('bruit') ||
        start('grincement') ||
        start('claquement') ||
        start('cliquet') ||
        start('raclement') ||
        start('ronronn') ||
        start('cogne') ||
        start('petarad') ||
        start('emball') ||
        start('patine') ||
        start('sifflement') ||
        start('couinement') ||
        start('vibr') ||
        start('tremble') ||
        start('broute') ||
        start('fume') ||
        exact('panne') ||
        exact('pannes') ||
        exact('cale') ||
        exact('coule') ||
        phrase('perte de puissance') ||
        phrase('difficile a demarrer') ||
        phrase('ne demarre pas');
    if (strong) return 'diagnostic';

    final weak = start('voyant') ||
        start('message') ||
        start('erreur') ||
        start('odeur') ||
        start('surchauffe') ||
        start('clignot') ||
        start('mollesse') ||
        start('bip') ||
        exact('chauffe') ||
        exact('allume') ||
        exact('mou') ||
        exact('molle') ||
        exact('dur') ||
        exact('dure');

    final repairVerb = start('remplac') ||
        start('chang') ||
        start('demont') ||
        start('install') ||
        start('vidang') ||
        start('purg') ||
        start('nettoy') ||
        start('regl') ||
        start('depos') ||
        start('reinit');

    if (weak && !repairVerb) return 'diagnostic';
    return 'reparation';
  }

  // ============================================
  // OUTILS
  // ============================================

  /// Prépare un nom pour une recherche "ilike" tolérante aux accents :
  /// chaque lettre accentuée ET chaque "e" devient "_" (joker d'un caractère).
  /// Ainsi "Megane" trouve "Mégane", et "Zoe" trouve "Zoé".
  String _loose(String s) {
    final cleaned = s
        .replaceAll('\\', '')
        .replaceAll('%', '')
        .replaceAll('_', ' ')
        .trim();
    return cleaned
        .replaceAll(RegExp(r'[^\x00-\x7F]'), '_')
        .replaceAll(RegExp(r'[eE]'), '_');
  }

  /// Autres façons d'écrire une marque dans un titre de fiche
  static const Map<String, List<String>> _brandAliases = {
    'volkswagen': ['vw'],
    'vw': ['volkswagen'],
  };

  /// Le titre d'une fiche "moteur précis" cite-t-il la marque ou le modèle
  /// de la voiture ? (mots entiers, sans accents)
  bool _titleTargetsCar(_IndexEntry e, String marque, String modele) {
    String clean(String s) =>
        ' ${_norm(s).replaceAll(RegExp(r'[^a-z0-9]+'), ' ').trim()} ';

    final title = clean(e.titre);

    final brandWords = clean(marque)
        .trim()
        .split(' ')
        .where((w) => w.length >= 2)
        .toList();
    final extra = <String>[];
    for (final w in brandWords) {
      extra.addAll(_brandAliases[w] ?? const []);
    }
    for (final w in [...brandWords, ...extra]) {
      if (title.contains(' $w ')) return true;
    }

    final modeleBase = clean(modele
            .replaceAll(
                RegExp(r'\s+(I|II|III|IV|V|VI|VII|VIII|IX|X)$',
                    caseSensitive: false),
                '')
            .trim())
        .trim();
    if (modeleBase.length >= 2 && title.contains(' $modeleBase ')) return true;

    return false;
  }

  String _fuelKey(String fuel) {
    final f = fuel.toLowerCase().replaceAll('é', 'e').replaceAll('è', 'e');
    if (f.contains('hybrid')) return 'hybride';
    if (f.contains('electri')) return 'electrique';
    if (f.contains('diesel') || f.contains('gazole')) return 'diesel';
    if (f.contains('essence')) return 'essence';
    return f.trim();
  }
}