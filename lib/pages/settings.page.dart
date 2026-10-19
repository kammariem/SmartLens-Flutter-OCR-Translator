import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/widgets/app_navigation.dart';
import '../theme/widgets/primary_button.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? 'Unkown User';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Settings'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              
              // User Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.person_rounded,
                  size: 64,
                  color: AppColors.primary,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // User Email
              Text(
                'Connected as',
                style: AppTextStyles.bodySmall,
              ),
              const SizedBox(height: 8),
              Text(
                email,
                style: AppTextStyles.title,
                textAlign: TextAlign.center,
              ),
              
              const Spacer(),
              
              // Logout Button
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  label: 'Logout',
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    // Navigation is handled by the StreamBuilder in main.dart, 
                    // but we can explicitly pop to be safe or ensure the route clears.
                    if (context.mounted) {
                      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                    }
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AppNavigationBar(currentIndex: 2),
    );
  }
}
