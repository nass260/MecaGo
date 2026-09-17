// lib/core/services/engine_database.dart

/// Base de données des motorisations par marque + modèle
/// Couvre les principaux véhicules du parc automobile français
class EngineDatabase {
  /// Récupère les motorisations pour une marque + modèle
  static List<String> getEngines(String brand, String model) {
    final key = '${brand.toLowerCase()}_${model.toLowerCase()}';

    // Cherche une correspondance exacte
    if (_database.containsKey(key)) {
      return _database[key]!;
    }

    // Cherche par marque seule
    final brandKey = brand.toLowerCase();
    if (_brandEngines.containsKey(brandKey)) {
      return _brandEngines[brandKey]!;
    }

    // Motorisations génériques par défaut
    return ['1.0', '1.2', '1.4', '1.6', '2.0'];
  }

  /// Base de données complète : marque_modèle → motorisations
  static final Map<String, List<String>> _database = {
    // ===== RENAULT =====
    'renault_clio': ['1.0 SCe 65ch', '1.0 TCe 90ch', '1.0 TCe 100ch', '1.3 TCe 140ch', '1.5 Blue dCi 85ch', '1.5 Blue dCi 100ch', '1.6 E-Tech 140ch Hybride'],
    'renault_clio 5': ['1.0 SCe 65ch', '1.0 TCe 90ch', '1.0 TCe 100ch', '1.3 TCe 140ch', '1.5 Blue dCi 85ch', '1.5 Blue dCi 100ch', '1.6 E-Tech 140ch Hybride'],
    'renault_captur': ['1.0 TCe 100ch', '1.3 TCe 140ch', '1.5 Blue dCi 95ch', '1.5 Blue dCi 115ch', '1.6 E-Tech 160ch Hybride'],
    'renault_megane': ['1.3 TCe 115ch', '1.3 TCe 140ch', '1.5 Blue dCi 110ch', '1.5 Blue dCi 115ch', '1.6 E-Tech 160ch Hybride'],
    'renault_zoe': ['R110 52 kWh', 'R135 52 kWh', 'R135 52 kWh Rapid'],
    'renault_twingo': ['1.0 SCe 65ch', '1.0 SCe 70ch', '0.9 TCe 90ch'],
    'renault_kangoo': ['1.3 TCe 100ch', '1.5 Blue dCi 95ch', '1.5 Blue dCi 115ch', 'E-Tech 100% Électrique'],
    'renault_megane e-tech': ['EV60 220ch', 'EV40 130ch'],

    // ===== PEUGEOT =====
    'peugeot_208': ['1.2 PureTech 75ch', '1.2 PureTech 100ch', '1.2 PureTech 130ch', '1.5 BlueHDi 100ch', '1.5 BlueHDi 130ch', 'e-208 136ch Électrique', 'e-208 156ch Électrique'],
    'peugeot_208 ii': ['1.2 PureTech 75ch', '1.2 PureTech 100ch', '1.2 PureTech 130ch', '1.5 BlueHDi 100ch', '1.5 BlueHDi 130ch', 'e-208 136ch Électrique', 'e-208 156ch Électrique'],
    'peugeot_2008': ['1.2 PureTech 100ch', '1.2 PureTech 130ch', '1.5 BlueHDi 110ch', '1.5 BlueHDi 130ch', 'e-2008 136ch Électrique', 'e-2008 156ch Électrique'],
    'peugeot_2008 ii': ['1.2 PureTech 100ch', '1.2 PureTech 130ch', '1.5 BlueHDi 110ch', '1.5 BlueHDi 130ch', 'e-2008 136ch Électrique', 'e-2008 156ch Électrique'],
    'peugeot_308': ['1.2 PureTech 110ch', '1.2 PureTech 130ch', '1.5 BlueHDi 130ch', '1.6 PureTech 225ch', 'Hybride 180ch', 'Hybride 225ch'],
    'peugeot_308 iii': ['1.2 PureTech 110ch', '1.2 PureTech 130ch', '1.5 BlueHDi 130ch', '1.6 PureTech 225ch', 'Hybride 180ch', 'Hybride 225ch'],
    'peugeot_3008': ['1.2 PureTech 130ch', '1.5 BlueHDi 130ch', '1.6 PureTech 180ch', '2.0 BlueHDi 180ch', 'Hybride 225ch'],
    'peugeot_3008 ii': ['1.2 PureTech 130ch', '1.5 BlueHDi 130ch', '1.6 PureTech 180ch', '2.0 BlueHDi 180ch', 'Hybride 225ch'],
    'peugeot_5008': ['1.2 PureTech 130ch', '1.5 BlueHDi 130ch', '1.6 PureTech 180ch', '2.0 BlueHDi 180ch'],
    'peugeot_508': ['1.5 BlueHDi 130ch', '1.6 PureTech 180ch', '2.0 BlueHDi 160ch', 'Hybride 225ch'],
    'peugeot_rifter': ['1.2 PureTech 110ch', '1.5 BlueHDi 100ch', '1.5 BlueHDi 130ch'],
    'peugeot_partner': ['1.2 PureTech 110ch', '1.5 BlueHDi 100ch', '1.5 BlueHDi 130ch'],
    'peugeot_expert': ['1.5 BlueHDi 95ch', '1.5 BlueHDi 120ch', '2.0 BlueHDi 150ch'],
    'peugeot_boxer': ['2.2 HDi 120ch', '2.2 HDi 140ch', '2.2 HDi 165ch', '3.0 HDi 177ch'],

    // ===== CITROEN =====
    'citroen_c3': ['1.2 PureTech 82ch', '1.2 PureTech 110ch', '1.5 BlueHDi 100ch'],
    'citroen_c3 iii': ['1.2 PureTech 82ch', '1.2 PureTech 110ch', '1.5 BlueHDi 100ch'],
    'citroen_c3 aircross': ['1.2 PureTech 110ch', '1.2 PureTech 130ch', '1.5 BlueHDi 110ch', '1.5 BlueHDi 120ch'],
    'citroen_c4': ['1.2 PureTech 130ch', '1.5 BlueHDi 130ch', 'ë-C4 136ch Électrique', 'ë-C4 156ch Électrique'],
    'citroen_c4 iii': ['1.2 PureTech 130ch', '1.5 BlueHDi 130ch', 'ë-C4 136ch Électrique', 'ë-C4 156ch Électrique'],
    'citroen_c5 aircross': ['1.2 PureTech 130ch', '1.5 BlueHDi 130ch', '2.0 BlueHDi 180ch', 'Hybride 225ch'],
    'citroen_c5 x': ['1.2 PureTech 130ch', '1.6 PureTech 180ch', 'Hybride 225ch'],
    'citroen_berlingo': ['1.2 PureTech 110ch', '1.5 BlueHDi 100ch', '1.5 BlueHDi 130ch'],
    'citroen_berlingo iii': ['1.2 PureTech 110ch', '1.5 BlueHDi 100ch', '1.5 BlueHDi 130ch'],
    'citroen_jumpy': ['1.5 BlueHDi 95ch', '1.5 BlueHDi 120ch', '2.0 BlueHDi 150ch'],
    'citroen_jumper': ['2.2 HDi 120ch', '2.2 HDi 140ch', '2.2 HDi 165ch', '3.0 HDi 177ch'],

    // ===== DACIA =====
    'dacia_sandero': ['1.0 SCe 65ch', '1.0 TCe 90ch', '1.0 TCe 100ch GPL', '1.5 Blue dCi 95ch'],
    'dacia_sandero iii': ['1.0 SCe 65ch', '1.0 TCe 90ch', '1.0 TCe 100ch GPL', '1.5 Blue dCi 95ch'],
    'dacia_duster': ['1.0 TCe 100ch', '1.0 TCe 130ch GPL', '1.3 TCe 130ch', '1.5 Blue dCi 115ch', '1.5 Blue dCi 95ch'],
    'dacia_duster ii': ['1.0 TCe 100ch', '1.0 TCe 130ch GPL', '1.3 TCe 130ch', '1.5 Blue dCi 115ch', '1.5 Blue dCi 95ch'],
    'dacia_logan': ['1.0 SCe 65ch', '1.0 TCe 90ch', '1.0 TCe 100ch GPL'],
    'dacia_jogger': ['1.0 TCe 90ch', '1.0 TCe 110ch', '1.0 TCe 100ch GPL', 'Hybride 140ch'],
    'dacia_spring': ['Electric 45ch', 'Electric 65ch'],

    // ===== TOYOTA =====
    'toyota_yaris': ['1.0 72ch', '1.5 125ch', '1.5 Hybride 116ch', '1.5 Hybride 130ch'],
    'toyota_yaris iv': ['1.0 72ch', '1.5 125ch', '1.5 Hybride 116ch', '1.5 Hybride 130ch'],
    'toyota_corolla': ['1.8 Hybride 122ch', '2.0 Hybride 180ch', '1.2 Turbo 116ch'],
    'toyota_corolla xii': ['1.8 Hybride 122ch', '2.0 Hybride 180ch', '1.2 Turbo 116ch'],
    'toyota_rav4': ['2.0 175ch', '2.5 Hybride 218ch', '2.5 Hybride 222ch', '2.5 Hybride 306ch'],
    'toyota_rav4 v': ['2.0 175ch', '2.5 Hybride 218ch', '2.5 Hybride 222ch', '2.5 Hybride 306ch'],
    'toyota_c-hr': ['1.2 Turbo 116ch', '1.8 Hybride 122ch', '2.0 Hybride 184ch'],
    'toyota_prius': ['1.8 Hybride 122ch', '2.0 Hybride 196ch'],
    'toyota_aygo': ['1.0 VVT-i 72ch'],
    'toyota_aygo x': ['1.0 VVT-i 72ch'],
    'toyota_hilux': ['2.4 D-4D 150ch', '2.8 D-4D 204ch'],
    'toyota_proace': ['1.5 BlueHDi 100ch', '1.5 BlueHDi 120ch', '2.0 BlueHDi 145ch'],

    // ===== VOLKSWAGEN =====
    'volkswagen_golf': ['1.0 TSI 110ch', '1.5 TSI 130ch', '1.5 TSI 150ch', '2.0 TDI 115ch', '2.0 TDI 150ch', '2.0 TSI GTI 245ch', '2.0 TSI R 320ch'],
    'volkswagen_golf viii': ['1.0 TSI 110ch', '1.5 TSI 130ch', '1.5 TSI 150ch', '2.0 TDI 115ch', '2.0 TDI 150ch', '2.0 TSI GTI 245ch', '2.0 TSI R 320ch'],
    'volkswagen_polo': ['1.0 TSI 95ch', '1.0 TSI 110ch', '2.0 TSI GTI 207ch'],
    'volkswagen_polo vi': ['1.0 TSI 95ch', '1.0 TSI 110ch', '2.0 TSI GTI 207ch'],
    'volkswagen_tiguan': ['1.5 TSI 130ch', '1.5 TSI 150ch', '2.0 TDI 150ch', '2.0 TDI 200ch'],
    'volkswagen_tiguan ii': ['1.5 TSI 130ch', '1.5 TSI 150ch', '2.0 TDI 150ch', '2.0 TDI 200ch'],
    'volkswagen_t-roc': ['1.0 TSI 110ch', '1.5 TSI 150ch', '2.0 TDI 150ch', '2.0 TSI R 300ch'],
    'volkswagen_t-cross': ['1.0 TSI 95ch', '1.0 TSI 110ch', '1.5 TSI 150ch'],
    'volkswagen_passat': ['1.5 TSI 150ch', '2.0 TDI 150ch', '2.0 TDI 200ch', 'GTE Hybride 218ch'],

    // ===== AUDI =====
    'audi_a1': ['25 TFSI 95ch', '30 TFSI 110ch', '35 TFSI 150ch'],
    'audi_a3': ['30 TFSI 110ch', '35 TFSI 150ch', '35 TDI 150ch', '40 TFSI 190ch', '40 TDI 200ch'],
    'audi_a3 8y': ['30 TFSI 110ch', '35 TFSI 150ch', '35 TDI 150ch', '40 TFSI 190ch', '40 TDI 200ch'],
    'audi_a4': ['35 TFSI 150ch', '40 TFSI 190ch', '40 TDI 190ch', '45 TFSI 245ch'],
    'audi_a5': ['35 TFSI 150ch', '40 TFSI 190ch', '40 TDI 190ch'],
    'audi_a6': ['40 TFSI 190ch', '45 TFSI 245ch', '40 TDI 204ch', '45 TDI 231ch', '55 TFSI 340ch'],
    'audi_q2': ['30 TFSI 116ch', '35 TFSI 150ch', '30 TDI 116ch'],
    'audi_q3': ['35 TFSI 150ch', '40 TFSI 190ch', '35 TDI 150ch', '40 TDI 200ch'],
    'audi_q3 f3': ['35 TFSI 150ch', '40 TFSI 190ch', '35 TDI 150ch', '40 TDI 200ch'],
    'audi_q5': ['40 TFSI 204ch', '45 TFSI 265ch', '40 TDI 204ch', '50 TDI 286ch'],
    'audi_q7': ['45 TFSI 340ch', '50 TDI 286ch', '55 TFSI 340ch'],

    // ===== BMW =====
    'bmw_serie 1': ['116i 109ch', '118i 136ch', '120i 178ch', '116d 116ch', '118d 150ch', '120d 190ch'],
    'bmw_serie 1 f40': ['116i 109ch', '118i 136ch', '120i 178ch', '116d 116ch', '118d 150ch', '120d 190ch'],
    'bmw_serie 2': ['218i 136ch', '220i 178ch', '218d 150ch', '220d 190ch'],
    'bmw_serie 3': ['318i 156ch', '320i 184ch', '330i 258ch', '318d 150ch', '320d 190ch', '330d 265ch', '330e Hybride 292ch'],
    'bmw_serie 3 g20': ['318i 156ch', '320i 184ch', '330i 258ch', '318d 150ch', '320d 190ch', '330d 265ch', '330e Hybride 292ch'],
    'bmw_serie 5': ['520i 184ch', '530i 252ch', '520d 190ch', '530d 265ch', '530e Hybride 292ch'],
    'bmw_x1': ['sDrive18i 136ch', 'sDrive20i 178ch', 'sDrive18d 150ch', 'xDrive20d 190ch', 'xDrive25e Hybride 220ch'],
    'bmw_x1 f48': ['sDrive18i 136ch', 'sDrive20i 178ch', 'sDrive18d 150ch', 'xDrive20d 190ch'],
    'bmw_x2': ['sDrive18i 136ch', 'sDrive20i 178ch', 'sDrive18d 150ch'],
    'bmw_x3': ['sDrive20i 184ch', 'xDrive30i 252ch', 'xDrive20d 190ch', 'xDrive30d 286ch'],
    'bmw_x4': ['xDrive20i 184ch', 'xDrive30i 252ch', 'xDrive20d 190ch', 'xDrive30d 265ch'],
    'bmw_x5': ['xDrive40i 340ch', 'xDrive30d 265ch', 'xDrive40d 340ch', 'xDrive45e Hybride 394ch'],
    'bmw_i3': ['i3 170ch Électrique', 'i3s 184ch Électrique'],
    'bmw_i4': ['eDrive40 340ch', 'M50 544ch'],
    'bmw_ix': ['xDrive40 326ch', 'xDrive50 523ch', 'M60 619ch'],
    'bmw_ix3': ['iX3 286ch Électrique'],

    // ===== MERCEDES =====
    'mercedes_classe a': ['A 180 136ch', 'A 200 163ch', 'A 250 224ch', 'A 180 d 116ch', 'A 200 d 150ch', 'A 250 e Hybride 218ch'],
    'mercedes_classe a w177': ['A 180 136ch', 'A 200 163ch', 'A 250 224ch', 'A 180 d 116ch', 'A 200 d 150ch', 'A 250 e Hybride 218ch'],
    'mercedes_classe b': ['B 180 136ch', 'B 200 163ch', 'B 180 d 116ch', 'B 200 d 150ch'],
    'mercedes_classe c': ['C 180 156ch', 'C 200 204ch', 'C 300 258ch', 'C 220 d 200ch', 'C 300 d 265ch', 'C 300 e Hybride 320ch'],
    'mercedes_classe c w206': ['C 180 156ch', 'C 200 204ch', 'C 300 258ch', 'C 220 d 200ch', 'C 300 d 265ch', 'C 300 e Hybride 320ch'],
    'mercedes_classe e': ['E 200 197ch', 'E 300 258ch', 'E 220 d 197ch', 'E 300 d 265ch', 'E 300 e Hybride 320ch'],
    'mercedes_classe s': ['S 450 367ch', 'S 500 435ch', 'S 350 d 286ch', 'S 400 d 330ch', 'S 580 e Hybride 510ch'],
    'mercedes_gla': ['GLA 200 163ch', 'GLA 250 224ch', 'GLA 200 d 150ch', 'GLA 250 e Hybride 218ch'],
    'mercedes_glb': ['GLB 200 163ch', 'GLB 250 224ch', 'GLB 200 d 150ch', 'GLB 220 d 190ch'],
    'mercedes_glc': ['GLC 200 197ch', 'GLC 300 258ch', 'GLC 220 d 197ch', 'GLC 300 d 245ch', 'GLC 300 e Hybride 320ch'],
    'mercedes_gle': ['GLE 350 367ch', 'GLE 450 381ch', 'GLE 300 d 245ch', 'GLE 350 d 272ch', 'GLE 400 d 330ch'],
    'mercedes_sprinter': ['211 CDI 114ch', '214 CDI 143ch', '216 CDI 163ch', '219 CDI 190ch'],

    // ===== FORD =====
    'ford_fiesta': ['1.0 EcoBoost 85ch', '1.0 EcoBoost 100ch', '1.0 EcoBoost 125ch', '1.5 TDCi 85ch', '1.5 TDCi 120ch'],
    'ford_fiesta vii': ['1.0 EcoBoost 85ch', '1.0 EcoBoost 100ch', '1.0 EcoBoost 125ch', '1.5 TDCi 85ch', '1.5 TDCi 120ch'],
    'ford_focus': ['1.0 EcoBoost 100ch', '1.0 EcoBoost 125ch', '1.5 EcoBoost 150ch', '1.5 EcoBlue 95ch', '1.5 EcoBlue 120ch', '2.0 ST 280ch'],
    'ford_focus iv': ['1.0 EcoBoost 100ch', '1.0 EcoBoost 125ch', '1.5 EcoBoost 150ch', '1.5 EcoBlue 95ch', '1.5 EcoBlue 120ch', '2.0 ST 280ch'],
    'ford_puma': ['1.0 EcoBoost 125ch', '1.0 EcoBoost 155ch', '1.5 EcoBlue 120ch', '1.0 EcoBoost Hybrid 125ch'],
    'ford_kuga': ['1.5 EcoBlue 120ch', '2.0 EcoBlue 150ch', '2.5 Hybride 190ch', '2.5 Hybride 225ch'],
    'ford_kuga iii': ['1.5 EcoBlue 120ch', '2.0 EcoBlue 150ch', '2.5 Hybride 190ch', '2.5 Hybride 225ch'],
    'ford_mustang mach-e': ['Standard Range RWD 269ch', 'Extended Range RWD 294ch', 'Extended Range AWD 351ch', 'GT 487ch'],
    'ford_transit': ['2.0 EcoBlue 105ch', '2.0 EcoBlue 130ch', '2.0 EcoBlue 170ch'],
    'ford_transit custom': ['2.0 EcoBlue 105ch', '2.0 EcoBlue 130ch', '2.0 EcoBlue 170ch'],
    'ford_ranger': ['2.0 EcoBlue 130ch', '2.0 EcoBlue 170ch', '2.0 EcoBlue 210ch', '3.0 V6 240ch'],
    'ford_f-150': ['3.3 V6 290ch', '2.7 EcoBoost 325ch', '5.0 V8 400ch', '3.5 EcoBoost 375ch'],
    'ford_mustang': ['2.3 EcoBoost 290ch', '5.0 V8 450ch', '5.0 V8 460ch'],

    // ===== OPEL =====
    'opel_corsa': ['1.2 75ch', '1.2 Turbo 100ch', '1.2 Turbo 130ch', '1.5 Diesel 102ch', 'Corsa-e 136ch Électrique'],
    'opel_corsa vi': ['1.2 75ch', '1.2 Turbo 100ch', '1.2 Turbo 130ch', '1.5 Diesel 102ch', 'Corsa-e 136ch Électrique'],
    'opel_astra': ['1.2 Turbo 110ch', '1.2 Turbo 130ch', '1.5 Diesel 130ch', '1.6 Turbo 180ch', 'Hybride 180ch'],
    'opel_astra l': ['1.2 Turbo 110ch', '1.2 Turbo 130ch', '1.5 Diesel 130ch', '1.6 Turbo 180ch', 'Hybride 180ch'],
    'opel_mokka': ['1.2 Turbo 100ch', '1.2 Turbo 130ch', '1.5 Diesel 110ch', 'Mokka-e 136ch Électrique'],
    'opel_grandland': ['1.2 Turbo 130ch', '1.5 Diesel 130ch', 'Hybride 225ch'],
    'opel_crossland': ['1.2 Turbo 110ch', '1.5 Diesel 110ch'],
    'opel_insignia': ['1.5 Turbo 165ch', '2.0 Turbo 200ch', '1.6 Diesel 136ch', '2.0 Diesel 170ch'],
    'opel_zafira': ['1.5 Diesel 120ch', '1.5 Diesel 130ch', '2.0 Diesel 150ch'],
    'opel_vivaro': ['1.5 Diesel 102ch', '1.5 Diesel 120ch', '2.0 Diesel 150ch'],
    'opel_movano': ['2.2 Diesel 120ch', '2.2 Diesel 140ch', '2.2 Diesel 165ch'],

    // ===== TESLA =====
    'tesla_model 3': ['Standard Range Plus RWD', 'Long Range AWD', 'Performance AWD'],
    'tesla_model y': ['Standard Range RWD', 'Long Range AWD', 'Performance AWD'],
    'tesla_model s': ['Long Range AWD', 'Plaid AWD'],
    'tesla_model x': ['Long Range AWD', 'Plaid AWD'],

    // ===== FIAT =====
    'fiat_500': ['1.0 Hybrid 70ch', '1.2 69ch', '500e 118ch Électrique'],
    'fiat_500 iii': ['1.0 Hybrid 70ch', '1.2 69ch', '500e 118ch Électrique'],
    'fiat_500x': ['1.0 120ch', '1.3 150ch', '1.6 Diesel 120ch'],
    'fiat_panda': ['1.0 Hybrid 70ch', '0.9 TwinAir 85ch', '1.2 69ch'],
    'fiat_tipo': ['1.0 100ch', '1.4 95ch', '1.6 Diesel 120ch'],
    'fiat_ducato': ['2.0 Diesel 115ch', '2.3 Diesel 130ch', '2.3 Diesel 160ch', '3.0 Diesel 180ch'],

    // ===== SEAT =====
    'seat_ibiza': ['1.0 TSI 80ch', '1.0 TSI 95ch', '1.0 TSI 110ch', '1.0 TGI 90ch GNC', '1.6 TDI 95ch'],
    'seat_ibiza vi': ['1.0 TSI 80ch', '1.0 TSI 95ch', '1.0 TSI 110ch', '1.0 TGI 90ch GNC', '1.6 TDI 95ch'],
    'seat_leon': ['1.0 TSI 110ch', '1.5 TSI 130ch', '1.5 TSI 150ch', '2.0 TDI 115ch', '2.0 TDI 150ch', '2.0 TSI Cupra 300ch'],
    'seat_leon iv': ['1.0 TSI 110ch', '1.5 TSI 130ch', '1.5 TSI 150ch', '2.0 TDI 115ch', '2.0 TDI 150ch', '2.0 TSI Cupra 300ch'],
    'seat_arona': ['1.0 TSI 95ch', '1.0 TSI 110ch', '1.5 TSI 150ch', '1.6 TDI 95ch'],
    'seat_ateca': ['1.0 TSI 115ch', '1.5 TSI 150ch', '2.0 TDI 150ch', '2.0 TSI 190ch'],
    'seat_tarraco': ['1.5 TSI 150ch', '2.0 TSI 190ch', '2.0 TDI 150ch', '2.0 TDI 200ch'],

    // ===== SKODA =====
    'skoda_fabia': ['1.0 MPI 60ch', '1.0 MPI 75ch', '1.0 TSI 95ch', '1.0 TSI 110ch', '1.5 TSI 150ch'],
    'skoda_octavia': ['1.0 TSI 110ch', '1.5 TSI 150ch', '2.0 TDI 115ch', '2.0 TDI 150ch', '2.0 TSI RS 245ch'],
    'skoda_octavia iv': ['1.0 TSI 110ch', '1.5 TSI 150ch', '2.0 TDI 115ch', '2.0 TDI 150ch', '2.0 TSI RS 245ch'],
    'skoda_superb': ['1.5 TSI 150ch', '2.0 TSI 190ch', '2.0 TDI 150ch', '2.0 TDI 200ch'],
    'skoda_kamiq': ['1.0 TSI 95ch', '1.0 TSI 110ch', '1.5 TSI 150ch', '1.6 TDI 115ch'],
    'skoda_karoq': ['1.0 TSI 110ch', '1.5 TSI 150ch', '2.0 TDI 150ch', '2.0 TSI 190ch'],
    'skoda_kodiaq': ['1.5 TSI 150ch', '2.0 TSI 190ch', '2.0 TDI 150ch', '2.0 TDI 200ch'],
    'skoda_scala': ['1.0 TSI 95ch', '1.0 TSI 110ch', '1.5 TSI 150ch'],
    'skoda_enyaq': ['iV 60 180ch', 'iV 80 204ch', 'iV 80x 265ch', 'RS iV 299ch'],

    // ===== NISSAN =====
    'nissan_micra': ['1.0 IG-T 92ch', '1.0 IG-T 100ch', '1.5 dCi 90ch'],
    'nissan_juke': ['1.0 DIG-T 114ch', '1.0 DIG-T 117ch', '1.6 DIG-T 190ch', '1.5 dCi 110ch'],
    'nissan_qashqai': ['1.3 DIG-T 140ch', '1.3 DIG-T 158ch', '1.5 dCi 115ch', '1.7 dCi 150ch', '1.3 DIG-T MHEV 158ch'],
    'nissan_qashqai iii': ['1.3 DIG-T 140ch', '1.3 DIG-T 158ch', '1.5 VC-T 158ch', 'e-Power 190ch Hybride'],
    'nissan_x-trail': ['1.3 DIG-T 158ch', '1.7 dCi 150ch', '2.0 dCi 177ch', 'e-Power 213ch Hybride'],
    'nissan_leaf': ['40 kWh 150ch', '62 kWh 217ch', 'e+ 62 kWh 217ch'],
    'nissan_ariya': ['63 kWh 218ch', '87 kWh 242ch', 'e-4ORCE 87 kWh 306ch'],
    'nissan_navara': ['2.3 dCi 160ch', '2.3 dCi 190ch'],

    // ===== HYUNDAI =====
    'hyundai_i10': ['1.0 67ch', '1.2 84ch', '1.0 T-GDi 100ch'],
    'hyundai_i10 iii': ['1.0 67ch', '1.2 84ch', '1.0 T-GDi 100ch'],
    'hyundai_i20': ['1.0 T-GDi 100ch', '1.2 84ch', '1.6 T-GDi 204ch N'],
    'hyundai_i20 iii': ['1.0 T-GDi 100ch', '1.2 84ch', '1.6 T-GDi 204ch N'],
    'hyundai_i30': ['1.0 T-GDi 120ch', '1.4 T-GDi 140ch', '1.5 T-GDi 160ch', '1.6 CRDi 136ch'],
    'hyundai_kona': ['1.0 T-GDi 120ch', '1.6 T-GDi 177ch', '1.6 CRDi 136ch', 'Kona Electric 64 kWh 204ch'],
    'hyundai_kona ii': ['1.0 T-GDi 120ch', '1.6 T-GDi 177ch', '1.6 CRDi 136ch', 'Kona Electric 65 kWh 218ch'],
    'hyundai_tucson': ['1.6 T-GDi 150ch', '1.6 T-GDi 180ch', '1.6 CRDi 136ch', '1.6 T-GDi Hybride 230ch', '1.6 T-GDi Hybride 265ch'],
    'hyundai_tucson iv': ['1.6 T-GDi 150ch', '1.6 T-GDi 180ch', '1.6 CRDi 136ch', '1.6 T-GDi Hybride 230ch', '1.6 T-GDi Hybride 265ch'],
    'hyundai_santa fe': ['2.2 CRDi 200ch', '2.5 T-GDi 180ch', '1.6 T-GDi Hybride 230ch', '1.6 T-GDi Hybride 265ch'],
    'hyundai_ioniq': ['1.6 GDi Hybride 141ch', 'Electric 38 kWh 136ch'],
    'hyundai_ioniq 5': ['58 kWh 170ch', '73 kWh 218ch', '73 kWh AWD 306ch'],
    'hyundai_ioniq 6': ['53 kWh 151ch', '77 kWh 228ch', '77 kWh AWD 325ch'],
    'hyundai_bayon': ['1.0 T-GDi 100ch', '1.0 T-GDi 120ch'],

    // ===== KIA =====
    'kia_picanto': ['1.0 67ch', '1.2 84ch', '1.0 T-GDi 100ch'],
    'kia_picanto iii': ['1.0 67ch', '1.2 84ch', '1.0 T-GDi 100ch'],
    'kia_rio': ['1.0 T-GDi 100ch', '1.2 84ch', '1.0 T-GDi 120ch'],
    'kia_rio iv': ['1.0 T-GDi 100ch', '1.2 84ch', '1.0 T-GDi 120ch'],
    'kia_ceed': ['1.0 T-GDi 120ch', '1.4 T-GDi 140ch', '1.5 T-GDi 160ch', '1.6 CRDi 136ch'],
    'kia_ceed iii': ['1.0 T-GDi 120ch', '1.4 T-GDi 140ch', '1.5 T-GDi 160ch', '1.6 CRDi 136ch'],
    'kia_stonic': ['1.0 T-GDi 100ch', '1.0 T-GDi 120ch', '1.6 CRDi 115ch'],
    'kia_xceed': ['1.0 T-GDi 120ch', '1.4 T-GDi 140ch', '1.5 T-GDi 160ch', '1.6 CRDi 136ch'],
    'kia_sportage': ['1.6 T-GDi 150ch', '1.6 T-GDi 180ch', '1.6 CRDi 136ch', '1.6 T-GDi Hybride 230ch'],
    'kia_sportage v': ['1.6 T-GDi 150ch', '1.6 T-GDi 180ch', '1.6 CRDi 136ch', '1.6 T-GDi Hybride 230ch'],
    'kia_sorento': ['2.2 CRDi 202ch', '2.5 T-GDi 180ch', '1.6 T-GDi Hybride 230ch', '1.6 T-GDi Hybride 265ch'],
    'kia_niro': ['1.6 GDi Hybride 141ch', 'e-Niro 64 kWh 204ch', '1.6 GDi Hybride 141ch'],
    'kia_ev6': ['58 kWh 170ch', '77 kWh 229ch', '77 kWh AWD 325ch', 'GT 585ch'],
    'kia_ev9': ['76 kWh 218ch', '99 kWh 203ch', '99 kWh AWD 385ch'],

    // ===== VOLVO =====
    'volvo_xc40': ['T2 129ch', 'T3 156ch', 'T4 190ch', 'T5 247ch', 'B4 197ch Mild Hybrid', 'Recharge T5 262ch Hybride', 'Recharge 300ch Électrique'],
    'volvo_xc60': ['B4 197ch Mild Hybrid', 'B5 235ch Mild Hybrid', 'T8 390ch Hybride', 'Recharge 300ch Électrique'],
    'volvo_xc90': ['B5 235ch Mild Hybrid', 'B6 300ch Mild Hybrid', 'T8 390ch Hybride'],
    'volvo_s60': ['B3 163ch Mild Hybrid', 'B4 197ch Mild Hybrid', 'T8 390ch Hybride'],
    'volvo_s90': ['B4 197ch Mild Hybrid', 'B5 235ch Mild Hybrid', 'T8 390ch Hybride'],
    'volvo_v40': ['T2 122ch', 'T3 152ch', 'D2 120ch', 'D3 150ch'],
    'volvo_v60': ['B3 163ch Mild Hybrid', 'B4 197ch Mild Hybrid', 'T8 390ch Hybride'],
    'volvo_v90': ['B4 197ch Mild Hybrid', 'B5 235ch Mild Hybrid', 'T8 390ch Hybride'],
    'volvo_ex30': ['Single Motor 272ch', 'Twin Motor 428ch'],
    'volvo_ex90': ['Twin Motor 517ch'],

    // ===== MINI =====
    'mini_cooper': ['Cooper 136ch', 'Cooper S 178ch', 'JCW 231ch', 'Cooper D 116ch', 'Cooper SE 184ch Électrique'],
    'mini_cooper iii': ['Cooper 136ch', 'Cooper S 178ch', 'JCW 231ch', 'Cooper D 116ch', 'Cooper SE 184ch Électrique'],
    'mini_countryman': ['Cooper 136ch', 'Cooper S 178ch', 'JCW 306ch', 'Cooper D 150ch', 'Cooper SE 218ch Hybride'],
    'mini_countryman ii': ['Cooper 136ch', 'Cooper S 178ch', 'JCW 306ch', 'Cooper D 150ch', 'Cooper SE 218ch Hybride'],
    'mini_clubman': ['Cooper 136ch', 'Cooper S 178ch', 'JCW 306ch', 'Cooper D 150ch'],
    'mini_cabrio': ['Cooper 136ch', 'Cooper S 178ch', 'JCW 231ch'],
    'mini_electric': ['Cooper SE 184ch Électrique'],

    // ===== SUZUKI =====
    'suzuki_swift': ['1.2 90ch', '1.2 Dualjet 90ch', '1.4 Boosterjet 129ch Sport', '1.2 Hybrid 83ch'],
    'suzuki_swift vi': ['1.2 90ch', '1.2 Dualjet 90ch', '1.4 Boosterjet 129ch Sport', '1.2 Hybrid 83ch'],
    'suzuki_vitara': ['1.0 Boosterjet 111ch', '1.4 Boosterjet 140ch', '1.6 120ch', '1.5 Hybrid 115ch'],
    'suzuki_s-cross': ['1.0 Boosterjet 111ch', '1.4 Boosterjet 129ch', '1.5 Hybrid 115ch'],
    'suzuki_s-cross ii': ['1.0 Boosterjet 111ch', '1.4 Boosterjet 129ch', '1.5 Hybrid 115ch'],
    'suzuki_jimny': ['1.5 102ch'],
    'suzuki_ignis': ['1.2 Dualjet 83ch', '1.2 Dualjet Hybrid 83ch'],
    'suzuki_across': ['2.5 Hybride 194ch'],
    'suzuki_swace': ['1.8 Hybride 122ch'],

    // ===== HONDA =====
    'honda_civic': ['1.0 VTEC Turbo 126ch', '1.5 VTEC Turbo 182ch', '2.0 i-VTEC Type R 320ch', '1.5 VTEC Turbo 182ch'],
    'honda_civic xi': ['1.5 VTEC Turbo 182ch', '2.0 e:HEV 184ch Hybride', '2.0 i-VTEC Type R 329ch'],
    'honda_jazz': ['1.3 i-VTEC 102ch', '1.5 i-VTEC 130ch', '1.5 e:HEV 109ch Hybride'],
    'honda_jazz iv': ['1.5 e:HEV 109ch Hybride', '1.5 e:HEV 122ch Hybride'],
    'honda_cr-v': ['1.5 VTEC Turbo 173ch', '2.0 i-MMD Hybride 184ch'],
    'honda_cr-v vi': ['1.5 VTEC Turbo 193ch', '2.0 e:HEV 184ch Hybride'],
    'honda_hr-v': ['1.5 i-VTEC 130ch', '1.6 i-DTEC 120ch', '1.5 e:HEV 131ch Hybride'],
    'honda_hr-v iii': ['1.5 e:HEV 131ch Hybride'],
    'honda_e:ny1': ['e:Ny1 204ch Électrique'],

    // ===== MAZDA =====
    'mazda_mazda2': ['1.5 Skyactiv-G 75ch', '1.5 Skyactiv-G 90ch', '1.5 Skyactiv-G 115ch', '1.5 Skyactiv-D 105ch'],
    'mazda_mazda2 iii': ['1.5 Skyactiv-G 75ch', '1.5 Skyactiv-G 90ch', '1.5 Skyactiv-G 115ch', '1.5 Skyactiv-D 105ch'],
    'mazda_mazda3': ['1.5 Skyactiv-G 122ch', '2.0 Skyactiv-G 122ch', '2.0 Skyactiv-X 180ch', '1.8 Skyactiv-D 116ch'],
    'mazda_mazda3 iv': ['1.5 Skyactiv-G 122ch', '2.0 Skyactiv-G 122ch', '2.0 Skyactiv-X 180ch', '1.8 Skyactiv-D 116ch'],
    'mazda_mazda6': ['2.0 Skyactiv-G 145ch', '2.5 Skyactiv-G 194ch', '2.2 Skyactiv-D 150ch', '2.2 Skyactiv-D 184ch'],
    'mazda_cx-3': ['1.5 Skyactiv-G 120ch', '2.0 Skyactiv-G 121ch', '1.5 Skyactiv-D 105ch'],
    'mazda_cx-30': ['2.0 Skyactiv-G 122ch', '2.0 Skyactiv-X 180ch', '1.8 Skyactiv-D 116ch'],
    'mazda_cx-5': ['2.0 Skyactiv-G 165ch', '2.5 Skyactiv-G 194ch', '2.2 Skyactiv-D 150ch', '2.2 Skyactiv-D 184ch'],
    'mazda_cx-60': ['2.5 Skyactiv-G 200ch', '3.3 Skyactiv-D 200ch', '2.5 PHEV 327ch Hybride'],
    'mazda_mx-5': ['1.5 Skyactiv-G 132ch', '2.0 Skyactiv-G 184ch'],
    'mazda_mx-30': ['e-Skyactiv 145ch Électrique'],

    // ===== JEEP =====
    'jeep_renegade': ['1.0 T3 120ch', '1.3 T4 150ch', '1.6 Multijet 120ch', '2.0 Multijet 140ch', '4xe 190ch Hybride'],
    'jeep_compass': ['1.3 T4 130ch', '1.3 T4 150ch', '1.6 Multijet 120ch', '2.0 Multijet 170ch', '4xe 190ch Hybride'],
    'jeep_cherokee': ['2.0 T4 270ch', '2.2 Multijet 150ch', '2.2 Multijet 195ch'],
    'jeep_grand cherokee': ['3.0 V6 190ch', '3.0 V6 250ch', '3.6 V6 286ch', '5.7 V8 352ch'],
    'jeep_wrangler': ['2.0 T4 272ch', '3.6 V6 285ch', '2.0 T4 380ch 4xe Hybride'],
    'jeep_avenger': ['1.2 Turbo 100ch', 'Electric 156ch Électrique'],

    // ===== MG =====
    'mg_mg4': ['Standard 51 kWh 170ch', 'Long Range 64 kWh 203ch', 'Luxury 64 kWh 203ch', 'XPower 435ch'],
    'mg_mg5': ['Standard 50 kWh 156ch', 'Long Range 61 kWh 156ch'],
    'mg_zs': ['1.0 T-GDi 111ch', '1.5 VTi 106ch', 'ZS EV 72 kWh 177ch'],
    'mg_hs': ['1.5 T-GDi 162ch', 'HS PHEV 258ch'],
    'mg_marvel r': ['Standard 70 kWh 180ch', 'Long Range 70 kWh 288ch'],
    'mg_cyberster': ['Trophy Extended Range 340ch', 'GT 503ch AWD'],

    // ===== BYD =====
    'byd_atto 3': ['60 kWh 204ch Électrique'],
    'byd_dolphin': ['45 kWh 95ch', '60 kWh 204ch'],
    'byd_seal': ['82 kWh 313ch', '82 kWh AWD 530ch'],
    'byd_han': ['85 kWh 517ch'],
    'byd_tang': ['86 kWh 517ch'],
    'byd_seal u': ['71 kWh 218ch', '87 kWh 238ch'],

    // ===== POLESTAR =====
    'polestar_1': ['2.0 Hybride 609ch'],
    'polestar_2': ['Standard 64 kWh 224ch', 'Long Range 78 kWh 231ch', 'Long Range Dual Motor 408ch'],
    'polestar_3': ['Long Range Dual Motor 489ch', 'Performance 517ch'],
    'polestar_4': ['Long Range Single Motor 272ch', 'Long Range Dual Motor 544ch'],

    // ===== CUPRA =====
    'cupra_formentor': ['1.5 TSI 150ch', '2.0 TSI 190ch', '2.0 TSI 310ch', '1.4 e-Hybrid 245ch'],
    'cupra_leon': ['1.5 TSI 130ch', '1.5 TSI 150ch', '2.0 TSI 190ch', '2.0 TSI 300ch', '1.4 e-Hybrid 204ch'],
    'cupra_born': ['58 kWh 204ch', '77 kWh 231ch', '77 kWh 231ch'],
    'cupra_ateca': ['1.5 TSI 150ch', '2.0 TSI 190ch', '2.0 TSI 300ch'],
    'cupra_tavascan': ['77 kWh 286ch', '77 kWh AWD 340ch'],
    'cupra_terramar': ['1.5 TSI 150ch', '2.0 TSI 204ch', '1.5 e-Hybrid 272ch'],

    // ===== DS =====
    'ds_ds3': ['1.2 PureTech 82ch', '1.2 PureTech 110ch', '1.5 BlueHDi 100ch'],
    'ds_ds3 crossback': ['1.2 PureTech 100ch', '1.2 PureTech 130ch', '1.2 PureTech 155ch', '1.5 BlueHDi 130ch', 'E-Tense 136ch Électrique'],
    'ds_ds4': ['1.6 THP 165ch', '1.6 THP 210ch', '2.0 BlueHDi 180ch'],
    'ds_ds4 ii': ['1.2 PureTech 130ch', '1.5 BlueHDi 130ch', '1.6 PureTech 180ch', 'E-Tense 225ch Hybride'],
    'ds_ds5': ['1.6 THP 165ch', '1.6 THP 210ch', '2.0 BlueHDi 180ch'],
    'ds_ds7 crossback': ['1.2 PureTech 130ch', '1.5 BlueHDi 130ch', '1.6 PureTech 180ch', '1.6 PureTech 225ch', 'E-Tense 300ch Hybride'],
    'ds_ds9': ['1.6 PureTech 225ch', 'E-Tense 250ch Hybride', 'E-Tense 360ch Hybride'],

    // ===== ALPINE =====
    'alpine_a110': ['1.8 Turbo 252ch', '1.8 Turbo 292ch', '1.8 Turbo 300ch S', '1.8 Turbo 300ch R'],
    'alpine_a110 s': ['1.8 Turbo 292ch'],
    'alpine_a110 r': ['1.8 Turbo 300ch'],
    'alpine_a290': ['Electric 220ch Électrique'],
  };

