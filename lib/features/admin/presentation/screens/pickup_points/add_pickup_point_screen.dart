import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:meal_house/core/di/service_locator.dart';
import 'package:meal_house/features/pickup_points/data/services/pickup_service.dart';
import 'package:meal_house/core/theme/app_theme.dart';

class AddPickupPointScreen extends StatefulWidget {
  final Map<String, dynamic>? initialData;
  const AddPickupPointScreen({super.key, this.initialData});

  @override
  State<AddPickupPointScreen> createState() => _AddPickupPointScreenState();
}

class _AddPickupPointScreenState extends State<AddPickupPointScreen> with TickerProviderStateMixin {
  // ─── Text Controllers ────────────────────────────────────────────────────────
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _searchCtrl = TextEditingController();
  final _latCtrl = TextEditingController(text: '19.0760');
  final _longCtrl = TextEditingController(text: '72.8777');
  // Meal Schedules State
  final _meals = ['Breakfast', 'Lunch', 'Dinner'];
  final Map<String, bool> _mealActive = {'Breakfast': false, 'Lunch': true, 'Dinner': true};
  final Map<String, TextEditingController> _mealStart = {
    'Breakfast': TextEditingController(text: '08:00'),
    'Lunch': TextEditingController(text: '12:00'),
    'Dinner': TextEditingController(text: '19:00'),
  };
  final Map<String, TextEditingController> _mealEnd = {
    'Breakfast': TextEditingController(text: '10:00'),
    'Lunch': TextEditingController(text: '14:00'),
    'Dinner': TextEditingController(text: '21:00'),
  };
  final _maxOrdersCtrl = TextEditingController(text: '50');
  final _instructionsCtrl = TextEditingController();
  
  // Contacts State
  final List<Map<String, TextEditingController>> _contacts = [];

  // ─── State ───────────────────────────────────────────────────────────────────
  bool _enablePoint = true;
  bool _isLoading = false;
  bool _isSearchingLocation = false;
  final PickupService _pickupService = sl<PickupService>();

  // ─── Animation ───────────────────────────────────────────────────────────────
  late AnimationController _saveAnimCtrl;
  late Animation<double> _saveScaleAnim;

