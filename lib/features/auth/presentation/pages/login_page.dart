// ───────────────────────────────────────────────────────────────
// login_page.dart  –  Matches Kotlin layout_sign_in.xml exactly
// White background, "Already have an Account?" header,
// Email+Password fields, Forgot, Login btn, Register link,
// "Use other Methods" divider, circular FB + Google buttons
// ───────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:dream_ludo/core/di/service_locator.dart';
import 'package:dream_ludo/core/router/app_router.dart';
import 'package:dream_ludo/core/theme/app_theme.dart';
import 'package:dream_ludo/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:dream_ludo/shared/widgets/loading_overlay.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _onLoginPressed(BuildContext context) {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(LoginRequested(
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text.trim(),
        ));
  }

  Future<void> _onGoogleSignIn(BuildContext context) async {
    try {
      await _googleSignIn.signOut();
      final account = await _googleSignIn.signIn();
      if (account == null) return;
      if (!mounted) return;
      context.read<AuthBloc>().add(SocialLoginRequested(
            name: account.displayName ?? '',
            email: account.email,
            socialId: account.id,
            type: 'google',
          ));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Google sign-in failed: $e')));
    }
  }

  Future<void> _onFacebookSignIn(BuildContext context) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Facebook login coming soon'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AuthBloc>(),
      child: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          debugPrint('🎨 Auth State changed: $state');
          if (state is AuthSuccess) {
            debugPrint('🚀 Login Success! Navigating to Home...');
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                context.go(AppRoutes.home);
              }
            });
          } else if (state is AuthSocialLoginNeedsRegistration) {
            context.go(AppRoutes.register, extra: {
              'fullName': state.name,
              'email': state.email,
              'username': state.username,
              'password': state.socialId,
            });
          } else if (state is AuthFailureState) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ));
          }
        },
        builder: (context, state) {
          return LoadingOverlay(
            isLoading: state is AuthLoading,
            child: Scaffold(
              // White background — just like Kotlin login_bk_color
              backgroundColor: AppColors.loginBg,
              body: SafeArea(
                child: GestureDetector(
                  onTap: () => FocusScope.of(context).unfocus(),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 20),

                          // ── Header Row: "Already have an Account?" + icon ──
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text(
                                'Already\nhave an\nAccount?',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.black,
                                  height: 1.3,
                                ),
                              ),
                              Image.asset(
                                'assets/images/app_icon.png',
                                width: 100,
                                height: 100,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.casino_rounded,
                                  size: 80,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // ── Email / Username field ────────────────────────
                          TextFormField(
                            controller: _emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            style: const TextStyle(color: AppColors.black),
                            decoration: _inputDecoration(
                              hint: 'Username or Email',
                            ),
                            validator: (v) =>
                                (v == null || v.isEmpty) ? 'Please enter email' : null,
                          ),

                          const SizedBox(height: 16),

                          // ── Password field ────────────────────────────────
                          TextFormField(
                            controller: _passwordCtrl,
                            obscureText: _obscurePassword,
                            style: const TextStyle(color: AppColors.black),
                            decoration: _inputDecoration(
                              hint: 'Password',
                              suffix: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: AppColors.textHint,
                                ),
                                onPressed: () => setState(
                                    () => _obscurePassword = !_obscurePassword),
                              ),
                            ),
                            validator: (v) =>
                                (v == null || v.isEmpty) ? 'Please enter password' : null,
                          ),

                          const SizedBox(height: 8),

                          // ── Forgot Password ───────────────────────────────
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () => context.push(AppRoutes.forgot),
                              style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                              child: const Text(
                                'Forgot Password?',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // ── Login Button ──────────────────────────────────
                          Builder(builder: (ctx) {
                            return ElevatedButton(
                              onPressed: () => _onLoginPressed(ctx),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: AppColors.white,
                                minimumSize: const Size(double.infinity, 52),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(28),
                                ),
                                elevation: 2,
                              ),
                              child: const Text(
                                'Login',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.white,
                                ),
                              ),
                            );
                          }),

                          const SizedBox(height: 20),

                          // ── "New user? Register Now" ──────────────────────
                          GestureDetector(
                            onTap: () => context.push(AppRoutes.register),
                            child: const Text(
                              'New user? Register Now',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          const SizedBox(height: 30),

                          // ── "Use other Methods" divider ───────────────────
                          Row(
                            children: [
                              const Expanded(
                                  child: Divider(color: Color(0xFF9391A4))),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                child: Text(
                                  'Use other Methods',
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const Expanded(
                                  child: Divider(color: Color(0xFF9391A4))),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // ── Social buttons: Facebook + Google (circles) ───
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _SocialCircleButton(
                                icon: 'assets/images/ic_facebook.png',
                                fallbackIcon: Icons.facebook_rounded,
                                color: const Color(0xFF1877F2),
                                onTap: () => _onFacebookSignIn(context),
                              ),
                              const SizedBox(width: 16),
                              _SocialCircleButton(
                                icon: 'assets/images/ic_google.png',
                                fallbackIcon: Icons.g_mobiledata_rounded,
                                color: const Color(0xFFDB4437),
                                onTap: () => _onGoogleSignIn(context),
                              ),
                            ],
                          ),

                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  InputDecoration _inputDecoration({required String hint, Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 14),
      filled: true,
      fillColor: Colors.grey[50],
      suffixIcon: suffix,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.grey),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.error),
      ),
    );
  }
}

// ── Circular social button — matches Kotlin ic_facebook/ic_google circles ──
class _SocialCircleButton extends StatelessWidget {
  final String icon;
  final IconData fallbackIcon;
  final Color color;
  final VoidCallback onTap;

  const _SocialCircleButton({
    required this.icon,
    required this.fallbackIcon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.35),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Image.asset(
          icon,
          color: AppColors.white,
          errorBuilder: (_, __, ___) =>
              Icon(fallbackIcon, color: AppColors.white, size: 22),
        ),
      ),
    );
  }
}
