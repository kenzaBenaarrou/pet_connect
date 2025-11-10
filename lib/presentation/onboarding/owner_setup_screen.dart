import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:pet_con/core/constants/app_constants.dart';
import 'package:pet_con/presentation/widgets/custom_button.dart';
import 'package:pet_con/presentation/widgets/custom_text_field.dart';
import 'package:pet_con/presentation/onboarding/pet_setup_screen.dart';
import 'package:pet_con/presentation/onboarding/onboarding_providers.dart';

class OwnerSetupScreen extends ConsumerStatefulWidget {
  const OwnerSetupScreen({super.key});

  @override
  ConsumerState<OwnerSetupScreen> createState() => _OwnerSetupScreenState();
}

class _OwnerSetupScreenState extends ConsumerState<OwnerSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final onboardingState = ref.watch(onboardingProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Setup Profile'),
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
                SizedBox(height: 20.h),

                // Header
                Text(
                  AppStrings.tellUsAboutYou,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppColors.primaryPink,
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 40.h),

                // Profile Picture
                Center(
                  child: GestureDetector(
                    onTap: _pickProfileImage,
                    child: Container(
                      width: 120.w,
                      height: 120.h,
                      decoration: BoxDecoration(
                        color: AppColors.backgroundLight,
                        borderRadius: BorderRadius.circular(60.r),
                        border: Border.all(
                          color: AppColors.primaryBlue,
                          width: 2,
                        ),
                      ),
                      child: onboardingState.ownerProfilePicture != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(60.r),
                              child: _buildImageWidget(
                                  onboardingState.ownerProfilePicture!),
                            )
                          : Icon(
                              Icons.camera_alt,
                              size: 40.w,
                              color: AppColors.primaryBlue,
                            ),
                    ),
                  ),
                ),

                SizedBox(height: 8.h),

                Center(
                  child: TextButton(
                    onPressed: _pickProfileImage,
                    child: Text(
                      onboardingState.ownerProfilePicture != null
                          ? 'Change Photo'
                          : 'Add Photo',
                    ),
                  ),
                ),

                SizedBox(height: 32.h),

                // Name Field
                CustomTextField(
                  controller: _nameController,
                  label: 'Your Name',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),

                SizedBox(height: 20.h),

                // Bio Field
                CustomTextField(
                  controller: _bioController,
                  label: 'About You (Optional)',
                  hint: 'Tell other pet owners about yourself...',
                  maxLines: 4,
                  maxLength: 300,
                ),

                SizedBox(height: 40.h),

                // Location Permission
                GestureDetector(
                  onTap: () async {
                    await ref
                        .read(onboardingProvider.notifier)
                        .requestLocationPermission();
                  },
                  child: Container(
                    padding: EdgeInsets.all(AppDimensions.paddingM.w),
                    decoration: BoxDecoration(
                      color: _getLocationCardColor(onboardingState),
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusM.r),
                      border: Border.all(
                        color: _getLocationBorderColor(onboardingState),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _getLocationIcon(onboardingState),
                          color: _getLocationIconColor(onboardingState),
                          size: 24.w,
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _getLocationTitle(onboardingState),
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: _getLocationTextColor(
                                          onboardingState),
                                    ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                _getLocationDescription(onboardingState),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        if (onboardingState.isLoading)
                          SizedBox(
                            width: 20.w,
                            height: 20.h,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.primaryBlue,
                              ),
                            ),
                          )
                        else if (onboardingState.ownerLocation != null)
                          Icon(
                            Icons.check_circle,
                            color: AppColors.success,
                            size: 20.w,
                          )
                        else
                          Icon(
                            Icons.arrow_forward_ios,
                            color: AppColors.textSecondary,
                            size: 16.w,
                          ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 40.h),

                // Continue Button
                CustomButton(
                  text: AppStrings.next,
                  onPressed: onboardingState.isLoading ? null : _handleContinue,
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

  void _pickProfileImage() async {
    final ImagePicker picker = ImagePicker();

    // Show dialog to choose between camera and gallery
    final ImageSource? source = await showDialog<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Choose Photo Source'),
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
          // For now, we'll use the local file path
          // In a real app, you'd upload this to Firebase Storage
          ref.read(onboardingProvider.notifier).setOwnerProfilePicture(
                image.path,
              );
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

  Widget _buildImageWidget(String imagePath) {
    // Check if it's a local file path or network URL
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return Image.network(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[300],
            child: Icon(
              Icons.error,
              color: Colors.grey[600],
              size: 40.sp,
            ),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
      );
    } else {
      // Local file path
      return Image.file(
        File(imagePath),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[300],
            child: Icon(
              Icons.error,
              color: Colors.grey[600],
              size: 40.sp,
            ),
          );
        },
      );
    }
  }

  // Location helper methods
  Color _getLocationCardColor(OnboardingState state) {
    if (state.error != null) {
      return AppColors.error.withOpacity(0.1);
    } else if (state.ownerLocation != null) {
      return AppColors.success.withOpacity(0.1);
    } else {
      return AppColors.info.withOpacity(0.1);
    }
  }

  Color _getLocationBorderColor(OnboardingState state) {
    if (state.error != null) {
      return AppColors.error.withOpacity(0.3);
    } else if (state.ownerLocation != null) {
      return AppColors.success.withOpacity(0.3);
    } else {
      return AppColors.info.withOpacity(0.3);
    }
  }

  IconData _getLocationIcon(OnboardingState state) {
    if (state.error != null) {
      return Icons.location_off;
    } else if (state.ownerLocation != null) {
      return Icons.location_on;
    } else {
      return Icons.location_searching;
    }
  }

  Color _getLocationIconColor(OnboardingState state) {
    if (state.error != null) {
      return AppColors.error;
    } else if (state.ownerLocation != null) {
      return AppColors.success;
    } else {
      return AppColors.info;
    }
  }

  Color _getLocationTextColor(OnboardingState state) {
    if (state.error != null) {
      return AppColors.error;
    } else if (state.ownerLocation != null) {
      return AppColors.success;
    } else {
      return AppColors.info;
    }
  }

  String _getLocationTitle(OnboardingState state) {
    if (state.error != null) {
      return 'Location Error';
    } else if (state.ownerLocation != null) {
      return 'Location Enabled';
    } else {
      return 'Location Access';
    }
  }

  String _getLocationDescription(OnboardingState state) {
    if (state.error != null) {
      return state.error!;
    } else if (state.ownerLocation != null) {
      return 'Great! We can now find nearby pets for playdates.';
    } else {
      return 'Tap to enable location access and find nearby pets for playdates.';
    }
  }

  void _handleContinue() async {
    if (!_formKey.currentState!.validate()) return;

    // Clear any previous errors
    if (ref.read(onboardingProvider).error != null) {
      ref.read(onboardingProvider.notifier).clearError();
    }

    // Save owner data
    ref.read(onboardingProvider.notifier).setOwnerData(
          name: _nameController.text.trim(),
          bio: _bioController.text.trim().isEmpty
              ? null
              : _bioController.text.trim(),
        );

    // Request location permission and get location if not already done
    if (ref.read(onboardingProvider).ownerLocation == null) {
      await ref.read(onboardingProvider.notifier).requestLocationPermission();
    }

    // Check if location was successfully obtained or if user wants to continue without it
    final currentState = ref.read(onboardingProvider);
    if (currentState.ownerLocation == null && currentState.error != null) {
      // Show dialog asking if user wants to continue without location
      final shouldContinue = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Location Required'),
            content: const Text(
              'Location access helps us find nearby pets for playdates. You can continue without it, but you may miss out on nearby connections.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Try Again'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Continue Without'),
              ),
            ],
          );
        },
      );

      if (shouldContinue != true) {
        return; // User wants to try again
      }
    }

    // Navigate to pet setup
    if (mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const PetSetupScreen(),
        ),
      );
    }
  }
}
