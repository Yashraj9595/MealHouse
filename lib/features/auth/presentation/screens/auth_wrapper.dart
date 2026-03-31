import 'package:flutter/material.dart';
import 'package:meal_house/core/di/service_locator.dart';
import 'package:meal_house/features/auth/data/services/auth_service.dart';
import 'package:meal_house/features/auth/presentation/screens/welcome/welcome_screen.dart';
import 'package:meal_house/features/user/main_navigation_wrapper.dart';
import 'package:meal_house/features/mess_owner/presentation/mess_owner_navigation_wrapper.dart';
import 'package:meal_house/features/admin/presentation/screens/admin_home.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final AuthService _authService = sl<AuthService>();
  bool _isLoading = true;
  Widget? _targetScreen;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    try {
      final token = await _authService.getAuthToken();
      if (token == null) {
        setState(() {
          _targetScreen = const WelcomeScreen();
          _isLoading = false;
        });
        return;
      }

      // If token exists, fetch profile to get role
      final response = await _authService.getCurrentUser();
      if (response.statusCode == 200 && response.data['data'] != null) {
        final userData = response.data['data']['user'];
        final role = userData['role'];

        if (role == 'admin') {
          _targetScreen = const AdminHomeScreen();
        } else if (role == 'manager') {
          _targetScreen = const MessOwnerNavigationWrapper();
        } else {
          _targetScreen = const MainNavigationWrapper();
        }
      } else {
        _targetScreen = const WelcomeScreen();
      }
    } catch (e) {
      // If error (e.g. token expired), go to welcome
      _targetScreen = const WelcomeScreen();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return _targetScreen ?? const WelcomeScreen();
  }
}
