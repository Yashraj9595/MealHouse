import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meal_house/core/di/service_locator.dart';
import 'package:meal_house/features/pickup_points/data/services/pickup_service.dart';
import 'package:meal_house/core/theme/app_theme.dart';
import 'add_pickup_point_screen.dart';

class PickupPointsScreen extends StatefulWidget {
  const PickupPointsScreen({super.key});

  @override
  State<PickupPointsScreen> createState() => _PickupPointsScreenState();
}

class _PickupPointsScreenState extends State<PickupPointsScreen> {
  final PickupService _pickupService = sl<PickupService>();
  final TextEditingController _searchCtrl = TextEditingController();
  
  int _selectedFilterIndex = 0; // 0: All, 1: Active, 2: Inactive
  final List<String> _filters = ['All Hubs', 'Operational', 'Maintenance'];
  
  List<dynamic> _locations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPickupPoints();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchPickupPoints() async {
    setState(() => _isLoading = true);
    try {
      final response = await _pickupService.getAllPickupPoints();
      if (mounted) {
        setState(() {
          _locations = response.data['data']['pickupPoints'];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Feed error: $e')));
      }
    }
  }

  List<dynamic> get _filteredLocations {
    List<dynamic> filtered = _locations;
    
    // Filter by Tab
    if (_selectedFilterIndex == 1) {
      filtered = filtered.where((l) => l['isActive'] == true).toList();
    } else if (_selectedFilterIndex == 2) {
      filtered = filtered.where((l) => l['isActive'] == false).toList();
    }
    
    // Search Filter
    if (_searchCtrl.text.isNotEmpty) {
      final query = _searchCtrl.text.toLowerCase();
      filtered = filtered.where((l) => 
        l['name'].toString().toLowerCase().contains(query) || 
        (l['address']?.toString().toLowerCase().contains(query) ?? false)
      ).toList();
    }
    
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 20),
                      _buildSearchAndFilter(),
                    ],
                  ),
                ),
              ),
              _isLoading 
                ? const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
                : _buildLocationsList(),
              const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
            ],
          ),
          Positioned(bottom: 24, left: 24, right: 24, child: _buildAddButton()),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textPrimary, size: 18),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text('Fleet Hubs', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 18)),
      actions: [
        IconButton(icon: const Icon(Icons.refresh_rounded, color: AppTheme.primary), onPressed: _fetchPickupPoints),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Operational Network',
          style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
        ),
        const SizedBox(height: 4),
        Text(
          'Manage your delivery points and capacity limits.',
          style: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppTheme.textSecondary),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilter() {
    return Column(
      children: [
        Container(
          height: 54,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.divider),
            boxShadow: [BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Row(
            children: [
              const SizedBox(width: 16),
              const Icon(Icons.search_rounded, color: AppTheme.textMuted, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Search hub name or tag...',
                    hintStyle: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppTheme.textMuted),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(_filters.length, (i) {
              final active = _selectedFilterIndex == i;
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: ChoiceChip(
                  label: Text(_filters[i]),
                  selected: active,
                  onSelected: (_) => setState(() => _selectedFilterIndex = i),
                  labelStyle: GoogleFonts.plusJakartaSans(
                    fontSize: 12, 
                    fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                    color: active ? Colors.white : AppTheme.textSecondary
                  ),
                  selectedColor: AppTheme.primary,
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: active ? AppTheme.primary : AppTheme.divider)),
                  showCheckmark: false,
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationsList() {
    final list = _filteredLocations;
    if (list.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_off_rounded, size: 64, color: AppTheme.textMuted.withAlpha(80)),
              const SizedBox(height: 16),
              Text('No hubs found', style: GoogleFonts.plusJakartaSans(color: AppTheme.textMuted, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      );
    }
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => _buildHubCard(list[index]),
        childCount: list.length,
      ),
    );
  }

  Widget _buildHubCard(dynamic loc) {
    final bool isActive = loc['isActive'] ?? true;
    
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.divider),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(4), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(loc['name'], style: GoogleFonts.plusJakartaSans(fontSize: 17, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
                    ),
                    _buildStatusBadge(isActive),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 14, color: AppTheme.textMuted),
                    const SizedBox(width: 4),
                    Expanded(child: Text(loc['address'] ?? 'No address', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppTheme.textSecondary), overflow: TextOverflow.ellipsis)),
                  ],
                ),
                const SizedBox(height: 16),
                _buildMealStatusRow(loc['operatingHours'] ?? {}),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: const BoxDecoration(color: Color(0xFFFAFAFA), borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20))),
            child: Row(
              children: [
                _actionIconButton(Icons.edit_note_rounded, 'EDIT', () async {
                  final res = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddPickupPointScreen(initialData: loc),
                    ),
                  );
                  if (res == true) _fetchPickupPoints();
                }),
                const Spacer(),
                _actionIconButton(Icons.delete_sweep_rounded, 'REMOVE', () async => _deleteHub(loc['_id']), isDanger: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: active ? const Color(0xFFE8F5E9) : const Color(0xFFFAEEEE),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        active ? 'OPERATIONAL' : 'MAINTENANCE',
        style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w800, color: active ? const Color(0xFF2E7D32) : AppTheme.error, letterSpacing: 0.5),
      ),
    );
  }

  Widget _buildMealStatusRow(Map<String, dynamic> oh) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _mealChip('B', oh['breakfast']),
          const SizedBox(width: 6),
          _mealChip('L', oh['lunch']),
          const SizedBox(width: 6),
          _mealChip('D', oh['dinner']),
        ],
      ),
    );
  }

  Widget _mealChip(String label, dynamic data) {
    final bool active = data != null && data['isActive'] == true;
    final String start = data?['startTime'] ?? '--:--';
    final String end = data?['endTime'] ?? '--:--';
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: active ? AppTheme.primary.withAlpha(15) : AppTheme.divider.withAlpha(50),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: active ? AppTheme.primary.withAlpha(40) : AppTheme.divider),
      ),
      child: Row(
        children: [
          Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w900, color: active ? AppTheme.primary : AppTheme.textMuted)),
          if (active) ...[
            const SizedBox(width: 6),
            Text('$start-$end', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
          ]
        ],
      ),
    );
  }

  Widget _actionIconButton(IconData icon, String label, VoidCallback onTap, {bool isDanger = false}) {
    return TextButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18, color: isDanger ? AppTheme.error : AppTheme.textSecondary),
      label: Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w800, color: isDanger ? AppTheme.error : AppTheme.textSecondary)),
    );
  }

  Future<void> _deleteHub(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Decommission Hub?', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800)),
        content: const Text('This will permanently remove the hub from the delivery grid.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('CANCEL')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text('REMOVE', style: TextStyle(color: AppTheme.error))),
        ],
      ),
    );
    if (confirm == true) {
      try {
        await _pickupService.deletePickupPoint(id);
        _fetchPickupPoints();
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Widget _buildAddButton() {
    return GestureDetector(
      onTap: () async {
        final res = await Navigator.push(context, MaterialPageRoute(builder: (context) => const AddPickupPointScreen()));
        if (res == true) _fetchPickupPoints();
      },
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [AppTheme.primary, Color(0xFFD63D22)]),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: AppTheme.primary.withAlpha(80), blurRadius: 20, offset: const Offset(0, 10))],
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.add_location_alt_rounded, color: Colors.white),
              const SizedBox(width: 12),
              Text('REGISTER NEW HUB', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1, fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}

