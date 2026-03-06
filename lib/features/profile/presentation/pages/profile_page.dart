import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:dream_ludo/core/theme/app_theme.dart';
import 'package:dream_ludo/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:dream_ludo/features/auth/data/models/user_model.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _fullNameController = TextEditingController();
  final _mobileController = TextEditingController();
  String _selectedGender = 'MALE';
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthSuccess) {
      _fullNameController.text = authState.user.fullName ?? '';
      _mobileController.text = authState.user.mobile ?? '';
      _selectedGender = authState.user.gender ?? 'MALE';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => setState(() => _isEditing = !_isEditing),
            icon: Icon(_isEditing ? Icons.close_rounded : Icons.edit_rounded, color: Colors.white),
          ),
        ],
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is! AuthSuccess) return const Center(child: CircularProgressIndicator());
          final user = state.user;

          return Stack(
            children: [
              // Glows
              Positioned(top: 50, left: -100, child: _buildGlow(AppColors.primary.withOpacity(0.1))),
              
              SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Header Card
                    _buildGlassCard(
                      child: Column(
                        children: [
                          const CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.white10,
                            child: Icon(Icons.person_rounded, size: 60, color: Colors.white30),
                          ),
                          const SizedBox(height: 16),
                          Text(user.fullName ?? 'Member', style: AppTextStyles.heading2),
                          Text('@${user.username}', style: AppTextStyles.body.copyWith(color: Colors.white60)),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildStat('Gems', '${user.gems ?? 0}', Icons.diamond_rounded, Colors.cyan),
                              _buildStat('Wins', '${user.wonBal ?? 0}', Icons.emoji_events_rounded, Colors.amber),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Edit Form
                    _buildGlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Personal Details', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary)),
                          const SizedBox(height: 20),
                          _buildField(label: 'Full Name', controller: _fullNameController, icon: Icons.person_rounded, enabled: _isEditing),
                          const SizedBox(height: 16),
                          _buildField(label: 'Mobile', controller: _mobileController, icon: Icons.phone_android_rounded, enabled: _isEditing, keyboardType: TextInputType.phone),
                          const SizedBox(height: 24),
                          
                          Text('Gender', style: AppTextStyles.body.copyWith(color: Colors.white60)),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                               Expanded(child: _genderToggle('MALE', Icons.male_rounded, _isEditing)),
                               const SizedBox(width: 12),
                               Expanded(child: _genderToggle('FEMALE', Icons.female_rounded, _isEditing)),
                            ],
                          ),
                          
                          if (_isEditing) ...[
                            const SizedBox(height: 32),
                            ElevatedButton(
                              onPressed: _handleUpdate,
                              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                              child: const Text('SAVE CHANGES'),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    
                    TextButton.icon(
                      onPressed: () {
                        context.read<AuthBloc>().add(LogoutRequested());
                        context.go('/login');
                      },
                      icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                      label: const Text('Logout Session', style: TextStyle(color: Colors.redAccent)),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildGlow(Color color) => Container(
      width: 400, height: 400, 
      decoration: BoxDecoration(shape: BoxShape.circle, color: color, boxShadow: [BoxShadow(color: color, blurRadius: 100, spreadRadius: 50)]));

  Widget _buildGlassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white10),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.white60)),
      ],
    );
  }

  Widget _buildField({required String label, required TextEditingController controller, required IconData icon, bool enabled = false, TextInputType? keyboardType}) {
    return TextField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white60),
        prefixIcon: Icon(icon, color: enabled ? AppColors.primary : Colors.white24),
        border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white10)),
        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white10)),
        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary)),
      ),
    );
  }

  Widget _genderToggle(String val, IconData icon, bool enabled) {
    bool isSelected = _selectedGender == val;
    return GestureDetector(
      onTap: enabled ? () => setState(() => _selectedGender = val) : null,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? AppColors.primary : Colors.white10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: isSelected ? AppColors.primary : Colors.white24),
            const SizedBox(width: 8),
            Text(val, style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : Colors.white24, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
          ],
        ),
      ),
    );
  }

  void _handleUpdate() {
    context.read<AuthBloc>().add(UpdateProfileRequested({
      'full_name': _fullNameController.text,
      'mobile': _mobileController.text,
      'gender': _selectedGender,
    }));
    setState(() => _isEditing = false);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile update requested')));
  }
}
