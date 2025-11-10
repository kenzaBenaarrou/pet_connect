import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pet_con/core/constants/app_constants.dart';
import 'package:pet_con/presentation/widgets/custom_button.dart';

class MatchDialog extends StatelessWidget {
  final String petName;
  final String petImageUrl;
  final VoidCallback onStartChatting;
  final VoidCallback onKeepSwiping;

  const MatchDialog({
    super.key,
    required this.petName,
    required this.petImageUrl,
    required this.onStartChatting,
    required this.onKeepSwiping,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.primaryWhite,
          borderRadius: BorderRadius.circular(AppDimensions.radiusL.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with animation
            Container(
              padding: EdgeInsets.all(AppDimensions.paddingL.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primaryBlue,
                    AppColors.primaryPink,
                  ],
                ),
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppDimensions.radiusL.r),
                ),
              ),
              child: Column(
                children: [
                  // Celebration Animation (placeholder)
                  Container(
                    width: 80.w,
                    height: 80.h,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryWhite,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.favorite,
                      color: AppColors.primaryPink,
                      size: 40.w,
                    ),
                  ),

                  SizedBox(height: 16.h),

                  Text(
                    AppStrings.itsAMatch,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppColors.primaryWhite,
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: 8.h),

                  Text(
                    'You and $petName liked each other',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.primaryWhite.withOpacity(0.9),
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Pet Image
            Padding(
              padding: EdgeInsets.all(AppDimensions.paddingL.w),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusM.r),
                    child: Image.network(
                      petImageUrl,
                      width: 120.w,
                      height: 120.h,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 120.w,
                          height: 120.h,
                          color: AppColors.backgroundLight,
                          child: Icon(
                            Icons.pets,
                            size: 40.w,
                            color: AppColors.textLight,
                          ),
                        );
                      },
                    ),
                  ),

                  SizedBox(height: 24.h),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          text: AppStrings.keepSwiping,
                          onPressed: onKeepSwiping,
                          backgroundColor: AppColors.primaryWhite,
                          textColor: AppColors.primaryBlue,
                          borderColor: AppColors.primaryBlue,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: CustomButton(
                          text: AppStrings.startChatting,
                          onPressed: onStartChatting,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void show(
    BuildContext context, {
    required String petName,
    required String petImageUrl,
    required VoidCallback onStartChatting,
    required VoidCallback onKeepSwiping,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => MatchDialog(
        petName: petName,
        petImageUrl: petImageUrl,
        onStartChatting: onStartChatting,
        onKeepSwiping: onKeepSwiping,
      ),
    );
  }
}
