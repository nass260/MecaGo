// lib/core/widgets/year_selector.dart
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Frise horizontale d'années 2005-2026
class YearSelector extends StatefulWidget {
  final List<int> years;
  final int? selectedYear;
  final ValueChanged<int> onChanged;

  const YearSelector({
    super.key,
    required this.years,
    required this.selectedYear,
    required this.onChanged,
  });

  @override
  State<YearSelector> createState() => _YearSelectorState();
}

class _YearSelectorState extends State<YearSelector> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelected();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToSelected() {
    if (widget.selectedYear == null) return;
    final index = widget.years.indexOf(widget.selectedYear!);
    if (index >= 0) {
      final offset = (index * 80.0) - (MediaQuery.of(context).size.width / 2) + 40;
      _scrollController.animateTo(
        offset.clamp(0.0, _scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: widget.years.length,
        itemBuilder: (context, index) {
          final year = widget.years[index];
          final isSelected = year == widget.selectedYear;

          return GestureDetector(
            onTap: () => widget.onChanged(year),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 70,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.orange : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? AppColors.orange : AppColors.border,
                  width: 1.5,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.orange.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Text(
                  '$year',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: isSelected ? Colors.white : AppColors.navy,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}