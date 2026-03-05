import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:MealHouse/app.dart';
import 'package:MealHouse/core/config/env_config.dart';
import 'package:MealHouse/core/di/injection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize DI
  await initInjection();
  
  // Initialize with Dev environment by default
  Environment.init(AppEnvironment.dev);
  
  runApp(
    const ProviderScope(
      child: MessApp(),
    ),
  );
}
