import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pet_con/core/constants/app_constants.dart';
import 'package:pet_con/presentation/widgets/custom_button.dart';
import 'package:pet_con/presentation/onboarding/owner_setup_screen.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppDimensions.paddingL.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 40.h),

              // Welcome Header
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.pets,
                      size: 100.w,
                      color: AppColors.primaryPink,
                    ),
                    SizedBox(height: 24.h),
                    Text(
                      AppStrings.welcomeTitle,
                      style:
                          Theme.of(context).textTheme.headlineLarge?.copyWith(
                                color: AppColors.primaryCream,
                                fontWeight: FontWeight.bold,
                              ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      AppStrings.welcomeSubtitle,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.primaryCream,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Onboarding Steps
              _OnboardingStep(
                icon: Icons.person,
                title: 'Create Your Profile',
                description: 'Tell us about yourself and your location',
                color: AppColors.primaryBlue,
              ),

              SizedBox(height: 20.h),

              _OnboardingStep(
                icon: Icons.pets,
                title: 'Add Your Pet',
                description: 'Share your pet\'s photos and personality',
                color: AppColors.primaryPink,
              ),

              SizedBox(height: 20.h),

              _OnboardingStep(
                icon: Icons.favorite,
                title: 'Find Matches',
                description: 'Swipe to find perfect playmates nearby',
                color: AppColors.accentOrange,
              ),

              const Spacer(),

              // Get Started Button
              CustomButton(
                text: 'Get Started',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const OwnerSetupScreen(),
                    ),
                  );
                },
              ),

              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingStep extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const _OnboardingStep({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 60.w,
          height: 60.h,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppDimensions.radiusXL.r),
          ),
          child: Icon(
            icon,
            color: color,
            size: 30.w,
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              SizedBox(height: 4.h),
              Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
