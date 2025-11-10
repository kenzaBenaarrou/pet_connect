import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pet_con/core/constants/app_constants.dart';
import 'package:pet_con/presentation/auth/auth_providers.dart';
import 'package:pet_con/presentation/profile/add_pet_screen.dart';
import 'package:pet_con/presentation/profile/pet_details_screen.dart';

class MyPetsScreen extends ConsumerWidget {
  const MyPetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Pets'),
        backgroundColor: AppColors.primaryWhite,
        foregroundColor: AppColors.primaryBlue,
        elevation: 0,
      ),
      body: currentUser == null
          ? const Center(
              child: Text('Please log in to view your pets'),
            )
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('pets')
                  .where('ownerId', isEqualTo: currentUser.uid)
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
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
                        SizedBox(height: 16.h),
                        Text(
                          'Loading your pets...',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                        ),
                      ],
                    ),
                  );
                }

                if (snapshot.hasError) {
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
                          'Error loading pets',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          snapshot.error.toString(),
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                final pets = snapshot.data?.docs ?? [];

                if (pets.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 120.w,
                          height: 120.h,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.primaryPink.withOpacity(0.1),
                                AppColors.primaryBlue.withOpacity(0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(60.r),
                          ),
                          child: Icon(
                            Icons.pets,
                            size: 60.w,
                            color: AppColors.primaryPink,
                          ),
                        ),
                        SizedBox(height: 24.h),
                        Text(
                          'No pets yet',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                color: AppColors.primaryBlue,
                                fontWeight: FontWeight.bold,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Add your first pet to get started\nwith PetConnect!',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 24.h),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 8.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryPink.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(
                              color: AppColors.primaryPink.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.add_circle_outline,
                                color: AppColors.primaryPink,
                                size: 16.w,
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                'Tap the + button below',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: AppColors.primaryPink,
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.all(AppDimensions.paddingM.w),
                  itemCount: pets.length,
                  itemBuilder: (context, index) {
                    final petDoc = pets[index];
                    final petData = petDoc.data() as Map<String, dynamic>;

                    // Try photoUrls first, then fallback to images for backward compatibility
                    final photoUrls = petData['photoUrls'] as List<dynamic>?;
                    final images = petData['images'] as List<dynamic>?;
                    final imageList = List<String>.from(photoUrls ?? images ?? []);

                    return _PetListItem(
                      petId: petDoc.id,
                      name: petData['name'] ?? 'Unknown',
                      breed: petData['breed'] ?? 'Unknown',
                      age: petData['age'] ?? 0,
                      images: imageList,
                    );
                  },
                );
              },
            ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryPink,
              AppColors.primaryPink.withOpacity(0.8),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryPink.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddPetScreen(),
              ),
            );
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Icon(
            Icons.add,
            color: AppColors.primaryWhite,
            size: 28.w,
          ),
        ),
      ),
    );
  }
}

class _PetListItem extends StatefulWidget {
  final String petId;
  final String name;
  final String breed;
  final int age;
  final List<String> images;

  const _PetListItem({
    required this.petId,
    required this.name,
    required this.breed,
    required this.age,
    required this.images,
  });

  @override
  State<_PetListItem> createState() => _PetListItemState();
}

class _PetListItemState extends State<_PetListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _animationController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: _handleTapDown,
            onTapUp: _handleTapUp,
            onTapCancel: _handleTapCancel,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PetDetailsScreen(
                    petId: widget.petId,
                    petName: widget.name,
                  ),
                ),
              );
            },
            child: Container(
              margin: EdgeInsets.only(bottom: 16.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.r),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primaryWhite,
                    AppColors.primaryWhite.withOpacity(0.8),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryPink.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: AppColors.primaryBlue.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                    spreadRadius: 0,
                  ),
                ],
                border: Border.all(
                  color: _isPressed
                      ? AppColors.primaryPink.withOpacity(0.3)
                      : AppColors.backgroundLight.withOpacity(0.5),
                  width: 1.5,
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: Row(
                  children: [
                    // Pet Image with Hero Animation
                    Hero(
                      tag: 'pet-${widget.petId}',
                      child: Container(
                        width: 80.w,
                        height: 80.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16.r),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.primaryPink.withOpacity(0.1),
                              AppColors.primaryBlue.withOpacity(0.1),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryPink.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16.r),
                          child: _buildPetImage(),
                        ),
                      ),
                    ),

                    SizedBox(width: 16.w),

                    // Pet Information
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Pet Name with Icon
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  widget.name,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primaryBlue,
                                        fontSize: 18.sp,
                                      ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.all(6.w),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryPink.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Icon(
                                  Icons.pets,
                                  color: AppColors.primaryPink,
                                  size: 16.w,
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 8.h),

                          // Breed with chip design
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.backgroundLight,
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color: AppColors.primaryBlue.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              widget.breed,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: AppColors.primaryBlue,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12.sp,
                                  ),
                            ),
                          ),

                          SizedBox(height: 8.h),

                          // Age with calendar icon
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                color: AppColors.textLight,
                                size: 14.w,
                              ),
                              SizedBox(width: 6.w),
                              Text(
                                _getAgeText(),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: AppColors.textSecondary,
                                      fontSize: 12.sp,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Arrow with animated container
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: _isPressed
                            ? AppColors.primaryPink.withOpacity(0.1)
                            : AppColors.backgroundLight.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        Icons.arrow_forward_ios,
                        color: _isPressed
                            ? AppColors.primaryPink
                            : AppColors.textLight,
                        size: 16.w,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPetImage() {
    if (widget.images.isEmpty) {
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
        child: Icon(
          Icons.pets,
          color: AppColors.primaryWhite,
          size: 32.w,
        ),
      );
    }

    final imageUrl = widget.images.first;

    // Check if it's a network URL or local path
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        width: 80.w,
        height: 80.h,
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
            child: SizedBox(
              width: 20.w,
              height: 20.h,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryPink),
              ),
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
          child: Icon(
            Icons.broken_image,
            color: AppColors.primaryWhite,
            size: 24.w,
          ),
        ),
      );
    } else {
      // Local file - in a real app you might want to handle this differently
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.photo,
              color: AppColors.primaryWhite,
              size: 20.w,
            ),
            SizedBox(height: 4.h),
            Text(
              'Local',
              style: TextStyle(
                color: AppColors.primaryWhite,
                fontSize: 8.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }
  }

  String _getAgeText() {
    if (widget.age < 12) {
      return '${widget.age} month${widget.age == 1 ? '' : 's'} old';
    } else {
      final years = (widget.age / 12).floor();
      final months = widget.age % 12;

      if (months == 0) {
        return '$years year${years == 1 ? '' : 's'} old';
      } else {
        return '$years year${years == 1 ? '' : 's'}, $months month${months == 1 ? '' : 's'} old';
      }
    }
  }
}
