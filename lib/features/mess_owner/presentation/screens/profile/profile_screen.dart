import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meal_house/core/di/service_locator.dart';
import 'package:meal_house/core/theme/app_theme.dart';
import 'package:meal_house/core/router/app_routes.dart';
import 'package:meal_house/features/auth/domain/repositories/auth_repository.dart';
import 'package:meal_house/features/auth/domain/entities/user.dart';
import 'package:meal_house/features/mess_owner/domain/repositories/mess_repository.dart';
import 'package:meal_house/features/mess_owner/domain/models/mess_model.dart';

class MessOwnerProfileScreen extends StatefulWidget {
  const MessOwnerProfileScreen({super.key});

  @override
  State<MessOwnerProfileScreen> createState() => _MessOwnerProfileScreenState();
}

class _MessOwnerProfileScreenState extends State<MessOwnerProfileScreen> {
  final AuthRepository _authRepository = sl<AuthRepository>();
  final MessRepository _messRepository = sl<MessRepository>();
  
  User? _user;
  MessModel? _mess;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    setState(() => _isLoading = true);
    try {
      final user = await _authRepository.getCurrentUser();
      final messes = await _messRepository.getMyMesses();
      
      if (mounted) {
        setState(() {
          _user = user;
          if (messes.isNotEmpty) {
            _mess = messes.first;
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFE65100)),
      );
    }

    return Column(
      children: [
        _buildCustomAppBar(context),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadProfileData,
            color: const Color(0xFFE65100),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBusinessInfoCard(),
                  const SizedBox(height: 16),
                  if (_mess?.operatingHours != null && _mess!.operatingHours!.isNotEmpty) ...[
                    _buildOperatingHoursCard(),
                    const SizedBox(height: 16),
                  ],
                  _buildSettingsCard(context),
                  const SizedBox(height: 24),
                  _buildAppVersion(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCustomAppBar(BuildContext context) {
    return Container(
      color: AppTheme.surface,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Profile',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          GestureDetector(
            onTap: () async {
              if (_mess != null) {
                final result = await Navigator.pushNamed(
                  context, 
                  AppRoutes.editMessProfileScreen,
                  arguments: _mess,
                );
                if (result == true) {
                  _loadProfileData();
                }
              } else {
                // Navigate to setup if no mess found
                final result = await Navigator.pushNamed(context, AppRoutes.setupMessScreen);
                if (result == true) {
                  _loadProfileData();
                }
              }
            },
            child: const Icon(
              Icons.edit_outlined,
              color: Color(0xFFE65100),
              size: 26,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessInfoCard() {
    final initials = _mess?.name.isNotEmpty == true 
        ? _mess!.name.split(' ').map((l) => l[0]).take(2).join('').toUpperCase()
        : 'MH';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(20),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: (_mess?.logo != null)
                      ? Image.network(
                          _mess!.logo!.startsWith('http')
                              ? _mess!.logo!
                              : 'http://localhost:5000${_mess!.logo}',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Center(
                            child: Text(
                              initials,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        )
                      : Center(
                          child: Text(
                            initials,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _mess?.name ?? 'No Mess Name',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Owner: ${_user?.firstName ?? ''} ${_user?.lastName ?? ''}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildInfoRow(Icons.phone_outlined, _mess?.mobile ?? _user?.mobile ?? 'No Contact'),
          const SizedBox(height: 14),
          _buildInfoRow(Icons.location_on_outlined, _mess?.address ?? 'No Address Set'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFFE65100), size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOperatingHoursCard() {
    final List<Map<String, String>> mealTimes = [];
    if (_mess?.operatingHours != null && _mess!.operatingHours!.isNotEmpty) {
      final hours = _mess!.operatingHours!.first; // Show first day's hours as representative
      if (hours.breakfast != null) mealTimes.add({'name': 'Breakfast', 'time': '${hours.breakfast!.start} – ${hours.breakfast!.end}'});
      if (hours.lunch != null) mealTimes.add({'name': 'Lunch', 'time': '${hours.lunch!.start} – ${hours.lunch!.end}'});
      if (hours.dinner != null) mealTimes.add({'name': 'Dinner', 'time': '${hours.dinner!.start} – ${hours.dinner!.end}'});
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Operating Hours',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              GestureDetector(
                onTap: () async {
                  if (_mess != null) {
                    final result = await Navigator.pushNamed(
                      context,
                      AppRoutes.operatingHoursScreen,
                      arguments: _mess,
                    );
                    if (result == true) {
                      _loadProfileData();
                    }
                  }
                },
                child: Text(
                  'UPDATE',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFE65100),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...mealTimes.map(
            (meal) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      meal['name']!,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      meal['time']!,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFE65100),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSettingsItem(
            icon: Icons.person_outline,
            label: 'Owner Profile',
            onTap: () async {
              if (_user != null) {
                final result = await Navigator.pushNamed(
                  context, 
                  AppRoutes.editOwnerProfileScreen,
                  arguments: _user,
                );
                if (result == true) {
                  _loadProfileData();
                }
              }
            },
            showDivider: true,
          ),
          _buildSettingsItem(
            icon: Icons.business_outlined,
            label: 'Mess Details',
            onTap: () async {
              if (_mess != null) {
                final result = await Navigator.pushNamed(
                  context, 
                  AppRoutes.editMessProfileScreen,
                  arguments: _mess,
                );
                if (result == true) {
                  _loadProfileData();
                }
              } else {
                final result = await Navigator.pushNamed(context, AppRoutes.setupMessScreen);
                if (result == true) {
                  _loadProfileData();
                }
              }
            },
            showDivider: true,
          ),
          _buildSettingsItem(
            icon: Icons.map_outlined,
            label: 'Mess Location',
            onTap: () async {
              if (_mess != null) {
                final result = await Navigator.pushNamed(
                  context, 
                  AppRoutes.messLocationScreen,
                  arguments: _mess,
                );
                if (result == true) {
                  _loadProfileData();
                }
              } else {
                final result = await Navigator.pushNamed(context, AppRoutes.setupMessScreen);
                if (result == true) {
                  _loadProfileData();
                }
              }
            },
            showDivider: true,
          ),
          _buildSettingsItem(
            icon: Icons.photo_library_outlined,
            label: 'Mess Photos',
            onTap: () async {
              if (_mess != null) {
                final result = await Navigator.pushNamed(
                  context, 
                  AppRoutes.uploadMessPhotosScreen,
                  arguments: _mess,
                );
                if (result == true) {
                  _loadProfileData();
                }
              } else {
                final result = await Navigator.pushNamed(context, AppRoutes.setupMessScreen);
                if (result == true) {
                  _loadProfileData();
                }
              }
            },
            showDivider: true,
          ),
          _buildSettingsItem(
            icon: Icons.lock_outline,
            label: 'Change Password',
            onTap: () {},
            showDivider: true,
          ),
          _buildLogoutItem(context),
        ],
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool showDivider,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: const Color(0xFFE65100), size: 22),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    label,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: AppTheme.textSecondary,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          const Divider(height: 1, thickness: 1, color: Color(0xFFF0F0F0)),
      ],
    );
  }

  Widget _buildLogoutItem(BuildContext context) {
    return InkWell(
      onTap: () => _showLogoutDialog(context),
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(16),
        bottomRight: Radius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFFFEBEE),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.logout,
                color: Color(0xFFE53935),
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              'Logout',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFE53935),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Logout',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: GoogleFonts.plusJakartaSans(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancel',
              style: GoogleFonts.plusJakartaSans(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await _authRepository.logout();
              if (mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
              }
            },
            child: Text(
              'Logout',
              style: GoogleFonts.plusJakartaSans(
                color: const Color(0xFFE53935),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppVersion() {
    return Center(
      child: Text(
        'App Version 1.0.0',
        style: GoogleFonts.plusJakartaSans(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: AppTheme.textMuted,
        ),
      ),
    );
  }
}
