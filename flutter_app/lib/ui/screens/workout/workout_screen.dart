import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';
import '../../../core/router.dart';
import '../../../data/providers/workout_provider.dart';
import '../../../data/models/workout_model.dart';

/// Workout screen - browse predefined and custom workouts + AI suggestions
class WorkoutScreen extends ConsumerStatefulWidget {
  const WorkoutScreen({super.key});

  @override
  ConsumerState<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends ConsumerState<WorkoutScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedType = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final workoutsAsync = ref.watch(allWorkoutsProvider);
    final suggestionsAsync = ref.watch(workoutSuggestionsProvider);

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        title: const Text('Workouts'),
        backgroundColor: AppTheme.darkBg,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: AppTheme.primaryColor),
            onPressed: () => _showCreateWorkoutSheet(context),
            tooltip: 'Create custom workout',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryColor,
          indicatorSize: TabBarIndicatorSize.label,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: AppTheme.darkTextMuted,
          tabs: const [
            Tab(text: 'Browse'),
            Tab(text: 'History'),
            Tab(text: 'AI Tips'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // ── Browse Tab ──────────────────────────────────────────────────
          Column(
            children: [
              // Type filter chips
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['all', 'gym', 'home', 'outdoor'].map((type) {
                      final isSelected = _selectedType == type;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedType = type),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? AppTheme.primaryColor : AppTheme.darkSurface2,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? AppTheme.primaryColor : AppTheme.darkBorder,
                            ),
                          ),
                          child: Text(
                            type[0].toUpperCase() + type.substring(1),
                            style: TextStyle(
                              color: isSelected ? Colors.white : AppTheme.darkTextMuted,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: workoutsAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor)),
                  error: (e, _) => Center(
                    child: Text('$e', style: TextStyle(color: AppTheme.darkTextMuted)),
                  ),
                  data: (workouts) {
                    final filtered = _selectedType == 'all'
                        ? workouts
                        : workouts.where((w) => w.type == _selectedType).toList();
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filtered.length,
                      itemBuilder: (ctx, i) => _WorkoutCard(
                        workout: filtered[i],
                        onTap: () => context.go('/workout/${filtered[i].id}', extra: {
                          'name': filtered[i].name,
                          'exercises': filtered[i].exercises.map((e) => e.toJson()).toList(),
                        }),
                      ).animate(delay: Duration(milliseconds: i * 80)).fadeIn().slideX(begin: 0.1, end: 0),
                    );
                  },
                ),
              ),
            ],
          ),

          // ── History Tab ──────────────────────────────────────────────────
          _WorkoutHistoryTab(),

          // ── AI Suggestions Tab ───────────────────────────────────────────
          suggestionsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor)),
            error: (e, _) => Center(child: Text('$e', style: TextStyle(color: AppTheme.darkTextMuted))),
            data: (data) => _AISuggestionsTab(data: data),
          ),
        ],
      ),
    );
  }

  void _showCreateWorkoutSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.darkSurface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Custom Workout', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.darkText)),
            const SizedBox(height: 16),
            Text('Custom workout creator coming soon!\nTap the + button to build your own routine.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.darkTextMuted)),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _WorkoutCard extends StatelessWidget {
  final WorkoutModel workout;
  final VoidCallback onTap;
  const _WorkoutCard({required this.workout, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final difficultyColor = {
      'beginner': AppTheme.accentGreen,
      'intermediate': AppTheme.accentColor,
      'advanced': AppTheme.accentOrange,
    }[workout.difficulty] ?? AppTheme.accentColor;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.darkSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.darkBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.fitness_center, color: Colors.white, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(workout.name,
                      style: const TextStyle(
                          color: AppTheme.darkText, fontWeight: FontWeight.w600, fontSize: 15)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.timer_outlined, size: 12, color: AppTheme.darkTextMuted),
                      const SizedBox(width: 4),
                      Text('${workout.estimatedDuration} min',
                          style: TextStyle(color: AppTheme.darkTextMuted, fontSize: 12)),
                      const SizedBox(width: 10),
                      Icon(Icons.local_fire_department, size: 12, color: AppTheme.accentOrange),
                      const SizedBox(width: 4),
                      Text('~${workout.estimatedCalories} kcal',
                          style: TextStyle(color: AppTheme.darkTextMuted, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: difficultyColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(workout.difficulty,
                      style: TextStyle(color: difficultyColor, fontSize: 11, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.darkSurface2,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(workout.type,
                      style: TextStyle(color: AppTheme.darkTextMuted, fontSize: 11)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkoutHistoryTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(workoutHistoryProvider);
    return historyAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor)),
      error: (e, _) => Center(child: Text('$e', style: TextStyle(color: AppTheme.darkTextMuted))),
      data: (logs) {
        if (logs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.history, size: 64, color: AppTheme.darkBorder),
                const SizedBox(height: 12),
                Text('No workout history yet', style: TextStyle(color: AppTheme.darkTextMuted)),
                const SizedBox(height: 4),
                Text('Complete a workout to see it here!', style: TextStyle(color: AppTheme.darkBorder, fontSize: 12)),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: logs.length,
          itemBuilder: (ctx, i) {
            final log = logs[i];
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.darkSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.darkBorder),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: AppTheme.accentGreen),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(log.workoutName,
                            style: const TextStyle(color: AppTheme.darkText, fontWeight: FontWeight.w500)),
                        Text('${log.date.day}/${log.date.month}/${log.date.year} · ${log.caloriesBurned} kcal',
                            style: TextStyle(color: AppTheme.darkTextMuted, fontSize: 12)),
                      ],
                    ),
                  ),
                  Text('${log.totalDuration} min',
                      style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w600)),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _AISuggestionsTab extends StatelessWidget {
  final Map<String, dynamic> data;
  const _AISuggestionsTab({required this.data});

  @override
  Widget build(BuildContext context) {
    final suggestions = data['suggestions'] as List? ?? [];
    final tip = data['tip'] as String? ?? '';

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const Text('🤖', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(tip,
                    style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.4)),
              ),
            ],
          ),
        ).animate().fadeIn(),
        const SizedBox(height: 16),
        const Text('Recommended for You',
            style: TextStyle(color: AppTheme.darkText, fontWeight: FontWeight.w600, fontSize: 16)),
        const SizedBox(height: 12),
        ...List.generate(suggestions.length, (i) {
          final s = suggestions[i] as Map<String, dynamic>;
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
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
                    Expanded(
                      child: Text(s['title'] as String,
                          style: const TextStyle(
                              color: AppTheme.darkText, fontWeight: FontWeight.w600, fontSize: 15)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('${s['duration']} min',
                          style: const TextStyle(color: AppTheme.primaryColor, fontSize: 11, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(s['reason'] as String,
                    style: TextStyle(color: AppTheme.darkTextMuted, fontSize: 13)),
              ],
            ),
          ).animate(delay: Duration(milliseconds: i * 100)).fadeIn().slideX(begin: 0.1, end: 0);
        }),
      ],
    );
  }
}
