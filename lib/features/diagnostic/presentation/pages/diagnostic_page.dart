import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/premium_card.dart';
import '../../../../core/widgets/premium_button.dart';
import '../managers/diagnostic_notifier.dart';

class DiagnosticPage extends StatefulWidget {
  const DiagnosticPage({super.key});

  @override
  State<DiagnosticPage> createState() => _DiagnosticPageState();
}

class _DiagnosticPageState extends State<DiagnosticPage> {
  final DiagnosticNotifier _notifier = DiagnosticNotifier();
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _runAnalysis() {
    if (_searchController.text.trim().isEmpty) return;
    FocusScope.of(context).unfocus(); // Ferme le clavier virtuel
    _notifier.submitSymptomAnalysis(_searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.navy),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Diagnostic IA',
          style: TextStyle(
            color: AppColors.navy,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _notifier,
          builder: (context, _) {
            final report = _notifier.currentReport;

            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'ASSISTANT DE RECHERCHE',
                          style: TextStyle(color: AppColors.orange, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Quel est le problème ?',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.navy, letterSpacing: -0.6),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Décrivez le symptôme ou le bruit inhabituel de votre véhicule pour que l’IA MecaGo identifie la panne.',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.45, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 20),

                        // BARRE DE SAISIE LUXE APPLE STYLE WITH INTEGRATED BUTTON
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 14, offset: const Offset(0, 4)),
                            ],
                          ),
                          child: TextField(
                            controller: _searchController,
                            style: const TextStyle(color: AppColors.navy, fontWeight: FontWeight.w600, fontSize: 15),
                            decoration: InputDecoration(
                              hintText: 'Ex: Bruit de sifflement au freinage...',
                              hintStyle: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                              prefixIcon: const Icon(Icons.psychology_alt_rounded, color: AppColors.orange),
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.arrow_circle_right_rounded, color: AppColors.orange, size: 32),
                                onPressed: _runAnalysis,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            ),
                            onSubmitted: (_) => _runAnalysis(),
                          ),
                        ),

                        const SizedBox(height: 28),

                        // ÉTAT 1 : RÉFLEXION DU RÉSEAU DE NEURONES IA
                        if (_notifier.isAnalyzing) ...[
                          const SizedBox(height: 40),
                          const Center(
                            child: Column(
                              children: [
                                CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppColors.orange), strokeWidth: 3.5),
                                const SizedBox(height: 18),
                                Text(
                                  'Analyse de l’arbre de décision mécanique...',
                                  style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        ],

                        // ÉTAT 2 : LE RAPPORT DE PANNE PREMIUM ISSU DE SQLITE/IA
                        if (report != null && !_notifier.isAnalyzing) ...[
                          const Text(
                            'BILAN DE SANTÉ DU MOTEUR IA',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                          ),
                          const SizedBox(height: 12),
                          PremiumCard(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Analyse de panne', style: TextStyle(color: AppColors.navy, fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: -0.4)),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(color: Color(report.colorValue).withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                                      child: Text(
                                        report.gravity,
                                        style: TextStyle(color: Color(report.colorValue), fontSize: 11, fontWeight: FontWeight.extrabold),
                                      ),
                                    ),
                                  ],
                                ),
                                Divider(height: 28, color: AppColors.border.withOpacity(0.4)),
                                const Text('CAUSE PROBABLE', style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                                const SizedBox(height: 6),
                                Text(report.probableCause, style: const TextStyle(color: AppColors.navy, fontSize: 15, fontWeight: FontWeight.w600, height: 1.4)),
                                const SizedBox(height: 18),
                                const Text('ÉQUIPEMENTIER RECOMMANDÉ FRANCE', style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(Icons.verified_user_rounded, color: AppColors.success, size: 16),
                                    const SizedBox(width: 6),
                                    Text(report.suggestedPartCategory, style: const TextStyle(color: AppColors.navy, fontSize: 14, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                Divider(height: 28, color: AppColors.border.withOpacity(0.4)),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Généré le ${report.timestamp}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w500)),
                                    TextButton(
                                      onPressed: () => _notifier.resetDiagnostic(),
                                      child: const Text('Réinitialiser', style: TextStyle(color: AppColors.orange, fontWeight: FontWeight.bold, fontSize: 13)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                
