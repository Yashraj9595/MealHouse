import 'package:flutter/material.dart';
import 'package:meal_house/core/constants/meal_enum.dart';
import 'package:meal_house/core/theme/app_theme.dart';


class PickupConfirmBarWidget extends StatelessWidget {
  final Map<String, String>? selectedPickup;
  final MealType selectedMeal;
  final VoidCallback onConfirm;

  const PickupConfirmBarWidget({
    super.key,
    required this.selectedPickup,
    required this.selectedMeal,
    required this.onConfirm,
  });

  String get _mealLabel {
    final name = selectedMeal.name;
    return name[0].toUpperCase() + name.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final pickup = selectedPickup;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 20,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (pickup != null) ...[
              // Selected pickup summary
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.storefront_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pickup['name'] ?? '',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                              fontFamily: 'Outfit',
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Row(
                            children: [
                              Text(
                                '$_mealLabel · ',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.primary,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Outfit',
                                ),
                              ),
                              Text(
                                pickup['timeSlot'] ?? '',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textSecondary,
                                  fontFamily: 'Outfit',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Text(
                      pickup['distance'] ?? '',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.success,
                        fontFamily: 'Outfit',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            // Confirm button with gradient
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: pickup != null ? onConfirm : null,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                  disabledBackgroundColor: AppTheme.muted.withAlpha(51),
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: pickup != null ? AppTheme.primaryGradient : null,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          color: pickup != null ? Colors.white : AppTheme.muted,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Confirm Pickup Location',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: pickup != null
                                ? Colors.white
                                : AppTheme.muted,
                            fontFamily: 'Outfit',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
