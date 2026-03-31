import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meal_house/core/theme/app_theme.dart';

class SkipMealScreen extends StatefulWidget {
  const SkipMealScreen({super.key});

  @override
  State<SkipMealScreen> createState() => _SkipMealScreenState();
}

class _SkipMealScreenState extends State<SkipMealScreen> {
  // Calendar state
  late DateTime _currentMonth;
  DateTime? _selectedDate;

  // Meal selection state
  bool _breakfastSelected = true;
  bool _lunchSelected = false;
  bool _dinnerSelected = true;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentMonth = DateTime(now.year, now.month);
    _selectedDate = now.add(const Duration(days: 1)); // Tomorrow by default
  }

  bool _isSelected(DateTime date) {
    return _selectedDate != null &&
        date.year == _selectedDate!.year &&
        date.month == _selectedDate!.month &&
        date.day == _selectedDate!.day;
  }

  String _monthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return months[month - 1];
  }

  String _ordinal(int day) {
    if (day >= 11 && day <= 13) return '${day}th';
    switch (day % 10) {
      case 1: return '${day}st';
      case 2: return '${day}nd';
      case 3: return '${day}rd';
      default: return '${day}th';
    }
  }

  List<DateTime?> _buildCalendarDays() {
    final firstDay = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final lastDay = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
    final startWeekday = firstDay.weekday % 7; // Sunday = 0

    final days = <DateTime?>[];
    for (int i = 0; i < startWeekday; i++) {
      days.add(null);
    }
    for (int d = 1; d <= lastDay.day; d++) {
      days.add(DateTime(_currentMonth.year, _currentMonth.month, d));
    }
    return days;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0EE),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F0EE),
        elevation: 0,
        surfaceTintColor: const Color(0xFFF5F0EE),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Skip Meal',
          style: GoogleFonts.dmSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 24),
            _buildHeading(),
            const SizedBox(height: 24),
            _buildCalendarCard(),
            const SizedBox(height: 24),
            _buildMealSection(),
            const SizedBox(height: 20),
            _buildSkipButton(),
            const SizedBox(height: 12),
            _buildNote(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHeading() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Text(
            'Skip Upcoming Meals',
            style: GoogleFonts.dmSans(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            'Heading out? Skip upcoming meals. Your balance will be adjusted accordingly.',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarCard() {
    final days = _buildCalendarDays();
    final dayHeaders = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left, color: AppTheme.primary),
                  onPressed: () => setState(() => _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1)),
                ),
                Text(
                  '${_monthName(_currentMonth.month)} ${_currentMonth.year}',
                  style: GoogleFonts.dmSans(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right, color: AppTheme.primary),
                  onPressed: () => setState(() => _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: dayHeaders
                  .map((d) => Expanded(
                    child: Center(
                      child: Text(
                        d,
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ),
                  ))
                  .toList(),
            ),
            const SizedBox(height: 12),
            _buildCalendarGrid(days),
            const SizedBox(height: 16),
            if (_selectedDate != null)
              Text(
                '${_monthName(_selectedDate!.month)} ${_ordinal(_selectedDate!.day)} selected',
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primary,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarGrid(List<DateTime?> days) {
    final rows = <Widget>[];
    for (int i = 0; i < days.length; i += 7) {
      final rowDays = days.sublist(i, i + 7 > days.length ? days.length : i + 7);
      while (rowDays.length < 7) { rowDays.add(null); }
      rows.add(Row(children: rowDays.map((date) => _buildDayCell(date)).toList()));
      if (i + 7 < days.length) rows.add(const SizedBox(height: 8));
    }
    return Column(children: rows);
  }

  Widget _buildDayCell(DateTime? date) {
    if (date == null) return const Expanded(child: SizedBox(height: 40));

    final bool isToday = _isSameDay(date, DateTime.now());
    final bool selected = _isSelected(date);
    final bool isPast = date.isBefore(DateTime.now().subtract(const Duration(days: 0))) && !isToday;

    return Expanded(
      child: GestureDetector(
        onTap: isPast ? null : () => setState(() => _selectedDate = date),
        child: Container(
          height: 40,
          decoration: BoxDecoration(
            color: selected ? AppTheme.primary : (isToday ? AppTheme.primaryLight : Colors.transparent),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '${date.day}',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: selected || isToday ? FontWeight.w700 : FontWeight.w400,
                color: selected ? Colors.white : (isPast ? Colors.grey.shade300 : AppTheme.textPrimary),
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  Widget _buildMealSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SELECT MEALS TO SKIP',
            style: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppTheme.primary,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 14),
          _buildMealCard(
            icon: Icons.coffee,
            title: 'Breakfast',
            time: '7:30 AM - 9:30 AM',
            selected: _breakfastSelected,
            onTap: () => setState(() => _breakfastSelected = !_breakfastSelected),
          ),
          const SizedBox(height: 12),
          _buildMealCard(
            icon: Icons.restaurant,
            title: 'Lunch',
            time: '12:30 PM - 2:30 PM',
            selected: _lunchSelected,
            onTap: () => setState(() => _lunchSelected = !_lunchSelected),
          ),
          const SizedBox(height: 12),
          _buildMealCard(
            icon: Icons.dinner_dining,
            title: 'Dinner',
            time: '7:30 PM - 9:30 PM',
            selected: _dinnerSelected,
            onTap: () => setState(() => _dinnerSelected = !_dinnerSelected),
          ),
        ],
      ),
    );
  }

  Widget _buildMealCard({
    required IconData icon,
    required String title,
    required String time,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: selected ? AppTheme.primary : Colors.transparent, width: 2),
        ),
        child: Row(
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(color: AppTheme.primaryLight, borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: AppTheme.primary, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w700)),
                Text(time, style: GoogleFonts.dmSans(fontSize: 13, color: AppTheme.textSecondary)),
              ],
            )),
            Checkbox(
              value: selected,
              onChanged: (_) => onTap(),
              activeColor: AppTheme.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkipButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Meals skipped successfully!'), backgroundColor: Colors.green),
            );
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primary,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: const Text('Skip Selected Meals', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        ),
      ),
    );
  }

  Widget _buildNote() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Text(
        'Note: Meals must be skipped at least 4 hours before the serving time.',
        style: GoogleFonts.dmSans(fontSize: 13, color: AppTheme.textMuted),
        textAlign: TextAlign.center,
      ),
    );
  }
}