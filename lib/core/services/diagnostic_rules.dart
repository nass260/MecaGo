// lib/core/services/diagnostic_rules.dart

/// Règles de diagnostic en dur (fallback si Gemini échoue)
class DiagnosticRule {
  final List<String> keywords;
  final String title;
  final String description;
  final String severity;
  final List<String> symptoms;
  final List<Map<String, String>> parts;
  final String estimatedCost;
  final bool urgent;

  const DiagnosticRule({
    required this.keywords,
    required this.title,
    required this.description,
    required this.severity,
    required this.symptoms,
    required this.parts,
    required this.estimatedCost,
    required this.urgent,
  });
}

class DiagnosticRules {
  static const List<DiagnosticRule> rules = [
    // ============================================
    // FREINS (10 règles)
    // ============================================
    DiagnosticRule(
      keywords: ['sifflement', 'frein', 'grincement', 'couinement'],
      title: 'Usure des plaquettes de frein',
      description:
          'Les plaquettes de frein avant présentent une usure avancée. '
          'Le sifflement est caractéristique du témoin d\'usure. '
          'Un remplacement est recommandé pour votre sécurité.',
      severity: 'critical',
      symptoms: ['Bruit de sifflement au freinage',
          'Usure > 80% détectée', 'Témoin d\'usure atteint'],
      parts: [
        {'name': 'Plaquettes de frein avant', 'category': 'freinage',
          'price_estimate': '35 - 45 EUR', 'priority': 'urgent'},
      ],
      estimatedCost: '35 - 45 EUR',
      urgent: true,
    ),
    DiagnosticRule(
      keywords: ['pédale', 'molle', 'spongieuse'],
      title: 'Niveau de liquide de frein bas',
      description:
          'Une pédale de frein molle indique généralement un niveau bas '
          'de liquide de frein ou une purge nécessaire. Vérification urgente.',
      severity: 'critical',
      symptoms: ['Pédale de frein molle', 'Freinage moins efficace',
          'Possible fuite'],
      parts: [
        {'name': 'Liquide de frein DOT4', 'category': 'freinage',
          'price_estimate': '10 - 20 EUR', 'priority': 'urgent'},
      ],
      estimatedCost: '50 - 200 EUR',
      urgent: true,
    ),
    DiagnosticRule(
      keywords: ['vibration', 'freinage', 'volant'],
      title: 'Disques de frein voilés',
      description:
          'Les vibrations au freinage indiquent des disques voilés ou usés. '
          'Un remplacement des disques est recommandé.',
      severity: 'high',
      symptoms: ['Vibrations au freinage', 'Volant qui tremble',
          'Freinage irrégulier'],
      parts: [
        {'name': 'Disques de frein avant', 'category': 'freinage',
          'price_estimate': '80 - 150 EUR', 'priority': 'urgent'},
      ],
      estimatedCost: '150 - 300 EUR',
      urgent: true,
    ),
    DiagnosticRule(
      keywords: ['frein', 'tire', 'droite', 'gauche'],
      title: 'Étrier de frein grippé',
      description:
          'La voiture qui tire d\'un côté au freinage indique un étrier '
          'grippé. Un remplacement ou une révision est nécessaire.',
      severity: 'high',
      symptoms: ['Voiture qui tire au freinage', 'Usure inégale',
          'Frein qui chauffe'],
      parts: [
        {'name': 'Étrier de frein', 'category': 'freinage',
          'price_estimate': '120 - 250 EUR', 'priority': 'urgent'},
      ],
      estimatedCost: '150 - 350 EUR',
      urgent: true,
    ),
    DiagnosticRule(
      keywords: ['frein', 'main', 'parking'],
      title: 'Frein à main défaillant',
      description:
          'Le frein à main ne tient plus le véhicule. '
          'Un réglage ou un remplacement des câbles est nécessaire.',
      severity: 'high',
      symptoms: ['Frein à main inefficace', 'Câble détendu',
          'Voyant allumé'],
      parts: [
        {'name': 'Câble de frein à main', 'category': 'freinage',
          'price_estimate': '40 - 90 EUR', 'priority': 'recommended'},
      ],
      estimatedCost: '80 - 180 EUR',
      urgent: false,
    ),
    DiagnosticRule(
      keywords: ['abs', 'voyant'],
      title: 'Défaut du système ABS',
      description:
          'Le voyant ABS allumé indique un défaut dans le système '
          'antiblocage. Un diagnostic électronique est nécessaire.',
      severity: 'high',
      symptoms: ['Voyant ABS allumé', 'Freinage dégradé',
          'Possible capteur HS'],
      parts: [
        {'name': 'Capteur ABS', 'category': 'electrique',
          'price_estimate': '40 - 120 EUR', 'priority': 'urgent'},
      ],
      estimatedCost: '80 - 250 EUR',
      urgent: true,
    ),
    DiagnosticRule(
      keywords: ['frein', 'bruit', 'métallique'],
      title: 'Plaquettes de frein usées à 100%',
      description:
          'Un bruit métallique au freinage indique que les plaquettes '
          'sont complètement usées. Remplacement IMMÉDIAT.',
      severity: 'critical',
      symptoms: ['Bruit métallique', 'Freinage inefficace',
          'Disques possibles endommagés'],
      parts: [
        {'name': 'Kit plaquettes + disques', 'category': 'freinage',
          'price_estimate': '150 - 300 EUR', 'priority': 'urgent'},
      ],
      estimatedCost: '200 - 400 EUR',
      urgent: true,
    ),
    DiagnosticRule(
      keywords: ['frein', 'à main', 'électrique', 'voyant'],
      title: 'Frein de parking électrique défaillant',
      description:
          'Le frein de parking électrique ne répond plus. '
          'Un diagnostic électronique est nécessaire.',
      severity: 'medium',
      symptoms: ['Frein électrique bloqué', 'Voyant allumé',
          'Message d\'erreur'],
      parts: [
        {'name': 'Moteur de frein de parking', 'category': 'electrique',
          'price_estimate': '200 - 500 EUR', 'priority': 'urgent'},
      ],
      estimatedCost: '250 - 600 EUR',
      urgent: true,
    ),
    DiagnosticRule(
      keywords: ['frein', 'chauffe', 'odeur'],
      title: 'Freins qui chauffent',
      description:
          'Les freins qui chauffent excessivement peuvent indiquer '
          'un étrier grippé ou une utilisation intensive. '
          'Vérification recommandée.',
      severity: 'high',
      symptoms: ['Odeur de brûlé', 'Freins très chauds',
          'Perte de puissance au freinage'],
      parts: [
        {'name': 'Kit de réparation étrier', 'category': 'freinage',
          'price_estimate': '50 - 150 EUR', 'priority': 'urgent'},
      ],
      estimatedCost: '100 - 300 EUR',
      urgent: true,
    ),
    DiagnosticRule(
      keywords: ['frein', 'voyant', 'liquide'],
      title: 'Niveau de liquide de frein bas',
      description:
          'Le voyant de liquide de frein est allumé. '
          'Un complément ou une purge est nécessaire.',
      severity: 'high',
      symptoms: ['Voyant liquide de frein', 'Niveau bas',
          'Possible fuite'],
      parts: [
        {'name': 'Liquide de frein DOT4', 'category': 'freinage',
          'price_estimate': '10 - 20 EUR', 'priority': 'urgent'},
      ],
      estimatedCost: '30 - 80 EUR',
      urgent: true,
    ),

    // ============================================
    // MOTEUR (10 règles)
    // ============================================
    DiagnosticRule(
      keywords: ['voyant', 'moteur', 'allumé'],
      title: 'Anomalie moteur détectée',
      description:
          'Le voyant moteur indique une anomalie. '
          'Un diagnostic électronique (OBD) est nécessaire '
          'pour identifier précisément la cause.',
      severity: 'high',
      symptoms: ['Voyant moteur allumé', 'Possible perte de puissance',
          'Consommation potentiellement augmentée'],
      parts: [
        {'name': 'Bougies d\'allumage', 'category': 'moteur',
          'price_estimate': '30 - 60 EUR', 'priority': 'recommended'},
      ],
      estimatedCost: '30 - 100 EUR',
      urgent: true,
    ),
    DiagnosticRule(
      keywords: ['démarre', 'difficile', 'démarrage'],
      title: 'Batterie faible',
      description:
          'Les difficultés de démarrage sont souvent liées '
          'à une batterie faible ou en fin de vie. '
          'Un test de batterie est recommandé.',
      severity: 'high',
      symptoms: ['Démarrage difficile', 'Phares faibles',
          'Bruit de clic au démarrage'],
      parts: [
        {'name': 'Batterie 12V', 'category': 'electrique',
          'price_estimate': '90 - 130 EUR', 'priority': 'urgent'},
      ],
      estimatedCost: '90 - 130 EUR',
      urgent: true,
    ),
    DiagnosticRule(
      keywords: ['fumée', 'blanche', 'échappement'],
      title: 'Joint de culasse possible',
      description:
          'La fumée blanche à l\'échappement peut indiquer '
          'un problème de joint de culasse. '
          'Une vérification urgente est nécessaire.',
      severity: 'critical',
      symptoms: ['Fumée blanche épaisse',
          'Perte de liquide de refroidissement', 'Surchauffe moteur'],
      parts: [
        {'name': 'Joint de culasse', 'category': 'moteur',
          'price_estimate': '500 - 1500 EUR', 'priority': 'urgent'},
      ],
      estimatedCost: '500 - 1500 EUR',
      urgent: true,
    ),
    DiagnosticRule(
      keywords: ['fumée', 'noire', 'échappement'],
      title: 'Mélange trop riche',
      description:
          'La fumée noire indique un mélange trop riche en carburant. '
          'Vérifiez les injecteurs et le filtre à air.',
      severity: 'medium',
      symptoms: ['Fumée noire', 'Consommation élevée',
          'Perte de puissance'],
      parts: [
        {'name': 'Filtre à air', 'category': 'filtration',
          'price_estimate': '15 - 30 EUR', 'priority': 'recommended'},
        {'name': 'Nettoyant injecteurs', 'category': 'moteur',
          'price_estimate': '10 - 25 EUR', 'priority': 'optional'},
      ],
      estimatedCost: '30 - 80 EUR',
      urgent: false,
    ),
    DiagnosticRule(
      keywords: ['consommation', 'carburant', 'élevée'],
      title: 'Filtre à air encrassé',
      description:
          'Une consommation élevée peut être causée par '
          'un filtre à air encrassé ou des bougies usées. '
          'Un remplacement améliorera la consommation.',
      severity: 'medium',
      symptoms: ['Consommation augmentée', 'Perte de puissance',
          'Fumée noire possible'],
      parts: [
        {'name': 'Filtre à air', 'category': 'filtration',
          'price_estimate': '15 - 30 EUR', 'priority': 'recommended'},
        {'name': 'Bougies d\'allumage', 'category': 'moteur',
          'price_estimate': '30 - 60 EUR', 'priority': 'recommended'},
      ],
      estimatedCost: '45 - 90 EUR',
      urgent: false,
    ),
    DiagnosticRule(
      keywords: ['ralenti', 'instable', 'tremble'],
      title: 'Ralenti instable',
      description:
          'Un ralenti instable peut indiquer un problème '
          'd\'allumage ou d\'injection. Vérification recommandée.',
      severity: 'medium',
      symptoms: ['Ralenti instable', 'Moteur qui tremble',
          'Calages fréquents'],
      parts: [
        {'name': 'Bougies d\'allumage', 'category': 'moteur',
          'price_estimate': '30 - 60 EUR', 'priority': 'recommended'},
        {'name': 'Bobines d\'allumage', 'category': 'electrique',
          'price_estimate': '80 - 200 EUR', 'priority': 'recommended'},
      ],
      estimatedCost: '100 - 250 EUR',
      urgent: false,
    ),
    DiagnosticRule(
      keywords: ['surchauffe', 'température', 'chauffe'],
      title: 'Surchauffe moteur',
      description:
          'Le moteur surchauffe. Vérifiez le niveau de liquide '
          'de refroidissement et le thermostat. '
          'Ne roulez PAS dans cet état.',
      severity: 'critical',
      symptoms: ['Température élevée', 'Voyant de surchauffe',
          'Perte de liquide'],
      parts: [
        {'name': 'Thermostat', 'category': 'moteur',
          'price_estimate': '40 - 120 EUR', 'priority': 'urgent'},
        {'name': 'Liquide de refroidissement', 'category': 'moteur',
          'price_estimate': '15 - 35 EUR', 'priority': 'urgent'},
      ],
      estimatedCost: '80 - 250 EUR',
      urgent: true,
    ),
    DiagnosticRule(
      keywords: ['huile', 'voyant', 'pression'],
      title: 'Pression d\'huile basse',
      description:
          'Le voyant de pression d\'huile est allumé. '
          'ARRÊTEZ le moteur immédiatement. '
          'Vérifiez le niveau d\'huile.',
      severity: 'critical',
      symptoms: ['Voyant pression huile', 'Bruit moteur anormal',
          'Fumée possible'],
      parts: [
        {'name': 'Huile moteur 5W30', 'category': 'moteur',
          'price_estimate': '40 - 70 EUR', 'priority': 'urgent'},
        {'name': 'Filtre à huile', 'category': 'filtration',
          'price_estimate': '10 - 20 EUR', 'priority': 'urgent'},
      ],
      estimatedCost: '50 - 120 EUR',
      urgent: true,
    ),
    DiagnosticRule(
      keywords: ['courroie', 'distribution', 'bruit'],
      title: 'Courroie de distribution usée',
      description:
          'La courroie de distribution doit être remplacée '
          'selon les préconisations du constructeur. '
          'Un bruit anormal est un signe d\'usure.',
      severity: 'critical',
      symptoms: ['Bruit de courroie', 'Kilométrage dépassé',
          'Risque de casse moteur'],
      parts: [
        {'name': 'Kit courroie de distribution', 'category': 'moteur',
          'price_estimate': '200 - 500 EUR', 'priority': 'urgent'},
      ],
      estimatedCost: '400 - 900 EUR',
      urgent: true,
    ),
    DiagnosticRule(
      keywords: ['échappement', 'bruit', 'pot'],
      title: 'Échappement percé',
      description:
          'Un bruit fort à l\'échappement indique une fuite ou un pot percé. '
          'Un remplacement est recommandé.',
      severity: 'medium',
      symptoms: ['Bruit fort', 'Fumée anormale', 'Odeur d\'échappement'],
      parts: [
        {'name': 'Silencieux d\'échappement', 'category': 'moteur',
          'price_estimate': '80 - 200 EUR', 'priority': 'recommended'},
      ],
      estimatedCost: '100 - 300 EUR',
      urgent: false,
    ),

    // ============================================
    // ÉLECTRICITÉ (10 règles)
    // ============================================
    DiagnosticRule(
      keywords: ['batterie', 'faible', 'décharge'],
      title: 'Batterie en fin de vie',
      description:
          'La batterie ne tient plus la charge. '
          'Un remplacement est nécessaire.',
      severity: 'high',
      symptoms: ['Démarrage difficile', 'Phares faibles',
          'Voyant batterie'],
      parts: [
        {'name': 'Batterie 12V', 'category': 'electrique',
          'price_estimate': '90 - 130 EUR', 'priority': 'urgent'},
      ],
      estimatedCost: '90 - 130 EUR',
      urgent: true,
    ),
    DiagnosticRule(
      keywords: ['alternateur', 'voyant', 'charge'],
      title: 'Alternateur défaillant',
      description:
          'L\'alternateur ne charge plus la batterie. '
          'Un remplacement est nécessaire.',
      severity: 'critical',
      symptoms: ['Voyant batterie allumé', 'Phares qui faiblissent',
          'Batterie qui se décharge'],
      parts: [
        {'name': 'Alternateur', 'category': 'electrique',
          'price_estimate': '200 - 500 EUR', 'priority': 'urgent'},
      ],
      estimatedCost: '250 - 600 EUR',
      urgent: true,
    ),
    DiagnosticRule(
      keywords: ['démarreur', 'clic', 'démarre'],
      title: 'Démarreur défaillant',
      description:
          'Le démarreur ne lance plus le moteur. '
          'Un remplacement est nécessaire.',
      severity: 'high',
      symptoms: ['Clic au démarrage', 'Moteur ne tourne pas',
          'Bruit anormal'],
      parts: [
        {'name': 'Démarreur', 'category': 'electrique',
          'price_estimate': '150 - 350 EUR', 'priority': 'urgent'},
      ],
      estimatedCost: '200 - 450 EUR',
      urgent: true,
    ),
    DiagnosticRule(
      keywords: ['phare', 'ampoule', 'grillée'],
      title: 'Ampoule grillée',
      description:
          'Une ampoule de phare est grillée. '
          'Un remplacement est nécessaire.',
      severity: 'low',
      symptoms: ['Phare qui ne s\'allume pas', 'Voyant allumé'],
      parts: [
        {'name': 'Ampoule de phare', 'category': 'electrique',
          'price_estimate': '10 - 30 EUR', 'priority': 'recommended'},
      ],
      estimatedCost: '15 - 40 EUR',
      urgent: false,
    ),
    DiagnosticRule(
      keywords: ['clignotant', 'rapide', 'ampoule'],
      title: 'Clignotant défaillant',
      description:
          'Un clignotant clignote trop vite, indiquant '
          'une ampoule grillée. Remplacement nécessaire.',
      severity: 'low',
      symptoms: ['Clignotant rapide', 'Ampoule grillée',
          'Voyant allumé'],
      parts: [
        {'name': 'Ampoule de clignotant', 'category': 'electrique',
          'price_estimate': '5 - 15 EUR', 'priority': 'recommended'},
      ],
      estimatedCost: '10 - 25 EUR',
      urgent: false,
    ),
    DiagnosticRule(
      keywords: ['centrale', 'clignotant', 'défaut'],
      title: 'Centrale clignotante défaillante',
      description:
          'La centrale clignotante est défectueuse. '
          'Un remplacement est nécessaire.',
      severity: 'medium',
      symptoms: ['Clignotants inopérants', 'Bruit anormal',
          'Voyant allumé'],
      parts: [
        {'name': 'Centrale clignotante', 'category': 'electrique',
          'price_estimate': '30 - 80 EUR', 'priority': 'recommended'},
      ],
      estimatedCost: '40 - 100 EUR',
      urgent: false,
    ),
    DiagnosticRule(
      keywords: ['vitre', 'électrique', 'bloquée'],
      title: 'Lève-vitre défaillant',
      description:
          'Le lève-vitre électrique est bloqué. '
          'Un remplacement du moteur est nécessaire.',
      severity: 'low',
      symptoms: ['Vitre bloquée', 'Bruit anormal',
          'Bouton inopérant'],
      parts: [
        {'name': 'Moteur de lève-vitre', 'category': 'electrique',
          'price_estimate': '60 - 150 EUR', 'priority': 'optional'},
      ],
      estimatedCost: '80 - 200 EUR',
      urgent: false,
    ),
    DiagnosticRule(
      keywords: ['capteur', 'stationnement', 'bip'],
      title: 'Capteur de recul défaillant',
      description:
          'Un capteur de recul ne fonctionne plus. '
          'Un remplacement est nécessaire.',
      severity: 'low',
      symptoms: ['Bip continu', 'Capteur inactif',
          'Message d\'erreur'],
      parts: [
        {'name': 'Capteur de recul', 'category': 'electrique',
          'price_estimate': '30 - 80 EUR', 'priority': 'optional'},
      ],
      estimatedCost: '50 - 120 EUR',
      urgent: false,
    ),
    DiagnosticRule(
      keywords: ['écran', 'multimédia', 'bloqué'],
      title: 'Écran multimédia défaillant',
      description:
          'L\'écran multimédia est bloqué ou ne s\'allume plus. '
          'Un redémarrage ou un remplacement est nécessaire.',
      severity: 'low',
      symptoms: ['Écran noir', 'Système bloqué', 'Redémarrages'],
      parts: [
        {'name': 'Unité multimédia', 'category': 'electrique',
          'price_estimate': '200 - 800 EUR', 'priority': 'optional'},
      ],
      estimatedCost: '250 - 900 EUR',
      urgent: false,
    ),
    DiagnosticRule(
      keywords: ['clé', 'télécommande', 'fonctionne'],
      title: 'Pile de télécommande faible',
      description:
          'La télécommande ne fonctionne plus correctement. '
          'Un remplacement de pile est nécessaire.',
      severity: 'low',
      symptoms: ['Télécommande inopérante', 'Portée réduite',
          'Voyant faible'],
      parts: [
        {'name': 'Pile de télécommande', 'category': 'electrique',
          'price_estimate': '3 - 8 EUR', 'priority': 'recommended'},
      ],
      estimatedCost: '5 - 15 EUR',
      urgent: false,
    ),

    // ============================================
    // CLIMATISATION (10 règles)
    // ============================================
    DiagnosticRule(
      keywords: ['clim', 'froid', 'refroidit'],
      title: 'Recharge de climatisation nécessaire',
      description:
          'La climatisation qui ne refroidit plus nécessite '
          'probablement une recharge de gaz. '
          'Un filtre habitacle neuf est aussi recommandé.',
      severity: 'low',
      symptoms: ['Air moins froid', 'Mauvaise odeur',
          'Compresseur bruyant'],
      parts: [
        {'name': 'Recharge de clim', 'category': 'filtration',
          'price_estimate': '60 - 120 EUR', 'priority': 'recommended'},
        {'name': 'Filtre habitacle', 'category': 'filtration',
          'price_estimate': '15 - 30 EUR', 'priority': 'recommended'},
      ],
      estimatedCost: '80 - 150 EUR',
      urgent: false,
    ),
    DiagnosticRule(
      keywords: ['clim', 'chauffe', 'chaud'],
      title: 'Chauffage défaillant',
      description:
          'Le chauffage ne fonctionne plus. '
          'Vérifiez le radiateur de chauffage et le thermostat.',
      severity: 'medium',
      symptoms: ['Air froid', 'Moteur qui chauffe',
          'Voyant allumé'],
      parts: [
        {'name': 'Radiateur de chauffage', 'category': 'moteur',
          'price_estimate': '80 - 250 EUR', 'priority': 'recommended'},
      ],
      estimatedCost: '120 - 350 EUR',
      urgent: false,
    ),
    DiagnosticRule(
      keywords: ['clim', 'odeur', 'mauvais'],
      title: 'Filtre habitacle encrassé',
      description:
          'Une mauvaise odeur dans l\'habitacle indique '
          'un filtre habitacle encrassé. '
          'Un remplacement est recommandé.',
      severity: 'low',
      symptoms: ['Mauvaise odeur', 'Air moins puissant',
          'Allergies'],
      parts: [
        {'name': 'Filtre habitacle', 'category': 'filtration',
          'price_estimate': '15 - 30 EUR', 'priority': 'recommended'},
      ],
      estimatedCost: '20 - 40 EUR',
      urgent: false,
    ),
    DiagnosticRule(
      keywords: ['clim', 'compresseur', 'bruit'],
      title: 'Compresseur de clim bruyant',
      description:
          'Le compresseur de climatisation fait un bruit anormal. '
          'Un diagnostic est nécessaire.',
      severity: 'medium',
      symptoms: ['Bruit au démarrage clim', 'Vibrations',
          'Clim inefficace'],
      parts: [
        {'name': 'Compresseur de clim', 'category': 'moteur',
          'price_estimate': '300 - 800 EUR', 'priority': 'urgent'},
      ],
      estimatedCost: '400 - 1000 EUR',
      urgent: true,
    ),
    DiagnosticRule(
      keywords: ['clim', 'fuite', 'gaz'],
      title: 'Fuite de gaz de clim',
      description:
          'Une fuite de gaz empêche la clim de fonctionner. '
          'Un diagnostic d\'étanchéité est nécessaire.',
      severity: 'medium',
      symptoms: ['Clim inefficace', 'Recharge fréquente',
          'Traces d\'huile'],
      parts: [
        {'name': 'Détection de fuite', 'category': 'filtration',
          'price_estimate': '40 - 80 EUR', 'priority': 'recommended'},
      ],
      estimatedCost: '60 - 150 EUR',
      urgent: false,
    ),
    DiagnosticRule(
      keywords: ['désembuage', 'buée', 'pare-brise'],
      title: 'Désembuage inefficace',
      description:
          'Le désembuage ne fonctionne plus correctement. '
          'Vérifiez le filtre habitacle et la clim.',
      severity: 'low',
      symptoms: ['Buée persistante', 'Air humide',
          'Mauvaise visibilité'],
      parts: [
        {'name': 'Filtre habitacle', 'category': 'filtration',
          'price_estimate': '15 - 30 EUR', 'priority': 'recommended'},
      ],
      estimatedCost: '20 - 40 EUR',
      urgent: false,
    ),
    DiagnosticRule(
      keywords: ['ventilation', 'souffle', 'puissance'],
      title: 'Ventilation faible',
      description:
          'La ventilation souffle faiblement. '
          'Vérifiez le filtre habitacle et le pulseur.',
      severity: 'low',
      symptoms: ['Souffle faible', 'Bruit de ventilation',
          'Odeur'],
      parts: [
        {'name': 'Filtre habitacle', 'category': 'filtration',
          'price_estimate': '15 - 30 EUR', 'priority': 'recommended'},
      ],
      estimatedCost: '20 - 50 EUR',
      urgent: false,
    ),
    DiagnosticRule(
      keywords: ['clim', 'voyant', 'erreur'],
      title: 'Erreur système de clim',
      description:
          'Le voyant de climatisation clignote. '
          'Un diagnostic électronique est nécessaire.',
      severity: 'medium',
      symptoms: ['Voyant clignotant', 'Clim inopérante',
          'Message d\'erreur'],
      parts: [
        {'name': 'Diagnostic clim', 'category': 'electrique',
          'price_estimate': '50 - 100 EUR', 'priority': 'recommended'},
      ],
      estimatedCost: '80 - 200 EUR',
      urgent: false,
    ),
    DiagnosticRule(
      keywords: ['condenseur', 'clim', 'encrassé'],
      title: 'Condenseur de clim encrassé',
      description:
          'Le condenseur de climatisation est encrassé. '
          'Un nettoyage est recommandé.',
      severity: 'low',
      symptoms: ['Clim moins efficace', 'Surchauffe moteur',
          'Bruit anormal'],
      parts: [
        {'name': 'Nettoyant condenseur', 'category': 'filtration',
          'price_estimate': '10 - 25 EUR', 'priority': 'optional'},
      ],
      estimatedCost: '15 - 40 EUR',
      urgent: false,
    ),
    DiagnosticRule(
      keywords: ['clim', 'automatique', 'régulation'],
      title: 'Régulation de clim défaillante',
      description:
          'La régulation automatique de la clim est défaillante. '
          'Un capteur ou le module est en cause.',
      severity: 'medium',
      symptoms: ['Température instable', 'Clim qui oscille',
          'Bruit anormal'],
      parts: [
        {'name': 'Capteur de température habitacle', 'category': 'electrique',
          'price_estimate': '30 - 80 EUR', 'priority': 'recommended'},
      ],
      estimatedCost: '50 - 120 EUR',
      urgent: false,
    ),

    // ============================================
    // SUSPENSION & DIRECTION (10 règles)
    // ============================================
    DiagnosticRule(
      keywords: ['vibration', 'volant', 'vitesse'],
      title: 'Déséquilibre des roues',
      description:
          'Les vibrations dans le volant indiquent probablement '
          'un déséquilibre des roues avant ou un problème '
          'd\'amortisseurs. Un équilibrage est recommandé.',
      severity: 'medium',
      symptoms: ['Vibrations dans le volant',
          'Apparition à vitesse élevée', 'Usure irrégulière des pneus'],
      parts: [
        {'name': 'Équilibrage des roues', 'category': 'suspension',
          'price_estimate': '20 - 40 EUR', 'priority': 'recommended'},
      ],
      estimatedCost: '80 - 160 EUR',
      urgent: false,
    ),
    DiagnosticRule(
      keywords: ['amortisseur', 'rebond', 'suspension'],
      title: 'Amortisseurs usés',
      description:
          'Les amortisseurs sont usés, ce qui affecte la tenue de route. '
          'Un remplacement est recommandé.',
      severity: 'medium',
      symptoms: ['Voiture qui rebondit', 'Tenue de route dégradée',
          'Usure pneus irrégulière'],
      parts: [
        {'name': 'Amortisseurs avant (x2)', 'category': 'suspension',
          'price_estimate': '120 - 250 EUR', 'priority': 'recommended'},
      ],
      estimatedCost: '200 - 450 EUR',
      urgent: false,
    ),
    DiagnosticRule(
      keywords: ['direction', 'dure', 'braque'],
      title: 'Direction dure',
      description:
          'La direction est dure, ce qui peut indiquer un problème '
          'de direction assistée. Vérifiez le niveau de liquide.',
      severity: 'high',
      symptoms: ['Direction dure', 'Bruit à la rotation',
          'Fuite possible'],
      parts: [
        {'name': 'Liquide de direction assistée', 'category': 'moteur',
          'price_estimate': '10 - 25 EUR', 'priority': 'urgent'},
      ],
      estimatedCost: '30 - 100 EUR',
      urgent: true,
    ),
    DiagnosticRule(
      keywords: ['direction', 'bruit', 'claquement'],
      title: 'Rotules de direction usées',
      description:
          'Un claquement dans la direction indique des rotules usées. '
          'Un remplacement est nécessaire.',
      severity: 'high',
      symptoms: ['Claquement', 'Jeu dans la direction',
          'Vibrations'],
      parts: [
        {'name': 'Rotules de direction', 'category': 'suspension',
          'price_estimate': '60 - 150 EUR', 'priority': 'urgent'},
      ],
      estimatedCost: '80 - 200 EUR',
      urgent: true,
    ),
    DiagnosticRule(
      keywords: ['pneu', 'usure', 'irrégulière'],
      title: 'Usure irrégulière des pneus',
      description:
          'Les pneus s\'usent irrégulièrement, ce qui indique '
          'un problème de géométrie ou de suspension.',
      severity: 'medium',
      symptoms: ['Usure irrégulière', 'Bruit de roulement',
          'Tenue de route dégradée'],
      parts: [
        {'name': 'Géométrie complète', 'category': 'suspension',
          'price_estimate': '60 - 120 EUR', 'priority': 'recommended'},
      ],
      estimatedCost: '80 - 150 EUR',
      urgent: false,
    ),
    DiagnosticRule(
      keywords: ['pneu', 'crevé', 'pression'],
      title: 'Pneu crevé ou sous-gonflé',
      description:
          'Un pneu est crevé ou sous-gonflé. '
          'Vérifiez la pression et réparez.',
      severity: 'high',
      symptoms: ['Pneu à plat', 'Voyant pression',
          'Direction qui tire'],
      parts: [
        {'name': 'Réparation pneu', 'category': 'pneumatiques',
          'price_estimate': '20 - 50 EUR', 'priority': 'urgent'},
      ],
      estimatedCost: '30 - 80 EUR',
      urgent: true,
    ),
    DiagnosticRule(
      keywords: ['roulement', 'bruit', 'roue'],
      title: 'Roulement de roue usé',
      description:
          'Un bruit de roulement indique un roulement usé. '
          'Un remplacement est nécessaire.',
      severity: 'high',
      symptoms: ['Bruit de roulement', 'Vibrations',
          'Bruit qui augmente en virage'],
      parts: [
        {'name': 'Roulement de roue', 'category': 'suspension',
          'price_estimate': '80 - 200 EUR', 'priority': 'urgent'},
      ],
      estimatedCost: '120 - 280 EUR',
      urgent: true,
    ),
    DiagnosticRule(
      keywords: ['barre', 'stabilisatrice', 'bruit'],
      title: 'Barre stabilisatrice usée',
      description:
          'Un bruit sourd dans les virages indique une barre '
          'stabilisatrice usée. Remplacement recommandé.',
      severity: 'medium',
      symptoms: ['Bruit sourd en virage', 'Tenue de route dégradée',
          'Vibrations'],
      parts: [
        {'name': 'Barre stabilisatrice', 'category': 'suspension',
          'price_estimate': '60 - 150 EUR', 'priority': 'recommended'},
      ],
      estimatedCost: '100 - 250 EUR',
      urgent: false,
    ),
    DiagnosticRule(
      keywords: ['cardan', 'claquement', 'virage'],
      title: 'Cardan usé',
      description:
          'Un claquement dans les virages indique un cardan usé. '
          'Un remplacement est nécessaire.',
      severity: 'high',
      symptoms: ['Claquement en virage', 'Vibrations',
          'Graisse visible'],
      parts: [
        {'name': 'Cardan', 'category': 'suspension',
          'price_estimate': '150 - 350 EUR', 'priority': 'urgent'},
      ],
      estimatedCost: '200 - 450 EUR',
      urgent: true,
    ),
    DiagnosticRule(
      keywords: ['parallélisme', 'tire', 'droite'],
      title: 'Parallélisme à refaire',
      description:
          'La voiture tire d\'un côté. Un parallélisme est nécessaire.',
      severity: 'medium',
      symptoms: ['Voiture qui tire', 'Usure irrégulière',
          'Volant pas centré'],
      parts: [
        {'name': 'Parallélisme', 'category': 'suspension',
          'price_estimate': '50 - 100 EUR', 'priority': 'recommended'},
      ],
      estimatedCost: '60 - 120 EUR',
      urgent: false,
    ),
  ];

  /// Trouve la règle correspondant au symptôme
  static DiagnosticRule? findRule(String symptom) {
    final lower = symptom.toLowerCase();
    for (final rule in rules) {
      for (final keyword in rule.keywords) {
        if (lower.contains(keyword)) {
          return rule;
        }
      }
    }
    return null;
  }
}