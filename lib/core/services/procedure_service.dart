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

    // ✅ "sans freiner" devient UN seul mot ("sans_freiner") :
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

  _IndexEntry({
    required this.id,
    required this.titre,
    required this.normTitre,
    required this.type,
    required this.carburantsExclus,
    required this.titleTokens,
    required this.keyTokens,
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
  _Scored(this.entry, this.score, this.coverage, this.precision);

  /// Classement : le score, plus un petit bonus pour la fiche dont le titre
  /// ressemble le plus à la question (départage les égalités)
  double get rank => score + 0.5 * precision;
}

class ProcedureService {
  const ProcedureService();

  static List<_IndexEntry> _index = [];
  static DateTime? _indexAt;

  /// Charge (et garde 5 minutes en mémoire) la liste des fiches VÉRIFIÉES.
  Future<List<_IndexEntry>> _loadIndex() async {
    final now = DateTime.now();
    if (_index.isNotEmpty &&
        _indexAt != null &&
        now.difference(_indexAt!).inMinutes < 5) {
      return _index;
    }

    final rows = await Supabase.instance.client
        .from('procedures')
        .select('id, titre, type, mots_cles, carburants_exclus')
        .eq('statut', 'verifie');

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
        normTitre:
            _norm(titre).replaceAll(RegExp(r'\s+'), ' ').trim(),
        type: (r['type'] ?? 'reparation').toString(),
        carburantsExclus: exclus,
        titleTokens: _tokens(titre),
        keyTokens: mots.expand((m) => _tokens(m)).toList(),
      ));
    }

    _index = list;
    _indexAt = now;
    debugPrint('📇 Index des fiches vérifiées chargé : ${list.length}');
    return list;
  }

  Future<Map<String, dynamic>?> findProcedure({
    required String question,
    required String marque,
    required String modele,
    String? moteur,
    String? carburant,
  }) async {
    try {
      final index = await _loadIndex();
      if (index.isEmpty) {
        debugPrint('ℹ️ Aucune fiche vérifiée dans Supabase → IA');
        return null;
      }

      // 1. TITRE EXACT (clic sur un bouton de diagnostic, par exemple)
      final cleaned = question
          .trim()
          .replaceFirst(RegExp(r'^diagnostic\s*:\s*', caseSensitive: false), '');
      final nq = _norm(cleaned).replaceAll(RegExp(r'\s+'), ' ').trim();
      for (final e in index) {
        if (e.normTitre == nq) {
          debugPrint('🎯 Titre exact trouvé : "${e.titre}"');
          return await _loadFull(e.id, marque, modele, carburant);
        }
      }

      // 2. INTENTION (simple bonus, ne bloque plus la recherche)
      final intent = _detectIntent(question);
      debugPrint('🎯 Intention détectée : $intent');

      // 3. MOTS DE LA QUESTION
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

      // 4. POIDS DES MOTS : un mot rare dans ta base compte plus qu'un mot courant
      final n = index.length;
      final weights = <String, double>{};
      final unknown = <String>[];
      for (final t in qTokens) {
        final df = index.where((e) => e.matches(t)).length;
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

      // 5. SCORE DE CHAQUE FICHE (+ sécurité carburant)
      final fuel = _fuelKey(carburant ?? '');
      final scored = <_Scored>[];
      for (final e in index) {
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

        scored.add(_Scored(e, score, covered / total, precision));
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
      if (best.coverage < 0.6 || best.score < floor) {
        debugPrint('ℹ️ Meilleure fiche trop incertaine → IA prendra le relais');
        return null;
      }

      return await _loadFull(best.entry.id, marque, modele, carburant);
    } catch (e) {
      debugPrint('❌ Erreur ProcedureService : $e');
      return null;
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
      notes = await _loadNotes(proc['id'], marque, modele, carburant);
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
    };
  }

  /// Notes propres au véhicule (uniquement celles marquées "verifie")
  Future<String?> _loadNotes(
    dynamic procedureId,
    String marque,
    String modele,
    String? carburant,
  ) async {
    try {
      final supabase = Supabase.instance.client;

      final modeleClean = modele
          .replaceAll(
              RegExp(r'\s+(I|II|III|IV|V|VI|VII|VIII|IX|X)$',
                  caseSensitive: false),
              '')
          .trim();

      var vQuery = supabase
          .from('vehicules')
          .select('id')
          .ilike('marque', '%${_loose(marque)}%')
          .ilike('modele', '%${_loose(modeleClean)}%');

      if (carburant != null && carburant.isNotEmpty) {
        vQuery = vQuery.ilike('carburant', '%${_loose(carburant)}%');
      }

      final vehiculeData = await vQuery.limit(1).maybeSingle();
      if (vehiculeData == null) return null;

      final pv = await supabase
          .from('procedures_vehicules')
          .select('notes_specifiques')
          .eq('procedure_id', procedureId)
          .eq('vehicule_id', vehiculeData['id'])
          .eq('statut', 'verifie')
          .maybeSingle();

      final v = pv?['notes_specifiques'];
      if (v == null) return null;
      debugPrint('✅ Notes spécifiques constructeur vérifiées trouvées !');
      return v is String ? v : jsonEncode(v);
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

  // Remplace chaque lettre accentuée par "_" (joker d'un caractère)
  String _loose(String s) => s.replaceAll(RegExp(r'[^\x00-\x7F]'), '_');

  String _fuelKey(String fuel) {
    final f = fuel.toLowerCase().replaceAll('é', 'e').replaceAll('è', 'e');
    if (f.contains('hybrid')) return 'hybride';
    if (f.contains('electri')) return 'electrique';
    if (f.contains('diesel') || f.contains('gazole')) return 'diesel';
    if (f.contains('essence')) return 'essence';
    return f.trim();
  }
}