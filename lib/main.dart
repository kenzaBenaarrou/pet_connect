import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pet_con/core/theme/app_theme.dart';
import 'package:pet_con/firebase_options.dart';
import 'package:pet_con/presentation/auth/auth_wrapper.dart';
import 'package:pet_con/data/services/firebase_service.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase FIRST
  await _initializeFirebase();

  // Initialize Firebase Service AFTER Firebase is initialized
  await FirebaseService.initialize();

  runApp(
    const ProviderScope(
      child: PetConnectApp(),
    ),
  );
}

Future<void> _initializeFirebase() async {
  try {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    log('✅ Firebase initialized successfully');

    // Initialize App Check AFTER Firebase
    await FirebaseAppCheck.instance.activate(
      // Use debug providers in debug mode, production providers in release mode
      androidProvider:
          kDebugMode ? AndroidProvider.debug : AndroidProvider.playIntegrity,
      appleProvider: kDebugMode ? AppleProvider.debug : AppleProvider.appAttest,
    );
    log('✅ Firebase App Check initialized');
  } on FirebaseException catch (e) {
    if (e.code == 'duplicate-app') {
      log('⚠️ Firebase already initialized, using existing instance');
      Firebase.app();
    } else {
      log('❌ Firebase error: ${e.code} - ${e.message}');
      rethrow;
    }
  } catch (e) {
    log('❌ Initialization error: $e');
    rethrow;
  }
}

class PetConnectApp extends StatelessWidget {
  const PetConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812), // iPhone 12 Pro design size
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'PetConnect',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system,
          home: const AuthWrapper(),
        );
      },
    );
  }
}