  @override
  void initState() {
    super.initState();
    _saveAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
    );
    _saveScaleAnim = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _saveAnimCtrl, curve: Curves.easeOutCubic),
    );

    if (widget.initialData != null) {
      final d = widget.initialData!;
      _nameCtrl.text = d['name'] ?? '';
      _addressCtrl.text = d['address'] ?? '';
      _maxOrdersCtrl.text = (d['maxOrders'] ?? 50).toString();
      _instructionsCtrl.text = d['instructions'] ?? '';
      _enablePoint = d['isActive'] ?? true;
      
      // Load Operating Hours
      if (d['operatingHours'] != null) {
        final oh = d['operatingHours'];
        for (var m in _meals) {
          final key = m.toLowerCase();
          if (oh[key] != null) {
            _mealActive[m] = oh[key]['isActive'] ?? false;
            _mealStart[m]?.text = oh[key]['startTime'] ?? '08:00';
            _mealEnd[m]?.text = oh[key]['endTime'] ?? '10:00';
          }
        }
      }
      
      if (d['location'] != null && d['location']['coordinates'] != null) {
        final coords = d['location']['coordinates'];
        _longCtrl.text = coords[0].toString();
        _latCtrl.text = coords[1].toString();
      }

      if (d['contacts'] != null && d['contacts'] is List) {
        for (var c in d['contacts']) {
          _addContact(name: c['name'], phone: c['phone']);
        }
      }
    }

    if (_contacts.isEmpty) _addContact();
  }

  void _addContact({String? name, String? phone}) {
    setState(() {
      _contacts.add({
        'name': TextEditingController(text: name ?? ''),
        'phone': TextEditingController(text: phone ?? ''),
      });
    });
  }

  void _removeContact(int index) {
    if (_contacts.length > 1) {
      setState(() {
        _contacts[index]['name']?.dispose();
        _contacts[index]['phone']?.dispose();
        _contacts.removeAt(index);
      });
    }
  }

  @override
  void dispose() {
    _saveAnimCtrl.dispose();
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _searchCtrl.dispose();
    _latCtrl.dispose();
    _longCtrl.dispose();
    for (var m in _meals) {
      _mealStart[m]?.dispose();
      _mealEnd[m]?.dispose();
    }
    _maxOrdersCtrl.dispose();
    _instructionsCtrl.dispose();
    for (var c in _contacts) {
      c['name']?.dispose();
      c['phone']?.dispose();
    }
    super.dispose();
  }

  // ─── Location Logic ──────────────────────────────────────────────────────────

  Future<void> _getCurrentLocation() async {
    setState(() => _isSearchingLocation = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      
      if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
        Position position = await Geolocator.getCurrentPosition();
        setState(() {
          _latCtrl.text = position.latitude.toStringAsFixed(6);
          _longCtrl.text = position.longitude.toStringAsFixed(6);
        });
        
        // Reverse geocode to get address
        List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
        if (placemarks.isNotEmpty) {
          Placemark place = placemarks[0];
          setState(() {
            _addressCtrl.text = '${place.name}, ${place.subLocality}, ${place.locality}';
          });
        }
      }
    } catch (e) {
      _showError('Location Error: $e');
    } finally {
      setState(() => _isSearchingLocation = false);
    }
  }

  Future<void> _searchLocation() async {
    if (_searchCtrl.text.isEmpty) return;
    setState(() => _isSearchingLocation = true);
    try {
      List<Location> locations = await locationFromAddress(_searchCtrl.text);
      if (locations.isNotEmpty) {
        setState(() {
          _latCtrl.text = locations[0].latitude.toStringAsFixed(6);
          _longCtrl.text = locations[0].longitude.toStringAsFixed(6);
          _addressCtrl.text = _searchCtrl.text;
        });
        _showSuccess('Location matched');
      }
    } catch (e) {
      _showError('No results found for this address');
    } finally {
      setState(() => _isSearchingLocation = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: AppTheme.error));
  }

  void _showSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.green));
  }

  // ─── Styling Helpers ─────────────────────────────────────────────────────────

  TextStyle _premiumFont(double size, FontWeight weight, {Color? color, double letterSpacing = 0}) {
    return GoogleFonts.plusJakartaSans(
      fontSize: size,
      fontWeight: weight,
      color: color ?? AppTheme.textPrimary,
      letterSpacing: letterSpacing,
    );
  }

  InputDecoration _underlineDeco({
    required String hint,
    Widget? prefixIcon,
    Widget? suffixIcon,
    String? label,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: _premiumFont(12, FontWeight.w700, color: AppTheme.textMuted, letterSpacing: 0.5),
      hintText: hint,
      hintStyle: _premiumFont(14, FontWeight.w400, color: AppTheme.textMuted.withAlpha(150)),
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.divider, width: 1.5)),
      focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.primary, width: 2.2)),
      errorBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.error, width: 1.5)),
      focusedErrorBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.error, width: 2.2)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    );
  }

  Widget _sectionLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 10, left: 4),
    child: Text(
      text,
      style: _premiumFont(12, FontWeight.w800, color: AppTheme.textMuted, letterSpacing: 0.8),
    ),
  );

  Widget _fieldCard({required Widget child, EdgeInsets? padding}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: child,
    );
  }

  Future<void> _pickTime(TextEditingController ctrl) async {
    final now = TimeOfDay.now();
    final picked = await showTimePicker(
      context: context,
      initialTime: now,
    );
    if (picked != null) {
      final hour = picked.hour.toString().padLeft(2, '0');
      final minute = picked.minute.toString().padLeft(2, '0');
      setState(() => ctrl.text = '$hour:$minute');
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    await _saveAnimCtrl.forward();
    await _saveAnimCtrl.reverse();

    setState(() => _isLoading = true);
    try {
      final double lat = double.parse(_latCtrl.text);
      final double long = double.parse(_longCtrl.text);

      final Map<String, dynamic> data = {
        'name': _nameCtrl.text,
        'address': _addressCtrl.text,
        'location': {
          'type': 'Point',
          'coordinates': [long, lat],
        },
        'operatingHours': {
          'breakfast': {
            'isActive': _mealActive['Breakfast'],
            'startTime': _mealStart['Breakfast']!.text,
            'endTime': _mealEnd['Breakfast']!.text,
          },
          'lunch': {
            'isActive': _mealActive['Lunch'],
            'startTime': _mealStart['Lunch']!.text,
            'endTime': _mealEnd['Lunch']!.text,
          },
          'dinner': {
            'isActive': _mealActive['Dinner'],
            'startTime': _mealStart['Dinner']!.text,
            'endTime': _mealEnd['Dinner']!.text,
          },
        },
        'maxOrders': int.tryParse(_maxOrdersCtrl.text) ?? 50,
        'instructions': _instructionsCtrl.text,
        'contacts': _contacts.map((c) => {
          'name': c['name']!.text,
          'phone': c['phone']!.text,
        }).toList(),
        'isActive': _enablePoint,
      };

      if (widget.initialData != null && widget.initialData!['_id'] != null) {
        await _pickupService.updatePickupPoint(widget.initialData!['_id'], data);
      } else {
        await _pickupService.createPickupPoint(data);
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF2D7A4F),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Text(
                  widget.initialData != null ? 'Hub updated successfully' : 'Location deployed successfully',
                  style: _premiumFont(14, FontWeight.w600, color: Colors.white),
                ),
              ],
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showError('Deployment failed: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textPrimary, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.initialData != null ? 'Edit Fleet Hub' : 'Register Location',
          style: _premiumFont(18, FontWeight.w800, letterSpacing: -0.5),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionLabel('LOCATE ON MAP'),
                _buildSearchField(),
                const SizedBox(height: 24),
                _buildMapPlaceholder(),
                const SizedBox(height: 24),
                _sectionLabel('PICKUP POINT IDENTITY'),
                _fieldCard(
                  child: TextFormField(
                    controller: _nameCtrl,
                    textCapitalization: TextCapitalization.words,
                    style: _premiumFont(15, FontWeight.w600),
                    validator: (v) => v!.isEmpty ? 'Name required' : null,
                    decoration: _underlineDeco(hint: 'e.g., Gate 4 Hub'),
                  ),
                ),
                const SizedBox(height: 20),
                _sectionLabel('STREET ADDRESS'),
                _fieldCard(
                  child: TextFormField(
                    controller: _addressCtrl,
                    style: _premiumFont(15, FontWeight.w500),
                    validator: (v) => v!.isEmpty ? 'Address required' : null,
                    decoration: _underlineDeco(
                      hint: 'Exact street details',
                      prefixIcon: const Icon(Icons.location_on_rounded, color: AppTheme.primary, size: 20),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _buildCoordinatesRow(),
                const SizedBox(height: 12),
                _sectionLabel('MEAL SCHEDULES'),
                _buildMealSchedules(),
                const SizedBox(height: 12),
                const SizedBox(height: 24),
                _buildCapacitySection(),
                const SizedBox(height: 24),
                _buildContactSection(),
                const SizedBox(height: 24),
                _sectionLabel('OPERATIONAL STATUS'),
                _buildStatusToggle(),
                const SizedBox(height: 48),
                _buildSubmitButton(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return _fieldCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: _searchCtrl,
              style: _premiumFont(14, FontWeight.w500),
              decoration: const InputDecoration(
                hintText: 'Search city, area or landmark...',
                border: InputBorder.none,
                icon: Icon(Icons.search_rounded, color: AppTheme.textMuted, size: 20),
              ),
              onFieldSubmitted: (_) => _searchLocation(),
            ),
          ),
          if (_isSearchingLocation)
            const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
          else
            IconButton(
              icon: const Icon(Icons.my_location_rounded, color: AppTheme.primary, size: 20),
              onPressed: _getCurrentLocation,
              tooltip: 'Get current location',
            ),
        ],
      ),
    );
  }

  Widget _buildMapPlaceholder() {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue.withAlpha(50)),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(painter: _MapGridPainter(), size: Size.infinite),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_on_rounded, color: AppTheme.primary, size: 40),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 10)],
                ),
                child: Text('Lat: ${_latCtrl.text}, Lng: ${_longCtrl.text}', 
                     style: _premiumFont(10, FontWeight.w800, color: AppTheme.primary)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMealSchedules() {
    return Column(
      children: _meals.map((m) => _buildMealSegment(m)).toList(),
    );
  }

  Widget _buildMealSegment(String meal) {
    bool active = _mealActive[meal] ?? false;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: active ? AppTheme.primary.withAlpha(50) : AppTheme.divider),
      ),
      child: Column(
        children: [
          ListTile(
            dense: true,
            title: Text(meal.toUpperCase(), style: _premiumFont(13, FontWeight.w800, color: active ? AppTheme.primary : AppTheme.textMuted)),
            trailing: Switch.adaptive(
              value: active,
              onChanged: (v) => setState(() => _mealActive[meal] = v),
              activeColor: AppTheme.primary,
            ),
          ),
          if (active) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: [
                   Expanded(
                    child: _mealTimeField(
                      _mealStart[meal]!, 
                      'Start', 
                      () => _pickTime(_mealStart[meal]!)
                    ),
                  ),
                  const SizedBox(width: 12),
                   Expanded(
                    child: _mealTimeField(
                      _mealEnd[meal]!, 
                      'End', 
                      () => _pickTime(_mealEnd[meal]!)
                    ),
                  ),
                ],
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _mealTimeField(TextEditingController ctrl, String hint, VoidCallback onTap) {
    return TextFormField(
      controller: ctrl,
      readOnly: true,
      onTap: onTap,
      style: _premiumFont(14, FontWeight.w700),
      decoration: _underlineDeco(
        hint: hint,
        suffixIcon: const Icon(Icons.access_time_rounded, color: AppTheme.primary, size: 16),
      ),
    );
  }

  Widget _buildCoordinatesRow() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionLabel('LATITUDE'),
              _fieldCard(
                child: TextFormField(
                  controller: _latCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: _premiumFont(15, FontWeight.w700),
                  decoration: _underlineDeco(hint: '0.0000'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionLabel('LONGITUDE'),
              _fieldCard(
                child: TextFormField(
                  controller: _longCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: _premiumFont(15, FontWeight.w700),
                  decoration: _underlineDeco(hint: '0.0000'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }


  Widget _buildCapacitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('MAX ORDER CAPACITY'),
        _fieldCard(
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _maxOrdersCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: _premiumFont(24, FontWeight.w900, color: AppTheme.primary),
                  decoration: const InputDecoration(border: InputBorder.none, hintText: '50'),
                ),
              ),
              Text('UNITS', style: _premiumFont(12, FontWeight.w800, color: AppTheme.textMuted, letterSpacing: 1.5)),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _sectionLabel('SPECIAL INSTRUCTIONS'),
        _fieldCard(
          child: TextFormField(
            controller: _instructionsCtrl,
            maxLines: 3,
            style: _premiumFont(14, FontWeight.w400),
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'e.g. Leave near the security desk...',
              hintStyle: TextStyle(fontSize: 13),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContactSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _sectionLabel('PRIMARY CONTACTS'),
            TextButton.icon(
              onPressed: () => _addContact(),
              icon: const Icon(Icons.add_circle_outline_rounded, size: 16, color: AppTheme.primary),
              label: Text('ADD CONTACT', style: _premiumFont(11, FontWeight.w800, color: AppTheme.primary, letterSpacing: 0.5)),
            ),
          ],
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _contacts.length,
          separatorBuilder: (_, _) => const SizedBox(height: 16),
          itemBuilder: (ctx, i) => _buildContactItem(i),
        ),
      ],
    );
  }

  Widget _buildContactItem(int index) {
    return _fieldCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.person_pin_rounded, color: AppTheme.primary, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: _contacts[index]['name'],
                  style: _premiumFont(14, FontWeight.w600),
                  decoration: _underlineDeco(hint: 'Contact Person Name'),
                ),
              ),
              if (_contacts.length > 1)
                IconButton(
                  onPressed: () => _removeContact(index),
                  icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.error, size: 20),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.phone_iphone_rounded, color: AppTheme.textMuted, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: _contacts[index]['phone'],
                  keyboardType: TextInputType.phone,
                  style: _premiumFont(14, FontWeight.w500),
                  decoration: _underlineDeco(hint: 'Emergency Phone'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusToggle() {
    return _fieldCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(_enablePoint ? Icons.check_circle_rounded : Icons.cancel_rounded, 
                   color: _enablePoint ? Colors.green : AppTheme.textMuted),
              const SizedBox(width: 12),
              Text(_enablePoint ? 'Active for Fleet' : 'Scheduled Maintenance', 
                   style: _premiumFont(14, FontWeight.w700)),
            ],
          ),
          Switch.adaptive(
            value: _enablePoint,
            activeColor: AppTheme.primary,
            onChanged: (v) => setState(() => _enablePoint = v),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return ScaleTransition(
      scale: _saveScaleAnim,
      child: GestureDetector(
        onTap: _isLoading ? null : _submit,
        child: Container(
          width: double.infinity,
          height: 60,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.primary, Color(0xFFD63D22)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withAlpha(80),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Center(
            child: _isLoading
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.rocket_launch_rounded, color: Colors.white, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        widget.initialData != null ? 'UPDATE HUB' : 'DEPLOY HUB',
                        style: _premiumFont(16, FontWeight.w900, color: Colors.white, letterSpacing: 1.5),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.withAlpha(10)
      ..strokeWidth = 1.0;
    
    for (double i = 0; i < size.width; i += 20) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += 20) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
    
    final accentPaint = Paint()
      ..color = Colors.blue.withAlpha(20)
      ..strokeWidth = 3.0;
    
    canvas.drawLine(Offset(size.width * 0.5, 0), Offset(size.width * 0.5, size.height), accentPaint);
    canvas.drawLine(Offset(0, size.height * 0.5), Offset(size.width, size.height * 0.5), accentPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

