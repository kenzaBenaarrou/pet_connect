import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:pet_con/core/constants/app_constants.dart';
import 'package:pet_con/presentation/widgets/custom_button.dart';
import 'package:pet_con/presentation/widgets/custom_text_field.dart';
import 'package:pet_con/presentation/onboarding/onboarding_providers.dart';
import 'package:pet_con/presentation/home/main_navigation.dart';

class PetSetupScreen extends ConsumerStatefulWidget {
  const PetSetupScreen({super.key});

  @override
  ConsumerState<PetSetupScreen> createState() => _PetSetupScreenState();
}

class _PetSetupScreenState extends ConsumerState<PetSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _breedController = TextEditingController();
  final _bioController = TextEditingController();

  String? _selectedSize;
  final List<String> _selectedTemperament = [];
  bool _vaccinated = false;
  bool _fixed = false;

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _breedController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final onboardingState = ref.watch(onboardingProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Your Pet'),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppDimensions.paddingL.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // SizedBox(height: 10.h),

                // Header
                Text(
                  AppStrings.tellUsAboutPet,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppColors.primaryPink,
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 40.h),

                // Pet Images
                _buildImageSection(),

                SizedBox(height: 32.h),

                // Pet Name
                CustomTextField(
                  controller: _nameController,
                  label: 'Pet Name',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your pet\'s name';
                    }
                    return null;
                  },
                ),

                SizedBox(height: 20.h),

                // Age and Breed Row
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: _ageController,
                        label: 'Age (months)',
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Required';
                          }
                          final age = int.tryParse(value);
                          if (age == null || age < 0 || age > 240) {
                            return 'Invalid age';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: CustomTextField(
                        controller: _breedController,
                        label: 'Breed',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter breed';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 20.h),

                // Size Selection
                _buildSizeSelection(),

                SizedBox(height: 20.h),

                // Temperament Selection
                _buildTemperamentSelection(),

                SizedBox(height: 20.h),

                // Health Info
                _buildHealthInfo(),

                SizedBox(height: 20.h),

                // Bio
                CustomTextField(
                  controller: _bioController,
                  label:
                      'About ${_nameController.text.isEmpty ? 'Pet' : _nameController.text} (Optional)',
                  hint:
                      'Tell other pet owners about your pet\'s personality...',
                  maxLines: 4,
                  maxLength: 300,
                ),

                SizedBox(height: 40.h),

                // Complete Button
                CustomButton(
                  text: 'Complete Setup',
                  onPressed: onboardingState.isLoading ? null : _handleComplete,
                  isLoading: onboardingState.isLoading,
                ),

                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    final onboardingState = ref.watch(onboardingProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pet Photos',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        SizedBox(height: 12.h),
        SizedBox(
          height: 100.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: onboardingState.petImages.length + 1,
            itemBuilder: (context, index) {
              if (index == onboardingState.petImages.length) {
                // Add photo button
                return GestureDetector(
                  onTap: _addPetImage,
                  child: Container(
                    width: 100.w,
                    margin: EdgeInsets.only(right: 12.w),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundLight,
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusM.r),
                      border: Border.all(
                        color: AppColors.primaryBlue,
                        style: BorderStyle.solid,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.add_a_photo,
                      color: AppColors.primaryBlue,
                      size: 30.w,
                    ),
                  ),
                );
              }

              // Pet image
              return Container(
                width: 100.w,
                margin: EdgeInsets.only(right: 12.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM.r),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM.r),
                  child: Stack(
                    children: [
                      _buildPetImageWidget(onboardingState.petImages[index]),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => _removePetImage(index),
                          child: Container(
                            padding: EdgeInsets.all(4.w),
                            decoration: const BoxDecoration(
                              color: AppColors.error,
                              shape: BoxShape.circle,
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
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSizeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pet Size',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        SizedBox(height: 12.h),
        Wrap(
          spacing: 8.w,
          children: AppConstants.petSizes.map((size) {
            final isSelected = _selectedSize == size;
            return ChoiceChip(
              label: Text(size),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedSize = selected ? size : null;
                });
              },
              selectedColor: AppColors.primaryBlue,
              labelStyle: TextStyle(
                color:
                    isSelected ? AppColors.primaryWhite : AppColors.primaryBlue,
                fontWeight: FontWeight.w500,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTemperamentSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Temperament (Select all that apply)',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        SizedBox(height: 12.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: AppConstants.temperaments.map((temperament) {
            final isSelected = _selectedTemperament.contains(temperament);
            return FilterChip(
              label: Text(temperament),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedTemperament.add(temperament);
                  } else {
                    _selectedTemperament.remove(temperament);
                  }
                });
              },
              selectedColor: AppColors.primaryPink,
              labelStyle: TextStyle(
                color:
                    isSelected ? AppColors.primaryWhite : AppColors.primaryPink,
                fontWeight: FontWeight.w500,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildHealthInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Health Information',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: CheckboxListTile(
                title: const Text('Vaccinated'),
                value: _vaccinated,
                onChanged: (value) {
                  setState(() {
                    _vaccinated = value ?? false;
                  });
                },
                contentPadding: EdgeInsets.zero,
                dense: true,
              ),
            ),
            Expanded(
              child: CheckboxListTile(
                title: const Text('Fixed/Neutered'),
                value: _fixed,
                onChanged: (value) {
                  setState(() {
                    _fixed = value ?? false;
                  });
                },
                contentPadding: EdgeInsets.zero,
                dense: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _addPetImage() async {
    final currentImages = ref.read(onboardingProvider).petImages;
    if (currentImages.length >= AppConstants.maxPetImages) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Maximum ${AppConstants.maxPetImages} photos allowed'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    final ImagePicker picker = ImagePicker();

    // Show dialog to choose between camera and gallery
    final ImageSource? source = await showDialog<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Pet Photo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () => Navigator.of(context).pop(ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () => Navigator.of(context).pop(ImageSource.gallery),
              ),
            ],
          ),
        );
      },
    );

    if (source != null) {
      try {
        final XFile? image = await picker.pickImage(
          source: source,
          maxWidth: 800,
          maxHeight: 800,
          imageQuality: 85,
        );

        if (image != null) {
          // Add the local file path to the pet images
          final newImages = [
            ...currentImages,
            image.path,
          ];
          ref.read(onboardingProvider.notifier).setPetImages(newImages);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error picking image: ${e.toString()}'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  void _removePetImage(int index) {
    final currentImages = ref.read(onboardingProvider).petImages;
    final newImages = [...currentImages];
    newImages.removeAt(index);
    ref.read(onboardingProvider.notifier).setPetImages(newImages);
  }

  Widget _buildPetImageWidget(String imagePath) {
    // Check if it's a local file path or network URL
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return Image.network(
        imagePath,
        fit: BoxFit.cover,
        width: 100.w,
        height: 100.h,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 100.w,
            height: 100.h,
            color: Colors.grey[300],
            child: Icon(
              Icons.error,
              color: Colors.grey[600],
              size: 30.sp,
            ),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return SizedBox(
            width: 100.w,
            height: 100.h,
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },
      );
    } else {
      // Local file path
      return Image.file(
        File(imagePath),
        fit: BoxFit.cover,
        width: 100.w,
        height: 100.h,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 100.w,
            height: 100.h,
            color: Colors.grey[300],
            child: Icon(
              Icons.error,
              color: Colors.grey[600],
              size: 30.sp,
            ),
          );
        },
      );
    }
  }

  void _handleComplete() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedSize == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select your pet\'s size'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_selectedTemperament.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one temperament'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    try {
      // Save pet data
      ref.read(onboardingProvider.notifier).setPetData(
            name: _nameController.text.trim(),
            age: int.parse(_ageController.text),
            breed: _breedController.text.trim(),
            size: _selectedSize!,
            temperament: _selectedTemperament,
            vaccinated: _vaccinated,
            fixed: _fixed,
            bio: _bioController.text.trim().isEmpty
                ? null
                : _bioController.text.trim(),
          );

      // Complete onboarding
      await ref.read(onboardingProvider.notifier).completeOnboarding();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile created successfully!'),
            backgroundColor: AppColors.success,
          ),
        );

        // Navigate to main app
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const MainNavigation()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
