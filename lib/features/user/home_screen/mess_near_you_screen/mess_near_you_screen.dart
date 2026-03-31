import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meal_house/core/router/app_routes.dart';
import 'package:meal_house/core/theme/app_theme.dart';
import 'package:meal_house/features/mess_owner/domain/models/mess_model.dart';
import 'package:meal_house/features/user/presentation/providers/mess_provider.dart';
import 'package:meal_house/shared/widgets/custom_image_widget.dart';

class MessNearYouScreen extends ConsumerStatefulWidget {
  const MessNearYouScreen({super.key});

  @override
  ConsumerState<MessNearYouScreen> createState() => _MessNearYouScreenState();
}

class _MessNearYouScreenState extends ConsumerState<MessNearYouScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _markerAnimController;
  late Animation<double> _markerPulseAnim;

  @override
  void initState() {
    super.initState();
    _markerAnimController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat(reverse: true);
    _markerPulseAnim = Tween<double>(begin: 0.85, end: 1.15).animate(CurvedAnimation(parent: _markerAnimController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _searchController.dispose();
    _markerAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final messState = ref.watch(messProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFE8C5B5),
      body: Stack(
        children: [
          _buildMapBackground(),
          SafeArea(child: Column(children: [_buildTopBar(context), const SizedBox(height: 10), _buildSearchBar()])),
          DraggableScrollableSheet(
            initialChildSize: 0.42, minChildSize: 0.18, maxChildSize: 0.85, snap: true,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
                child: Column(
                  children: [
                    Center(child: Container(margin: const EdgeInsets.only(top: 12, bottom: 16), width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
                    if (messState.isLoading)
                      const Expanded(child: Center(child: CircularProgressIndicator()))
                    else if (messState.error != null)
                      Expanded(child: Center(child: Text('Error: ${messState.error}')))
                    else
                      Expanded(
                        child: ListView.builder(
                          controller: scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: messState.messes.length,
                          itemBuilder: (context, index) => _buildMessCard(messState.messes[index]),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMapBackground() => Positioned.fill(child: CustomPaint(painter: _MapPainter(), child: Stack(children: [Positioned(left: 200, top: 400, child: _buildYouMarker())])));
  Widget _buildYouMarker() => ScaleTransition(scale: _markerPulseAnim, child: Container(width: 38, height: 38, decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: Colors.green, width: 3))));

  Widget _buildTopBar(BuildContext context) => Padding(padding: const EdgeInsets.all(16), child: Row(children: [IconButton(icon: const Icon(Icons.arrow_back_ios), onPressed: () => Navigator.pop(context)), const Expanded(child: Center(child: Text('Mess Near You', style: TextStyle(fontWeight: FontWeight.bold)))), const SizedBox(width: 42)]));
  Widget _buildSearchBar() => Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Container(padding: const EdgeInsets.symmetric(horizontal: 16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28)), child: TextField(controller: _searchController, decoration: const InputDecoration(hintText: 'Search mess...', border: InputBorder.none))));

  Widget _buildMessCard(MessModel mess) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 10)]),
      child: Column(
        children: [
          ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(18)), child: CustomImageWidget(imageUrl: mess.photos.isNotEmpty ? mess.photos.first : '', width: double.infinity, height: 150, fit: BoxFit.cover)),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(mess.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(mess.address, style: const TextStyle(color: Colors.grey, fontSize: 12), maxLines: 1),
                ])),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.restaurantDetailScreen, arguments: mess),
                  child: const Text('View', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFFD4A898).withAlpha(100);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = const Color(0xFFE8C5B5));
    canvas.drawLine(Offset(0, size.height/2), Offset(size.width, size.height/2), paint..strokeWidth=20);
    canvas.drawLine(Offset(size.width/2, 0), Offset(size.width/2, size.height), paint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
