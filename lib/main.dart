import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mycards/core/utils/storage_bucket.dart';
import 'package:mycards/features/auth/presentation/verify_email/email_verify_view.dart';
import 'package:mycards/features/auth/presentation/phone_login/phone_login_view.dart';
import 'package:mycards/screens/bottom_navbar_controller.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:mycards/features/home/services/auth_service.dart';
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
          if (snapshot.connectionState == ConnectionState.active) {
            if (snapshot.hasData) {
              final user = snapshot.data!;
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
              return const PhoneLoginView();
            }
          }
          // Show a loading indicator while waiting for the stream
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
