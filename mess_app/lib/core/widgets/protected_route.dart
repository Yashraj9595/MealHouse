import 'package:flutter/material.dart';
import '../auth/user_session.dart';
import '../../../routes/app_routes.dart';

class ProtectedRoute extends StatelessWidget {
  final Widget child;
  final UserRole requiredRole;

  const ProtectedRoute({
    super.key,
    required this.child,
    required this.requiredRole,
  });

  @override
  Widget build(BuildContext context) {
    final session = UserSession();
    
    if (!session.isLoggedIn) {
      // Not logged in, redirect to login
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, AppRoutes.loginScreen);
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (session.role != requiredRole && session.role != UserRole.admin) {
      // Wrong role, show access denied or redirect
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_person, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Access Denied',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('You do not have permission to access this page.'),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.loginScreen),
                child: const Text('Back to Login'),
              ),
            ],
          ),
        ),
      );
    }

    return child;
  }
}
