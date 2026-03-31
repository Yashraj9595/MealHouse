import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meal_house/core/services/location_service.dart';
import 'package:meal_house/shared/widgets/custom_image_widget.dart';
import 'package:meal_house/core/app_export.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_house/features/profile/presentation/providers/profile_provider.dart';

class LocationHeaderWidget extends ConsumerWidget {
  final String? location;
  final VoidCallback onNotificationTap;
  final VoidCallback onProfileTap;
  final VoidCallback onLocationTap;
  final bool showActions;

  const LocationHeaderWidget({
    super.key,
    this.location,
    required this.onNotificationTap,
    required this.onProfileTap,
    required this.onLocationTap,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);

    return Container(
      color: Colors.transparent, // Blends with brand background
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          // Location Section
          Expanded(
            child: GestureDetector(
              onTap: onLocationTap,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        size: 13,
                        color: Color(0xFFF97316),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        'YOUR LOCATION',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF9CA3AF),
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Flexible(
                        child: ValueListenableBuilder<String>(
                          valueListenable: LocationService.selectedLocation,
                          builder: (context, currentLoc, _) {
                            return Text(
                              location ?? currentLoc,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF1A1A1A),
                              ),
                              overflow: TextOverflow.ellipsis,
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 18,
                        color: Color(0xFF1A1A1A),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          if (showActions)
            // Actions
            Row(
              children: [
                // Notification Bell
                GestureDetector(
                  onTap: onNotificationTap,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(5),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        const Center(
                          child: Icon(
                            Icons.notifications_outlined,
                            size: 22,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFFF97316),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Avatar
                GestureDetector(
                  onTap: onProfileTap,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFF97316),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(5),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: profileAsync.when(
                        data: (user) => CustomImageWidget(
                          imageUrl: user?.profileImage,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                          errorWidget: Container(
                            color: const Color(0xFFFEE2E2),
                            child: const Icon(Icons.person, color: Color(0xFFEF4444)),
                          ),
                        ),
                        loading: () => const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                        error: (_, __) => const Icon(Icons.person, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
