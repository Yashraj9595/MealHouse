import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meal_house/core/router/app_routes.dart';
import 'package:meal_house/shared/widgets/custom_image_widget.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:meal_house/core/services/location_service.dart';
import 'package:meal_house/features/user/presentation/providers/mess_provider.dart';
import 'package:meal_house/features/mess_owner/domain/models/mess_model.dart';


class HomeMessNearbyWidget extends ConsumerWidget {
  final VoidCallback onViewMapsTap;

  const HomeMessNearbyWidget({super.key, required this.onViewMapsTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nearbyMessesAsync = ref.watch(nearbyMessesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Mess Near You',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
              GestureDetector(
                onTap: onViewMapsTap,
                child: Row(
                  children: [
                    const Icon(
                      Icons.map_outlined,
                      size: 14,
                      color: Color(0xFFF97316),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'View Maps',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFF97316),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        nearbyMessesAsync.when(
          data: (messes) {
            if (messes.isEmpty) {
              return Center(child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text('No messes found nearby'),
              ));
            }
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(15),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: List.generate(messes.length, (index) {
                  final mess = messes[index];
                  final isLast = index == messes.length - 1;
                  return _MessNearbyItem(mess: mess, isLast: isLast, index: index);
                }),
              ),
            );
          },
          loading: () => Center(child: CircularProgressIndicator()),
          error: (e, s) => Center(child: Text('Error loading messes')),
        ),
      ],
    );
  }
}

class _MessNearbyItem extends StatefulWidget {
  final MessModel mess;
  final bool isLast;
  final int index;

  const _MessNearbyItem({
    required this.mess,
    required this.isLast,
    required this.index,
  });

  @override
  State<_MessNearbyItem> createState() => _MessNearbyItemState();
}

class _MessNearbyItemState extends State<_MessNearbyItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _fadeAnim = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    Future.delayed(Duration(milliseconds: 300 + widget.index * 80), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.restaurantDetailScreen, arguments: widget.mess);
          },
          splashColor: const Color(0xFFF97316).withAlpha(15),
          borderRadius: BorderRadius.circular(widget.isLast ? 18 : 0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 13,
                ),
                child: Row(
                  children: [
                    // Logo
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CustomImageWidget(
                        imageUrl: widget.mess.photos.isNotEmpty ? widget.mess.photos.first : 'https://images.pexels.com/photos/1640777/pexels-photo-1640777.jpeg',
                        width: 52,
                        height: 52,
                        fit: BoxFit.cover,
                        semanticLabel: widget.mess.name,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.mess.name,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1A1A1A),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            widget.mess.cuisineType,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                size: 12,
                                color: Color(0xFFF59E0B),
                              ),
                              const SizedBox(width: 3),
                              Text(
                                widget.mess.rating.toString(),
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF4B5563),
                                ),
                              ),
                              const SizedBox(width: 5),
                               Text(
                                '(${widget.mess.numReviews})',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFF9CA3AF),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Right: status + distance
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: widget.mess.isActive
                                ? const Color(0xFFECFDF5)
                                : const Color(0xFFFEF2F2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            widget.mess.isActive ? 'Open' : 'Closed',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: widget.mess.isActive
                                  ? const Color(0xFF16A34A)
                                  : const Color(0xFFEF4444),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        ValueListenableBuilder<Position?>(
                          valueListenable: LocationService.selectedPosition,
                          builder: (context, pos, _) {
                            if (pos == null) {
                              return Text(
                                'Nearby',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF9CA3AF),
                                ),
                              );
                            }
                            final dist = Geolocator.distanceBetween(
                              pos.latitude, pos.longitude,
                              widget.mess.latitude, widget.mess.longitude,
                            );
                            String distLabel;
                            if (dist < 1000) {
                              distLabel = '${dist.round()} m';
                            } else {
                              distLabel = '${(dist / 1000).toStringAsFixed(1)} km';
                            }
                            return Text(
                              distLabel,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFFF97316),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Divider
              if (!widget.isLast)
                Container(
                  height: 1,
                  margin: const EdgeInsets.only(left: 78),
                  color: const Color(0xFFF0F0F0),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
