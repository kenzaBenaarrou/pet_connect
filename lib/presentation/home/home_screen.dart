import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:pet_con/core/constants/app_constants.dart';
import 'package:pet_con/presentation/home/home_providers.dart';
import 'package:pet_con/presentation/widgets/pet_card.dart';
import 'package:pet_con/data/models/pet_profile.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final SwiperController _controller = SwiperController();

  @override
  Widget build(BuildContext context) {
    final discoveryState = ref.watch(discoveryProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Row(
          children: [
            Icon(
              Icons.pets,
              color: AppColors.primaryPink,
              size: 28.w,
            ),
            SizedBox(width: 8.w),
            Text(
              AppStrings.appName,
              style: TextStyle(
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.bold,
                fontSize: AppFonts.sizeXL.sp,
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.primaryWhite,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              Icons.tune,
              color: AppColors.textSecondary,
              size: 24.w,
            ),
            onPressed: _showFilters,
          ),
        ],
      ),
      body: SafeArea(
        child: _buildBody(discoveryState),
      ),
    );
  }

  Widget _buildBody(DiscoveryState state) {
    if (state.isLoading && state.pets.isEmpty) {
      return _buildLoadingState();
    }

    if (state.error != null && state.pets.isEmpty) {
      return _buildErrorState(state.error!);
    }

    if (state.pets.isEmpty) {
      return _buildEmptyState();
    }

    final pets = state.pets;
    return Column(
      children: [
        // Location Info
        _buildLocationInfo(),

        // Swipe Stack
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(AppDimensions.paddingM.w),
            child: Swiper(
              controller: _controller,
              itemCount: pets.length,
              itemBuilder: (context, index) {
                final pet = pets[index];
                return PetCard(
                  pet: pet,
                  onTap: () => _showPetDetails(pet),
                );
              },
              onIndexChanged: (index) {
                // Optional: Load more pets when approaching end
                if (index >= pets.length - 3) {
                  ref.read(discoveryProvider.notifier).loadMorePets();
                }
              },
              layout: SwiperLayout.STACK,
              itemWidth: AppDimensions.cardWidth.w,
              itemHeight: AppDimensions.cardHeight.h,
              loop: false,
              curve: Curves.easeInOut,
            ),
          ),
        ),

        // Action Buttons
        _buildActionButtons(),
      ],
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
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
            'Something went wrong',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          SizedBox(height: 8.h),
          Text(
            error,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          ElevatedButton(
            onPressed: () {
              ref.read(discoveryProvider.notifier).refresh();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationInfo() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingM.w,
        vertical: AppDimensions.paddingS.h,
      ),
      color: AppColors.primaryWhite,
      child: Row(
        children: [
          Icon(
            Icons.location_on,
            color: AppColors.primaryBlue,
            size: 16.w,
          ),
          SizedBox(width: 4.w),
          Text(
            'Discovering pets near you',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const Spacer(),
          Text(
            '${ref.watch(discoverySettingsProvider).distance} miles',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.paddingL.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pets,
              size: 80.w,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
            SizedBox(height: 24.h),
            Text(
              'No more pets nearby',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            SizedBox(height: 12.h),
            Text(
              'Try adjusting your filters or check back later for new pets to meet!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32.h),
            ElevatedButton.icon(
              onPressed: () {
                ref.read(discoveryProvider.notifier).refresh();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: AppColors.primaryWhite,
                padding: EdgeInsets.symmetric(
                  horizontal: 24.w,
                  vertical: 12.h,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppDimensions.paddingL.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Pass Button
          _buildActionButton(
            icon: Icons.close,
            color: AppColors.error,
            onPressed: _onPassPressed,
          ),
          // Like Button
          _buildActionButton(
            icon: Icons.favorite,
            color: AppColors.primaryPink,
            onPressed: _onLikePressed,
            size: 60.w,
          ),
          // Super Like Button
          _buildActionButton(
            icon: Icons.star,
            color: AppColors.accentOrange,
            onPressed: _onSuperLikePressed,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    double? size,
  }) {
    final buttonSize = size ?? 50.w;
    return Container(
      width: buttonSize,
      height: buttonSize,
      decoration: BoxDecoration(
        color: AppColors.primaryWhite,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.textSecondary.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          icon,
          color: color,
          size: (buttonSize * 0.5),
        ),
      ),
    );
  }

  void _onPassPressed() {
    _controller.next();
  }

  void _onLikePressed() {
    _controller.next();
  }

  void _onSuperLikePressed() {
    _controller.next();
  }

  void _showFilters() {
    // TODO: Implement filter dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Filters coming soon!')),
    );
  }

  void _showPetDetails(PetProfile pet) {
    // TODO: Implement pet details screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Details for ${pet.name}')),
    );
  }
}
