import 'package:flutter/material.dart';
import 'package:meal_house/features/auth/presentation/screens/login/login_screen.dart';
import 'package:meal_house/core/theme/app_theme.dart';
import 'package:meal_house/features/admin/presentation/screens/admin_home.dart';
import 'package:meal_house/features/mess_owner/presentation/mess_owner_navigation_wrapper.dart';
import 'package:meal_house/features/user/main_navigation_wrapper.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0.0;
  final double _heroHeight = 600.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    setState(() {
      _scrollOffset = _scrollController.offset;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    
    // Parallax logic values
    // Scale from 1.0 to 0.95 as we scroll
    final double scale = (1.0 - (_scrollOffset / _heroHeight) * 0.05).clamp(0.95, 1.0);
    // Darken from 0.0 to 0.4 opacity
    final double darkenOpacity = (_scrollOffset / _heroHeight * 0.4).clamp(0.0, 0.4);

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: Stack(
        children: [
          // Sticky Parallax Hero Background
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: _heroHeight,
            child: Transform.scale(
              scale: scale,
              child: Stack(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuBODvVUEpacze2j_Q5C5h2ZTosZdG7N2KpBoPJn4tK0hLEgJlrYnypMB74K-OgrObqvzQivzeWmsZ2kcjYf6jQTTzjKphLlJPWYm48Kw15sYO9pwVY1yB_S7OhtkW2sP1ofGQwmfnTrRqaQrPiCUAy5gpOukLUeUJjQ9sjNUUaX-UO2R6XQawC1LzCiv8e5bPV8jgIjAa9HuadDHifhDhwB-sGf8yuA7fozgVJ_L77ChHMYn-fEOw2I1_9ljbO545RJ_yd8J8g_Ww'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  // Darkening Overlay
                  Container(
                    color: Colors.black.withOpacity(darkenOpacity),
                  ),
                  // Bottom Gradient Blend
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 200,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            AppTheme.backgroundLight,
                            AppTheme.backgroundLight.withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Scrollable Content
          SingleChildScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                // Spacer for Hero
                SizedBox(height: _heroHeight - 40),
                
                // Content Card
                Container(
                  width: size.width,
                  decoration: const BoxDecoration(
                    color: AppTheme.backgroundLight,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 20,
                        offset: Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
                    child: Column(
                      children: [
                        // Decorative Handle
                        Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 40),
                        
                        // Main Title
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: theme.textTheme.displayLarge?.copyWith(
                              fontSize: 40,
                              height: 1.1,
                              color: AppTheme.slate900,
                              fontWeight: FontWeight.w900,
                            ),
                            children: [
                              const TextSpan(text: 'Enjoy Instant\n'),
                              TextSpan(
                                text: 'Delivery & Payment',
                                style: TextStyle(color: AppTheme.primaryColor),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // Subtitle
                        Text(
                          'Delicious meals from your favorite mess, delivered fresh and fast to your doorstep. Experience premium dining at home.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: 18,
                            color: AppTheme.slate600,
                            height: 1.6,
                          ),
                        ),
                        
                        const SizedBox(height: 60),
                        
                        // Get Started Button
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const LoginScreen()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            minimumSize: const Size.fromHeight(68),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100),
                            ),
                            elevation: 12,
                            shadowColor: AppTheme.primaryColor.withValues(alpha: 0.5),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Get Started',
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                              ),
                              SizedBox(width: 12),
                              Icon(Icons.arrow_forward_rounded, size: 28),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Login Link
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const LoginScreen()),
                            );
                          },
                          child: RichText(
                            text: TextSpan(
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: AppTheme.slate500,
                                fontWeight: FontWeight.w600,
                              ),
                              children: [
                                const TextSpan(text: 'Already have an account? '),
                                TextSpan(
                                  text: 'Log in',
                                  style: TextStyle(
                                    color: AppTheme.primaryColor,
                                    fontWeight: FontWeight.w900,
                                    decoration: TextDecoration.underline,
                                    decorationThickness: 2,
                                    decorationColor: AppTheme.primaryColor.withValues(alpha: 0.3),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 48),
                        
                        // Quick Access Title
                        Text(
                          'QUICK ACCESS',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppTheme.slate500,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // Role Buttons Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildRoleShortcut(
                              context,
                              'USER',
                              Icons.person_rounded,
                              AppTheme.primaryColor,
                              const MainNavigationWrapper(),
                            ),
                            _buildRoleShortcut(
                              context,
                              'OWNER',
                              Icons.restaurant_menu_rounded,
                              Colors.green[600]!,
                              const MessOwnerNavigationWrapper(),
                            ),
                            _buildRoleShortcut(
                              context,
                              'ADMIN',
                              Icons.admin_panel_settings_rounded,
                              Colors.blueGrey[800]!,
                              const AdminHomeScreen(),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 60),
                        
                        // Trust Badges
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildInfoBadge(Icons.verified_user_rounded, 'Premium'),
                            const SizedBox(width: 20),
                            Container(width: 4, height: 4, decoration: const BoxDecoration(color: Colors.black12, shape: BoxShape.circle)),
                            const SizedBox(width: 20),
                            _buildInfoBadge(Icons.bolt_rounded, 'Fastest'),
                          ],
                        ),
                        
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleShortcut(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    Widget target,
  ) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => target),
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withValues(alpha: 0.1), width: 1),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: color,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBadge(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.slate500),
        const SizedBox(width: 6),
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
            color: AppTheme.slate500,
          ),
        ),
      ],
    );
  }
}
