import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme.dart';
import '../../../data/providers/workout_provider.dart';

/// Workout detail screen - shows exercises and allows logging sets/reps/weight
class WorkoutDetailScreen extends ConsumerStatefulWidget {
  final String workoutId;
  final Map<String, dynamic>? workoutData;

  const WorkoutDetailScreen({super.key, required this.workoutId, this.workoutData});

  @override
  ConsumerState<WorkoutDetailScreen> createState() => _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends ConsumerState<WorkoutDetailScreen> {
  bool _isStarted = false;
  bool _isLogging = false;
  int _currentExercise = 0;
  final Map<int, List<Map<String, TextEditingController>>> _setControllers = {};

  List<Map<String, dynamic>> get exercises {
    if (widget.workoutData != null) {
      return List<Map<String, dynamic>>.from(widget.workoutData!['exercises'] ?? []);
    }
    return [];
  }

  String get workoutName => widget.workoutData?['name'] ?? 'Workout';

  @override
  void initState() {
    super.initState();
    // Initialize editing controllers for each exercise
    for (int i = 0; i < exercises.length; i++) {
      final ex = exercises[i];
      final sets = ex['defaultSets'] ?? 3;
      _setControllers[i] = List.generate(sets, (s) => {
        'reps': TextEditingController(text: '${ex['defaultReps'] ?? 10}'),
        'weight': TextEditingController(text: '${ex['defaultWeight'] ?? 0}'),
      });
    }
  }

  @override
  void dispose() {
    for (final sets in _setControllers.values) {
      for (final ctrls in sets) {
        ctrls['reps']?.dispose();
        ctrls['weight']?.dispose();
      }
    }
    super.dispose();
  }

  Future<void> _finishWorkout() async {
    setState(() => _isLogging = true);
    try {
      // Build workout log data
      final exerciseLogs = exercises.asMap().entries.map((entry) {
        final i = entry.key;
        final ex = entry.value;
        final sets = (_setControllers[i] ?? []).asMap().entries.map((s) => {
          'setNumber': s.key + 1,
          'reps': int.tryParse(s.value['reps']?.text ?? '0') ?? 0,
          'weight': double.tryParse(s.value['weight']?.text ?? '0') ?? 0,
          'completed': true,
        }).toList();
        return {
          'exerciseName': ex['name'] ?? '',
          'muscleGroup': ex['muscleGroup'] ?? 'full_body',
          'sets': sets,
        };
      }).toList();

      await ref.read(workoutLogNotifierProvider.notifier).logWorkout({
        'workoutName': workoutName,
        'exercises': exerciseLogs,
        'totalDuration': 45,
        'caloriesBurned': 300,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Workout logged successfully! 🎉'),
              ],
            ),
            backgroundColor: AppTheme.accentGreen,
          ),
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
      if (mounted) setState(() => _isLogging = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        backgroundColor: AppTheme.darkBg,
        title: Text(workoutName),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: exercises.isEmpty
          ? const Center(child: Text('No exercises found', style: TextStyle(color: AppTheme.darkTextMuted)))
          : Column(
              children: [
                // Exercise list
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: exercises.length,
                    itemBuilder: (ctx, i) => _ExerciseCard(
                      exercise: exercises[i],
                      setControllers: _setControllers[i] ?? [],
                      isActive: _isStarted && _currentExercise == i,
                      isStarted: _isStarted,
                      onSetFocus: () => setState(() => _currentExercise = i),
                    ).animate(delay: Duration(milliseconds: i * 100)).fadeIn().slideY(begin: 0.1, end: 0),
                  ),
                ),

                // Bottom action bar
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.darkSurface,
                    border: Border(top: BorderSide(color: AppTheme.darkBorder)),
                  ),
                  child: _isStarted
                      ? SizedBox(
                          width: double.infinity,
                          child: GestureDetector(
                            onTap: _isLogging ? null : _finishWorkout,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                gradient: AppTheme.greenGradient,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Center(
                                child: _isLogging
                                    ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                                    : const Text('✓ Finish & Log Workout',
                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)),
                              ),
                            ),
                          ),
                        )
                      : SizedBox(
                          width: double.infinity,
                          child: GestureDetector(
                            onTap: () => setState(() => _isStarted = true),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                gradient: AppTheme.primaryGradient,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.primaryColor.withOpacity(0.4),
                                    blurRadius: 15,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Text('▶ Start Workout',
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)),
                              ),
                            ),
                          ),
                        ),
                ),
              ],
            ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  final Map<String, dynamic> exercise;
  final List<Map<String, TextEditingController>> setControllers;
  final bool isActive;
  final bool isStarted;
  final VoidCallback onSetFocus;

  const _ExerciseCard({
    required this.exercise,
    required this.setControllers,
    required this.isActive,
    required this.isStarted,
    required this.onSetFocus,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSetFocus,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.primaryColor.withOpacity(0.1) : AppTheme.darkSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive ? AppTheme.primaryColor : AppTheme.darkBorder,
            width: isActive ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.sports_gymnastics, color: AppTheme.primaryColor, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(exercise['name'] ?? '',
                          style: const TextStyle(
                              color: AppTheme.darkText, fontWeight: FontWeight.w600, fontSize: 15)),
                      Text(exercise['muscleGroup'] ?? '',
                          style: TextStyle(color: AppTheme.darkTextMuted, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
            if (isStarted) ...[
              const SizedBox(height: 16),
              // Set headers
              Row(
                children: [
                  const SizedBox(width: 4),
                  const Text('Set', style: TextStyle(color: AppTheme.darkTextMuted, fontSize: 12, fontWeight: FontWeight.w500)),
                  const Spacer(),
                  const SizedBox(width: 80, child: Text('Reps', style: TextStyle(color: AppTheme.darkTextMuted, fontSize: 12), textAlign: TextAlign.center)),
                  const SizedBox(width: 8),
                  const SizedBox(width: 80, child: Text('Weight (kg)', style: TextStyle(color: AppTheme.darkTextMuted, fontSize: 12), textAlign: TextAlign.center)),
                ],
              ),
              const SizedBox(height: 8),
              ...setControllers.asMap().entries.map((entry) {
                final setNum = entry.key + 1;
                final ctrls = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text('$setNum',
                              style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                      ),
                      const Spacer(),
                      SizedBox(
                        width: 80,
                        child: TextFormField(
                          controller: ctrls['reps'],
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppTheme.darkText, fontSize: 14),
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(vertical: 8),
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 80,
                        child: TextFormField(
                          controller: ctrls['weight'],
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppTheme.darkText, fontSize: 14),
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(vertical: 8),
                            isDense: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ] else ...[
              const SizedBox(height: 10),
              Text('${exercise['defaultSets']} sets × ${exercise['defaultReps']} reps'
                  '${(exercise['defaultWeight'] ?? 0) > 0 ? ' @ ${exercise['defaultWeight']}kg' : ''}',
                  style: TextStyle(color: AppTheme.darkTextMuted, fontSize: 13)),
            ],
          ],
        ),
      ),
    );
  }
}
