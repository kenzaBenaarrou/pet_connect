import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pet_con/core/constants/app_constants.dart';
import 'package:pet_con/presentation/profile/edit_pet_screen.dart';

class PetDetailsScreen extends ConsumerWidget {
  final String petId;
  final String petName;

  const PetDetailsScreen({
    super.key,
    required this.petId,
    required this.petName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('pets')
            .doc(petId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingState(context);
          }

          if (snapshot.hasError ||
              !snapshot.hasData ||
              !snapshot.data!.exists) {
            return _buildErrorState(context);
          }

          final petData = snapshot.data!.data() as Map<String, dynamic>;
          return _buildPetDetails(context, petData);
        },
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(petName),
        backgroundColor: AppColors.primaryWhite,
        foregroundColor: AppColors.primaryBlue,
        elevation: 0,
      ),
      body: Center(
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
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              AppColors.primaryPink,
            ),
            strokeWidth: 3,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pet Details'),
        backgroundColor: AppColors.primaryWhite,
        foregroundColor: AppColors.primaryBlue,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64.w,
              color: AppColors.error,
            ),
            SizedBox(height: 16.h),
            Text(
              'Pet not found',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            SizedBox(height: 8.h),
            Text(
              'This pet may have been removed or doesn\'t exist.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPetDetails(BuildContext context, Map<String, dynamic> petData) {
    // Try photoUrls first, then fallback to images for backward compatibility
    final photoUrls = petData['photoUrls'] as List<dynamic>?;
    final images = petData['images'] as List<dynamic>?;
    final List<String> imageUrls = List<String>.from(photoUrls ?? images ?? []);
    
    final String name = petData['name'] ?? 'Unknown';
    final String breed = petData['breed'] ?? 'Unknown';
    final int age = petData['age'] ?? 0;
    final String size = petData['size'] ?? 'Unknown';
    final List<String> temperament =
        List<String>.from(petData['temperament'] ?? []);
    final bool vaccinated = petData['vaccinated'] ?? false;
    final bool fixed = petData['fixed'] ?? false;
    final String bio = petData['bio'] ?? '';

    return CustomScrollView(
      slivers: [
        // Hero Image Section
        SliverAppBar(
          expandedHeight: 300.h,
          pinned: true,
          backgroundColor: AppColors.primaryWhite,
          foregroundColor: AppColors.primaryBlue,
          elevation: 0,
          flexibleSpace: FlexibleSpaceBar(
            background: _buildImageCarousel(imageUrls),
          ),
          actions: [
            Container(
              margin: EdgeInsets.only(right: 16.w),
              decoration: BoxDecoration(
                color: AppColors.primaryWhite.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: IconButton(
                icon: Icon(
                  Icons.favorite_border,
                  color: AppColors.primaryPink,
                ),
                onPressed: () {
                  // TODO: Add to favorites functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Favorite feature coming soon!'),
                      backgroundColor: AppColors.primaryPink,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),

        // Pet Details Content
        SliverToBoxAdapter(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.primaryWhite,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            ),
            child: Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Pet Name and Basic Info
                  _buildPetHeader(name, breed, age),
                  SizedBox(height: 24.h),

                  // Quick Stats
                  _buildQuickStats(size, vaccinated, fixed),
                  SizedBox(height: 24.h),

                  // Temperament Tags
                  if (temperament.isNotEmpty) ...[
                    _buildTemperamentSection(temperament),
                    SizedBox(height: 24.h),
                  ],

                  // Bio Section
                  if (bio.isNotEmpty) ...[
                    _buildBioSection(bio),
                    SizedBox(height: 24.h),
                  ],

                  // Action Buttons
                  _buildActionButtons(context, petData),
                  SizedBox(height: 32.h),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageCarousel(List<String> images) {
    if (images.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryPink.withOpacity(0.3),
              AppColors.primaryBlue.withOpacity(0.3),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.pets,
                size: 80.w,
                color: AppColors.primaryWhite,
              ),
              SizedBox(height: 12.h),
              Text(
                'No Photos Available',
                style: TextStyle(
                  color: AppColors.primaryWhite,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        PageView.builder(
          itemCount: images.length,
          itemBuilder: (context, index) {
            final imageUrl = images[index];

            // Check if it's a network URL or local path
            if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
              return CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primaryPink.withOpacity(0.1),
                        AppColors.primaryBlue.withOpacity(0.1),
                      ],
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 40.w,
                          height: 40.h,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primaryPink,
                            ),
                          ),
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'Loading image...',
                          style: TextStyle(
                            color: AppColors.primaryBlue,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primaryPink.withOpacity(0.3),
                        AppColors.primaryBlue.withOpacity(0.3),
                      ],
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.broken_image,
                          size: 60.w,
                          color: AppColors.primaryWhite,
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          'Failed to load image',
                          style: TextStyle(
                            color: AppColors.primaryWhite,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Tap to retry',
                          style: TextStyle(
                            color: AppColors.primaryWhite.withOpacity(0.8),
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            } else {
              // Local file path - show placeholder for now
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primaryPink.withOpacity(0.3),
                      AppColors.primaryBlue.withOpacity(0.3),
                    ],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.photo,
                        size: 60.w,
                        color: AppColors.primaryWhite,
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        'Local Image',
                        style: TextStyle(
                          color: AppColors.primaryWhite,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Not uploaded to cloud',
                        style: TextStyle(
                          color: AppColors.primaryWhite.withOpacity(0.8),
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
          },
        ),
        // Image counter
        if (images.length > 1)
          Positioned(
            top: 16.h,
            right: 16.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.8),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                '1/${images.length}',
                style: TextStyle(
                  color: AppColors.primaryWhite,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPetHeader(String name, String breed, int age) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                name,
                style: TextStyle(
                  fontSize: 32.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBlue,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: 6.h,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primaryPink.withOpacity(0.2),
                    AppColors.primaryBlue.withOpacity(0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: AppColors.primaryPink.withOpacity(0.3),
                ),
              ),
              child: Text(
                _getAgeText(age),
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryBlue,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Text(
          breed,
          style: TextStyle(
            fontSize: 18.sp,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStats(String size, bool vaccinated, bool fixed) {
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
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              icon: Icons.straighten,
              label: 'Size',
              value: size,
            ),
          ),
          Container(
            width: 1,
            height: 40.h,
            color: AppColors.backgroundLight,
          ),
          Expanded(
            child: _buildStatItem(
              icon: Icons.medical_services,
              label: 'Vaccinated',
              value: vaccinated ? 'Yes' : 'No',
              valueColor: vaccinated ? AppColors.success : AppColors.error,
            ),
          ),
          Container(
            width: 1,
            height: 40.h,
            color: AppColors.backgroundLight,
          ),
          Expanded(
            child: _buildStatItem(
              icon: Icons.healing,
              label: 'Spayed/Neutered',
              value: fixed ? 'Yes' : 'No',
              valueColor: fixed ? AppColors.success : AppColors.error,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          size: 24.w,
          color: AppColors.primaryPink,
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 10.sp,
            color: AppColors.textLight,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 2.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 12.sp,
            color: valueColor ?? AppColors.primaryBlue,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTemperamentSection(List<String> temperament) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Temperament',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryBlue,
          ),
        ),
        SizedBox(height: 12.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: temperament.map((trait) {
            return Container(
              padding: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: 8.h,
              ),
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
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Text(
                trait,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.primaryWhite,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildBioSection(String bio) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'About',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryBlue,
          ),
        ),
        SizedBox(height: 12.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppColors.backgroundLight.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: AppColors.backgroundLight,
            ),
          ),
          child: Text(
            bio,
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.primaryBlue,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(
      BuildContext context, Map<String, dynamic> petData) {
    return Column(
      children: [
        // Edit Pet Button
        Container(
          width: double.infinity,
          height: 52.h,
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
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditPetScreen(
                    petId: petId,
                    petData: petData,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.edit,
                  color: AppColors.primaryWhite,
                  size: 20.w,
                ),
                SizedBox(width: 8.w),
                Text(
                  'Edit Pet Profile',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryWhite,
                  ),
                ),
              ],
            ),
          ),
        ),

        SizedBox(height: 12.h),

        // Delete Pet Button
        Container(
          width: double.infinity,
          height: 52.h,
          child: OutlinedButton(
            onPressed: () {
              _showDeleteConfirmation(context);
            },
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                color: AppColors.error,
                width: 2,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.delete_outline,
                  color: AppColors.error,
                  size: 20.w,
                ),
                SizedBox(width: 8.w),
                Text(
                  'Delete Pet',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.error,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Pet',
          style: TextStyle(
            color: AppColors.primaryBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'Are you sure you want to delete this pet? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deletePet(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: Text(
              'Delete',
              style: TextStyle(color: AppColors.primaryWhite),
            ),
          ),
        ],
      ),
    );
  }

  void _deletePet(BuildContext context) async {
    try {
      await FirebaseFirestore.instance.collection('pets').doc(petId).delete();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Pet deleted successfully'),
            backgroundColor: AppColors.success,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting pet: ${e.toString()}'),
            backgroundColor: AppColors.error,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
        );
      }
    }
  }

  String _getAgeText(int age) {
    if (age < 12) {
      return '$age month${age == 1 ? '' : 's'} old';
    } else {
      final years = (age / 12).floor();
      final months = age % 12;

      if (months == 0) {
        return '$years year${years == 1 ? '' : 's'} old';
      } else {
        return '$years year${years == 1 ? '' : 's'}, $months month${months == 1 ? '' : 's'} old';
      }
    }
  }
}
