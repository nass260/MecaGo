// lib/features/scanner/presentation/pages/scanner_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/premium_button.dart';

enum ScanMode {
  qrCode('QR Code', Icons.qr_code_scanner_rounded, 'Scannez le QR code du véhicule'),
  plate('Plaque', Icons.pin_rounded, 'Scannez la plaque d\'immatriculation'),
  part('Pièce', Icons.build_circle_rounded, 'Analysez l\'usure d\'une pièce');

  final String label;
  final IconData icon;
  final String description;
  const ScanMode(this.label, this.icon, this.description);
}

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  ScanMode _selectedMode = ScanMode.qrCode;
  bool _isScanning = false;
  bool _showResult = false;
  Map<String, dynamic>? _scanResult;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // ============================================
            // 1. VISEUR (fond)
            // ============================================
            Positioned.fill(
              child: _buildScannerView(),
            ),

            // ============================================
            // 2. BARRE SUPÉRIEURE
            // ============================================
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _buildTopBar(context),
            ),

            // ============================================
            // 3. SÉLECTEUR DE MODE
            // ============================================
            Positioned(
              top: 100,
              left: 0,
              right: 0,
              child: _buildModeSelector(),
            ),

            // ============================================
            // 4. INSTRUCTIONS
            // ============================================
            Positioned(
              bottom: 220,
              left: 0,
              right: 0,
              child: _buildInstructions(),
            ),

            // ============================================
            // 5. BARRE INFÉRIEURE
            // ============================================
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildBottomBar(context),
            ),

            // ============================================
            // 6. RÉSULTAT (overlay)
            // ============================================
            if (_showResult && _scanResult != null)
              Positioned.fill(
                child: _buildResultOverlay(context),
              ),
          ],
        ),
      ),
    );
  }

  // ============================================
  // VISEUR
  // ============================================

  Widget _buildScannerView() {
    return Container(
      color: Colors.black,
      child: Stack(
        children: [
          // Fond simulé de la caméra
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  Colors.grey.shade900,
                  Colors.black,
                ],
              ),
            ),
          ),

          // Cadre de scan
          Center(
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.orange,
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Stack(
                children: [
                  // Coins
                  _buildCorner(Alignment.topLeft),
                  _buildCorner(Alignment.topRight),
                  _buildCorner(Alignment.bottomLeft),
                  _buildCorner(Alignment.bottomRight),

                  // Ligne de scan animée
                  if (_isScanning)
                    Positioned.fill(
                      child: TweenAnimationBuilder(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: const Duration(seconds: 2),
                        builder: (context, value, child) {
                          return Align(
                            alignment: Alignment(0, value * 2 - 1),
                            child: Container(
                              height: 2,
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    AppColors.orange,
                                    Colors.transparent,
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.orange.withOpacity(0.8),
                                    blurRadius: 12,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        onEnd: () {},
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCorner(Alignment alignment) {
    return Align(
      alignment: alignment,
      child: Container(
        width: 30,
        height: 30,
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border(
            top: alignment.y < 0
                ? const BorderSide(color: AppColors.orange, width: 4)
                : BorderSide.none,
            bottom: alignment.y > 0
                ? const BorderSide(color: AppColors.orange, width: 4)
                : BorderSide.none,
            left: alignment.x < 0
                ? const BorderSide(color: AppColors.orange, width: 4)
                : BorderSide.none,
            right: alignment.x > 0
                ? const BorderSide(color: AppColors.orange, width: 4)
                : BorderSide.none,
          ),
        ),
      ),
    );
  }

  // ============================================
  // BARRE SUPÉRIEURE
  // ============================================

  Widget _buildTopBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _buildCircleButton(
            icon: Icons.close_rounded,
            onTap: () => context.pop(),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.orange,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'IA Active',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          _buildCircleButton(
            icon: Icons.flash_on_rounded,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }

  // ============================================
  // SÉLECTEUR DE MODE
  // ============================================

  Widget _buildModeSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: ScanMode.values.map((mode) {
          final isSelected = _selectedMode == mode;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedMode = mode),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.orange : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      mode.icon,
                      color: isSelected ? Colors.white : Colors.white60,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      mode.label,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.white60,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ============================================
  // INSTRUCTIONS
  // ============================================

  Widget _buildInstructions() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.orange.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _selectedMode.icon,
              color: AppColors.orange,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _selectedMode.description,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // BARRE INFÉRIEURE
  // ============================================

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Bouton de capture
          GestureDetector(
            onTap: _startScan,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.orange.withOpacity(0.5),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Container(
                margin: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: AppColors.orange,
                  shape: BoxShape.circle,
                ),
                child: _isScanning
                    ? const Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                          strokeWidth: 3,
                        ),
                      )
                    : const Icon(
                        Icons.camera_alt_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _isScanning ? 'Analyse en cours...' : 'Appuyez pour scanner',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // OVERLAY RÉSULTAT
  // ============================================

  Widget _buildResultOverlay(BuildContext context) {
    final result = _scanResult!;
    return Container(
      color: Colors.black.withOpacity(0.85),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: (result['success'] == true
                                ? AppColors.success
                                : Colors.red)
                            .withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        result['success'] == true
                            ? Icons.check_circle_rounded
                            : Icons.error_rounded,
                        color: result['success'] == true
                            ? AppColors.success
                            : Colors.red,
                        size: 36,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      result['title'] ?? 'Résultat',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.navy,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      result['description'] ?? '',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (result['data'] != null) ...[
                      const SizedBox(height: 16),
                      ...((result['data'] as Map<String, dynamic>)
                          .entries
                          .map((e) => _buildResultRow(e.key, e.value))),
                    ],
                    const SizedBox(height: 24),
                    PremiumButton(
                      text: 'Terminer',
                      onPressed: () {
                        setState(() {
                          _showResult = false;
                          _scanResult = null;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value.toString(),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.navy,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // LOGIQUE DE SCAN
  // ============================================

  void _startScan() async {
    setState(() => _isScanning = true);

    // Simulation d'analyse (à remplacer par la vraie logique)
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    setState(() {
      _isScanning = false;
      _showResult = true;

      // Résultats simulés selon le mode
      switch (_selectedMode) {
        case ScanMode.qrCode:
          _scanResult = {
            'success': true,
            'title': 'Véhicule identifié',
            'description': 'QR code détecté avec succès',
            'data': {
              'Marque': 'Tesla',
              'Modèle': 'Model 3',
              'Plaque': 'AB-123-CD',
            },
          };
          break;
        case ScanMode.plate:
          _scanResult = {
            'success': true,
            'title': 'Plaque détectée',
            'description': 'Immatriculation reconnue',
            'data': {
              'Plaque': 'AB-123-CD',
              'Pays': '🇫🇷 France',
              'Confiance': '98%',
            },
          };
          break;
        case ScanMode.part:
          _scanResult = {
            'success': true,
            'title': 'Pièce analysée',
            'description': 'Usure détectée',
            'data': {
              'Type': 'Plaquette de frein',
              'Usure': '92%',
              'État': '⚠️ À remplacer',
            },
          };
          break;
      }
    });
  }
}
