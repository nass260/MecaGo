import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/premium_card.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _useMiles = false;
  String _selectedLanguage = "Français";

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
          'Réglages Généraux',
          style: TextStyle(
            color: AppColors.navy,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Préférences',
                style: TextStyle(color: AppColors.navy, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: -0.3),
              ),
              const SizedBox(height: 12),

              // Section 1 : Unités et Langues de l'utilisateur
              PremiumCard(
                child: Column(
                  children: [
                    // Sélecteur d'unité kilométrique
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Utiliser les Miles (mi)', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.navy, fontSize: 15)),
                            SizedBox(height: 2),
                            Text('Convertit les jauges kilométriques', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                          ],
                        ),
                        Switch.adaptive(
                          value: _useMiles,
                          activeColor: AppColors.orange,
                          onChanged: (val) => setState(() => _useMiles = val),
                        ),
                      ],
                    ),
                    Divider(height: 24, color: Colors.grey.shade100),
                    
                    // Menu Langue
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Langue de l’application', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.navy, fontSize: 15)),
                        DropdownButton<String>(
                          value: _selectedLanguage,
                          underline: const SizedBox(),
                          icon: const Icon(Icons.arrow_drop_down_rounded, color: AppColors.orange),
                          style: const TextStyle(color: AppColors.orange, fontWeight: FontWeight.bold, fontSize: 14),
                          items: <String>['Français', 'English', 'Español'].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedLanguage = val);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),
              const Text(
                'Informations légales',
                style: TextStyle(color: AppColors.navy, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: -0.3),
              ),
              const SizedBox(height: 12),

              // Section 2 : CGU & Versioning requis pour les stores d'applications
              PremiumCard(
                child: Column(
                  children: [
                    _buildSettingsRow(title: "Conditions Générales d’Utilisation", sub: "Consulter les CGU de MecaGo"),
                    Divider(height: 24, color: Colors.grey.shade100),
                    _buildSettingsRow(title: "Politique de Confidentialité", sub: "Réglementation RGPD et protection"),
                    Divider(height: 24, color: Colors.grey.shade100),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('Version de l’application', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.navy, fontSize: 15)),
                        Text('v1.0.0 (Production)', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold, fontSize: 13, fontFamily: 'monospace')),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsRow({required String title, required String sub}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.navy, fontSize: 15)),
            const SizedBox(height: 2),
            Text(sub, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          ],
        ),
        const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textSecondary, size: 14),
      ],
    );
  }
}
