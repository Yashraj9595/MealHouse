import 'package:google_fonts/google_fonts.dart';
import 'package:meal_house/core/app_export.dart';
import 'package:meal_house/shared/widgets/custom_image_widget.dart';
import 'package:meal_house/features/mess_owner/domain/models/mess_model.dart';

class HeroHeaderWidget extends StatelessWidget {
  final bool isTablet;
  final MessModel mess;

  const HeroHeaderWidget({super.key, required this.isTablet, required this.mess});

  @override
  Widget build(BuildContext context) {
    final heroHeight = isTablet ? 340.0 : 280.0;
    
    final image = mess.photos.isNotEmpty ? mess.photos.first : 'https://images.pexels.com/photos/1640777/pexels-photo-1640777.jpeg';

    return SliverAppBar(
      expandedHeight: heroHeight,
      pinned: true,
      stretch: true,
      backgroundColor: AppTheme.primary,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: _CircleIconButton(
          icon: Icons.arrow_back_ios_new_rounded,
          onTap: () => Navigator.of(context).maybePop(),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: _CircleIconButton(icon: Icons.search_rounded, onTap: () {}),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 8, right: 12),
          child: _CircleIconButton(icon: Icons.share_outlined, onTap: () {}),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        stretchModes: const [StretchMode.zoomBackground],
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Hero Image
            CustomImageWidget(
              imageUrl: image,
              width: double.infinity,
              height: heroHeight,
              fit: BoxFit.cover,
              semanticLabel: mess.name,
            ),
            // Gradient overlay
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Color(0x40000000),
                    Color(0xCC000000),
                  ],
                  stops: [0.3, 0.6, 1.0],
                ),
              ),
            ),
            // Restaurant info at bottom
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    mess.name,
                    style: GoogleFonts.outfit(
                      fontSize: isTablet ? 34 : 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      // Rating badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.success,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              mess.rating.toString(),
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 3),
                            const Icon(
                              Icons.star_rounded,
                              size: 13,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      _MetaDot(),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          mess.cuisineType,
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
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
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.black.withAlpha(89),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }
}

class _MetaDot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 4,
      height: 4,
      decoration: const BoxDecoration(
        color: Colors.white54,
        shape: BoxShape.circle,
      ),
    );
  }
}
