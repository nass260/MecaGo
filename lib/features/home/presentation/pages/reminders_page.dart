// lib/features/home/presentation/pages/reminders_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';

class RemindersPage extends StatefulWidget {
  const RemindersPage({super.key});

  @override
  State<RemindersPage> createState() => _RemindersPageState();
}

class _RemindersPageState extends State<RemindersPage> {
  String _selectedFilter = 'Tous';

  final List<String> _filters = ['Tous', 'Critique', 'Élevée', 'Moyenne', 'Faible'];

  final List<Map<String, dynamic>> _reminders = [
    {
      'title': 'Vidange moteur',
      'description': 'Huile moteur + filtre',
      'dueDate': '15 Avril 2026',
      'remainingKm': '1 200 km',
      'vehicle': 'Tesla Model 3',
      'plate': 'AB-123-CD',
      'priority': 'Élevée',
      'icon': Icons.opacity_rounded,
    },
    {
      'title': 'Filtre habitacle HEPA',
      'description': 'Remplacement recommandé',
      'dueDate': '30 Mai 2026',
      'remainingKm': '8 500 km',
      'vehicle': 'Tesla Model 3',
      'plate': 'AB-123-CD',
      'priority': 'Moyenne',
      'icon': Icons.filter_alt_rounded,
    },
    {
      'title': 'Plaquettes de frein',
      'description': 'Jeu de plaquettes avant',
      'dueDate': '10 Juin 2026',
      'remainingKm': '3 200 km',
      'vehicle': 'Renault Clio 5',
      'plate': 'EF-456-GH',
      'priority': 'Critique',
      'icon': Icons.car_repair_rounded,
    },
    {
      'title': 'Liquide de refroidissement',
      'description': 'Niveau à contrôler',
      'dueDate': '20 Juillet 2026',
      'remainingKm': '5 000 km',
      'vehicle': 'Tesla Model 3',
      'plate': 'AB-123-CD',
      'priority': 'Faible',
      'icon': Icons.ac_unit_rounded,
    },
    {
      'title': 'Changement pneus',
      'description': 'Pneus hiver → été',
      'dueDate': '01 Avril 2026',
      'remainingKm': '200 km',
      'vehicle': 'Renault Clio 5',
      'plate': 'EF-456-GH',
      'priority': 'Critique',
      'icon': Icons.tire_repair_rounded,
    },
  ];

  List<Map<String, dynamic>> get _filteredReminders {
    if (_selectedFilter == 'Tous') return _reminders;
    return _reminders.where((r) => r['priority'] == _selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final criticalCount =
        _reminders.where((r) => r['priority'] == 'Critique').length;
    final highCount =
        _reminders.where((r) => r['priority'] == 'Élevée').length;

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
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // RÉSUMÉ
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      title: 'Critique',
                      count: criticalCount,
                      color: AppColors.danger,
                      icon: Icons.warning_rounded,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildSummaryCard(
                      title: 'Élevée',
                      count: highCount,
                      color: AppColors.orange,
                      icon: Icons.priority_high_rounded,
                    ),
                  ),
                  const SizedBox(width: 10),
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
            ),
            const SizedBox(height: 20),

            // FILTRES
            SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: _filters.map((filter) {
                  final isSelected = _selectedFilter == filter;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedFilter = filter),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.orange : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.orange
                              : AppColors.border,
                        ),
                        boxShadow: isSelected
                            ? AppShadows.orangeButton
                            : AppShadows.card,
                      ),
                      child: Center(
                        child: Text(
                          filter,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : AppColors.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // LISTE
            Text(
              '${_filteredReminders.length} rappel${_filteredReminders.length > 1 ? 's' : ''}',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),

            ..._filteredReminders.map((reminder) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _buildReminderCard(reminder),
              );
            }),
          ],
        ),
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
        boxShadow: AppShadows.card,
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
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
            style: const TextStyle(
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
        priorityColor = AppColors.danger;
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
        boxShadow: AppShadows.card,
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: priorityColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              reminder['icon'] as IconData,
              color: priorityColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        reminder['title'] as String,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.navy,
                        ),
                      ),
                    ),
                    Text(priorityIcon, style: const TextStyle(fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  reminder['description'] as String,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${reminder['vehicle']} · ${reminder['plate']}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.navy,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: priorityColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  reminder['dueDate'] as String,
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
                  const Icon(Icons.speed_rounded,
                      size: 12, color: AppColors.textSecondary),
                  const SizedBox(width: 2),
                  Text(
                    reminder['remainingKm'] as String,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}