// lib/features/garage/presentation/pages/vin_input_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';

class VinInputPage extends StatefulWidget {
  const VinInputPage({super.key});

  @override
  State<VinInputPage> createState() => _VinInputPageState();
}

class _VinInputPageState extends State<VinInputPage> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _isValid => _controller.text.length == 17;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.navy),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Saisir le VIN',
          style: TextStyle(
            color: AppColors.navy,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // CARTE EXPLICATIVE
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppGradients.navy,
                borderRadius: BorderRadius.circular(20),
                boxShadow: AppShadows.hero,
              ),
              child: Column(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(
                      Icons.vpn_key_rounded,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Numéro d\'identification\ndu véhicule',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      height: 1.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.info_outline_rounded,
                            color: Colors.white70, size: 16),
                        SizedBox(width: 8),
                        Text(
                          '17 caractères · Case E de la carte grise',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // CHAMP VIN
            const Text(
              'Entrez votre VIN',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.navy,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppShadows.card,
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _controller,
                    textCapitalization: TextCapitalization.characters,
                    maxLength: 17,
                    onChanged: (_) => setState(() {}),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                      color: AppColors.navy,
                    ),
                    decoration: InputDecoration(
                      hintText: '1CNFY2AB...',
                      hintStyle: TextStyle(
                        color: AppColors.textLight.withOpacity(0.6),
                        letterSpacing: 2,
                      ),
                      counterText: '',
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.orange,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Compteur de caractères
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: _controller.text.length / 17,
                            backgroundColor:
                                AppColors.border.withOpacity(0.3),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _isValid ? AppColors.success : AppColors.orange,
                            ),
                            minHeight: 6,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${_controller.text.length}/17',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: _isValid
                              ? AppColors.success
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // OÙ TROUVER LE VIN ?
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.orange.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.orange.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.help_outline_rounded,
                          color: AppColors.orange, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Où trouver mon VIN ?',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.navy,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildHelpRow(Icons.description_rounded,
                      'Sur la carte grise (case E)'),
                  const SizedBox(height: 6),
                  _buildHelpRow(Icons.directions_car_rounded,
                      'Sur le pare-brise (bas côté conducteur)'),
                  const SizedBox(height: 6),
                  _buildHelpRow(Icons.door_front_door_rounded,
                      'Sur le montant de la portière'),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // BOUTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isValid
                    ? () => context.push('/cascade-search')
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _isValid ? AppColors.orange : AppColors.border,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search_rounded,
                      color: _isValid
                          ? Colors.white
                          : AppColors.textSecondary,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Rechercher le véhicule',
                      style: TextStyle(
                        color:
                            _isValid ? Colors.white : AppColors.textSecondary,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: AppColors.orange, size: 16),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.navy,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}