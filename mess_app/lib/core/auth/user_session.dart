enum UserRole { user, messOwner, admin, guest }

class UserSession {
  static final UserSession _instance = UserSession._internal();
  factory UserSession() => _instance;
  UserSession._internal();

  UserRole _role = UserRole.guest;
  bool _isLoggedIn = false;

  UserRole get role => _role;
  bool get isLoggedIn => _isLoggedIn;

  void login(UserRole role) {
    _role = role;
    _isLoggedIn = true;
  }

  void logout() {
    _role = UserRole.guest;
    _isLoggedIn = false;
  }

  bool hasAccess(UserRole requiredRole) {
    if (!_isLoggedIn) return false;
    return _role == requiredRole || _role == UserRole.admin;
  }
}
