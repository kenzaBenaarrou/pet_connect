import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:io';
import 'package:pet_con/core/constants/app_constants.dart';
import 'package:pet_con/presentation/auth/auth_providers.dart';
import 'package:pet_con/presentation/widgets/custom_button.dart';
import 'package:pet_con/data/repositories/owner_repository.dart';
import 'package:pet_con/presentation/profile/my_pets_screen.dart';
import 'package:pet_con/presentation/profile/discovery_settings_screen.dart';
import 'package:pet_con/presentation/profile/location_screen.dart';
import 'package:pet_con/presentation/profile/notifications_screen.dart';
import 'package:pet_con/presentation/profile/help_support_screen.dart';
import 'package:pet_con/presentation/profile/privacy_policy_screen.dart';

// Provider to fetch owner profile
final ownerProfileProvider = FutureProvider.autoDispose((ref) async {
  final currentUser = ref.watch(currentUserProvider);
  if (currentUser == null) return null;

  final ownerRepository = ref.read(ownerRepositoryProvider);
  return ownerRepository.getOwnerProfile(currentUser.uid);
});

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final ownerProfileAsync = ref.watch(ownerProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.profile),
        backgroundColor: AppColors.primaryWhite,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              Icons.settings,
              color: AppColors.textSecondary,
              size: 24.w,
            ),
            onPressed: () {
              // TODO: Navigate to settings
            },
          ),
        ],
      ),
      body: ownerProfileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error loading profile: $error'),
        ),
        data: (ownerProfile) => SingleChildScrollView(
          padding: EdgeInsets.all(AppDimensions.paddingL.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Profile Header
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 100.w,
                      height: 100.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50.r),
                        border: Border.all(
                          color: AppColors.primaryBlue,
                          width: 3,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                            47.r), // Slightly smaller to account for border
                        child: _buildProfileImage(
                          ownerProfile?.profilePicture ?? currentUser?.photoURL,
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      ownerProfile?.name ??
                          currentUser?.displayName ??
                          'Pet Owner',
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      currentUser?.email ?? '',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                    if (ownerProfile?.bio != null &&
                        ownerProfile!.bio!.isNotEmpty) ...[
                      SizedBox(height: 8.h),
                      Text(
                        ownerProfile.bio!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                              fontStyle: FontStyle.italic,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),

              SizedBox(height: 40.h),

              // Menu Items
              _ProfileMenuItem(
                icon: Icons.pets,
                title: 'My Pets',
                subtitle: 'Manage your pet profiles',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const MyPetsScreen(),
                    ),
                  );
                },
              ),

              _ProfileMenuItem(
                icon: Icons.tune,
                title: 'Discovery Settings',
                subtitle: 'Adjust search preferences',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const DiscoverySettingsScreen(),
                    ),
                  );
                },
              ),

              _ProfileMenuItem(
                icon: Icons.location_on,
                title: 'Location',
                subtitle: 'Update your location',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const LocationScreen(),
                    ),
                  );
                },
              ),

              _ProfileMenuItem(
                icon: Icons.notifications,
                title: 'Notifications',
                subtitle: 'Manage push notifications',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const NotificationsScreen(),
                    ),
                  );
                },
              ),

              _ProfileMenuItem(
                icon: Icons.help_outline,
                title: 'Help & Support',
                subtitle: 'FAQs and contact us',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const HelpSupportScreen(),
                    ),
                  );
                },
              ),

              _ProfileMenuItem(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy Policy',
                subtitle: 'View our privacy policy',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const PrivacyPolicyScreen(),
                    ),
                  );
                },
              ),

              SizedBox(height: 40.h),

              // Sign Out Button
              CustomButton(
                text: AppStrings.signOut,
                onPressed: () => _handleSignOut(context, ref),
                backgroundColor: AppColors.error,
              ),

              SizedBox(height: 20.h),

              // App Version
              Center(
                child: Text(
                  'PetConnect v1.0.0',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textLight,
                      ),
                ),
              ),

              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }

  void _handleSignOut(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(authProvider.notifier).signOut();
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      // Default placeholder when no image
      return Container(
        color: AppColors.backgroundLight,
        child: Icon(
          Icons.person,
          size: 50.w,
          color: AppColors.primaryBlue,
        ),
      );
    }

    // Check if it's a local file path or network URL
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        width: 100.w,
        height: 100.h,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: AppColors.backgroundLight,
            child: Icon(
              Icons.person,
              size: 50.w,
              color: AppColors.primaryBlue,
            ),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: AppColors.backgroundLight,
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
                strokeWidth: 2,
              ),
            ),
          );
        },
      );
    } else {
      // Local file path
      return Image.file(
        File(imageUrl),
        fit: BoxFit.cover,
        width: 100.w,
        height: 100.h,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: AppColors.backgroundLight,
            child: Icon(
              Icons.person,
              size: 50.w,
              color: AppColors.primaryBlue,
            ),
          );
        },
      );
    }
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      child: ListTile(
        leading: Container(
          width: 48.w,
          height: 48.h,
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppDimensions.radiusM.r),
          ),
          child: Icon(
            icon,
            color: AppColors.primaryBlue,
            size: 24.w,
          ),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.w600,
              ),
        ),
        subtitle: Text(
          subtitle,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: AppColors.textLight,
          size: 20.w,
        ),
        onTap: onTap,
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingM.w,
          vertical: AppDimensions.paddingS.h,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusM.r),
        ),
        tileColor: AppColors.primaryWhite,
      ),
    );
  }
}
