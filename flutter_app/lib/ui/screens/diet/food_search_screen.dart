import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme.dart';
import '../../../data/providers/meal_provider.dart';
import '../../../data/models/meal_model.dart';

/// Food search screen - search food database and add to a meal
class FoodSearchScreen extends ConsumerStatefulWidget {
  final String mealType;
  const FoodSearchScreen({super.key, required this.mealType});

  @override
  ConsumerState<FoodSearchScreen> createState() => _FoodSearchScreenState();
}

class _FoodSearchScreenState extends ConsumerState<FoodSearchScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  bool _isAdding = false;
  final List<Map<String, dynamic>> _selectedFoods = [];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _logMeal() async {
    if (_selectedFoods.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least one food item.')),
      );
      return;
    }
    setState(() => _isAdding = true);
    try {
      final mealData = {
        'mealType': widget.mealType,
        'date': DateTime.now().toIso8601String(),
        'items': _selectedFoods,
      };
      final success = await ref.read(mealNotifierProvider.notifier).addMeal(mealData);
      if (success && mounted) {
        ref.invalidate(mealsProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Meal logged! 🎉'), backgroundColor: AppTheme.accentGreen),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isAdding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final searchAsync = ref.watch(foodSearchProvider(_query));

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        backgroundColor: AppTheme.darkBg,
        title: Text('Add to ${widget.mealType[0].toUpperCase()}${widget.mealType.substring(1)}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (_selectedFoods.isNotEmpty)
            TextButton(
              onPressed: _isAdding ? null : _logMeal,
              child: _isAdding
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text('Add (${_selectedFoods.length})',
                      style: const TextStyle(color: AppTheme.accentGreen, fontWeight: FontWeight.w600)),
            ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              controller: _searchCtrl,
              autofocus: true,
              style: const TextStyle(color: AppTheme.darkText),
              decoration: InputDecoration(
                hintText: 'Search food (e.g. chicken, oats)',
                prefixIcon: const Icon(Icons.search, color: AppTheme.darkTextMuted),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: AppTheme.darkTextMuted),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _query = '');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppTheme.darkBorder),
                ),
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),

          // Selected foods preview
          if (_selectedFoods.isNotEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 40,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: _selectedFoods.length,
                itemBuilder: (ctx, i) => Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.accentGreen.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.accentGreen),
                  ),
                  child: Row(
                    children: [
                      Text(_selectedFoods[i]['foodName'],
                          style: const TextStyle(color: AppTheme.accentGreen, fontSize: 12, fontWeight: FontWeight.w500)),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () => setState(() => _selectedFoods.removeAt(i)),
                        child: const Icon(Icons.close, color: AppTheme.accentGreen, size: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],

          const SizedBox(height: 8),

          // Search results
          Expanded(
            child: _query.trim().isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.restaurant_menu, size: 64, color: AppTheme.darkBorder),
                        const SizedBox(height: 12),
                        Text('Search for food to add', style: TextStyle(color: AppTheme.darkTextMuted)),
                      ],
                    ),
                  )
                : searchAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor)),
                    error: (e, _) => Center(child: Text('$e', style: TextStyle(color: AppTheme.darkTextMuted))),
                    data: (foods) {
                      if (foods.isEmpty) {
                        return Center(
                          child: Text('No results for "$_query"',
                              style: TextStyle(color: AppTheme.darkTextMuted)),
                        );
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: foods.length,
                        itemBuilder: (ctx, i) {
                          final food = foods[i];
                          final isSelected = _selectedFoods.any((f) => f['foodName'] == food.name);
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  _selectedFoods.removeWhere((f) => f['foodName'] == food.name);
                                } else {
                                  _selectedFoods.add({
                                    'foodName': food.name,
                                    'quantity': 1,
                                    'unit': food.servingUnit,
                                    'calories': food.calories,
                                    'protein': food.protein,
                                    'carbs': food.carbs,
                                    'fat': food.fat,
                                  });
                                }
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppTheme.accentGreen.withOpacity(0.1)
                                    : AppTheme.darkSurface,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isSelected ? AppTheme.accentGreen : AppTheme.darkBorder,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 42,
                                    height: 42,
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(Icons.restaurant, color: AppTheme.primaryColor, size: 20),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(food.name,
                                            style: const TextStyle(
                                                color: AppTheme.darkText,
                                                fontWeight: FontWeight.w500,
                                                fontSize: 14)),
                                        const SizedBox(height: 3),
                                        Text(
                                          '${food.calories.toInt()} kcal · P: ${food.protein.toInt()}g · C: ${food.carbs.toInt()}g · F: ${food.fat.toInt()}g',
                                          style: TextStyle(color: AppTheme.darkTextMuted, fontSize: 11),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    isSelected ? Icons.check_circle : Icons.add_circle_outline,
                                    color: isSelected ? AppTheme.accentGreen : AppTheme.darkTextMuted,
                                    size: 22,
                                  ),
                                ],
                              ),
                            ).animate(delay: Duration(milliseconds: i * 50)).fadeIn(),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
