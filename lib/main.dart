import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:mycards/core/utils/storage_bucket.dart';
import 'package:mycards/features/auth/presentation/verify_email/email_verify_view.dart';
import 'package:mycards/features/auth/presentation/phone_login/phone_login_view.dart';
import 'package:mycards/screens/bottom_navbar_controller.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:mycards/features/home/services/auth_service.dart';
import 'package:mycards/features/app_user/app_user_provider.dart';
import 'package:mycards/core/utils/logger.dart';
// import 'package:mycards/utils/populate_templates.dart'; // Uncomment to populate templates

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Hive.initFlutter();
  await Hive.openBox(localCacheBox);

  // Configure global image cache settings
  PaintingBinding.instance.imageCache.maximumSize =
      1000; // Increase memory cache
  PaintingBinding.instance.imageCache.maximumSizeBytes =
      100 << 20; // 100MB cache

  // FIRST TIME SETUP: Uncomment the line below to populate Firestore with initial template data
  //await TemplatePopulator.populateTemplates();

  // Initialize app user service singleton
  try {
    final appUserService = AppUserService.instance;
    AppLogger.log('AppUserService singleton initialized in main', tag: 'Main');
  } catch (e) {
    AppLogger.logError('Error initializing AppUserService singleton: $e',
        tag: 'Main');
  }

  runApp(
    ProviderScope(
      child: const MyApp(),
    ),
  );

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812), // iPhone X design size
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            fontFamily: 'Roboto',
            textTheme: const TextTheme(
                // ... (existing text theme styles)
                ),
          ),
          home: StreamBuilder(
            stream: AuthService().authStateChanges,
            builder: (context, snapshot) {
              AppLogger.log('MyApp: Auth state - ${snapshot.connectionState}',
                  tag: 'MyApp');

              if (snapshot.connectionState == ConnectionState.active) {
                if (snapshot.hasData) {
                  final user = snapshot.data!;
                  AppLogger.log('MyApp: User authenticated - ${user.uid}',
                      tag: 'MyApp');
                  if (user.emailVerified) {
                    return const ScreenController();
                  } else if (user.providerData
                      .any((provider) => provider.providerId == 'phone')) {
                    return const ScreenController();
                  } else {
                    return const EmailVerifyView();
                  }
                } else {
                  // No user is signed in
                  AppLogger.log('MyApp: No user signed in', tag: 'MyApp');
                  return const PhoneLoginView();
                }
              }
              // Show a loading indicator while waiting for the stream
              AppLogger.log('MyApp: Auth loading...', tag: 'MyApp');
              return const Center(
                  child: LoadingIndicator(
                indicatorType: Indicator.ballGridBeat,
                //backgroundColor: Colors.white,
                colors: [Colors.red, Colors.orange, Colors.redAccent, Colors.orangeAccent],
              ));
            },
          ),
        );
      },
    );
  }
}
