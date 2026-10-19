import 'package:flutter/material.dart';
import '../app_colors.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isDisabled;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isDisabled ? AppColors.textSecondary.withOpacity(0.3) : AppColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
      onPressed: isDisabled ? null : onPressed,
      child: Text(label, style: const TextStyle(color: AppColors.textLight, fontSize: 16, fontWeight: FontWeight.w600)),
    );
  }
}
