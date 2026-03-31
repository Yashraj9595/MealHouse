

import 'package:meal_house/core/app_export.dart';
import 'package:meal_house/core/services/location_service.dart';
import 'package:meal_house/core/di/service_locator.dart';
import './widgets/permission_actions_widget.dart';
import './widgets/permission_blob_widget.dart';
import './widgets/permission_illustration_widget.dart';

class LocationPermissionScreen extends StatefulWidget {
  const LocationPermissionScreen({super.key});

  @override
  State<LocationPermissionScreen> createState() =>
      _LocationPermissionScreenState();
}

class _LocationPermissionScreenState extends State<LocationPermissionScreen>
    with TickerProviderStateMixin {
  late AnimationController _blobController;
  late AnimationController _contentController;
  late Animation<double> _contentFade;
  late Animation<Offset> _contentSlide;

  // TODO: Replace with permission_handler for production
  bool _isRequesting = false;

  @override
  void initState() {
    super.initState();
    _blobController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..repeat(reverse: true);

    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _contentFade = CurvedAnimation(
      parent: _contentController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
    );

    _contentSlide =
        Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _contentController,
            curve: Curves.easeOutCubic,
          ),
        );

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _contentController.forward();
    });

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }

  @override
  void dispose() {
    _blobController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _handleAllowLocation() async {
    if (_isRequesting) return;
    setState(() => _isRequesting = true);
    
    try {
      final locationService = sl<LocationService>();
      final position = await locationService.getCurrentPosition();
      
      if (mounted) {
        setState(() => _isRequesting = false);
        if (position != null) {
          Navigator.pushNamed(context, AppRoutes.locationSelectionScreen);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Permission denied or location services disabled.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isRequesting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _handleSelectManually() {
    Navigator.pushNamed(context, AppRoutes.locationSelectionScreen);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 600;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          // Morphing blob background — LOCKED technique
          PermissionBlobWidget(controller: _blobController),

          // Main content
          SafeArea(
            child: isTablet ? _buildTabletLayout() : _buildPhoneLayout(),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneLayout() {
    return FadeTransition(
      opacity: _contentFade,
      child: SlideTransition(
        position: _contentSlide,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 24),
              // App logo / brand mark
              _buildBrandMark(),
              const Spacer(flex: 1),
              // Illustration
              const PermissionIllustrationWidget(),
              const Spacer(flex: 1),
              // Heading + description
              _buildHeadingSection(),
              const SizedBox(height: 40),
              // Action buttons
              PermissionActionsWidget(
                isLoading: _isRequesting,
                onAllowLocation: _handleAllowLocation,
                onSelectManually: _handleSelectManually,
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabletLayout() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: FadeTransition(
          opacity: _contentFade,
          child: SlideTransition(
            position: _contentSlide,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(242),
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(20),
                    blurRadius: 32,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildBrandMark(dark: true),
                  const SizedBox(height: 32),
                  const PermissionIllustrationWidget(),
                  const SizedBox(height: 32),
                  _buildHeadingSection(dark: true),
                  const SizedBox(height: 32),
                  PermissionActionsWidget(
                    isLoading: _isRequesting,
                    onAllowLocation: _handleAllowLocation,
                    onSelectManually: _handleSelectManually,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBrandMark({bool dark = false}) {
    return Row(
      mainAxisAlignment: dark
          ? MainAxisAlignment.center
          : MainAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.restaurant_rounded,
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          'MealSpot',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: dark ? AppTheme.textPrimary : Colors.white,
            fontFamily: 'Outfit',
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildHeadingSection({bool dark = false}) {
    final titleColor = dark ? AppTheme.textPrimary : Colors.white;
    final bodyColor = dark
        ? AppTheme.textSecondary
        : Colors.white.withAlpha(217);

    return Column(
      children: [
        Text(
          'Enable Location\nPermission',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: titleColor,
            fontFamily: 'Outfit',
            height: 1.2,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'To provide you with the best delivery\nexperience and accurate arrival times.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: bodyColor,
            fontFamily: 'Outfit',
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
