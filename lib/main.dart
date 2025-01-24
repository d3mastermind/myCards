import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mycards/auth/auth_screens/forgot_password_view.dart';
import 'package:mycards/auth/auth_screens/phone_login_view.dart';
import 'package:mycards/screens/bottom_navbar_screens/home_screen.dart';
import 'package:mycards/screens/card_screens/card_page_view.dart';
import 'package:mycards/screens/pre_edit_card_screens/pre_edit_card_preview_page.dart';
import 'package:mycards/screens/pre_edit_card_screens/pre_edit_card_page_view.dart';
import 'package:mycards/screens/bottom_navbar_controller.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:mycards/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
          if (snapshot.hasData) {
            final user = snapshot.data!;
            if (user.emailVerified) {
              return const ScreenController();
            } else {
              // Check if the user signed in with a phone number
              if (user.providerData
                  .any((provider) => provider.providerId == 'phone')) {
                // Redirect to the phone login view
                return const ScreenController();
              } else {
                // Redirect to the forgot password view
                return const ForgotPasswordView();
              }
            }
          } else {
            return const PhoneLoginView();
          }
        },
      ),
    );
  }
}
