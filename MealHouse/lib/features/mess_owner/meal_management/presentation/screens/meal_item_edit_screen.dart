import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:MealHouse/core/app_export.dart';
import '../../domain/entities/meal_group_entity.dart';
import '../../domain/entities/meal_item_entity.dart';
import 'package:MealHouse/core/services/media_picker_service.dart';
import '../state/meal_providers.dart';

class MealItemEditScreen extends ConsumerStatefulWidget {
  final MealGroupEntity? group;
  final String messId;

  const MealItemEditScreen({super.key, this.group, required this.messId});

  @override
  ConsumerState<MealItemEditScreen> createState() => _MealItemEditScreenState();
}

class _MealItemEditScreenState extends ConsumerState<MealItemEditScreen> {
  late TextEditingController _titleController;
  late TextEditingController _priceController;
  late TextEditingController _quantityController;
  late List<MealItemEntity> _items;
  late MealType _selectedMealType;
  String? _selectedImagePath;
  String? _selectedVideoPath;
  final MediaPickerService _mediaPickerService = MediaPickerService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.group?.title ?? "");
    _priceController = TextEditingController(text: widget.group?.price.toString() ?? "");
    _quantityController = TextEditingController(text: widget.group?.availableQuantity.toString() ?? "50");
    _items = widget.group != null ? List.from(widget.group!.items) : [];
    _selectedMealType = widget.group?.mealType ?? MealType.lunch;
    _selectedImagePath = widget.group?.imageUrl;
    _selectedVideoPath = widget.group?.videoUrl;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _saveMeal() async {
    if (_titleController.text.isEmpty || _priceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all required fields")),
      );
      return;
    }

    setState(() => _isLoading = true);

    final newGroup = MealGroupEntity(
      id: widget.group?.id ?? '', // ID will be handled by backend for creates usually, or generaetd here if needed
      title: _titleController.text,
      price: double.tryParse(_priceController.text) ?? 0.0,
      items: _items,
      availableQuantity: int.tryParse(_quantityController.text) ?? 0,
      mealType: _selectedMealType,
      imageUrl: _selectedImagePath,
      videoUrl: _selectedVideoPath,
      isActive: widget.group?.isActive ?? true,
    );

    final result = widget.group == null
        ? await ref.read(createMealGroupUseCaseProvider)(widget.messId, newGroup)
        : await ref.read(updateMealGroupUseCaseProvider)(widget.messId, newGroup);

    setState(() => _isLoading = false);

    result.fold(
      (failure) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.message))),
      (success) {
        ref.refresh(mealListProvider(widget.messId));
        Navigator.pop(context);
      },
    );
  }

  void _addItem() {
    showDialog(
      context: context,
      builder: (context) {
        final itemController = TextEditingController();
        return AlertDialog(
          title: const Text("Add New Item"),
          content: TextField(
            controller: itemController,
            decoration: const InputDecoration(
              hintText: "Enter item name (e.g. Butter Roti)",
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                if (itemController.text.isNotEmpty) {
                  setState(() {
                    _items.add(MealItemEntity(
                      id: DateTime.now().toString(),
                      name: itemController.text,
                    ));
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () async {
                Navigator.pop(context);
                final path = await _mediaPickerService.pickImageFromGallery();
                if (path != null) {
                  setState(() {
                    _selectedImagePath = path;
                  });
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a Photo'),
              onTap: () async {
                Navigator.pop(context);
                final path = await _mediaPickerService.pickImageFromCamera();
                if (path != null) {
                  setState(() {
                    _selectedImagePath = path;
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickVideo() async {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.video_library),
              title: const Text('Choose from Gallery'),
              onTap: () async {
                Navigator.pop(context);
                final path = await _mediaPickerService.pickVideoFromGallery();
                if (path != null) {
                  setState(() {
                    _selectedVideoPath = path;
                  });
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.videocam),
              title: const Text('Record a Video'),
              onTap: () async {
                Navigator.pop(context);
                final path = await _mediaPickerService.pickVideoFromCamera();
                if (path != null) {
                  setState(() {
                    _selectedVideoPath = path;
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.group == null ? "Create New Meal" : "Edit Meal",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: _isLoading 
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) 
              : const CustomIconWidget(iconName: AppIcons.checkGroup, color: AppColors.primary),
            onPressed: _isLoading ? null : _saveMeal,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(5.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("Media (Photo & Video)"),
            SizedBox(height: 2.h),
            Row(
              children: [
                _buildMediaPicker(
                  label: "Photo",
                  icon: AppIcons.camera,
                  path: _selectedImagePath,
                  onTap: _pickImage,
                  isImage: true,
                ),
                SizedBox(width: 4.w),
                _buildMediaPicker(
                  label: "Video",
                  icon: AppIcons.video,
                  path: _selectedVideoPath,
                  onTap: _pickVideo,
                  isImage: false,
                ),
              ],
            ),
            SizedBox(height: 4.h),
            _buildSectionTitle("Basic Details"),
            SizedBox(height: 2.h),
            _buildTextField("Meal Title", _titleController, "e.g. Sunday Special Thali"),
            SizedBox(height: 2.h),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    "Price (₹)",
                    _priceController,
                    "e.g. 150",
                    keyboardType: TextInputType.number,
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: _buildTextField(
                    "Total Quantity",
                    _quantityController,
                    "e.g. 50",
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            SizedBox(height: 3.h),
            _buildSectionTitle("Meal Type"),
            SizedBox(height: 1.5.h),
            _buildMealTypeSelector(),
            SizedBox(height: 4.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSectionTitle("Meal Items"),
                TextButton.icon(
                  onPressed: _addItem,
                  icon: const CustomIconWidget(iconName: AppIcons.add, color: AppColors.primary, size: 16),
                  label: const Text("Add Item"),
                ),
              ],
            ),
            SizedBox(height: 1.h),
            if (_items.isEmpty)
              _buildEmptyItems()
            else
              _buildItemsList(),
            SizedBox(height: 5.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveMeal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  disabledBackgroundColor: Colors.grey,
                ),
                child: _isLoading 
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text("Save Meal", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaPicker({
    required String label,
    required String icon,
    String? path,
    required VoidCallback onTap,
    required bool isImage,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 15.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: path != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: isImage
                      ? (path.startsWith('http')
                          ? Image.network(path, fit: BoxFit.cover)
                          : Image.file(File(path), fit: BoxFit.cover))
                      : Container(
                          color: Colors.black87,
                          child: const Center(
                            child: CustomIconWidget(iconName: AppIcons.video, color: Colors.white, size: 32),
                          ),
                        ),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomIconWidget(iconName: icon, color: AppColors.primary, size: 32),
                    SizedBox(height: 1.h),
                    Text("Add $label", style: const TextStyle(fontSize: 12, color: AppColors.textBody)),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildMealTypeSelector() {
    return Row(
      children: MealType.values.map((type) {
        final isSelected = _selectedMealType == type;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedMealType = type),
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 1.w),
              padding: EdgeInsets.symmetric(vertical: 1.5.h),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? AppColors.primary : Colors.grey[300]!,
                ),
              ),
              child: Center(
                child: Text(
                  type.name,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textBody,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textHeader),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, String hint, {TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textBody, fontSize: 14)),
        SizedBox(height: 1.h),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyItems() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!, style: BorderStyle.solid),
      ),
      child: Column(
        children: [
          Opacity(
            opacity: 0.3,
            child: const CustomIconWidget(iconName: AppIcons.menu, size: 48, color: AppColors.textBody),
          ),
          SizedBox(height: 2.h),
          const Text(
            "No items added yet. Click 'Add Item' to start building your meal.",
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textBody),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsList() {
    return Column(
      children: _items.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        return Container(
          margin: EdgeInsets.only(bottom: 1.5.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w500)),
            trailing: IconButton(
              icon: const CustomIconWidget(iconName: AppIcons.delete, color: Colors.red, size: 20),
              onPressed: () {
                setState(() {
                  _items.removeAt(index);
                });
              },
            ),
          ),
        );
      }).toList(),
    );
  }
}
