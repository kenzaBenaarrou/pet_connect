import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pet_con/core/constants/app_constants.dart';

/// Demo widget to show how Firebase Storage URLs work with CachedNetworkImage
class FirebaseImageDemo extends StatelessWidget {
  FirebaseImageDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Image Demo'),
        backgroundColor: AppColors.primaryWhite,
        foregroundColor: AppColors.primaryBlue,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Firebase Storage Integration Demo',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlue,
              ),
            ),
            SizedBox(height: 16.h),
            
            Text(
              'Features Implemented:',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryPink,
              ),
            ),
            SizedBox(height: 8.h),
            
            _buildFeatureItem('✅ Multi-image upload to Firebase Storage'),
            _buildFeatureItem('✅ Unique folder structure: pets/{userId}/{petId}/'),
            _buildFeatureItem('✅ Download URLs stored in Firestore'),
            _buildFeatureItem('✅ CachedNetworkImage for efficient loading'),
            _buildFeatureItem('✅ Upload progress tracking'),
            _buildFeatureItem('✅ Error handling and offline support'),
            _buildFeatureItem('✅ Backward compatibility with existing data'),
            
            SizedBox(height: 24.h),
            
            Text(
              'How it works:',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryBlue,
              ),
            ),
            SizedBox(height: 8.h),
            
            _buildStepItem('1. User selects multiple images', Icons.photo_library),
            _buildStepItem('2. Images upload to Firebase Storage', Icons.cloud_upload),
            _buildStepItem('3. Download URLs saved to Firestore', Icons.storage),
            _buildStepItem('4. Images display with caching', Icons.image),
            
            SizedBox(height: 24.h),
            
            Text(
              'Sample Firebase Storage URL Structure:',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 8.h),
            
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppColors.backgroundLight.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: AppColors.primaryPink.withOpacity(0.3)),
              ),
              child: Text(
                'pets/{userId}/{petId}/{timestamp}_0.jpg',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontFamily: 'monospace',
                  color: AppColors.primaryBlue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem(String text, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryPink.withOpacity(0.1),
                  AppColors.primaryBlue.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              icon,
              size: 20.w,
              color: AppColors.primaryPink,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}