  /// Motorisations génériques par marque
  static final Map<String, List<String>> _brandEngines = {
    'renault': ['1.0 TCe', '1.3 TCe', '1.5 Blue dCi', 'E-Tech Hybride'],
    'peugeot': ['1.2 PureTech', '1.5 BlueHDi', 'Hybride', 'Électrique'],
    'citroen': ['1.2 PureTech', '1.5 BlueHDi', 'Hybride', 'Électrique'],
    'dacia': ['1.0 SCe', '1.0 TCe', '1.5 Blue dCi', 'Électrique'],
    'toyota': ['1.5 Hybride', '1.8 Hybride', '2.0 Hybride', '2.5 Hybride'],
    'volkswagen': ['1.0 TSI', '1.5 TSI', '2.0 TDI', '2.0 TSI'],
    'audi': ['30 TFSI', '35 TFSI', '40 TFSI', '35 TDI', '40 TDI'],
    'bmw': ['116i', '118i', '120i', '116d', '118d', '120d'],
    'mercedes': ['A 180', 'A 200', 'A 250', 'A 180 d', 'A 200 d'],
    'ford': ['1.0 EcoBoost', '1.5 EcoBlue', '2.0 EcoBlue', 'Hybride'],
    'opel': ['1.2 Turbo', '1.5 Diesel', 'Électrique'],
    'tesla': ['Standard Range', 'Long Range', 'Performance'],
    'fiat': ['1.0 Hybrid', '1.2', '1.3', '1.6 Diesel'],
    'seat': ['1.0 TSI', '1.5 TSI', '2.0 TDI', '2.0 TSI'],
    'skoda': ['1.0 TSI', '1.5 TSI', '2.0 TDI', '2.0 TSI'],
    'nissan': ['1.0 DIG-T', '1.3 DIG-T', '1.5 dCi', 'e-Power Hybride'],
    'hyundai': ['1.0 T-GDi', '1.6 T-GDi', '1.6 CRDi', 'Hybride', 'Électrique'],
    'kia': ['1.0 T-GDi', '1.6 T-GDi', '1.6 CRDi', 'Hybride', 'Électrique'],
    'volvo': ['B4 Mild Hybrid', 'B5 Mild Hybrid', 'T8 Hybride', 'Recharge Électrique'],
    'mini': ['Cooper', 'Cooper S', 'JCW', 'Cooper SE Électrique'],
    'suzuki': ['1.2 Dualjet', '1.4 Boosterjet', 'Hybrid'],
    'honda': ['1.5 VTEC Turbo', '2.0 e:HEV Hybride', 'Type R'],
    'mazda': ['Skyactiv-G', 'Skyactiv-X', 'Skyactiv-D'],
    'jeep': ['1.0 T3', '1.3 T4', '2.0 Multijet', '4xe Hybride'],
    'mg': ['1.0 T-GDi', '1.5 VTi', 'Électrique'],
    'byd': ['Électrique 60 kWh', 'Électrique 82 kWh'],
    'polestar': ['Long Range Single Motor', 'Long Range Dual Motor', 'Performance'],
    'cupra': ['1.5 TSI', '2.0 TSI', 'e-Hybrid', 'Électrique'],
    'ds': ['1.2 PureTech', '1.5 BlueHDi', 'E-Tense Hybride', 'Électrique'],
    'alpine': ['1.8 Turbo', 'Électrique'],
  };
}