import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // <-- 1. Importation de navigation ajoutée

// ==========================================
// CHARTE GRAPHIQUE PREMIUM (Style Apple)
// ==========================================
class AppColors {
  static const Color orange = Color(0xFFFF6A00);
  static const Color navy = Color(0xFF111827);
  static const Color background = Color(0xFFF3F7FB);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color success = Color(0xFF10B981);
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(), // Effet élastique iPhone
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              // 1. EN-TÊTE CHIRURGICAL APPPLE STYLE
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('MECAGO CENTRAL', style: TextStyle(color: AppColors.orange, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                        SizedBox(height: 4),
                        Text('Bonjour, Pro 🛠️', style: TextStyle(color: AppColors.navy, fontSize: 26, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                    child: const Icon(Icons.notifications_none_rounded, color: AppColors.navy, size: 22),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // 2. CARTE MECA GO SCORE
              Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.grey.shade100)),
                child: Row(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle),
                      child: const Center(child: Text('85', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'monospace'))),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('MecaGo Score™', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.navy)),
                          SizedBox(height: 4),
                          Text('Santé globale optimale. Prochaine vérification dans 4 500 km.', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.4)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              const Text('Véhicule Actif', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.navy, letterSpacing: -0.3)),
              const SizedBox(height: 14),
              
              // 3. LA CARTE TESLA CONCEPT DESIGN
              Container(
                padding: const EdgeInsets.all(22.0),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(26), border: Border.all(color: Colors.grey.shade100)),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('Tesla Model 3', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.navy)),
                            SizedBox(height: 2),
                            Text('Dual Motor — Électrique', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.navy, width: 1.5)),
                          child: const Text('AB-123-CD', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'monospace', color: AppColors.navy, fontSize: 12)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // Silhouette vectorielle épurée de la Tesla
                    Container(
                      width: double.infinity,
                      height: 120,
                      decoration: BoxDecoration(color: AppColors.navy, borderRadius: BorderRadius.circular(20)),
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.electric_car_rounded, size: 48, color: Colors.white),
                            SizedBox(height: 8),
                            Text('SYS. ÉLECTRIQUE SYNC.', style: TextStyle(color: Colors.white60, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // 2. LE BOUTON CONNECTÉ AU ROUTEUR
                    InkWell(
                      onTap: () {
                        context.push('/reminders'); // Navigue vers l'écran des Rappels Intelligents
                      },
                      child: Container(
                        width: double.infinity,
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [AppColors.orange, Color(0xFFFF8C00)]),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [BoxShadow(color: AppColors.orange.withOpacity(0.25), blurRadius: 16, offset: const Offset(0, 6))],
                        ),
                        child: const Center(
                          child: Text('Démarrer un entretien', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                        ),
                      ),
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
}
