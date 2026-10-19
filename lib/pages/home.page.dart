import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/widgets/app_navigation.dart';
import '../theme/widgets/primary_button.dart';
import '../theme/widgets/primary_card_button.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Icon
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(
                    Icons.crop_free_rounded,
                    size: 48,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 24),

                // Title
                const Text("SmartLens", style: AppTextStyles.display),
                const SizedBox(height: 8),
                const Text(
                  "Capture. Translate.",
                  style: AppTextStyles.subtitle,
                ),
                const SizedBox(height: 40),

                // Buttons
                PrimaryCardButton(
                  icon: Icons.camera_alt_outlined,
                  title: "Capture an Image",
                  subtitle: "Use your camera",
                  iconColor: AppColors.primary,
                  onTap: () {
                    Navigator.pushNamed(context, '/capture');
                  },
                ),
                /*PrimaryCardButton(
                  icon: Icons.upload_rounded,
                  title: "Importer de la Galerie",
                  subtitle: "Choisir depuis l'appareil",
                  iconColor: AppColors.accent,
                  onTap: () {
                    // TODO: Open gallery picker
                  },
                ),*/
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const AppNavigationBar(currentIndex: 0),
    );
  }
}
