import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/premium_card.dart';
import '../../../../core/widgets/premium_button.dart'; // Importation du bouton officiel
import '../../../../core/services/pdf_export_service.dart'; // Importation du service PDF

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final PdfExportService _pdfService = const PdfExportService();
  bool _isLoading = false;
  bool _isExporting = false; // Indicateur pour le traitement du PDF

  // Liste simulée des données d'interventions extraites de la base SQLite
  final List<Map<String, dynamic>> _maintenanceLogs = [
    {
      'date': '18 août 2026',
      'mileage': '42 150 km',
      'icon': '💨',
      'title': 'Filtre habitacle HEPA',
      'brand': 'PURFLUX',
      'cost': 18.50,
      'saved': 35.00,
      'status': 'Validé',
    },
    {
      'date': '02 juin 2026',
      'mileage': '38 900 km',
      'icon': '🛑',
      'title': 'Plaquettes de frein Avant',
      'brand': 'VALEO Tech',
      'cost': 34.90,
      'saved': 90.00,
      'status': 'Validé',
    }
  ];

  @override
  void initState() {
    super.initState();
    _loadHistoryLogs();
  }

  Future<void> _loadHistoryLogs() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  /// Déclenche la compilation et l'exportation du document PDF d'entretien
  Future<void> _handlePdfExport() async {
    setState(() => _isExporting = true);
    
    // Appel asynchrone de notre service technique de 25 lignes
    final bool success = await _pdfService.generateMaintenanceReportPdf(
      vehicleName: "Tesla Model 3",
      totalSaved: "125 €",
      logs: _maintenanceLogs,
    );

    if (!mounted) return;
    setState(() => _isExporting = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("📄 Carnet d'entretien PDF généré et enregistré !"),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Historique',
          style: TextStyle(color: AppColors.navy, fontWeight: FontWeight.w900, fontSize: 20, letterSpacing: -0.5),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppColors.orange)))
          : ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              children: [
                
                // 1. CARTE DE SYNTHÈSE DES GAINS
                PremiumCard(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: const [
                          Text('125 €', style: TextStyle(color: AppColors.success, fontSize: 22, fontWeight: FontWeight.w900, fontFamily: 'monospace')),
                          SizedBox(height: 4),
                          Text('Économisés au total', style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      Container(width: 1, height: 40, color: AppColors.border),
                      Column(
                        children: const [
                          Text('2', style: TextStyle(color: AppColors.navy, fontSize: 22, fontWeight: FontWeight.w900)),
                          SizedBox(height: 4),
                          Text('Interventions faites', style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),

                // 2. CORRECTION EXCLUSIVE : INTÉGRATION DU BOUTON ACTIONS D'EXPORTATION PDF
                _isExporting
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 12.0),
                          child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppColors.orange), strokeWidth: 3),
                        ),
                      )
                    : PremiumButton(
                        text: 'Exporter mon carnet en PDF',
                        onPressed: _handlePdfExport,
                      ),

                const SizedBox(height: 24),
                const Text('Journal de maintenance SIV', style: TextStyle(color: AppColors.navy, fontSize: 15, fontWeight: FontWeight.w900, letterSpacing: -0.2)),
                const SizedBox(height: 12),

                // 3. BOUCLE DE RENDER DES ENREGISTREMENTS DE L'HISTORIQUE
                ..._maintenanceLogs.map((log) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: PremiumCard(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(12)),
                            child: Center(child: Text(log['icon'] as String, style: const TextStyle(fontSize: 20))),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(log['title'] as String, style: const TextStyle(color: AppColors.navy, fontWeight: FontWeight.extrabold, fontSize: 14)),
                                const SizedBox(height: 2),
                                Text('${log['brand']} • ${log['mileage']}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
                                const SizedBox(height: 4),
                                Text('📅 ${log['date']}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('+${(log['saved'] as double).round()} €', style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.w900, fontSize: 15, fontFamily: 'monospace')),
                              const SizedBox(height: 2),
                              Text('Achat : ${log['cost']} €', style: const TextStyle(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
    );
  }
}
