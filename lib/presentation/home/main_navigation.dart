import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pet_con/core/constants/app_constants.dart';
import 'package:pet_con/presentation/home/home_screen.dart';
import 'package:pet_con/presentation/matches/matches_screen.dart';
import 'package:pet_con/presentation/chat/chat_list_screen.dart';
import 'package:pet_con/presentation/profile/profile_screen.dart';

final currentTabProvider = StateProvider<int>((ref) => 0);

class MainNavigation extends ConsumerWidget {
  const MainNavigation({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTab = ref.watch(currentTabProvider);

    final screens = [
      const HomeScreen(),
      const MatchesScreen(),
      const ChatListScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: currentTab,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.primaryWhite,
          boxShadow: [
            BoxShadow(
              color: AppColors.textLight,
              blurRadius: 8,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            height: AppDimensions.bottomNavHeight.h,
            child: BottomNavigationBar(
              currentIndex: currentTab,
              onTap: (index) =>
                  ref.read(currentTabProvider.notifier).state = index,
              type: BottomNavigationBarType.fixed,
              backgroundColor: AppColors.primaryWhite,
              selectedItemColor: AppColors.primaryBlue,
              unselectedItemColor: AppColors.textLight,
              elevation: 0,
              selectedLabelStyle: TextStyle(
                fontFamily: AppFonts.fontFamily,
                fontWeight: FontWeight.w600,
                fontSize: AppFonts.sizeXS.sp,
              ),
              unselectedLabelStyle: TextStyle(
                fontFamily: AppFonts.fontFamily,
                fontWeight: FontWeight.w500,
                fontSize: AppFonts.sizeXS.sp,
              ),
              items: [
                BottomNavigationBarItem(
                  icon: Icon(
                    currentTab == 0 ? Icons.home : Icons.home_outlined,
                    size: 24.w,
                  ),
                  label: AppStrings.home,
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    currentTab == 1 ? Icons.favorite : Icons.favorite_outline,
                    size: 24.w,
                  ),
                  label: AppStrings.matches,
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    currentTab == 2 ? Icons.chat : Icons.chat_outlined,
                    size: 24.w,
                  ),
                  label: AppStrings.chat,
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    currentTab == 3 ? Icons.person : Icons.person_outline,
                    size: 24.w,
                  ),
                  label: AppStrings.profile,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
