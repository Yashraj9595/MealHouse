import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meal_house/core/router/app_routes.dart';
import 'package:sizer/sizer.dart';

import './issue_tile_widget.dart';

class CommonIssuesWidget extends StatelessWidget {
  final bool isTablet;

  const CommonIssuesWidget({super.key, required this.isTablet});

  static final List<Map<String, dynamic>> _issueMaps = [
    {
      'title': 'Report Order Issue',
      'icon': Icons.inventory_2_outlined,
      'route': AppRoutes.reportProblemScreen,
    },
    {
      'title': 'Pickup Problem',
      'icon': Icons.location_on_outlined,
      'route': AppRoutes.reportProblemScreen,
    },
    {
      'title': 'Payment Issue',
      'icon': Icons.payment_outlined,
      'route': AppRoutes.reportProblemScreen,
    },
    {
      'title': 'General Support',
      'icon': Icons.help_outline_rounded,
      'route': AppRoutes.reportProblemScreen,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'COMMON ISSUES',
          style: GoogleFonts.dmSans(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF8A8A8A),
            letterSpacing: 1.2,
          ),
        ),
        SizedBox(height: 1.5.h),
        if (isTablet)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 4.5,
            ),
            itemCount: _issueMaps.length,
            itemBuilder: (context, index) {
              final issue = _issueMaps[index];
              return IssueTileWidget(
                title: issue['title'] as String,
                icon: issue['icon'] as IconData,
                onTap: () {
                  Navigator.pushNamed(context, issue['route'] as String);
                },
              );
            },
          )
        else
          Column(
            children: List.generate(_issueMaps.length, (index) {
              final issue = _issueMaps[index];
              return Padding(
                padding: EdgeInsets.only(
                  bottom: index < _issueMaps.length - 1 ? 1.5.h : 0,
                ),
                child: IssueTileWidget(
                  title: issue['title'] as String,
                  icon: issue['icon'] as IconData,
                  onTap: () {
                    Navigator.pushNamed(context, issue['route'] as String);
                  },
                ),
              );
            }),
          ),
      ],
    );
  }
}
