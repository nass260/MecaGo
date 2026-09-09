// lib/features/home/presentation/pages/reminders_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/premium_card.dart';
import '../managers/home_notifier.dart';

class RemindersPage extends StatefulWidget {
  const RemindersPage({super.key});

  @override
  State<RemindersPage> createState() => _RemindersPageState();
}

class _RemindersPageState extends State<RemindersPage> {
  final HomeNotifier _notifier = HomeNotifier();

  // Données simulées de rappels d'entretien
  final List<Map<String, dynamic>> _reminders = [
    {
      'id': '1',
      'title': 'Vidange moteur',
      'description': 'Huile moteur + filtre',
      'dueDate': '15 Avril 2026',
      'remainingKm': '1 200 km',
      'vehicle': 'Tesla Model 3',
      'plate': 'AB-123-CD',
      'priority': 'Élevée',
      'icon': Icons.opacity_rounded,
      'color': Colors.red,
    },
    {
      'id': '2',
      'title': 'Filtre habitacle HEPA',
      'description': 'Remplacement recommandé',
      'dueDate': '30 Mai 2026',
      'remainingKm': '8 500 km',
      'vehicle': 'Tesla Model 3',
      'plate': 'AB-123-CD',
      'priority': 'Moyenne',
      'icon': Icons.filter_alt_rounded,
      'color': AppColors.orange,
    },
    {
      'id': '3',
      'title': 'Plaquettes de frein',
      'description': 'Jeu de plaquettes avant',
      'dueDate': '10 Juin 2026',
      'remainingKm': '3 200 km',
      'vehicle': 'Renault Clio 5',
      'plate': 'EF-456-GH',
      'priority': 'Élevée',
      'icon': Icons.car_repair_rounded,
      'color': Colors.red,
    },
    {
      'id': '4',
      'title': 'Liquide de refroidissement',
      'description': 'Niveau à contrôler',
      'dueDate': '20 Juillet 2026',
      'remainingKm': '5 000 km',
      'vehicle': 'Tesla Model 3',
      'plate': 'AB-123-CD',
      'priority': 'Faible',
      'icon': Icons.ac_unit_rounded,
      'color': AppColors.success,
    },
    {
      'id': '5',
      'title': 'Changement pneus',
      'description': 'Pneus hiver → été',
      'dueDate': '01 Avril 2026',
      'remainingKm': '200 km',
      'vehicle': 'Renault Clio 5',
      'plate': 'EF-456-GH',
      'priority': 'Critique',
      'icon': Icons.grass_rounded,
      'color': Colors.red,
    },
  ];

  @override
  void initState() {
    super.initState();
    _notifier.loadDashboardData();
  }

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
          'Rappels d\'entretien',
          style: TextStyle(
            color: AppColors.navy,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded, color: AppColors.navy),
            onPressed: () {
              // Filtrer les rappels
              _showFilterDialog();
            },
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _notifier,
        builder: (context, _) {
          if (_notifier.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.orange),
              ),
            );
          }

          // Compter les rappels par priorité
          final criticalCount = _reminders.where((r) => r['priority'] == 'Critique').length;
          final highCount = _reminders.where((r) => r['priority'] == 'Élevée').length;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ============================================
                // 1. RÉSUMÉ DES RAPPELS
                // ============================================
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryCard(
                        title: 'Critique',
                        count: criticalCount,
                        color: Colors.red,
                        icon: Icons.warning_rounded,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSummaryCard(
                        title: 'Élevée',
                        count: highCount,
                        color: AppColors.orange,
                        icon: Icons.priority_high_rounded,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSummaryCard(
                        title: 'Total',
                        count: _reminders.length,
                        color: AppColors.navy,
                        icon: Icons.list_rounded,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // ============================================
                // 2. LISTE DES RAPPELS
                // ============================================
                const Text(
                  'Tous les rappels',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),

                if (_reminders.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(40),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.border.withOpacity(0.4)),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.notifications_off_rounded,
                          size: 64,
                          color: AppColors.border,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Aucun rappel',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.navy,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tous vos entretiens sont à jour ! 🎉',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Column(
                    children: _reminders.map((reminder) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildReminderCard(reminder),
                      );
                    }).toList(),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required int count,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderCard(Map<String, dynamic> reminder) {
    final priority = reminder['priority'];
    Color priorityColor;
    String priorityIcon;

    switch (priority) {
      case 'Critique':
        priorityColor = Colors.red;
        priorityIcon = '🚨';
        break;
      case 'Élevée':
        priorityColor = AppColors.orange;
        priorityIcon = '⚠️';
        break;
      case 'Moyenne':
        priorityColor = Colors.blue;
        priorityIcon = '📌';
        break;
      default:
        priorityColor = AppColors.success;
        priorityIcon = '✅';
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: priorityColor.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: priorityColor.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icône
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: priorityColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              reminder['icon'],
              color: priorityColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          // Contenu
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      reminder['title'],
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.navy,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      priorityIcon,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  reminder['description'],
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      reminder['vehicle'],
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.navy,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '· ${reminder['plate']}',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Date et KM
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: priorityColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  reminder['dueDate'],
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: priorityColor,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    Icons.speed_rounded,
                    size: 12,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    reminder['remainingKm'],
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(width: 8),
          // Flèche
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.border.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filtrer les rappels',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.navy,
              ),
            ),
            const SizedBox(height: 16),
            _buildFilterOption('Tous', Icons.list_rounded, true),
            _buildFilterOption('Critique', Icons.warning_rounded, false),
            _buildFilterOption('Élevée', Icons.priority_high_rounded, false),
            _buildFilterOption('Moyenne', Icons.flag_rounded, false),
            _buildFilterOption('Faible', Icons.check_circle_rounded, false),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  'Appliquer',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterOption(String label, IconData icon, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            icon,
            color: isSelected ? AppColors.orange : AppColors.textSecondary,
            size: 22,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isSelected ? AppColors.orange : AppColors.navy,
            ),
          ),
          const Spacer(),
          if (isSelected)
            const Icon(
              Icons.check_circle_rounded,
              color: AppColors.orange,
              size: 20,
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _notifier.dispose();
    super.dispose();
  }
}
