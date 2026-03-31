import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_house/core/router/app_routes.dart';
import 'package:meal_house/shared/widgets/custom_image_widget.dart';
import 'package:meal_house/shared/widgets/status_badge_widget.dart';
import 'package:meal_house/features/user/presentation/providers/mess_provider.dart';

class HomePopularTodayWidget extends ConsumerWidget {
  final int selectedMealTab;
  final bool isTablet;

  const HomePopularTodayWidget({
    super.key,
    required this.selectedMealTab,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final popularAsync = ref.watch(recommendedThalisProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    'Popular Today',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text('🔥', style: TextStyle(fontSize: 16)),
                ],
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.recommendedForYou);
                },
                child: Text(
                  'See All',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFF97316),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: popularAsync.when(
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
              if (filtered.isEmpty) return const SizedBox.shrink();
              
              final displayItems = filtered.take(4).toList();
              
              if (isTablet) {
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.72, // Reduced from 0.78 for more vertical space
                  ),
                  itemCount: displayItems.length,
                  itemBuilder: (context, index) =>
                      _PopularCard(item: displayItems[index], index: index),
                );
              }
              return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.70, // Reduced from 0.75 for more vertical space
                  ),
                  itemCount: displayItems.length,
                  itemBuilder: (context, index) =>
                      _PopularCard(item: displayItems[index], index: index),
                );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }
}

class _PopularCard extends StatefulWidget {
  final RecommendedThaliModel item;
  final int index;

  const _PopularCard({required this.item, required this.index});

  @override
  State<_PopularCard> createState() => _PopularCardState();
}

class _PopularCardState extends State<_PopularCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    Future.delayed(Duration(milliseconds: 200 + widget.index * 80), () {
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
      child: SlideTransition(
        position: _slideAnim,
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRoutes.dishDetailPath(widget.item.mess.id!, widget.item.item.id!),
                arguments: {
                  'item': widget.item.item,
                  'mess': widget.item.mess,
                },
              );
            },
            splashColor: const Color(0xFFF97316).withAlpha(20),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(18),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image with badge
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                        child: CustomImageWidget(
                          imageUrl: widget.item.item.image ?? (widget.item.mess.photos.isNotEmpty ? widget.item.mess.photos.first : 'https://images.pexels.com/photos/1640777/pexels-photo-1640777.jpeg'),
                          width: double.infinity,
                          height: 110,
                          fit: BoxFit.cover,
                          semanticLabel: widget.item.item.name,
                        ),
                      ),
                      Positioned(
                        top: 8,
                        left: 8,
                        child: StatusBadgeWidget(label: "Best Seller", status: BadgeStatus.bestSeller),
                      ),
                    ],
                  ),

                  // Content
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.item.item.name,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1A1A1A),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.item.mess.name,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF6B7280),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const Icon(
                              Icons.star_rounded,
                              size: 14,
                              color: Color(0xFFF59E0B),
                            ),
                            const SizedBox(width: 2),
                            Flexible(
                              child: Text(
                                widget.item.mess.rating.toString(),
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF4B5563),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 11,
                              color: Color(0xFF9CA3AF),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              widget.item.distanceString,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                '₹${widget.item.item.price}',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFFF97316),
                                  fontFeatures: [const FontFeature.tabularFigures()],
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF97316).withAlpha(20),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.add_rounded,
                                size: 18,
                                color: Color(0xFFF97316),
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
