import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme.dart';
import '../../../data/providers/goal_provider.dart';
import '../../../data/models/goal_model.dart';

/// Goals screen - set and track fitness goals
class GoalsScreen extends ConsumerStatefulWidget {
  const GoalsScreen({super.key});

  @override
  ConsumerState<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends ConsumerState<GoalsScreen> {
  @override
  Widget build(BuildContext context) {
    final goalsAsync = ref.watch(goalNotifierProvider);
    final completionAsync = ref.watch(goalCompletionProvider);

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        backgroundColor: AppTheme.darkBg,
        title: const Text('My Goals'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppTheme.primaryColor),
            onPressed: () => _showAddGoalSheet(context),
          ),
        ],
      ),
      body: goalsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor)),
        error: (e, _) => Center(child: Text('$e', style: TextStyle(color: AppTheme.darkTextMuted))),
        data: (goals) {
          if (goals.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.flag_outlined, size: 72, color: AppTheme.darkBorder),
                  const SizedBox(height: 16),
                  const Text('No goals yet',
                      style: TextStyle(color: AppTheme.darkText, fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Text('Tap + to set your first fitness goal',
                      style: TextStyle(color: AppTheme.darkTextMuted)),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Set a Goal'),
                    onPressed: () => _showAddGoalSheet(context),
                  ),
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Smart suggestions banner
              _SmartSuggestionCard().animate().fadeIn(),
              const SizedBox(height: 16),
              const Text('Active Goals',
                  style: TextStyle(color: AppTheme.darkText, fontWeight: FontWeight.w600, fontSize: 16)),
              const SizedBox(height: 12),
              ...goals.where((g) => g.isActive).toList().asMap().entries.map((entry) {
                final i = entry.key;
                final goal = entry.value;
                // Get completion % from completionAsync
                final completion = completionAsync.value
                    ?.firstWhere((c) => c['_id'] == goal.id, orElse: () => {});
                final pct = (completion?['completionPercentage'] as num?)?.toDouble() ?? 0;
                return _GoalCard(
                  goal: goal,
                  completionPct: pct,
                  onDelete: () async {
                    await ref.read(goalNotifierProvider.notifier).deleteGoal(goal.id);
                  },
                ).animate(delay: Duration(milliseconds: i * 100)).fadeIn().slideX(begin: 0.1, end: 0);
              }),
              if (goals.any((g) => !g.isActive)) ...[
                const SizedBox(height: 20),
                const Text('Completed Goals',
                    style: TextStyle(color: AppTheme.darkTextMuted, fontWeight: FontWeight.w500)),
                const SizedBox(height: 12),
                ...goals.where((g) => !g.isActive).map((goal) => _GoalCard(
                  goal: goal,
                  completionPct: 100,
                  onDelete: () async {
                    await ref.read(goalNotifierProvider.notifier).deleteGoal(goal.id);
                  },
                )),
              ],
              const SizedBox(height: 80),
            ],
          );
        },
      ),
    );
  }

  void _showAddGoalSheet(BuildContext context) {
    String selectedGoalType = 'weight_loss';
    final targetWeightCtrl = TextEditingController();
    final targetStepsCtrl = TextEditingController(text: '10000');
    DateTime? deadline;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.darkSurface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Set a New Goal',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.darkText)),
              const SizedBox(height: 16),

              // Goal type selector
              const Text('Goal Type', style: TextStyle(color: AppTheme.darkTextMuted, fontSize: 13)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: {
                  'weight_loss': 'Weight Loss',
                  'weight_gain': 'Weight Gain',
                  'maintenance': 'Maintenance',
                  'muscle_building': 'Muscle',
                }.entries.map((e) {
                  final isSelected = selectedGoalType == e.key;
                  return GestureDetector(
                    onTap: () => setModalState(() => selectedGoalType = e.key),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.primaryColor : AppTheme.darkSurface2,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: isSelected ? AppTheme.primaryColor : AppTheme.darkBorder),
                      ),
                      child: Text(e.value,
                          style: TextStyle(
                              color: isSelected ? Colors.white : AppTheme.darkTextMuted,
                              fontSize: 13)),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Target weight
              TextField(
                controller: targetWeightCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: AppTheme.darkText),
                decoration: const InputDecoration(
                  hintText: 'Target Weight (kg)',
                  prefixIcon: Icon(Icons.monitor_weight_outlined),
                ),
              ),
              const SizedBox(height: 12),

              // Target steps
              TextField(
                controller: targetStepsCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: AppTheme.darkText),
                decoration: const InputDecoration(
                  hintText: 'Daily Steps Goal',
                  prefixIcon: Icon(Icons.directions_walk),
                ),
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final success = await ref.read(goalNotifierProvider.notifier).createGoal({
                      'goalType': selectedGoalType,
                      'targetWeight': double.tryParse(targetWeightCtrl.text),
                      'targetSteps': int.tryParse(targetStepsCtrl.text) ?? 10000,
                    });
                    if (success && ctx.mounted) {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Goal created! 🎯'), backgroundColor: AppTheme.accentGreen),
                      );
                    }
                  },
                  child: const Text('Create Goal'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  final GoalModel goal;
  final double completionPct;
  final VoidCallback onDelete;

  const _GoalCard({required this.goal, required this.completionPct, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final color = {
      'weight_loss': AppTheme.accentColor,
      'weight_gain': AppTheme.accentOrange,
      'maintenance': AppTheme.accentGreen,
      'muscle_building': AppTheme.accentPink,
    }[goal.goalType] ?? AppTheme.primaryColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.darkSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.darkBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.flag, color: color, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(goal.goalTypeLabel,
                        style: const TextStyle(
                            color: AppTheme.darkText, fontWeight: FontWeight.w600, fontSize: 15)),
                    if (goal.targetWeight != null)
                      Text('Target: ${goal.targetWeight}kg',
                          style: TextStyle(color: AppTheme.darkTextMuted, fontSize: 12)),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: AppTheme.darkTextMuted, size: 18),
                onPressed: onDelete,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Progress', style: TextStyle(color: AppTheme.darkTextMuted, fontSize: 12)),
              Text('${completionPct.toInt()}%',
                  style: TextStyle(color: color, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (completionPct / 100).clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: color.withOpacity(0.15),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          if (goal.daysRemaining != null) ...[
            const SizedBox(height: 8),
            Text(
              goal.daysRemaining! > 0
                  ? '${goal.daysRemaining} days remaining'
                  : 'Deadline passed',
              style: TextStyle(
                  color: goal.daysRemaining! > 7 ? AppTheme.darkTextMuted : AppTheme.accentOrange,
                  fontSize: 11),
            ),
          ],
        ],
      ),
    );
  }
}

class _SmartSuggestionCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A0A4E), Color(0xFF0A2540)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Text('💡', style: TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Smart Suggestion',
                    style: TextStyle(color: AppTheme.darkText, fontWeight: FontWeight.w600)),
                SizedBox(height: 4),
                Text('Stay consistent! Users who log daily are 3x more likely to reach their goals.',
                    style: TextStyle(color: AppTheme.darkTextMuted, fontSize: 12, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
