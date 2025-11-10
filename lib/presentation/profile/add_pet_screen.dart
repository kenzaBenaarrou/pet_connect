import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:pet_con/core/constants/app_constants.dart';
import 'package:pet_con/presentation/auth/auth_providers.dart';
import 'package:pet_con/data/services/image_upload_service.dart';

class AddPetScreen extends ConsumerStatefulWidget {
  const AddPetScreen({super.key});

  @override
  ConsumerState<AddPetScreen> createState() => _AddPetScreenState();
}

class _AddPetScreenState extends ConsumerState<AddPetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  final _bioController = TextEditingController();

  int _selectedAge = 6; // months
  String _selectedSize = 'Medium';
  List<String> _selectedTemperaments = ['Friendly']; // Changed to list
  bool _isVaccinated = true;
  bool _isFixed = false;
  List<File> _selectedImages = [];
  bool _isLoading = false;

  final List<String> _sizeOptions = ['Small', 'Medium', 'Large'];
  final List<String> _temperamentOptions = [
    'Friendly',
    'Energetic',
    'Calm',
    'Playful',
    'Independent',
    'Affectionate'
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppColors.textLight,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              'Add Photos',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlue,
                  ),
            ),
            SizedBox(height: 20.h),
            Row(
              children: [
                Expanded(
                  child: _buildImageSourceOption(
                    icon: Icons.camera_alt,
                    title: 'Camera',
                    onTap: () async {
                      Navigator.pop(context);
                      final XFile? image = await picker.pickImage(
                        source: ImageSource.camera,
                        maxWidth: 800,
                        maxHeight: 800,
                        imageQuality: 85,
                      );
                      if (image != null) {
                        setState(() {
                          _selectedImages.add(File(image.path));
                        });
                      }
                    },
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: _buildImageSourceOption(
                    icon: Icons.photo_library,
                    title: 'Gallery',
                    onTap: () async {
                      Navigator.pop(context);
                      final List<XFile> images = await picker.pickMultiImage(
                        maxWidth: 800,
                        maxHeight: 800,
                        imageQuality: 85,
                      );
                      if (images.isNotEmpty) {
                        setState(() {
                          _selectedImages.addAll(
                            images.map((image) => File(image.path)).toList(),
                          );
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSourceOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryPink.withOpacity(0.1),
              AppColors.primaryBlue.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: AppColors.primaryPink.withOpacity(0.3),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32.w,
              color: AppColors.primaryPink,
            ),
            SizedBox(height: 8.h),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryBlue,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _savePet() async {
    if (!_formKey.currentState!.validate()) return;

    // Validate temperament selection
    if (_selectedTemperaments.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select at least one temperament'),
          backgroundColor: AppColors.error,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
      );
      return;
    }

    if (_selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please add at least one photo of your pet'),
          backgroundColor: AppColors.error,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final currentUser = ref.read(currentUserProvider);
      if (currentUser == null) {
        throw Exception('User not logged in');
      }

      // Get current position
      Position? position;
      try {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
      } catch (e) {
        // If location fails, we'll continue without it
        debugPrint('Failed to get location: $e');
      }

      // Generate a unique pet ID first
      const uuid = Uuid();
      final petId = uuid.v4();

      // Upload images to Firebase Storage
      List<String> imageUrls = [];
      if (_selectedImages.isNotEmpty) {
        try {
          // Show upload progress
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  SizedBox(
                    width: 20.w,
                    height: 20.h,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primaryWhite,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Text('Uploading ${_selectedImages.length} image${_selectedImages.length > 1 ? 's' : ''}...'),
                ],
              ),
              backgroundColor: AppColors.primaryPink,
              duration: const Duration(seconds: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          );

          imageUrls = await ImageUploadService.uploadPetImages(
            petId: petId,
            imageFiles: _selectedImages,
            onProgress: (progress) {
              debugPrint('Upload progress: ${(progress * 100).toStringAsFixed(1)}%');
            },
          );
          
          debugPrint('Successfully uploaded ${imageUrls.length} images');
        } catch (uploadError) {
          debugPrint('Error uploading images: $uploadError');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to upload images: ${uploadError.toString()}'),
                backgroundColor: AppColors.error,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            );
          }
          return; // Don't create pet without images
        }
      }

      // Save to Firestore with both photoUrls and images for compatibility
      await FirebaseFirestore.instance.collection('pets').doc(petId).set({
        'id': petId,
        'ownerId': currentUser.uid,
        'name': _nameController.text.trim(),
        'age': _selectedAge,
        'breed': _breedController.text.trim(),
        'size': _selectedSize,
        'temperament': _selectedTemperaments,
        'vaccinated': _isVaccinated,
        'fixed': _isFixed,
        'bio': _bioController.text.trim(),
        'photoUrls': imageUrls,
        'images': imageUrls, // Keep for backward compatibility
        if (position != null)
          'geoPoint': GeoPoint(position.latitude, position.longitude),
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: AppColors.primaryWhite,
                ),
                SizedBox(width: 8.w),
                Text('${_nameController.text} has been added successfully!'),
              ],
            ),
            backgroundColor: AppColors.success,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding pet: ${e.toString()}'),
            backgroundColor: AppColors.error,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Pet'),
        backgroundColor: AppColors.primaryWhite,
        foregroundColor: AppColors.primaryBlue,
        elevation: 0,
        actions: [
          if (_isLoading)
            Container(
              margin: EdgeInsets.only(right: 16.w),
              child: Center(
                child: SizedBox(
                  width: 20.w,
                  height: 20.h,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primaryPink,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pet Photos Section
              _buildSectionTitle('Pet Photos'),
              SizedBox(height: 12.h),
              _buildPhotoSection(),
              SizedBox(height: 24.h),

              // Basic Information
              _buildSectionTitle('Basic Information'),
              SizedBox(height: 12.h),
              _buildTextField(
                controller: _nameController,
                label: 'Pet Name',
                hint: 'Enter your pet\'s name',
                validator: (value) =>
                    value?.isEmpty == true ? 'Name is required' : null,
              ),
              SizedBox(height: 16.h),
              _buildTextField(
                controller: _breedController,
                label: 'Breed',
                hint: 'e.g., Golden Retriever, Persian Cat',
                validator: (value) =>
                    value?.isEmpty == true ? 'Breed is required' : null,
              ),
              SizedBox(height: 16.h),
              _buildAgeSelector(),
              SizedBox(height: 24.h),

              // Physical Characteristics
              _buildSectionTitle('Physical Characteristics'),
              SizedBox(height: 12.h),
              _buildDropdownField(
                label: 'Size',
                value: _selectedSize,
                items: _sizeOptions,
                onChanged: (value) => setState(() => _selectedSize = value!),
              ),
              SizedBox(height: 16.h),
              _buildTemperamentTagSelector(),
              SizedBox(height: 24.h),

              // Health Information
              _buildSectionTitle('Health Information'),
              SizedBox(height: 12.h),
              _buildSwitchTile(
                title: 'Vaccinated',
                subtitle: 'Is your pet up to date with vaccinations?',
                value: _isVaccinated,
                onChanged: (value) => setState(() => _isVaccinated = value),
              ),
              _buildSwitchTile(
                title: 'Spayed/Neutered',
                subtitle: 'Has your pet been fixed?',
                value: _isFixed,
                onChanged: (value) => setState(() => _isFixed = value),
              ),
              SizedBox(height: 24.h),

              // Bio Section
              _buildSectionTitle('About Your Pet'),
              SizedBox(height: 12.h),
              _buildTextField(
                controller: _bioController,
                label: 'Bio',
                hint:
                    'Tell us about your pet\'s personality, likes, and dislikes',
                maxLines: 4,
                validator: (value) =>
                    value?.isEmpty == true ? 'Bio is required' : null,
              ),
              SizedBox(height: 32.h),

              // Save Button
              _buildSaveButton(),
              SizedBox(height: 32.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primaryBlue,
          ),
    );
  }

  Widget _buildPhotoSection() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryPink.withOpacity(0.05),
            AppColors.primaryBlue.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.primaryPink.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          if (_selectedImages.isEmpty)
            GestureDetector(
              onTap: _pickImages,
              child: Container(
                height: 120.h,
                decoration: BoxDecoration(
                  color: AppColors.backgroundLight,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: AppColors.textLight.withOpacity(0.3),
                    style: BorderStyle.solid,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate,
                        size: 32.w,
                        color: AppColors.primaryPink,
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Add Photos',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: AppColors.primaryPink,
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Tap to add photos of your pet',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          if (_selectedImages.isNotEmpty) ...[
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8.w,
                mainAxisSpacing: 8.h,
              ),
              itemCount: _selectedImages.length + 1,
              itemBuilder: (context, index) {
                if (index == _selectedImages.length) {
                  return GestureDetector(
                    onTap: _pickImages,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.backgroundLight,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: AppColors.primaryPink.withOpacity(0.3),
                        ),
                      ),
                      child: Icon(
                        Icons.add,
                        color: AppColors.primaryPink,
                        size: 24.w,
                      ),
                    ),
                  );
                }
                return Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.r),
                        image: DecorationImage(
                          image: FileImage(_selectedImages[index]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4.w,
                      right: 4.w,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedImages.removeAt(index);
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.all(4.w),
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Icon(
                            Icons.close,
                            color: AppColors.primaryWhite,
                            size: 16.w,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.primaryPink,
              ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          validator: validator,
          maxLines: maxLines,
          style: TextStyle(
            fontFamily: AppFonts.fontFamily,
            fontSize: AppFonts.sizeS.sp,
            color: AppColors.primaryBlue,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: AppColors.textLight,
              fontSize: 14.sp,
            ),
            filled: true,
            fillColor: AppColors.primaryWhite,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: AppColors.backgroundLight,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: AppColors.backgroundLight,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: AppColors.primaryPink,
                width: 2,
              ),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 16.h,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAgeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Age',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.primaryPink,
              ),
        ),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppColors.primaryWhite,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: AppColors.backgroundLight,
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_selectedAge} month${_selectedAge == 1 ? '' : 's'} old',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryBlue,
                        ),
                  ),
                  Text(
                    _getAgeYearsText(),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Slider(
                value: _selectedAge.toDouble(),
                min: 1,
                max: 180, // 15 years
                divisions: 179,
                activeColor: AppColors.primaryPink,
                inactiveColor: AppColors.backgroundLight,
                onChanged: (value) {
                  setState(() {
                    _selectedAge = value.round();
                  });
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getAgeYearsText() {
    if (_selectedAge < 12) {
      return 'Puppy/Kitten';
    } else {
      final years = (_selectedAge / 12).floor();
      return '${years} year${years == 1 ? '' : 's'}';
    }
  }

  Widget _buildTemperamentTagSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Temperament',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.primaryBlue,
              ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Select all that apply to your pet',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
        SizedBox(height: 12.h),
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppColors.primaryWhite,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: AppColors.backgroundLight,
            ),
          ),
          child: Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: _temperamentOptions.map((temperament) {
              final isSelected = _selectedTemperaments.contains(temperament);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedTemperaments.remove(temperament);
                    } else {
                      _selectedTemperaments.add(temperament);
                    }
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 10.h,
                  ),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.primaryPink,
                              AppColors.primaryPink.withOpacity(0.8),
                            ],
                          )
                        : null,
                    color: isSelected ? null : AppColors.backgroundLight,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primaryPink
                          : AppColors.backgroundLight,
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.primaryPink.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isSelected) ...[
                        Icon(
                          Icons.check_circle,
                          size: 16.w,
                          color: AppColors.primaryWhite,
                        ),
                        SizedBox(width: 6.w),
                      ],
                      Text(
                        temperament,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: isSelected
                                  ? AppColors.primaryWhite
                                  : AppColors.primaryBlue,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                            ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        if (_selectedTemperaments.isEmpty)
          Padding(
            padding: EdgeInsets.only(top: 8.h),
            child: Text(
              'Please select at least one temperament',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.error,
                  ),
            ),
          ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.primaryBlue,
              ),
        ),
        SizedBox(height: 8.h),
        DropdownButtonFormField<String>(
          value: value,
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(item),
            );
          }).toList(),
          style: TextStyle(
            fontFamily: AppFonts.fontFamily,
            fontSize: AppFonts.sizeS.sp,
            color: AppColors.primaryBlue,
          ),
          icon: Icon(Icons.keyboard_arrow_down, color: AppColors.primaryPink),
          onChanged: (String? newValue) {
            if (newValue != null) {
              onChanged(newValue);
            }
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.primaryWhite,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: AppColors.backgroundLight,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: AppColors.backgroundLight,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: AppColors.primaryPink,
                width: 2,
              ),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 16.h,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.primaryWhite,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColors.backgroundLight,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryBlue,
                      ),
                ),
                SizedBox(height: 4.h),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primaryPink,
            activeTrackColor: AppColors.primaryPink.withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return Container(
      width: double.infinity,
      height: 56.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryPink,
            AppColors.primaryPink.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryPink.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _savePet,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
        ),
        child: _isLoading
            ? SizedBox(
                width: 24.w,
                height: 24.h,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.primaryWhite,
                  ),
                ),
              )
            : Text(
                'Add Pet',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryWhite,
                    ),
              ),
      ),
    );
  }
}
