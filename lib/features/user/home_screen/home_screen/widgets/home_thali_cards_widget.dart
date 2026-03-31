import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_house/core/router/app_routes.dart';
import 'package:meal_house/shared/widgets/custom_image_widget.dart';
import 'package:meal_house/features/user/presentation/providers/mess_provider.dart';
import 'package:intl/intl.dart';

class HomeThaliCardsWidget extends ConsumerWidget {
  final int selectedMealTab;
  final bool isTablet;

  const HomeThaliCardsWidget({
    super.key,
    required this.selectedMealTab,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final thalisAsync = ref.watch(recommendedThalisProvider);

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
                "Today's Thalis Near You",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F8F8),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.tune_rounded,
                  size: 18,
                  color: Color(0xFF4B5563),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        thalisAsync.when(
          data: (allThalis) {
            String targetMealType;
            switch (selectedMealTab) {
              case 0: targetMealType = 'Breakfast'; break;
              case 1: targetMealType = 'Lunch'; break;
              case 2: targetMealType = 'Dinner'; break;
              default: targetMealType = 'Extra';
            }

            final filtered = allThalis.where((t) => 
               t.item.mealType.contains(targetMealType) || t.item.mealType.contains('Extra')
            ).toList();

            if (filtered.isEmpty) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                child: Center(
                  child: Column(
                    children: [
                      const Icon(
                        Icons.no_food_outlined,
                        size: 48,
                        color: Color(0xFF9CA3AF),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No $targetMealType thalis available right now',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          color: const Color(0xFF6B7280),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }
            if (isTablet) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) =>
                      _ThaliCard(thali: filtered[index], index: index),
                ),
              );
            }
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filtered.length,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _ThaliCard(thali: filtered[index], index: index),
              ),
            );
          },
          loading: () => const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, s) => const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _ThaliCard extends StatefulWidget {
  final RecommendedThaliModel thali;
  final int index;

  const _ThaliCard({required this.thali, required this.index});

  @override
  State<_ThaliCard> createState() => _ThaliCardState();
}

class _ThaliCardState extends State<_ThaliCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _fadeAnim = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    Future.delayed(Duration(milliseconds: 100 + widget.index * 100), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _isOpen() {
    final mess = widget.thali.mess;
    if (mess.operatingHours == null || mess.operatingHours!.isEmpty) return false;
    final currentDay = DateFormat('EEEE').format(DateTime.now());
    final hours = mess.operatingHours!.firstWhere(
      (h) => h.day == currentDay,
      orElse: () => mess.operatingHours!.first,
    );
    return hours.isOpen;
  }

  String _getTimeSlot() {
    final mess = widget.thali.mess;
    if (mess.operatingHours == null || mess.operatingHours!.isEmpty) return 'Closed';
    final currentDay = DateFormat('EEEE').format(DateTime.now());
    final hours = mess.operatingHours!.firstWhere(
      (h) => h.day == currentDay,
      orElse: () => mess.operatingHours!.first,
    );
    if (!hours.isOpen) return 'Closed';

    final start = hours.breakfast?.start ?? hours.lunch?.start ?? hours.dinner?.start;
    final end = hours.dinner?.end ?? hours.lunch?.end ?? hours.breakfast?.end;
    
    if (start != null && end != null) return '$start - $end';
    return 'Open';
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.thali.item;
    final mess = widget.thali.mess;
    final isOpen = _isOpen();

    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRoutes.dishDetailPath(widget.thali.mess.id!, widget.thali.item.id!),
                arguments: {
                  'item': item,
                  'mess': mess,
                },
              );
            },
            splashColor: const Color(0xFFF97316).withAlpha(15),
            borderRadius: BorderRadius.circular(18),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(18),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Food Image with overlaid tags
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(18),
                          topRight: Radius.circular(18),
                        ),
                        child: CustomImageWidget(
                          imageUrl: item.image ??
                              (mess.photos.isNotEmpty ? mess.photos.first : 'https://images.pexels.com/photos/1640777/pexels-photo-1640777.jpeg'),
                          width: double.infinity,
                          height: 160,
                          fit: BoxFit.cover,
                          semanticLabel: item.name,
                        ),
                      ),
                    ],
                  ),

                  // Content
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name + Price row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                item.name,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF1A1A1A),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '₹${item.price}',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFFF97316),
                                fontFeatures: [
                                  const FontFeature.tabularFigures(),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 4),

                        // Mess name + open status
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                mess.name,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF6B7280),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              width: 4,
                              height: 4,
                              decoration: const BoxDecoration(
                                color: Color(0xFF9CA3AF),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              isOpen ? 'Open Now' : 'Closed',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isOpen
                                    ? const Color(0xFF16A34A)
                                    : const Color(0xFFEF4444),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        // Divider
                        Container(height: 1, color: const Color(0xFFF0F0F0)),

                        const SizedBox(height: 10),

                        // Distance + Time row
                        Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.location_on_outlined,
                                    size: 13,
                                    color: Color(0xFF9CA3AF),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    widget.thali.distanceString,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      color: const Color(0xFF6B7280),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.access_time_outlined,
                                    size: 13,
                                    color: Color(0xFF9CA3AF),
                                  ),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      _getTimeSlot(),
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                        color: const Color(0xFF6B7280),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
