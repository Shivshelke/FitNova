import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme.dart';
import '../../../core/router.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/goal_provider.dart';
import '../../../data/providers/progress_provider.dart';
import 'package:go_router/go_router.dart';

/// Home / Dashboard screen
/// Shows daily summary: steps, calories, water, macros, goals
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final dashboardAsync = ref.watch(dashboardProvider);

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: RefreshIndicator(
        color: AppTheme.primaryColor,
        backgroundColor: AppTheme.darkSurface,
        onRefresh: () => ref.refresh(dashboardProvider.future),
        child: CustomScrollView(
          slivers: [
            // ── App Bar ─────────────────────────────────────────────────────
            SliverAppBar(
              expandedHeight: 120,
              floating: true,
              pinned: false,
              backgroundColor: AppTheme.darkBg,
              flexibleSpace: FlexibleSpaceBar(
                background: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 50, 20, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Good ${_getGreeting()}! 👋',
                              style: TextStyle(color: AppTheme.darkTextMuted, fontSize: 14)),
                          const SizedBox(height: 4),
                          Text(user?.name.split(' ').first ?? 'Athlete',
                              style: const TextStyle(
                                  color: AppTheme.darkText,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          if (user?.id == 'guest_user_123') {
                            context.push(AppRoutes.login);
                          }
                        },
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              if (user?.id == 'guest_user_123')
                                BoxShadow(
                                  color: AppTheme.primaryColor.withOpacity(0.3),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              (user?.name.isNotEmpty ?? false) ? user!.name[0].toUpperCase() : 'A',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Content ─────────────────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: dashboardAsync.when(
                loading: () => const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator(color: AppTheme.primaryColor)),
                ),
                error: (e, _) => SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.wifi_off, color: AppTheme.darkTextMuted, size: 48),
                        const SizedBox(height: 12),
                        Text('Backend not reachable.\nStart the backend server.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppTheme.darkTextMuted)),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: () => context.push(AppRoutes.login),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              ),
                              child: const Text('Log In'),
                            ),
                            const SizedBox(width: 12),
                            OutlinedButton(
                              onPressed: () => context.push(AppRoutes.signup),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppTheme.primaryColor),
                                foregroundColor: AppTheme.primaryColor,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              ),
                              child: const Text('Sign Up'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () {},
                          child: const Text('Continue with Demo Data', 
                            style: TextStyle(color: AppTheme.darkTextMuted)),
                        ),
                      ],
                    ),
                  ),
                ),
                data: (summary) => SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: 8),
                    _buildDailyRings(summary),
                    const SizedBox(height: 20),
                    _buildStatsRow(summary),
                    const SizedBox(height: 20),
                    _buildNutritionSection(summary),
                    const SizedBox(height: 20),
                    _buildGoalsSection(summary),
                    const SizedBox(height: 100), // bottom nav padding
                  ]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }

  Widget _buildDailyRings(Map<String, dynamic> summary) {
    final steps = summary['steps'] ?? {'current': 0, 'target': 10000, 'percentage': 0};
    final calories = summary['calories'] ?? {'intake': 0, 'target': 2000, 'percentage': 0};
    final water = summary['water'] ?? {'current': 0, 'target': 2500, 'percentage': 0};

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.darkBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Today\'s Activity',
              style: TextStyle(color: AppTheme.darkText, fontWeight: FontWeight.w600, fontSize: 16)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildRingCard('Steps',
                  '${steps['current']}',
                  'of ${steps['target']}',
                  (steps['percentage'] as num).toDouble() / 100,
                  AppTheme.accentColor,
                  Icons.directions_walk),
              _buildRingCard('Calories',
                  '${calories['intake']}',
                  'of ${calories['target']} kcal',
                  (calories['percentage'] as num).toDouble() / 100,
                  AppTheme.accentOrange,
                  Icons.local_fire_department),
              _buildRingCard('Water',
                  '${water['current']}',
                  'of ${water['target']} ml',
                  (water['percentage'] as num).toDouble() / 100,
                  AppTheme.accentGreen,
                  Icons.water_drop_outlined),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildRingCard(String label, String value, String sub, double progress, Color color, IconData icon) {
    return Column(
      children: [
        SizedBox(
          width: 80,
          height: 80,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox.expand(
                child: CircularProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  strokeWidth: 7,
                  backgroundColor: color.withOpacity(0.15),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  strokeCap: StrokeCap.round,
                ),
              ),
              Icon(icon, color: color, size: 28),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(value,
            style: const TextStyle(
                color: AppTheme.darkText, fontWeight: FontWeight.bold, fontSize: 16)),
        Text(sub, style: TextStyle(color: AppTheme.darkTextMuted, fontSize: 10),
            textAlign: TextAlign.center),
        const SizedBox(height: 4),
        Text(label,
            style: const TextStyle(color: AppTheme.darkText, fontSize: 12, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildStatsRow(Map<String, dynamic> summary) {
    final calories = summary['calories'] ?? {};
    final workouts = summary['workoutsToday'] ?? 0;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard('Burned', '${calories['burned'] ?? 0}',
              'kcal', Icons.whatshot, AppTheme.accentOrange),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard('Net Calories', '${calories['net'] ?? 0}',
              'kcal', Icons.calculate_outlined, AppTheme.primaryColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard('Workouts', '$workouts',
              'today', Icons.fitness_center, AppTheme.accentPink),
        ),
      ],
    ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.1, end: 0);
  }

  Widget _buildStatCard(String label, String value, String unit, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.darkSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.darkBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(value,
              style: const TextStyle(
                  color: AppTheme.darkText, fontWeight: FontWeight.bold, fontSize: 18)),
          Text('$unit\n$label',
              style: TextStyle(color: AppTheme.darkTextMuted, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildNutritionSection(Map<String, dynamic> summary) {
    final nutrition = summary['nutrition'] ?? {'protein': 0, 'carbs': 0, 'fat': 0};
    final protein = (nutrition['protein'] as num?)?.toDouble() ?? 0;
    final carbs = (nutrition['carbs'] as num?)?.toDouble() ?? 0;
    final fat = (nutrition['fat'] as num?)?.toDouble() ?? 0;
    final total = protein + carbs + fat;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.darkSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.darkBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Today\'s Macros',
              style: TextStyle(color: AppTheme.darkText, fontWeight: FontWeight.w600, fontSize: 16)),
          const SizedBox(height: 16),
          _buildMacroBar('Protein', protein, total, AppTheme.accentGreen, '${protein.toInt()}g'),
          const SizedBox(height: 12),
          _buildMacroBar('Carbs', carbs, total, AppTheme.accentColor, '${carbs.toInt()}g'),
          const SizedBox(height: 12),
          _buildMacroBar('Fat', fat, total, AppTheme.accentOrange, '${fat.toInt()}g'),
        ],
      ),
    ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.1, end: 0);
  }

  Widget _buildMacroBar(String label, double value, double total, Color color, String display) {
    final ratio = total > 0 ? (value / total).clamp(0.0, 1.0) : 0.0;
    return Row(
      children: [
        SizedBox(
          width: 60,
          child: Text(label, style: TextStyle(color: AppTheme.darkTextMuted, fontSize: 13)),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 8,
              backgroundColor: color.withOpacity(0.15),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(display,
            style: const TextStyle(color: AppTheme.darkText, fontWeight: FontWeight.w500, fontSize: 13)),
      ],
    );
  }

  Widget _buildGoalsSection(Map<String, dynamic> summary) {
    final goals = summary['goals'] as List? ?? [];
    if (goals.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Active Goals',
            style: TextStyle(
                color: AppTheme.darkText, fontWeight: FontWeight.w600, fontSize: 16)),
        const SizedBox(height: 12),
        ...goals.take(2).map((g) => Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.darkSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.darkBorder),
          ),
          child: Row(
            children: [
              const Icon(Icons.flag_outlined, color: AppTheme.primaryColor),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  (g['goalType'] as String).replaceAll('_', ' ').toUpperCase(),
                  style: const TextStyle(color: AppTheme.darkText, fontWeight: FontWeight.w500),
                ),
              ),
              Text('Active', style: TextStyle(color: AppTheme.accentGreen, fontSize: 12)),
            ],
          ),
        )),
      ],
    ).animate(delay: 400.ms).fadeIn().slideY(begin: 0.1, end: 0);
  }
}
