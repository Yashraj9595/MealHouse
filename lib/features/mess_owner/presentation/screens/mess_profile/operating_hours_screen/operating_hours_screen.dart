import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meal_house/core/router/app_routes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_house/features/mess_owner/domain/models/mess_model.dart';
import 'package:meal_house/features/mess_owner/presentation/providers/mess_registration_provider.dart';
import 'package:meal_house/features/mess_owner/domain/repositories/mess_repository.dart';
import 'package:meal_house/core/di/service_locator.dart';

class OperatingHoursScreen extends ConsumerStatefulWidget {
  final MessModel? initialMess;
  const OperatingHoursScreen({super.key, this.initialMess});

  @override
  ConsumerState<OperatingHoursScreen> createState() => _OperatingHoursScreenState();
}

class _OperatingHoursScreenState extends ConsumerState<OperatingHoursScreen> {
  static const Color _blueColor = Color(0xFFE8650A); // Use theme primary
  static const Color _bgColor = Color(0xFFF5F6FA);
  static const Color _cardColor = Colors.white;
  static const Color _darkNavy = Color(0xFF1A1A2E);

  bool _isSaving = false;
  final MessRepository _messRepository = sl<MessRepository>();

  // Available days: Monday to Sunday
  final List<String> _dayNames = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
  ];
  final List<String> _dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  late List<bool> _selectedDays;

  // Meal toggles
  bool _breakfastEnabled = true;
  bool _lunchEnabled = true;
  bool _dinnerEnabled = true;

  // Meal times
  TimeOfDay _breakfastStart = const TimeOfDay(hour: 7, minute: 0);
  TimeOfDay _breakfastEnd = const TimeOfDay(hour: 10, minute: 30);
  TimeOfDay _lunchStart = const TimeOfDay(hour: 12, minute: 0);
  TimeOfDay _lunchEnd = const TimeOfDay(hour: 15, minute: 0);
  TimeOfDay _dinnerStart = const TimeOfDay(hour: 18, minute: 30);
  TimeOfDay _dinnerEnd = const TimeOfDay(hour: 23, minute: 0);

  @override
  void initState() {
    super.initState();
    _selectedDays = List.filled(7, false);
    
    if (widget.initialMess != null && widget.initialMess!.operatingHours != null) {
      _initializeFromMess(widget.initialMess!);
    } else {
      // Default sample selection
      _selectedDays = [false, true, true, true, true, false, false];
    }
  }

  void _initializeFromMess(MessModel mess) {
    if (mess.operatingHours == null || mess.operatingHours!.isEmpty) return;

    for (var oh in mess.operatingHours!) {
      int index = _dayNames.indexOf(oh.day);
      if (index != -1) {
        _selectedDays[index] = oh.isOpen;
      }
    }

    // Grab first open day to populate times
    final openDay = mess.operatingHours!.firstWhere((element) => element.isOpen, orElse: () => mess.operatingHours!.first);
    
    if (openDay.breakfast != null) {
      _breakfastEnabled = true;
      _breakfastStart = _stringToTime(openDay.breakfast!.start);
      _breakfastEnd = _stringToTime(openDay.breakfast!.end);
    } else {
       _breakfastEnabled = false;
    }

    if (openDay.lunch != null) {
      _lunchEnabled = true;
      _lunchStart = _stringToTime(openDay.lunch!.start);
      _lunchEnd = _stringToTime(openDay.lunch!.end);
    } else {
      _lunchEnabled = false;
    }

    if (openDay.dinner != null) {
      _dinnerEnabled = true;
      _dinnerStart = _stringToTime(openDay.dinner!.start);
      _dinnerEnd = _stringToTime(openDay.dinner!.end);
    } else {
       _dinnerEnabled = false;
    }
  }

  TimeOfDay _stringToTime(String timeString) {
    final parts = timeString.split(':');
    if (parts.length != 2) return const TimeOfDay(hour: 12, minute: 0);
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '${hour.toString().padLeft(2, '0')}:$minute $period';
  }

  String _timeToString(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _pickTime(
    BuildContext context,
    TimeOfDay initial,
    ValueChanged<TimeOfDay> onPicked,
  ) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFE8650A),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF1A1A2E),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      onPicked(picked);
    }
  }

  Future<void> _onFinishOrSave() async {
    final List<OperatingHoursModel> operatingHours = [];
    
    for (int i = 0; i < _dayNames.length; i++) {
        operatingHours.add(OperatingHoursModel(
          day: _dayNames[i],
          isOpen: _selectedDays[i],
          breakfast: _breakfastEnabled ? MealTimeModel(
            start: _timeToString(_breakfastStart),
            end: _timeToString(_breakfastEnd),
          ) : null,
          lunch: _lunchEnabled ? MealTimeModel(
            start: _timeToString(_lunchStart),
            end: _timeToString(_lunchEnd),
          ) : null,
          dinner: _dinnerEnabled ? MealTimeModel(
            start: _timeToString(_dinnerStart),
            end: _timeToString(_dinnerEnd),
          ) : null,
        ));
    }

    if (widget.initialMess != null) {
      // Edit mode
      setState(() => _isSaving = true);
      try {
        await _messRepository.updateMess(widget.initialMess!.id!, {
          'operatingHours': operatingHours.map((e) => e.toJson()).toList(),
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Operating hours updated successfully')),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update: $e')),
          );
        }
      } finally {
        if (mounted) setState(() => _isSaving = false);
      }
    } else {
      // Registration mode
      ref.read(messRegistrationProvider.notifier).updateOperatingHours(operatingHours);
      final success = await ref.read(messRegistrationProvider.notifier).submit();
      
      if (success && mounted) {
        Navigator.pushNamed(context, AppRoutes.messProfileReadyScreen);
      } else if (mounted) {
        final error = ref.read(messRegistrationProvider).error ?? 'Submission failed';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 600;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: _bgColor,
        appBar: _buildAppBar(),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isTablet ? 560 : double.infinity,
              ),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 20,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildAvailableDaysSection(),
                          const SizedBox(height: 20),
                          _buildMealCard(
                            mealName: 'Breakfast',
                            iconBgColor: const Color(0xFFFFF3E0),
                            iconColor: const Color(0xFFFF8C00),
                            icon: Icons.wb_sunny_rounded,
                            isEnabled: _breakfastEnabled,
                            onToggle: (val) =>
                                setState(() => _breakfastEnabled = val),
                            startTime: _breakfastStart,
                            endTime: _breakfastEnd,
                            onStartTap: () => _pickTime(
                              context,
                              _breakfastStart,
                              (t) => setState(() => _breakfastStart = t),
                            ),
                            onEndTap: () => _pickTime(
                              context,
                              _breakfastEnd,
                              (t) => setState(() => _breakfastEnd = t),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildMealCard(
                            mealName: 'Lunch',
                            iconBgColor: const Color(0xFFFFF9C4),
                            iconColor: const Color(0xFFD4A017),
                            icon: Icons.menu_book_rounded,
                            isEnabled: _lunchEnabled,
                            onToggle: (val) =>
                                setState(() => _lunchEnabled = val),
                            startTime: _lunchStart,
                            endTime: _lunchEnd,
                            onStartTap: () => _pickTime(
                              context,
                              _lunchStart,
                              (t) => setState(() => _lunchStart = t),
                            ),
                            onEndTap: () => _pickTime(
                              context,
                              _lunchEnd,
                              (t) => setState(() => _lunchEnd = t),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildMealCard(
                            mealName: 'Dinner',
                            iconBgColor: const Color(0xFFE8EAF6),
                            iconColor: const Color(0xFF5C6BC0),
                            icon: Icons.nightlight_round,
                            isEnabled: _dinnerEnabled,
                            onToggle: (val) =>
                                setState(() => _dinnerEnabled = val),
                            startTime: _dinnerStart,
                            endTime: _dinnerEnd,
                            onStartTap: () => _pickTime(
                              context,
                              _dinnerStart,
                              (t) => setState(() => _dinnerStart = t),
                            ),
                            onEndTap: () => _pickTime(
                              context,
                              _dinnerEnd,
                              (t) => setState(() => _dinnerEnd = t),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                  _buildFinishButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1F2E)),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Operating Hours',
        style: GoogleFonts.plusJakartaSans(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF1A1A2E),
          letterSpacing: -0.2,
        ),
      ),
      systemOverlayStyle: SystemUiOverlayStyle.dark,
    );
  }

  Widget _buildAvailableDaysSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'AVAILABLE DAYS',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF8A94A6),
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          decoration: BoxDecoration(
            color: _cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(10),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_dayLabels.length, (index) {
              final isSelected = _selectedDays[index];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDays[index] = !_selectedDays[index];
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? _blueColor : const Color(0xFFEEEFF3),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _dayLabels[index],
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF9EA8B8),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildMealCard({
    required String mealName,
    required Color iconBgColor,
    required Color iconColor,
    required IconData icon,
    required bool isEnabled,
    required ValueChanged<bool> onToggle,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
    required VoidCallback onStartTap,
    required VoidCallback onEndTap,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardColor,
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
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  mealName,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _darkNavy,
                  ),
                ),
              ),
              Switch(
                value: isEnabled,
                onChanged: onToggle,
                activeThumbColor: Colors.white,
                activeTrackColor: _blueColor,
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: const Color(0xFFCDD0D8),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTimePicker(
                  label: 'Start Time',
                  time: startTime,
                  onTap: onStartTap,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTimePicker(
                  label: 'End Time',
                  time: endTime,
                  onTap: onEndTap,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimePicker({
    required String label,
    required TimeOfDay time,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF9EA8B8),
          ),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F6FA),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E5EC), width: 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatTime(time),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: _darkNavy,
                  ),
                ),
                const Icon(
                  Icons.access_time_rounded,
                  size: 18,
                  color: Color(0xFF9EA8B8),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFinishButton() {
    final isLoading = ref.watch(messRegistrationProvider).isLoading || _isSaving;
    final isEditMode = widget.initialMess != null;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: isLoading ? null : _onFinishOrSave,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1A1A2E),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  isEditMode ? 'Save Changes' : 'Finish Setup',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }
}
