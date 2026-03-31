import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/config/env_manager.dart';
import 'core/di/service_locator.dart';
import 'core/router/app_routes.dart';
import 'package:meal_house/core/theme/app_theme.dart';
import 'package:sizer/sizer.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize environment configuration
  EnvManager.initialize();
  
  // Initialize dependency injection
  await initializeDependencies();
  
  runApp(
    const ProviderScope(
      child: MealHouseApp(),
    ),
  );
}

class MealHouseApp extends StatelessWidget {
  const MealHouseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MaterialApp(
          title: 'Meal House',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          initialRoute: AppRoutes.initial,
          routes: AppRoutes.routes,
          onGenerateRoute: AppRoutes.onGenerateRoute,
          onUnknownRoute: AppRoutes.onUnknownRoute,
        );
      },
    );
  }
}
