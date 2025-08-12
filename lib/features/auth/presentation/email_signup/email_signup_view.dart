import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:mycards/features/auth/presentation/verify_email/email_verify_view.dart';
import 'package:mycards/features/auth/presentation/phone_login/phone_login_view.dart';
import 'package:mycards/features/auth/presentation/phone_signup/phone_signup_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mycards/features/auth/presentation/email_signup/email_signup_vm.dart';
import 'package:mycards/core/utils/logger.dart';
import 'package:mycards/widgets/loading_indicators/circular_loading_widget.dart';
import 'package:mycards/screens/bottom_navbar_controller.dart';

class EmailSignUpView extends ConsumerStatefulWidget {
  const EmailSignUpView({super.key});

  @override
  ConsumerState<EmailSignUpView> createState() => _EmailSignUpViewState();
}

class _EmailSignUpViewState extends ConsumerState<EmailSignUpView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool obscureText = true;
  bool obscureText2 = true;
  String password = "";
  String confirmPassword = "";
  String email = "";

  @override
  void initState() {
    super.initState();
  }

  void _handleSignUp() {
    AppLogger.log('EmailSignUpView: User initiated email signup',
        tag: 'EmailSignUpView');
    if (_formKey.currentState!.validate()) {
      AppLogger.log(
          'EmailSignUpView: Form validation passed, proceeding with signup',
          tag: 'EmailSignUpView');
      ref.read(emailSignUpVMProvider.notifier).signUp(email, password);
    } else {
      AppLogger.logWarning('EmailSignUpView: Form validation failed',
          tag: 'EmailSignUpView');
    }
  }

  void _handleGoogleSignUp() {
    AppLogger.log('EmailSignUpView: User initiated Google signup',
        tag: 'EmailSignUpView');
    ref.read(emailSignUpVMProvider.notifier).signUpWithGoogle();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(emailSignUpVMProvider);

    // Listen to state changes in build method
    ref.listen<EmailSignUpState>(emailSignUpVMProvider, (previous, next) {
      if (next.isSuccess) {
        AppLogger.logSuccess(
            'EmailSignUpView: Signup successful, navigating to email verification',
            tag: 'EmailSignUpView');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const EmailVerifyView(),
          ),
        );
        // Clear success state after navigation
        ref.read(emailSignUpVMProvider.notifier).clearSuccess();
      } else if (next.isGoogleSuccess) {
        AppLogger.logSuccess(
            'EmailSignUpView: Google signup successful, navigating to home',
            tag: 'EmailSignUpView');
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const ScreenController()),
          (route) => false,
        );
        ref.read(emailSignUpVMProvider.notifier).clearSuccess();
      } else if (next.isError && next.errorMessage.isNotEmpty) {
        AppLogger.logError(
            'EmailSignUpView: Signup failed: ${next.errorMessage}',
            tag: 'EmailSignUpView');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        ref.read(emailSignUpVMProvider.notifier).clearError();
      }
    });
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    // Logo with enhanced styling
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: SizedBox(
                        height: 50,
                        child: Image.asset("assets/images/logo.png"),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Title with better typography
                    Text(
                      "Create Account",
                      style:
                          Theme.of(context).textTheme.headlineMedium!.copyWith(
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1A1A1A),
                              ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Sign up to get started",
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                    const SizedBox(height: 24),
                    // Form fields in a card
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Email field
                          TextFormField(
                            keyboardType: TextInputType.emailAddress,
                            onChanged: (value) => email = value,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Please enter a valid Email.";
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: const Color(0xFFF8F9FA),
                              prefixIcon: Icon(
                                Icons.email_outlined,
                                color: Colors.grey[600],
                              ),
                              hintText: "Enter your email",
                              hintStyle: TextStyle(color: Colors.grey[500]),
                              border: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Color(0xFF6C63FF),
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Password field
                          TextFormField(
                            keyboardType: TextInputType.visiblePassword,
                            onChanged: (value) => password = value,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Please enter a valid password.";
                              }
                              return null;
                            },
                            obscureText: obscureText,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: const Color(0xFFF8F9FA),
                              prefixIcon: Icon(
                                Icons.lock_outline,
                                color: Colors.grey[600],
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  obscureText
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: Colors.grey[600],
                                ),
                                onPressed: () {
                                  log("eye pressed");
                                  setState(() {
                                    obscureText = !obscureText;
                                  });
                                },
                              ),
                              hintText: "Enter your password",
                              hintStyle: TextStyle(color: Colors.grey[500]),
                              border: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Color(0xFF6C63FF),
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Confirm password field
                          TextFormField(
                            onChanged: (value) => confirmPassword = value,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Please confirm your password.";
                              }
                              if (value != password) {
                                return "Passwords do not match.";
                              }
                              return null;
                            },
                            obscureText: obscureText2,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: const Color(0xFFF8F9FA),
                              prefixIcon: Icon(
                                Icons.lock_outline,
                                color: Colors.grey[600],
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  obscureText2
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: Colors.grey[600],
                                ),
                                onPressed: () {
                                  log("eye pressed");
                                  setState(() {
                                    obscureText2 = !obscureText2;
                                  });
                                },
                              ),
                              hintText: "Confirm your password",
                              hintStyle: TextStyle(color: Colors.grey[500]),
                              border: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Color(0xFF6C63FF),
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Sign up button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: state.isLoading ? null : _handleSignUp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                          shadowColor: Colors.transparent,
                        ),
                        child: state.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularLoadingWidget(),
                              )
                            : Text(
                                "Create Account",
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium!
                                    .copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Divider
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 1,
                            color: Colors.grey[300],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            "or continue with",
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: 1,
                            color: Colors.grey[300],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Social login buttons
                    Column(
                      children: [
                        // Google signup button
                        GestureDetector(
                          onTap: state.isGoogleLoading
                              ? null
                              : _handleGoogleSignUp,
                          child: Container(
                            width: double.infinity,
                            height: 56,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.grey[300]!,
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (state.isGoogleLoading)
                                  const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularLoadingWidget(),
                                  )
                                else
                                  Image.asset(
                                    "assets/icon/google.png",
                                    height: 24,
                                  ),
                                const SizedBox(width: 12),
                                Text(
                                  state.isGoogleLoading
                                      ? "Signing up..."
                                      : "Continue with Google",
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium!
                                      .copyWith(
                                        color: const Color(0xFF1A1A1A),
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Phone signup button
                        GestureDetector(
                          onTap: () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PhoneSignUpView(),
                              ),
                              (route) => false,
                            );
                          },
                          child: Container(
                            width: double.infinity,
                            height: 56,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.grey[300]!,
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  "assets/icon/phone.png",
                                  height: 24,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  "Continue with Phone",
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium!
                                      .copyWith(
                                        color: const Color(0xFF1A1A1A),
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Login link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Already have an account? ",
                          style:
                              Theme.of(context).textTheme.bodyMedium!.copyWith(
                                    color: Colors.grey[600],
                                  ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PhoneLoginView(),
                              ),
                              (route) => false,
                            );
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            "Sign In",
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                  color: const Color(0xFF6C63FF),
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
