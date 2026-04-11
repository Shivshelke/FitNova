import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';
import '../../../core/router.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/meal_provider.dart';

/// User profile screen with settings, stats, and dark mode toggle
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final dietTipsAsync = ref.watch(dietTipsProvider);

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: CustomScrollView(
        slivers: [
          // Profile header
          SliverAppBar(
            expandedHeight: 200,
            backgroundColor: AppTheme.darkBg,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1A0A2E), AppTheme.darkBg],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryColor.withOpacity(0.4),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : 'A',
                            style: const TextStyle(
                                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 32),
                          ),
                        ),
                      ).animate().scale(delay: 100.ms, curve: Curves.elasticOut),
                      const SizedBox(height: 12),
                      Text(user?.name ?? 'Athlete',
                          style: const TextStyle(
                              color: AppTheme.darkText, fontWeight: FontWeight.bold, fontSize: 20))
                          .animate(delay: 200.ms).fadeIn(),
                      Text(user?.email ?? '',
                          style: TextStyle(color: AppTheme.darkTextMuted, fontSize: 13))
                          .animate(delay: 250.ms).fadeIn(),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Stats row
                _buildStatsRow(user),
                const SizedBox(height: 20),

                // Diet tips from AI
                dietTipsAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (data) => _DietTipsSection(data: data),
                ),
                const SizedBox(height: 16),

                // Profile settings
                _sectionHeader('Profile'),
                _settingsTile(
                  icon: Icons.person_outline,
                  title: 'Edit Profile',
                  subtitle: '${user?.goal?.replaceAll("_", " ") ?? "Set your goal"}',
                  onTap: () {},
                ),
                _settingsTile(
                  icon: Icons.monitor_weight_outlined,
                  title: 'Body Stats',
                  subtitle: user?.weight != null ? '${user!.weight}kg · ${user.height}cm' : 'Not set',
                  onTap: () {},
                ),
                const SizedBox(height: 16),

                _sectionHeader('Settings'),
                _settingsTile(
                  icon: Icons.notifications_outlined,
                  title: 'Notifications',
                  subtitle: 'Workout & water reminders',
                  onTap: () {},
                ),
                _settingsTile(
                  icon: Icons.dark_mode_outlined,
                  title: 'Dark Mode',
                  subtitle: 'Currently active',
                  onTap: () {},
                ),
                const SizedBox(height: 16),

                _sectionHeader('About'),
                _settingsTile(
                  icon: Icons.info_outline,
                  title: 'About FitNova',
                  subtitle: 'Version 1.0.0',
                  onTap: () {},
                ),

                const SizedBox(height: 24),

                // Logout button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.logout, color: Colors.red),
                    label: const Text('Sign Out', style: TextStyle(color: Colors.red)),
                    onPressed: () async {
                      await ref.read(authStateProvider.notifier).logout();
                      if (context.mounted) context.go(AppRoutes.login);
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ).animate(delay: 300.ms).fadeIn(),

                const SizedBox(height: 80),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(user) {
    return Row(
      children: [
        _StatBox(label: 'Goal', value: user?.goalLabel ?? '-', icon: Icons.flag_outlined, color: AppTheme.primaryColor),
        const SizedBox(width: 10),
        _StatBox(label: 'BMI', value: user?.bmi != null ? user!.bmi!.toStringAsFixed(1) : '-', icon: Icons.monitor_weight_outlined, color: AppTheme.accentGreen),
        const SizedBox(width: 10),
        _StatBox(label: 'Weight', value: user?.weight != null ? '${user!.weight}kg' : '-', icon: Icons.scale, color: AppTheme.accentColor),
      ],
    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(title,
          style: const TextStyle(
              color: AppTheme.darkTextMuted, fontWeight: FontWeight.w600, fontSize: 13, letterSpacing: 0.5)),
    );
  }

  Widget _settingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.darkSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.darkBorder),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.primaryColor, size: 20),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: AppTheme.darkText, fontWeight: FontWeight.w500)),
                  Text(subtitle, style: TextStyle(color: AppTheme.darkTextMuted, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppTheme.darkBorder),
          ],
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _StatBox({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 6),
            Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 15)),
            Text(label, style: TextStyle(color: AppTheme.darkTextMuted, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class _DietTipsSection extends StatelessWidget {
  final Map<String, dynamic> data;
  const _DietTipsSection({required this.data});

  @override
  Widget build(BuildContext context) {
    final tips = data['tips'] as List? ?? [];
    if (tips.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('AI Diet Tips 🤖',
            style: TextStyle(color: AppTheme.darkText, fontWeight: FontWeight.w600, fontSize: 16)),
        const SizedBox(height: 10),
        ...tips.take(3).map((tip) {
          final t = tip as Map<String, dynamic>;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.darkSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.darkBorder),
            ),
            child: Row(
              children: [
                Text(t['emoji'] ?? '💡', style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(t['tip'] as String,
                      style: TextStyle(color: AppTheme.darkTextMuted, fontSize: 13, height: 1.4)),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 12),
      ],
    ).animate().fadeIn();
  }
}
