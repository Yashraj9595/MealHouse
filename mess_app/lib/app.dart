import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:MealHouse/core/theme/app_theme.dart';
import 'package:MealHouse/core/constants/app_strings.dart';
import 'package:MealHouse/routes/app_routes.dart';

class MessApp extends StatelessWidget {
  const MessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MaterialApp(
          title: AppStrings.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          themeMode: ThemeMode.light,
          initialRoute: AppRoutes.loginScreen,
          routes: AppRoutes.routes,
        );
      },
    );
  }
}
