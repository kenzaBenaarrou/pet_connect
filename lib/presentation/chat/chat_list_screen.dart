import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pet_con/core/constants/app_constants.dart';

class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.chat),
        backgroundColor: AppColors.primaryWhite,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Safety Banner
          Container(
            margin: EdgeInsets.all(AppDimensions.paddingM.w),
            padding: EdgeInsets.all(AppDimensions.paddingM.w),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radiusM.r),
              border: Border.all(
                color: AppColors.info.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.security,
                  color: AppColors.info,
                  size: 20.w,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    AppStrings.safetyTip,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.info,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ),
              ],
            ),
          ),

          // Chat List (Empty State)
          Expanded(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(AppDimensions.paddingL.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.chat_bubble_outline,
                      size: 80.w,
                      color: AppColors.accentGreen,
                    ),
                    SizedBox(height: 24.h),
                    Text(
                      'No Conversations Yet',
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      'When you match with other pets, you can start chatting with their owners here.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 32.h),
                    Text(
                      'Get swiping to start conversations!',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.accentGreen,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
