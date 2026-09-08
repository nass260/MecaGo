import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; 
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/premium_card.dart';
import '../../../../core/widgets/premium_button.dart';
import '../../../../core/services/autodoc_service.dart'; 

class DiagnosticPage extends StatefulWidget {
  const DiagnosticPage({super.key});

  @override
  State<DiagnosticPage> createState() => _DiagnosticPageState();
}

class _DiagnosticPageState extends State<DiagnosticPage> {
  final TextEditingController _controller = TextEditingController();
  final AutodocService _autodocService = const AutodocService();

  bool _isLoading = false;
  bool _showReport = false;
  String _cause = "";
  
  String _partName = "";
  String _partBrand = "";
  double _partPrice = 0.0;
  String _affiliateUrl = "";

  void _runAnalysis() {
    final String query = _controller.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _showReport = false;
      _isLoading = true;
    });

    Future.delayed(const Duration(milliseconds: 1200), () async {
      if (!mounted) return;

      String detectedCategory = "filter";
      if (query.toLowerCase().contains('frein') || query.toLowerCase().contains('bruit') || query.toLowerCase().contains('sifflement')) {
        _cause = "Usure prononcée des garnitures de friction des plaquettes de frein d'origine de votre Tesla.";
        detectedCategory = "brakes";
      } else {
        _cause = "Colmatage potentiel du filtre d'habitacle par accumulation de micro-particules routières.";
        detectedCategory = "filter";
      }

      final partData = await _autodocService.fetchPartAffiliationData(
        vehicleModel: "Tesla Model 3",
        partCategory: detectedCategory,
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _showReport = true;
        if (partData != null) {
          _partName = partData['partName'] as String;
          _partBrand = partData['brand'] as String;
          _partPrice = partData['price'] as double;
          _affiliateUrl = partData['affiliateUrl'] as String;
        }
      });
    });
  }

  Future<void> _launchAutodocWebsite() async {
    final Uri url = Uri.parse(_affiliateUrl);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint("MecaGo Error — Impossible d'ouvrir le lien marchand : $_affiliateUrl");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Diagnostic IA',
          style: TextStyle(color: AppColors.navy, fontWeight: FontWeight.w900, fontSize: 20, letterSpacing: -0.5),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Assistant d’atelier virtuel',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.navy, letterSpacing: -0.5),
            ),
            const SizedBox(height: 4),
            const Text(
              'Décrivez le sifflement ou le problème constaté sur votre véhicule.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 18),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              child: Row(
                children: [
                  const Icon(Icons.psychology_outlined, color: AppColors.orange, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      style: const TextStyle(color: AppColors.navy, fontWeight: FontWeight.w600, fontSize: 14),
                      decoration: const InputDecoration(
                        hintText: 'Ex: Bruit de sifflement au freinage...',
                        hintStyle: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => _runAnalysis(),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _runAnalysis,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.orange,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      elevation: 0,
                    ),
                    child: const Text('Analyser', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                ],
              ),
            ),

            if (_isLoading) ...[
              const SizedBox(height: 50),
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppColors.orange), strokeWidth: 3.5),
                    SizedBox(height: 16),
                    Text('L’IA étudie l’origine de la panne...', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
              ),
            ],

            if (_showReport) ...[
              const SizedBox(height: 24),
              
              PremiumCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Bilan de santé mécanique', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.navy, letterSpacing: -0.2)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(10)),
                          child: const Text('CRITIQUE 🚨', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 10)),
                        ),
                      ],
                    ),
                    const Divider(height: 24, color: AppColors.border),
                    const Text('CAUSE PROBABLE CALCULÉE', style: TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                    const SizedBox(height: 6),
                    Text(_cause, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.navy, fontSize: 14, height: 1.4)),
                    
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14.0),
                      child: Divider(color: AppColors.border),
                    ),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(color: AppColors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                          child: const Icon(Icons.shopping_bag_outlined, color: AppColors.orange, size: 22),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Équipementier Recommandé 🇫🇷', style: TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.bold, letterSpacing: 0.3)),
                              const SizedBox(height: 2),
                              Text('$_partName $_partBrand', style: const TextStyle(fontWeight: FontWeight.extrabold, color: AppColors.navy, fontSize: 14)),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('$_partPrice €', style: const TextStyle(color: AppColors.navy, fontSize: 20, fontWeight: FontWeight.w900, fontFamily: 'monospace')),
                            const Text('En stock', style: TextStyle(color: AppColors.success, fontSize: 10, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    PremiumButton(
                      text: 'Commander la pièce sur AUTODOC',
                      onPressed: _launchAutodocWebsite,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
