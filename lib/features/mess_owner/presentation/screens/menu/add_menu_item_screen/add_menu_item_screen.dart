import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meal_house/core/di/service_locator.dart';
import 'package:meal_house/features/mess_owner/domain/repositories/mess_repository.dart';
import 'package:meal_house/features/mess_owner/domain/models/menu_model.dart';
import 'package:meal_house/core/theme/app_theme.dart';

class AddMenuItemScreen extends StatefulWidget {
  final MenuItemModel? initialItem;
  final int? itemIndex;

  const AddMenuItemScreen({
    super.key,
    this.initialItem,
    this.itemIndex,
  });

  @override
  State<AddMenuItemScreen> createState() => _AddMenuItemScreenState();
}

class _AddMenuItemScreenState extends State<AddMenuItemScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  String _selectedCategory = 'Veg';
  List<String> _selectedMealTypes = ['Extra'];
  bool _isAvailable = true;
  late TextEditingController _quantityController;
  String? _existingImageUrl;

  XFile? _pickedImage;
  final ImagePicker _picker = ImagePicker();
  bool _isSaving = false;
  String? _messId;
  final MessRepository _messRepository = sl<MessRepository>();

  final List<String> _mealTypes = ['Breakfast', 'Lunch', 'Dinner', 'Extra'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialItem?.name ?? '');
    _descriptionController = TextEditingController(text: widget.initialItem?.description ?? '');
    _priceController = TextEditingController(text: widget.initialItem?.price.toString() ?? '');
    _quantityController = TextEditingController(text: widget.initialItem?.platesAvailable.toString() ?? '0');
    _selectedCategory = widget.initialItem?.category ?? 'Veg';
    _selectedMealTypes = widget.initialItem?.mealType ?? ['Extra'];
    _isAvailable = widget.initialItem?.isAvailable ?? true;
    _existingImageUrl = widget.initialItem?.image;
    _fetchMyMesses();
  }

  Future<void> _fetchMyMesses() async {
    try {
      final messes = await _messRepository.getMyMesses();
      if (messes.isNotEmpty) {
        setState(() {
          _messId = messes.first.id;
        });
      }
    } catch (e) {
      debugPrint('Error fetching messes: $e');
    }
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Photo Library'),
              onTap: () async {
                final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
                if (image != null) {
                  setState(() {
                    _pickedImage = image;
                  });
                }
                if (mounted) Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Camera'),
              onTap: () async {
                final XFile? image = await _picker.pickImage(source: ImageSource.camera, imageQuality: 70);
                if (image != null) {
                  setState(() {
                    _pickedImage = image;
                  });
                }
                if (mounted) Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: _buildAppBar(),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildFoodMediaSection(),
            const SizedBox(height: 20),
            _buildThaliNameField(),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildPriceField()),
                const SizedBox(width: 16),
                Expanded(child: _buildCategoryDropdown()),
              ],
            ),
            const SizedBox(height: 16),
            _buildMealTypeSelection(),
            const SizedBox(height: 16),
            _buildQuantityField(),
            const SizedBox(height: 16),
            _buildShortDescriptionField(),
            const SizedBox(height: 24),
            _buildAvailabilityToggle(),
            const SizedBox(height: 32),
            _buildAddButton(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1F2E), size: 24),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        widget.initialItem != null ? 'Edit Menu Item' : 'Add Menu Item',
        style: GoogleFonts.plusJakartaSans(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF1A1F2E),
        ),
      ),
      centerTitle: false,
      titleSpacing: 0,
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF1A1F2E),
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildFoodMediaSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Food Media'),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            width: double.infinity,
            height: 180,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE8D5C0), width: 1.5),
            ),
            child: _pickedImage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: kIsWeb 
                      ? Image.network(_pickedImage!.path, fit: BoxFit.cover)
                      : Image.file(File(_pickedImage!.path), fit: BoxFit.cover),
                  )
                : _existingImageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.network(
                        _existingImageUrl!.startsWith('http') 
                          ? _existingImageUrl! 
                          : 'http://localhost:5000$_existingImageUrl',
                        fit: BoxFit.cover,
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFDE8D8),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.add_a_photo_outlined,
                            color: Color(0xFFE8650A),
                            size: 26,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Upload Food Image',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1A1A1A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'JPG, PNG format (Maximum 5MB)',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF888888),
                          ),
                        ),
                      ],
                    ),
          ),
        ),
      ],
    );
  }

  Widget _buildMealTypeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Meal Type (When is this served?)',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A1F2E),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _mealTypes.map((type) {
            final isSelected = _selectedMealTypes.contains(type);
            return FilterChip(
              label: Text(
                type,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? Colors.white : const Color(0xFF6B7280),
                ),
              ),
              selected: isSelected,
              onSelected: (bool selected) {
                setState(() {
                  if (selected) {
                    _selectedMealTypes.add(type);
                    if (type != 'Extra') _selectedMealTypes.remove('Extra');
                  } else {
                    _selectedMealTypes.remove(type);
                    if (_selectedMealTypes.isEmpty) _selectedMealTypes.add('Extra');
                  }
                });
              },
              backgroundColor: Colors.white,
              selectedColor: AppTheme.primary,
              checkmarkColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(
                  color: isSelected ? AppTheme.primary : const Color(0xFFE5E7EB),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildQuantityField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Plates Available (Quantity)',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A1F2E),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _quantityController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            color: const Color(0xFF1A1F2E),
          ),
          decoration: InputDecoration(
            hintText: 'e.g. 50',
            hintStyle: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: const Color(0xFF9CA3AF),
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.primary, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter availability count';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildThaliNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Item Name',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A1F2E),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _nameController,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            color: const Color(0xFF1A1F2E),
          ),
          decoration: InputDecoration(
            hintText: 'e.g. Special Veg Thali',
            hintStyle: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: const Color(0xFF9CA3AF),
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.primary, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter item name';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPriceField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Price',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A1F2E),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _priceController,
          keyboardType: const TextInputType.numberWithOptions(
            decimal: true,
          ),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
          ],
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            color: const Color(0xFF1A1F2E),
          ),
          decoration: InputDecoration(
            hintText: '0.00',
            hintStyle: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: const Color(0xFF9CA3AF),
            ),
            prefixText: '₹  ',
            prefixStyle: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: const Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppTheme.primary,
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter price';
            }
            if (double.tryParse(value) == null) {
              return 'Please enter a valid number';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A1F2E),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedCategory,
              hint: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Select Category',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    color: const Color(0xFF1A1F2E),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              isExpanded: true,
              icon: const Padding(
                padding: EdgeInsets.only(right: 16),
                child: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Color(0xFF6B7280),
                  size: 28,
                ),
              ),
              borderRadius: BorderRadius.circular(12),
              items: <String>['Veg', 'Non-Veg', 'Snacks', 'Drinks']
                  .map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      value,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        color: const Color(0xFF1A1F2E),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedCategory = newValue!;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildShortDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Short Description',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A1F2E),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _descriptionController,
          maxLines: 4,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            color: const Color(0xFF1A1F2E),
          ),
          decoration: InputDecoration(
            hintText:
                'Describe the items (e.g. 2 Roti, Dal, Rice...)',
            hintStyle: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: const Color(0xFF9CA3AF),
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.primary, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a description';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildAvailabilityToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Available',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A1F2E),
          ),
        ),
        Switch(
          value: _isAvailable,
          onChanged: (value) {
            setState(() {
              _isAvailable = value;
            });
          },
          activeThumbColor: AppTheme.primary,
        ),
      ],
    );
  }

  Widget _buildAddButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _handleAddMenuItem,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: _isSaving
            ? const CircularProgressIndicator(color: Colors.white)
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(50),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: Icon(widget.initialItem != null ? Icons.save : Icons.add, size: 16, color: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    widget.initialItem != null ? 'Update Menu Item' : 'Add Menu Item',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _handleAddMenuItem() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_messId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mess information not found. Please try again.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      // 1. Upload new image if selected, otherwise keep existing
      String? imageUrl = _existingImageUrl;
      if (_pickedImage != null) {
        final bytes = await _pickedImage!.readAsBytes();
        final uploadedUrls = await _messRepository.uploadImagesBytes([bytes], [_pickedImage!.name]);
        if (uploadedUrls.isNotEmpty) {
          imageUrl = uploadedUrls[0];
        }
      }

      // 2. Fetch current menu
      MenuModel? currentMenu;
      try {
        currentMenu = await _messRepository.getMenu(_messId!);
      } catch (e) {
        currentMenu = MenuModel(messId: _messId!, items: []);
      }

      // 3. Create/Update item
      final newItem = MenuItemModel(
        id: widget.initialItem?.id,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        price: double.parse(_priceController.text),
        category: _selectedCategory,
        mealType: _selectedMealTypes,
        platesAvailable: int.tryParse(_quantityController.text) ?? 0,
        isAvailable: _isAvailable,
        image: imageUrl,
      );

      // 4. Update items list
      List<MenuItemModel> updatedItems = List<MenuItemModel>.from(currentMenu.items);
      
      if (widget.initialItem != null && widget.itemIndex != null) {
        // Find by index if possible, otherwise by name/price (safer fallback)
        if (widget.itemIndex! < updatedItems.length) {
          updatedItems[widget.itemIndex!] = newItem;
        } else {
           // Fallback matching
           final idx = updatedItems.indexWhere((i) => i.id == widget.initialItem!.id || 
               (i.name == widget.initialItem!.name && i.price == widget.initialItem!.price));
           if (idx != -1) updatedItems[idx] = newItem;
        }
      } else {
        updatedItems.add(newItem);
      }
      
      final updatedMenu = currentMenu.copyWith(items: updatedItems);

      // 5. Save to backend
      await _messRepository.updateMenu(updatedMenu);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.initialItem != null ? 'Item updated successfully!' : 'Item added successfully!'),
            backgroundColor: const Color(0xFF22C55E),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      debugPrint('Error saving menu: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}