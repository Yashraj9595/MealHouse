import 'package:flutter/material.dart';
import 'package:meal_house/core/theme/app_theme.dart';

class PermissionActionsWidget extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onAllowLocation;
  final VoidCallback onSelectManually;

  const PermissionActionsWidget({
    super.key,
    required this.isLoading,
    required this.onAllowLocation,
    required this.onSelectManually,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Primary CTA — Allow Location Access
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: isLoading ? null : onAllowLocation,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppTheme.primary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              disabledBackgroundColor: Colors.white.withAlpha(179),
            ),
            child: isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppTheme.primary,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.my_location_rounded, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'Allow Location Access',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Outfit',
                          letterSpacing: 0.1,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 14),
        // Secondary CTA — Select Manually
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton(
            onPressed: onSelectManually,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white54, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'Select Manually',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                fontFamily: 'Outfit',
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
