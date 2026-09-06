import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/premium_card.dart';
import '../../../../core/widgets/premium_button.dart';
import '../../infrastructure/services/autodoc_shop_service.dart';

class PartsCatalogPage extends StatefulWidget {
  const PartsCatalogPage({super.key});

  @override
  State<PartsCatalogPage> createState() => _PartsCatalogPageState();
}

class _PartsCatalogPageState extends State<PartsCatalogPage> {
  final AutodocShopService _shopService = const AutodocShopService();
  bool _isLoading = false;
  
  // Données de tarification dynamiques injectées par notre service France
  String _filterPrice = "18.50 €";
  String _filterBrand = "PURFLUX";
  String _brakePrice = "45.00 €";
  String _brakeBrand = "VALEO Tech";

  @override
  void initState() {
    super.initState();
    _loadMarketPricing();
  }

  /// Interroge le service commercial pour extraire les tarifs leaders du marché français
  Future<void> _loadMarketPricing() async {
    setState(() => _isLoading = true);
    
    final filterData = await _shopService.fetchCompatiblePartPricing(vehicleBrand: "RENAULT", partCategory: "filtre");
    final brakeData = await _shopService.fetchCompatiblePartPricing(vehicleBrand: "RENAULT", partCategory: "frein");

    if (mounted) {
      setState(() {
        _filterPrice = filterData['estimated_price'] as String;
        _filterBrand = filterData['recommended_brand'] as String;
        _brakePrice = brakeData['estimated_price'] as String;
        _brakeBrand = brakeData['recommended_brand'] as String;
        _isLoading = false;
      });
    }
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
          'Pièces & Consommables',
          style: TextStyle(color: AppColors.navy, fontWeight: FontWeight.w800, letterSpacing: -0.5),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppColors.orange)),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Bandeau de guidage
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'COMPATIBILITÉ CERTIFIÉE SIV FRANCE',
                          style: TextStyle(color: AppColors.orange, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Achetez vos composants',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.navy, letterSpacing: -0.6),
                        ),
                      ],
                    ),
                  ),

                  // Liste des pièces leaders certifiées d'origine
                  Expanded(
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      children: [
                        _buildPartItem(
                          title: "Filtre d'habitacle Haute Efficacité",
                          brand: _filterBrand,
                          price: _filterPrice,
                          icon: Icons.air_rounded,
                          desc: "Filtration n°1 en France. Bloque 99% des allergènes.",
                        ),
                        const SizedBox(height: 16),
                        _buildPartItem(
                          title: "Jeu de 4 plaquettes de frein avant",
                          brand: _brakeBrand,
                          price: _brakePrice,
                          icon: Icons.disc_full_rounded,
                          desc: "Garniture d'origine française. Performance thermique accrue.",
                        ),
                        const SizedBox(height: 16),
                        _buildPartItem(
                          title: "Balais d'essuie-glace avant (paire)",
                          brand: "VALEO HydroConnect",
                          price: "22.00 €",
                          icon: Icons.water_drop_rounded,
                          desc: "Gomme longue durée. Profil aérodynamique anti-bruit.",
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildPartItem({
    required String title,
    required String brand,
    required String price,
    required IconData icon,
    required String desc,
  }) {
    return PremiumCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(14)),
                child: Icon(icon, color: AppColors.orange, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.navy, letterSpacing: -0.3)),
                    const SizedBox(height: 2),
                    Text('Marque : $brand 🇫🇷', style: const TextStyle(color: AppColors.orange, fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
              ),
              Text(price, style: const TextStyle(color: AppColors.navy, fontWeight: FontWeight.w900, fontSize: 18, fontFamily: 'monospace')),
            ],
          ),
          const SizedBox(height: 12),
          Text(desc, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4)),
          Divider(height: 24, color: AppColors.border.withOpacity(0.4)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.check_circle_rounded, color: AppColors.success, size: 16),
                  SizedBox(width: 6),
                  Text('En stock — Livraison 24h', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 12)),
                ],
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.navy,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 0,
                ),
                onPressed: () {}, // Lien d'affiliation commercial
                child: const Text('Commander', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
