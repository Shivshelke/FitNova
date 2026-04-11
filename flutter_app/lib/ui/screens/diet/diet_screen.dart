import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';
import '../../../core/router.dart';
import '../../../data/providers/meal_provider.dart';
import '../../../data/models/meal_model.dart';
import '../../../core/constants.dart';

/// Diet screen - shows daily meals with nutritional summary
class DietScreen extends ConsumerStatefulWidget {
  const DietScreen({super.key});

  @override
  ConsumerState<DietScreen> createState() => _DietScreenState();
}

class _DietScreenState extends ConsumerState<DietScreen> {
  @override
  Widget build(BuildContext context) {
    final mealsAsync = ref.watch(mealsProvider);
    final selectedDate = ref.watch(selectedMealDateProvider);

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        backgroundColor: AppTheme.darkBg,
        title: const Text('Nutrition'),
        actions: [
          // Date picker
          TextButton.icon(
            icon: const Icon(Icons.calendar_today, size: 16, color: AppTheme.primaryColor),
            label: Text(
              '${selectedDate.day}/${selectedDate.month}',
              style: const TextStyle(color: AppTheme.primaryColor),
            ),
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime.now().subtract(const Duration(days: 90)),
                lastDate: DateTime.now(),
                builder: (ctx, child) => Theme(
                  data: Theme.of(ctx).copyWith(
                    colorScheme: const ColorScheme.dark(primary: AppTheme.primaryColor),
                  ),
                  child: child!,
                ),
              );
              if (picked != null) {
                ref.read(selectedMealDateProvider.notifier).state = picked;
              }
            },
          ),
        ],
      ),
      body: mealsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor)),
        error: (e, _) => Center(
          child: Text('Error: $e', style: TextStyle(color: AppTheme.darkTextMuted)),
        ),
        data: (data) {
          final meals = data['meals'] as List<MealModel>;
          final totals = data['dailyTotals'] as Map<String, dynamic>? ?? {};

          return RefreshIndicator(
            color: AppTheme.primaryColor,
            onRefresh: () => ref.refresh(mealsProvider.future),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // ── Daily Summary Card ────────────────────────────────────
                _DailySummaryCard(totals: totals)
                    .animate().fadeIn().slideY(begin: 0.1, end: 0),

                const SizedBox(height: 20),

                // ── Meal sections ─────────────────────────────────────────
                ...AppConstants.mealTypes.map((mealType) {
                  final mealsList = meals.where((m) => m.mealType == mealType).toList();
                  return _MealSection(
                    mealType: mealType,
                    meals: mealsList,
                    onAddTap: () => context.go(
                      AppRoutes.foodSearch,
                      extra: {'mealType': mealType},
                    ),
                    onDeleteMeal: (mealId) async {
                      await ref.read(mealNotifierProvider.notifier).deleteMeal(mealId);
                      ref.invalidate(mealsProvider);
                    },
                  );
                }),

                const SizedBox(height: 80),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DailySummaryCard extends StatelessWidget {
  final Map<String, dynamic> totals;
  const _DailySummaryCard({required this.totals});

  @override
  Widget build(BuildContext context) {
    final calories = (totals['calories'] as num?)?.toInt() ?? 0;
    final protein = (totals['protein'] as num?)?.toInt() ?? 0;
    final carbs = (totals['carbs'] as num?)?.toInt() ?? 0;
    final fat = (totals['fat'] as num?)?.toInt() ?? 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.darkBorder),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Daily Summary',
                  style: TextStyle(color: AppTheme.darkText, fontWeight: FontWeight.w600, fontSize: 16)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('$calories kcal',
                    style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _MacroItem('Protein', protein, AppTheme.accentGreen, 'g'),
              _MacroItem('Carbs', carbs, AppTheme.accentColor, 'g'),
              _MacroItem('Fat', fat, AppTheme.accentOrange, 'g'),
            ],
          ),
          const SizedBox(height: 16),
          // Calorie progress bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('$calories / 2000 kcal',
                      style: TextStyle(color: AppTheme.darkTextMuted, fontSize: 12)),
                  Text('${(2000 - calories).clamp(0, 2000)} kcal remaining',
                      style: TextStyle(color: AppTheme.darkTextMuted, fontSize: 12)),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (calories / 2000).clamp(0.0, 1.0),
                  minHeight: 8,
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.15),
                  valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MacroItem extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  final String unit;
  const _MacroItem(this.label, this.value, this.color, this.unit);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text('$value$unit',
                style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: AppTheme.darkTextMuted, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _MealSection extends StatelessWidget {
  final String mealType;
  final List<MealModel> meals;
  final VoidCallback onAddTap;
  final Function(String) onDeleteMeal;

  const _MealSection({
    required this.mealType,
    required this.meals,
    required this.onAddTap,
    required this.onDeleteMeal,
  });

  @override
  Widget build(BuildContext context) {
    final label = AppConstants.mealTypeLabels[mealType] ?? mealType;
    final icons = {
      'breakfast': Icons.wb_sunny_outlined,
      'lunch': Icons.lunch_dining_outlined,
      'dinner': Icons.dinner_dining_outlined,
      'snack': Icons.restaurant_outlined,
    };
    final totalCal = meals.fold<double>(0, (s, m) => s + m.totalCalories);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.darkSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.darkBorder),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Icon(icons[mealType], color: AppTheme.primaryColor, size: 20),
                const SizedBox(width: 10),
                Text(label,
                    style: const TextStyle(
                        color: AppTheme.darkText, fontWeight: FontWeight.w600, fontSize: 15)),
                const Spacer(),
                if (totalCal > 0)
                  Text('${totalCal.toInt()} kcal',
                      style: TextStyle(color: AppTheme.darkTextMuted, fontSize: 13)),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: onAddTap,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.add, color: AppTheme.primaryColor, size: 16),
                  ),
                ),
              ],
            ),
          ),
          // Meal items
          if (meals.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 14, left: 14),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('No $label logged yet',
                    style: TextStyle(color: AppTheme.darkBorder, fontSize: 13)),
              ),
            )
          else
            ...meals.map((meal) => Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(meal.items.map((i) => i.foodName).join(', '),
                            style: const TextStyle(color: AppTheme.darkText, fontSize: 13)),
                        Text('${meal.totalCalories.toInt()} kcal · P: ${meal.totalProtein.toInt()}g · C: ${meal.totalCarbs.toInt()}g · F: ${meal.totalFat.toInt()}g',
                            style: TextStyle(color: AppTheme.darkTextMuted, fontSize: 11)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: AppTheme.darkTextMuted, size: 18),
                    onPressed: () => onDeleteMeal(meal.id),
                  ),
                ],
              ),
            )),
        ],
      ),
    );
  }
}
