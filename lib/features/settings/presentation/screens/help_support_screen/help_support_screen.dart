import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meal_house/core/router/app_routes.dart';
import 'package:sizer/sizer.dart';
import './widgets/search_banner_widget.dart';
import './widgets/common_issues_widget.dart';
import './widgets/contact_us_widget.dart';
import './widgets/help_bottom_nav_widget.dart';
import './widgets/logout_confirmation_sheet.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  // TODO: Replace with Riverpod/Bloc for production
  int _activeNavIndex = 2;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onNavTap(int index) {
    setState(() {
      _activeNavIndex = index;
    });
    if (index == 2) {
      Navigator.pushNamed(context, AppRoutes.myWalletScreen);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isTablet = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: _buildAppBar(context),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 4.w : 4.w,
              vertical: 2.h,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SearchBannerWidget(searchController: _searchController),
                SizedBox(height: 2.5.h),
                _buildFaqSection(context),
                SizedBox(height: 2.5.h),
                CommonIssuesWidget(isTablet: isTablet),
                SizedBox(height: 2.5.h),
                const ContactUsWidget(),
                SizedBox(height: 2.h),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: HelpBottomNavWidget(
        activeIndex: _activeNavIndex,
        onTap: _onNavTap,
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFFF5F5F5),
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: GestureDetector(
        onTap: () => Navigator.maybePop(context),
        child: Container(
          margin: const EdgeInsets.only(left: 8),
          child: const Icon(
            Icons.arrow_back_rounded,
            color: Color(0xFFD4541B),
            size: 24,
          ),
        ),
      ),
      title: Text(
        'Help & Support',
        style: GoogleFonts.dmSans(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF1A1A1A),
          letterSpacing: -0.3,
        ),
      ),
      titleSpacing: 4,
      actions: [
        IconButton(
          onPressed: () async {
            await LogoutConfirmationSheet.show(context);
          },
          icon: const Icon(
            Icons.logout_rounded,
            color: Color(0xFFD4541B),
            size: 24,
          ),
          tooltip: 'Logout',
        ),
      ],
    );
  }

  Widget _buildFaqSection(BuildContext context) {
    final faqs = [
      'How do I cancel my order?',
      'When will I get my refund?',
      'Can I change my delivery address?',
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'FREQUENTLY ASKED QUESTIONS',
          style: GoogleFonts.dmSans(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF8A8A8A),
            letterSpacing: 1.2,
          ),
        ),
        SizedBox(height: 1.5.h),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Column(
            children: List.generate(faqs.length, (index) {
              return Column(
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.faqDetailScreen);
                    },
                    borderRadius: BorderRadius.circular(12.0),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 4.w,
                        vertical: 1.8.h,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              faqs[index],
                              style: GoogleFonts.dmSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFF1A1A1A),
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right_rounded,
                            color: Color(0xFF8A8A8A),
                            size: 22,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (index < faqs.length - 1)
                    const Divider(
                      height: 1,
                      indent: 16,
                      endIndent: 16,
                      color: Color(0xFFEEEEEE),
                    ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }
}
