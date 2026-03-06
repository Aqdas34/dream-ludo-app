import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:dream_ludo/core/theme/app_theme.dart';
import 'package:dream_ludo/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:dream_ludo/features/auth/domain/usecases/register_usecase.dart';

class RegisterPage extends StatefulWidget {
  final Map<String, String>? prefillData;
  const RegisterPage({super.key, this.prefillData});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();
  final _referController = TextEditingController();
  
  String _selectedGender = 'MALE';

  @override
  void initState() {
    super.initState();
    if (widget.prefillData != null) {
      _fullNameController.text = widget.prefillData!['name'] ?? '';
      _emailController.text = widget.prefillData!['email'] ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background Glows
          Positioned(
            top: -100,
            right: -100,
            child: _buildGlow(AppColors.primary.withOpacity(0.3)),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: _buildGlow(AppColors.secondary.withOpacity(0.2)),
          ),
          
          SafeArea(
            child: BlocListener<AuthBloc, AuthState>(
              listener: (context, state) {
                if (state is AuthSuccess) {
                  context.go('/home');
                } else if (state is AuthFailureState) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message), backgroundColor: Colors.redAccent),
                  );
                }
              },
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      IconButton(
                        onPressed: () => context.pop(),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                        style: IconButton.styleFrom(backgroundColor: AppColors.surface),
                      ),
                      const SizedBox(height: 32),
                      Text('Create Account', style: AppTextStyles.heading1),
                      const SizedBox(height: 8),
                      Text('Join the ultimate Ludo experience', style: AppTextStyles.body.copyWith(color: Colors.white70)),
                      const SizedBox(height: 40),
                      
                      _buildTextField(
                        controller: _fullNameController,
                        label: 'Full Name',
                        icon: Icons.person_outline_rounded,
                        validator: (v) => v!.isEmpty ? 'Name required' : null,
                      ),
                      const SizedBox(height: 20),
                      
                      _buildTextField(
                        controller: _usernameController,
                        label: 'Username',
                        icon: Icons.alternate_email_rounded,
                        validator: (v) => v!.isEmpty ? 'Username required' : null,
                      ),
                      const SizedBox(height: 20),
                      
                      _buildTextField(
                        controller: _emailController,
                        label: 'Email',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) => !v!.contains('@') ? 'Invalid email' : null,
                      ),
                      const SizedBox(height: 20),
                      
                      _buildTextField(
                        controller: _mobileController,
                        label: 'Mobile Number',
                        icon: Icons.phone_android_rounded,
                        keyboardType: TextInputType.phone,
                        validator: (v) => v!.length < 10 ? 'Invalid mobile' : null,
                      ),
                      const SizedBox(height: 20),

                      // Gender Selection
                      Text('Gender', style: AppTextStyles.body.copyWith(color: Colors.white70)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: _buildGenderChoice('MALE', Icons.male_rounded)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildGenderChoice('FEMALE', Icons.female_rounded)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      
                      _buildTextField(
                        controller: _passwordController,
                        label: 'Password',
                        icon: Icons.lock_outline_rounded,
                        isPassword: true,
                        validator: (v) => v!.length < 6 ? 'Min 6 chars' : null,
                      ),
                      const SizedBox(height: 20),

                      _buildTextField(
                        controller: _referController,
                        label: 'Referral Code (Optional)',
                        icon: Icons.card_giftcard_rounded,
                      ),
                      const SizedBox(height: 40),
                      
                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          return ElevatedButton(
                            onPressed: state is AuthLoading ? null : _handleRegister,
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 56),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            child: state is AuthLoading 
                              ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Text('CREATE ACCOUNT', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                          );
                        },
                      ),
                      const SizedBox(height: 32),
                      Center(
                        child: TextButton(
                          onPressed: () => context.pop(),
                          child: RichText(
                            text: TextSpan(
                              text: 'Already have an account? ',
                              style: AppTextStyles.body.copyWith(color: Colors.white60),
                              children: [
                                TextSpan(text: 'Login', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlow(Color color) => Container(
        width: 300,
        height: 300,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color, boxShadow: [BoxShadow(color: color, blurRadius: 100, spreadRadius: 50)]),
      );

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: TextFormField(
            controller: controller,
            obscureText: isPassword,
            keyboardType: keyboardType,
            style: const TextStyle(color: Colors.white),
            validator: validator,
            decoration: InputDecoration(
              labelText: label,
              labelStyle: const TextStyle(color: Colors.white60),
              prefixIcon: Icon(icon, color: AppColors.primary),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGenderChoice(String val, IconData icon) {
    bool isSelected = _selectedGender == val;
    return GestureDetector(
      onTap: () => setState(() => _selectedGender = val),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.2) : AppColors.surface.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? AppColors.primary : Colors.white10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? AppColors.primary : Colors.white60),
            const SizedBox(width: 8),
            Text(val, style: TextStyle(color: isSelected ? Colors.white : Colors.white60, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
          ],
        ),
      ),
    );
  }

  void _handleRegister() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(RegisterRequested(RegisterParams(
        fullName: _fullNameController.text,
        username: _usernameController.text,
        email: _emailController.text,
        mobile: _mobileController.text,
        password: _passwordController.text,
        countryCode: '+1', // Default or pick from a list
        fcmToken: 'temp_token',
        deviceId: 'device_123',
        referCode: _referController.text,
        gender: _selectedGender,
      )));
    }
  }
}
