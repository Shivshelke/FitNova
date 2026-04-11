import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';
import '../../../core/router.dart';
import '../../../data/providers/auth_provider.dart';

/// Profile setup screen shown after first-time signup
/// Collects age, weight, height, and fitness goal
class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;

  // Form values
  final _ageCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  String _gender = 'male';
  String _goal = 'weight_loss';
  bool _isLoading = false;

  final List<Map<String, dynamic>> _goals = [
    {'key': 'weight_loss', 'label': 'Weight Loss', 'icon': Icons.trending_down, 'color': AppTheme.accentColor},
    {'key': 'weight_gain', 'label': 'Weight Gain', 'icon': Icons.trending_up, 'color': AppTheme.accentOrange},
    {'key': 'maintenance', 'label': 'Maintenance', 'icon': Icons.balance, 'color': AppTheme.accentGreen},
    {'key': 'muscle_building', 'label': 'Muscle Building', 'icon': Icons.fitness_center, 'color': AppTheme.accentPink},
  ];

  Future<void> _complete() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await ref.read(authStateProvider.notifier).updateProfile({
        'age': int.tryParse(_ageCtrl.text),
        'weight': double.tryParse(_weightCtrl.text),
        'height': double.tryParse(_heightCtrl.text),
        'gender': _gender,
        'goal': _goal,
        'profileComplete': true,
      });
      if (mounted) context.go(AppRoutes.home);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red.shade700),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                // Progress indicator
                Row(
                  children: List.generate(2, (i) {
                    return Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 4,
                        decoration: BoxDecoration(
                          color: i <= _currentStep ? AppTheme.primaryColor : AppTheme.darkBorder,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 32),

                if (_currentStep == 0) _buildStep1(),
                if (_currentStep == 1) _buildStep2(),

                const Spacer(),

                Row(
                  children: [
                    if (_currentStep > 0)
                      OutlinedButton(
                        onPressed: () => setState(() => _currentStep--),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.darkText,
                          side: const BorderSide(color: AppTheme.darkBorder),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text('Back'),
                      ),
                    if (_currentStep > 0) const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: _isLoading ? null : () {
                          if (_currentStep < 1) {
                            setState(() => _currentStep++);
                          } else {
                            _complete();
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(
                            child: _isLoading
                                ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                                : Text(
                                    _currentStep < 1 ? 'Next →' : '🚀 Start My Journey',
                                    style: const TextStyle(
                                        color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Tell us about yourself 📋',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.darkText)),
        const SizedBox(height: 8),
        Text('This helps us personalize your experience.',
            style: TextStyle(color: AppTheme.darkTextMuted)),
        const SizedBox(height: 32),

        // Gender selector
        const Text('Gender', style: TextStyle(color: AppTheme.darkText, fontWeight: FontWeight.w500)),
        const SizedBox(height: 12),
        Row(
          children: ['male', 'female', 'other'].map((g) {
            final isSelected = _gender == g;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _gender = g),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primaryColor.withOpacity(0.2) : AppTheme.darkSurface2,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? AppTheme.primaryColor : AppTheme.darkBorder,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      g[0].toUpperCase() + g.substring(1),
                      style: TextStyle(
                        color: isSelected ? AppTheme.primaryColor : AppTheme.darkTextMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 24),

        // Age, Weight, Height
        Row(
          children: [
            Expanded(
              child: _buildNumberField('Age', _ageCtrl, 'yrs',
                  validator: (v) => (v?.isEmpty ?? true) ? 'Required' : null),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildNumberField('Weight', _weightCtrl, 'kg',
                  validator: (v) => (v?.isEmpty ?? true) ? 'Required' : null),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildNumberField('Height', _heightCtrl, 'cm',
                  validator: (v) => (v?.isEmpty ?? true) ? 'Required' : null),
            ),
          ],
        ),
      ],
    ).animate().fadeIn().slideX(begin: 0.1, end: 0);
  }

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('What\'s your goal? 🎯',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.darkText)),
        const SizedBox(height: 8),
        Text('We\'ll customize your plan based on this.',
            style: TextStyle(color: AppTheme.darkTextMuted)),
        const SizedBox(height: 32),
        ...List.generate(_goals.length, (i) {
          final g = _goals[i];
          final isSelected = _goal == g['key'];
          return GestureDetector(
            onTap: () => setState(() => _goal = g['key']),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected ? (g['color'] as Color).withOpacity(0.15) : AppTheme.darkSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? (g['color'] as Color) : AppTheme.darkBorder,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: (g['color'] as Color).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(g['icon'] as IconData, color: g['color'] as Color, size: 22),
                  ),
                  const SizedBox(width: 16),
                  Text(g['label'] as String,
                      style: TextStyle(
                        color: isSelected ? AppTheme.darkText : AppTheme.darkTextMuted,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        fontSize: 16,
                      )),
                  const Spacer(),
                  if (isSelected)
                    Icon(Icons.check_circle, color: g['color'] as Color, size: 22),
                ],
              ),
            ),
          ).animate(delay: Duration(milliseconds: i * 100)).fadeIn().slideX(begin: 0.1, end: 0);
        }),
      ],
    ).animate().fadeIn().slideX(begin: 0.1, end: 0);
  }

  Widget _buildNumberField(String label, TextEditingController ctrl, String suffix,
      {String? Function(String?)? validator}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppTheme.darkText, fontWeight: FontWeight.w500, fontSize: 13)),
        const SizedBox(height: 8),
        TextFormField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: AppTheme.darkText),
          decoration: InputDecoration(
            hintText: suffix,
            suffixText: suffix,
            suffixStyle: TextStyle(color: AppTheme.darkTextMuted),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          validator: validator,
        ),
      ],
    );
  }
}
