import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meal_house/core/router/app_routes.dart';
import 'package:meal_house/shared/widgets/custom_image_widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_house/features/user/presentation/providers/mess_provider.dart';
import 'package:meal_house/features/mess_owner/domain/models/mess_model.dart';

class HomeMessCardsWidget extends ConsumerWidget {
  final bool isTablet;

  const HomeMessCardsWidget({super.key, required this.isTablet});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nearbyMessesAsync = ref.watch(nearbyMessesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Explore Messes',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
              GestureDetector(
                onTap: () {},
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
        nearbyMessesAsync.when(
          data: (messes) {
            if (messes.isEmpty) return const SizedBox.shrink();
            return SizedBox(
              height: isTablet ? 135 : 125,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: messes.length,
                itemBuilder: (context, index) {
                  final mess = messes[index];
                  return _MessCard(mess: mess, isTablet: isTablet, index: index);
                },
              ),
            );
          },
          loading: () => const SizedBox(height: 110, child: Center(child: CircularProgressIndicator())),
          error: (e, s) => const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _MessCard extends StatefulWidget {
  final MessModel mess;
  final bool isTablet;
  final int index;

  const _MessCard({
    required this.mess,
    required this.isTablet,
    required this.index,
  });

  @override
  State<_MessCard> createState() => _MessCardState();
}

class _MessCardState extends State<_MessCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 350 + widget.index * 60),
    );
    _fadeAnim = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _slideAnim = Tween<Offset>(
      begin: const Offset(0.15, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    Future.delayed(Duration(milliseconds: widget.index * 60), () {
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
    final cardWidth = widget.isTablet ? 135.0 : 115.0;

    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: Container(
          width: cardWidth,
          margin: const EdgeInsets.only(right: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(12),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              onTap: () {
                Navigator.pushNamed(
                  context, 
                  AppRoutes.restaurantDetailPath(widget.mess.id!), 
                  arguments: widget.mess,
                );
              },
              splashColor: const Color(0xFFF97316).withAlpha(20),
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(20),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CustomImageWidget(
                          imageUrl: widget.mess.photos.isNotEmpty ? widget.mess.photos.first : 'https://images.pexels.com/photos/1640777/pexels-photo-1640777.jpeg',
                          width: 58,
                          height: 58,
                          fit: BoxFit.cover,
                          semanticLabel: widget.mess.name,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Flexible(
                      child: Text(
                        widget.mess.name,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1A1A1A),
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 13,
                          color: Color(0xFFF59E0B),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          widget.mess.rating.toString(),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF4B5563),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
