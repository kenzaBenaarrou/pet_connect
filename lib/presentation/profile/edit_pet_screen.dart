import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pet_con/core/constants/app_constants.dart';
import 'package:pet_con/presentation/auth/auth_providers.dart';
import 'package:pet_con/data/services/image_upload_service.dart';

class EditPetScreen extends ConsumerStatefulWidget {
  final String petId;
  final Map<String, dynamic> petData;

  const EditPetScreen({
    super.key,
    required this.petId,
    required this.petData,
  });

  @override
  ConsumerState<EditPetScreen> createState() => _EditPetScreenState();
}

class _EditPetScreenState extends ConsumerState<EditPetScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _breedController;
  late TextEditingController _bioController;

  late int _selectedAge;
  late String _selectedSize;
  late List<String> _selectedTemperaments;
  late bool _isVaccinated;
  late bool _isFixed;
  List<File> _newImages = [];
  List<String> _existingImages = [];
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
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _nameController = TextEditingController(text: widget.petData['name'] ?? '');
    _breedController =
        TextEditingController(text: widget.petData['breed'] ?? '');
    _bioController = TextEditingController(text: widget.petData['bio'] ?? '');

    _selectedAge = widget.petData['age'] ?? 6;
    _selectedSize = widget.petData['size'] ?? 'Medium';
    _selectedTemperaments =
        List<String>.from(widget.petData['temperament'] ?? ['Friendly']);
    _isVaccinated = widget.petData['vaccinated'] ?? true;
    _isFixed = widget.petData['fixed'] ?? false;
    
    // Try photoUrls first, then fallback to images for backward compatibility
    final photoUrls = widget.petData['photoUrls'] as List<dynamic>?;
    final images = widget.petData['images'] as List<dynamic>?;
    _existingImages = List<String>.from(photoUrls ?? images ?? []);
  }

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
              'Add New Photos',
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
                          _newImages.add(File(image.path));
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
                          _newImages.addAll(
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

  Future<void> _updatePet() async {
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

    // Validate images (existing + new)
    if (_existingImages.isEmpty && _newImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please keep at least one photo of your pet'),
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

      // Get current position (optional)
      Position? position;
      try {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
      } catch (e) {
        debugPrint('Failed to get location: $e');
      }

      // Upload new images to Firebase Storage if any
      List<String> allImageUrls = [..._existingImages];
      
      if (_newImages.isNotEmpty) {
        try {
          // Show upload progress in snackbar
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
                  Text('Uploading ${_newImages.length} image${_newImages.length > 1 ? 's' : ''}...'),
                ],
              ),
              backgroundColor: AppColors.primaryPink,
              duration: const Duration(seconds: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          );

          // Upload new images to Firebase Storage
          final newImageUrls = await ImageUploadService.uploadPetImages(
            petId: widget.petId,
            imageFiles: _newImages,
            onProgress: (progress) {
              debugPrint('Upload progress: ${(progress * 100).toStringAsFixed(1)}%');
            },
          );
          
          allImageUrls.addAll(newImageUrls);
          debugPrint('Successfully uploaded ${newImageUrls.length} new images');
          
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
          // Continue with existing images only
        }
      }

      // Update pet profile in Firestore
      await FirebaseFirestore.instance
          .collection('pets')
          .doc(widget.petId)
          .update({
        'name': _nameController.text.trim(),
        'breed': _breedController.text.trim(),
        'age': _selectedAge,
        'size': _selectedSize,
        'temperament': _selectedTemperaments,
        'vaccinated': _isVaccinated,
        'fixed': _isFixed,
        'bio': _bioController.text.trim(),
        'photoUrls': allImageUrls,
        'images': allImageUrls, // Keep for backward compatibility
        if (position != null)
          'geoPoint': GeoPoint(position.latitude, position.longitude),
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
                Text('${_nameController.text} has been updated successfully!'),
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
            content: Text('Error updating pet: ${e.toString()}'),
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
        title: Text('Edit ${widget.petData['name'] ?? 'Pet'}'),
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

              // Update Button
              _buildUpdateButton(),
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
    final totalImages = _existingImages.length + _newImages.length;

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Current Photos ($totalImages)',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryBlue,
                    ),
              ),
              TextButton.icon(
                onPressed: _pickImages,
                icon: Icon(
                  Icons.add_photo_alternate,
                  size: 18.w,
                  color: AppColors.primaryPink,
                ),
                label: Text(
                  'Add More',
                  style: TextStyle(
                    color: AppColors.primaryPink,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          if (totalImages == 0)
            Container(
              height: 120.h,
              decoration: BoxDecoration(
                color: AppColors.backgroundLight,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: AppColors.textLight.withOpacity(0.3),
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
                      'No Photos',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          if (totalImages > 0)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8.w,
                mainAxisSpacing: 8.h,
              ),
              itemCount: totalImages,
              itemBuilder: (context, index) {
                final isExisting = index < _existingImages.length;

                if (isExisting) {
                  // Existing image
                  final imageUrl = _existingImages[index];
                  return Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: AppColors.primaryBlue.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10.r),
                          child: _buildExistingImage(imageUrl),
                        ),
                      ),
                      Positioned(
                        top: 4.w,
                        right: 4.w,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _existingImages.removeAt(index);
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
                } else {
                  // New image
                  final newImageIndex = index - _existingImages.length;
                  return Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: AppColors.primaryPink.withOpacity(0.5),
                            width: 2,
                          ),
                          image: DecorationImage(
                            image: FileImage(_newImages[newImageIndex]),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 4.w,
                        left: 4.w,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryPink,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            'NEW',
                            style: TextStyle(
                              color: AppColors.primaryWhite,
                              fontSize: 8.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 4.w,
                        right: 4.w,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _newImages.removeAt(newImageIndex);
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
                }
              },
            ),
        ],
      ),
    );
  }

  Widget _buildExistingImage(String imageUrl) {
    // Check if it's a network URL or local path
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        placeholder: (context, url) => Container(
          color: AppColors.backgroundLight,
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
        errorWidget: (context, url, error) => Container(
          color: AppColors.backgroundLight,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.broken_image,
                color: AppColors.textLight,
                size: 24.w,
              ),
              SizedBox(height: 4.h),
              Text(
                'Failed to load',
                style: TextStyle(
                  color: AppColors.textLight,
                  fontSize: 8.sp,
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      // Local file or placeholder
      return Container(
        color: AppColors.backgroundLight,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pets,
              color: AppColors.textLight,
              size: 24.w,
            ),
            SizedBox(height: 4.h),
            Text(
              'Local',
              style: TextStyle(
                color: AppColors.textLight,
                fontSize: 8.sp,
              ),
            ),
          ],
        ),
      );
    }
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
                color: AppColors.primaryPink,
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
          icon: Icon(Icons.keyboard_arrow_down, color: AppColors.primaryPink),
          onChanged: (String? newValue) {
            if (newValue != null) {
              onChanged(newValue);
            }
          },
          style: TextStyle(
            fontFamily: AppFonts.fontFamily,
            fontSize: AppFonts.sizeS.sp,
            color: AppColors.primaryBlue,
          ),
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

  Widget _buildUpdateButton() {
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
        onPressed: _isLoading ? null : _updatePet,
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
                'Update Pet',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryWhite,
                    ),
              ),
      ),
    );
  }
}
