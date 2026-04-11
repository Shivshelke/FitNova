import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';
import '../../../core/router.dart';
import '../../../data/providers/auth_provider.dart';

/// Signup screen for new users
class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      await ref.read(authStateProvider.notifier).signup(
        _nameCtrl.text.trim(),
        _emailCtrl.text.trim(),
        _passwordCtrl.text,
      );
      if (mounted) context.go(AppRoutes.profileSetup);
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppTheme.darkText),
          onPressed: () => context.go(AppRoutes.login),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Create Account 🚀',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppTheme.darkText))
                    .animate().fadeIn().slideY(begin: 0.2, end: 0),

                const SizedBox(height: 8),
                Text('Join FitNova and start your transformation.',
                    style: TextStyle(color: AppTheme.darkTextMuted, fontSize: 15))
                    .animate(delay: 100.ms).fadeIn(),

                const SizedBox(height: 32),

                _buildField('Full Name', _nameCtrl, Icons.person_outline,
                    validator: (v) => (v?.isEmpty ?? true) ? 'Name required' : null,
                    delay: 200),

                const SizedBox(height: 16),

                _buildField('Email', _emailCtrl, Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v?.isEmpty ?? true) return 'Email required';
                      if (!v!.contains('@')) return 'Enter a valid email';
                      return null;
                    },
                    delay: 250),

                const SizedBox(height: 16),

                _buildField('Password', _passwordCtrl, Icons.lock_outline,
                    obscure: _obscurePassword,
                    onToggleObscure: () => setState(() => _obscurePassword = !_obscurePassword),
                    validator: (v) {
                      if (v?.isEmpty ?? true) return 'Password required';
                      if (v!.length < 6) return 'At least 6 characters';
                      return null;
                    },
                    delay: 300),

                const SizedBox(height: 16),

                _buildField('Confirm Password', _confirmPasswordCtrl, Icons.lock_outline,
                    obscure: true,
                    validator: (v) {
                      if (v != _passwordCtrl.text) return 'Passwords do not match';
                      return null;
                    },
                    delay: 350),

                const SizedBox(height: 32),

                // Signup button
                SizedBox(
                  width: double.infinity,
                  child: GestureDetector(
                    onTap: _isLoading ? null : _signup,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryColor.withOpacity(0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Center(
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                            : const Text('Create Account',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ),
                ).animate(delay: 400.ms).fadeIn().slideY(begin: 0.2, end: 0),

                const SizedBox(height: 24),

                Center(
                  child: GestureDetector(
                    onTap: () => context.go(AppRoutes.login),
                    child: RichText(
                      text: TextSpan(
                        text: 'Already have an account? ',
                        style: TextStyle(color: AppTheme.darkTextMuted, fontSize: 15),
                        children: [
                          const TextSpan(
                            text: 'Login',
                            style: TextStyle(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ).animate(delay: 450.ms).fadeIn(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController ctrl,
    IconData icon, {
    bool obscure = false,
    VoidCallback? onToggleObscure,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    required int delay,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
              color: AppTheme.darkText,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            )),
        const SizedBox(height: 8),
        TextFormField(
          controller: ctrl,
          obscureText: obscure,
          keyboardType: keyboardType,
          style: const TextStyle(color: AppTheme.darkText),
          decoration: InputDecoration(
            hintText: 'Enter your $label',
            prefixIcon: Icon(icon, color: AppTheme.darkTextMuted),
            suffixIcon: onToggleObscure != null
                ? IconButton(
                    icon: Icon(
                      obscure ? Icons.visibility_off : Icons.visibility,
                      color: AppTheme.darkTextMuted,
                    ),
                    onPressed: onToggleObscure,
                  )
                : null,
          ),
          validator: validator,
        ),
      ],
    ).animate(delay: Duration(milliseconds: delay)).fadeIn().slideY(begin: 0.1, end: 0);
  }
}
