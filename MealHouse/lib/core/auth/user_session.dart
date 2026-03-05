enum UserRole { user, messOwner, admin, guest }

class UserSession {
  static final UserSession _instance = UserSession._internal();
  factory UserSession() => _instance;
  UserSession._internal();

  UserRole _role = UserRole.guest;
  bool _isLoggedIn = false;

  UserRole get role => _role;
  bool get isLoggedIn => _isLoggedIn;

  void login(String roleStr) {
    _role = _mapStringToRole(roleStr);
    _isLoggedIn = true;
  }

  UserRole _mapStringToRole(String roleStr) {
    switch (roleStr.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'mess-owner':
      case 'mess_owner':
      case 'messowner':
        return UserRole.messOwner;
      case 'user':
        return UserRole.user;
      default:
        return UserRole.guest;
    }
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
