import 'package:flutter/material.dart';
import 'package:meal_house/core/di/service_locator.dart';
import 'package:meal_house/core/network/api_client.dart';
import 'package:meal_house/features/auth/presentation/screens/welcome/welcome_screen.dart';

class RoleGuard extends StatefulWidget {
  final Widget child;
  final List<String> allowedRoles;

  const RoleGuard({
    super.key,
    required this.child,
    required this.allowedRoles,
  });

  @override
  State<RoleGuard> createState() => _RoleGuardState();
}

class _RoleGuardState extends State<RoleGuard> {
  final ApiClient _apiClient = sl<ApiClient>();
  bool _isAuthorized = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkRole();
  }

  Future<void> _checkRole() async {
    try {
      final role = await _apiClient.getUserRole();
      if (role != null && widget.allowedRoles.contains(role)) {
        setState(() {
          _isAuthorized = true;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isAuthorized = false;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isAuthorized = false;
        _isLoading = false;
      });
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

    if (!_isAuthorized) {
      // If unauthorized, redirect to welcome or show access denied
      return const WelcomeScreen();
    }

    return widget.child;
  }
}
