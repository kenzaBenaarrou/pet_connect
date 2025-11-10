import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pet_con/core/constants/app_constants.dart';
import 'package:pet_con/data/models/pet_profile.dart';

class PetCard extends StatefulWidget {
  final PetProfile pet;
  final VoidCallback? onTap;

  const PetCard({
    super.key,
    required this.pet,
    this.onTap,
  });

  @override
  State<PetCard> createState() => _PetCardState();
}

class _PetCardState extends State<PetCard> {
  int _currentImageIndex = 0;
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: AppDimensions.cardWidth.w,
        height: AppDimensions.cardHeight.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppDimensions.radiusL.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.textPrimary.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppDimensions.radiusL.r),
          child: Stack(
            children: [
              // Background Image Carousel
              _buildImageCarousel(),

              // Gradient Overlay
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 200.h,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        AppColors.textPrimary.withOpacity(0.8),
                      ],
                    ),
                  ),
                ),
              ),

              // Image Indicators
              if (widget.pet.images.length > 1) _buildImageIndicators(),

              // Pet Information
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildPetInfo(),
              ),

              // Health Icons
              Positioned(
                top: 16.h,
                right: 16.w,
                child: _buildHealthIcons(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageCarousel() {
    if (widget.pet.images.isEmpty) {
      return Container(
        color: AppColors.backgroundLight,
        child: Center(
          child: Icon(
            Icons.pets,
            size: 100.w,
            color: AppColors.textLight,
          ),
        ),
      );
    }

    return PageView.builder(
      controller: _pageController,
      itemCount: widget.pet.images.length,
      onPageChanged: (index) {
        setState(() {
          _currentImageIndex = index;
        });
      },
      itemBuilder: (context, index) {
        return CachedNetworkImage(
          imageUrl: widget.pet.images[index],
          fit: BoxFit.cover,
          width: double.infinity,
          placeholder: (context, url) => Container(
            color: AppColors.backgroundLight,
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.primaryBlue,
                ),
              ),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            color: AppColors.backgroundLight,
            child: Center(
              child: Icon(
                Icons.error_outline,
                size: 48.w,
                color: AppColors.error,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageIndicators() {
    return Positioned(
      top: 16.h,
      left: 16.w,
      right: 60.w, // Leave space for health icons
      child: Row(
        children: widget.pet.images.asMap().entries.map((entry) {
          final index = entry.key;
          return Container(
            width: 8.w,
            height: 8.h,
            margin: EdgeInsets.only(right: 4.w),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _currentImageIndex == index
                  ? AppColors.primaryWhite
                  : AppColors.primaryWhite.withOpacity(0.4),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildHealthIcons() {
    return Column(
      children: [
        if (widget.pet.vaccinated)
          Container(
            padding: EdgeInsets.all(8.w),
            margin: EdgeInsets.only(bottom: 8.h),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.9),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.vaccines,
              color: AppColors.primaryWhite,
              size: 16.w,
            ),
          ),
        if (widget.pet.fixed)
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.9),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.healing,
              color: AppColors.primaryWhite,
              size: 16.w,
            ),
          ),
      ],
    );
  }

  Widget _buildPetInfo() {
    return Padding(
      padding: EdgeInsets.all(AppDimensions.paddingL.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Name and Age
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.pet.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppColors.primaryWhite,
                        fontWeight: FontWeight.bold,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                  vertical: 4.h,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusXL.r),
                ),
                child: Text(
                  widget.pet.ageText,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.primaryWhite,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),

          SizedBox(height: 8.h),

          // Breed and Size
          Row(
            children: [
              Icon(
                Icons.pets,
                color: AppColors.primaryWhite,
                size: 16.w,
              ),
              SizedBox(width: 4.w),
              Text(
                '${widget.pet.breed} • ${widget.pet.size}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.primaryWhite.withOpacity(0.9),
                    ),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          // Temperament Tags
          if (widget.pet.temperament.isNotEmpty) ...[
            Wrap(
              spacing: 6.w,
              runSpacing: 6.h,
              children: widget.pet.temperament.take(3).map((temperament) {
                return Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryWhite.withOpacity(0.2),
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusS.r),
                    border: Border.all(
                      color: AppColors.primaryWhite.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    temperament,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.primaryWhite,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 8.h),
          ],

          // Bio Preview
          if (widget.pet.bio != null && widget.pet.bio!.isNotEmpty) ...[
            Text(
              widget.pet.bio!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.primaryWhite.withOpacity(0.9),
                  ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}
