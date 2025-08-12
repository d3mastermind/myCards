import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:mycards/features/auth/presentation/email_login/email_login_vm.dart';
import 'package:mycards/features/auth/presentation/forgot_password/forgot_password_view.dart';
import 'package:mycards/features/auth/presentation/phone_login/phone_login_view.dart';
import 'package:mycards/features/auth/presentation/phone_signup/phone_signup_view.dart';
import 'package:mycards/screens/bottom_navbar_controller.dart';
import 'package:mycards/core/utils/logger.dart';

class EmailLoginView extends ConsumerStatefulWidget {
  const EmailLoginView({super.key});

  @override
  ConsumerState<EmailLoginView> createState() => _EmailLoginViewState();
}

class _EmailLoginViewState extends ConsumerState<EmailLoginView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool obscureText = true;
  String password = "";
  String email = "";

  @override
  void initState() {
    super.initState();
  }

  void _handleLogin() {
    AppLogger.log('EmailLoginView: User initiated email login',
        tag: 'EmailLoginView');
    if (_formKey.currentState!.validate()) {
      AppLogger.log(
          'EmailLoginView: Form validation passed, proceeding with login',
          tag: 'EmailLoginView');
      ref.read(emailLoginVMProvider.notifier).login(email, password);
    } else {
      AppLogger.logWarning('EmailLoginView: Form validation failed',
          tag: 'EmailLoginView');
    }
  }

  void _handleGoogleSignIn() {
    AppLogger.log('EmailLoginView: User initiated Google sign-in',
        tag: 'EmailLoginView');
    ref.read(emailLoginVMProvider.notifier).signInWithGoogle();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(emailLoginVMProvider);

    // Listen to state changes and navigate on success
    ref.listen<EmailLoginState>(emailLoginVMProvider, (previous, next) {
      if (next.isSuccess) {
        AppLogger.logSuccess(
            'EmailLoginView: Login successful, navigating to home screen',
            tag: 'EmailLoginView');
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => ScreenController()),
          (route) => false,
        );
        // Clear success state after navigation
        ref.read(emailLoginVMProvider.notifier).clearSuccess();
      } else if (next.isError && next.errorMessage.isNotEmpty) {
        AppLogger.logError('EmailLoginView: Login failed: ${next.errorMessage}',
            tag: 'EmailLoginView');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage)),
        );
        ref.read(emailLoginVMProvider.notifier).clearError();
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    // Logo with enhanced styling
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        child: SizedBox(
                          height: 50,
                          child: Image.asset("assets/images/logo.png"),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Title with better typography
                    Center(
                      child: Text(
                        "Welcome Back",
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium!
                            .copyWith(
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1A1A1A),
                            ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        "Sign in to your account",
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ),
                    const SizedBox(height: 40),
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
                          const SizedBox(height: 8),
                          // Forgot password
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ForgotPasswordView(),
                                  ),
                                  (route) => false,
                                );
                              },
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 4, vertical: 8),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                "Forgot Password?",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(
                                      color: const Color(0xFF6C63FF),
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Login button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: state.isLoading ? null : _handleLogin,
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
                                child: LoadingIndicator(
                                  indicatorType: Indicator.lineSpinFadeLoader,
                                  colors: [
                                    Colors.white,
                                    Colors.white70,
                                    Colors.white60,
                                    Colors.white54
                                  ],
                                ),
                              )
                            : Text(
                                "Sign In",
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
                        // Google login button
                        GestureDetector(
                          onTap: state.isGoogleLoading
                              ? null
                              : _handleGoogleSignIn,
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
                                    child: LoadingIndicator(
                                      indicatorType:
                                          Indicator.lineSpinFadeLoader,
                                      colors: [
                                        Colors.grey,
                                        Colors.grey,
                                        Colors.grey,
                                        Colors.grey
                                      ],
                                    ),
                                  )
                                else
                                  Image.asset(
                                    "assets/icon/google.png",
                                    height: 24,
                                  ),
                                const SizedBox(width: 12),
                                Text(
                                  state.isGoogleLoading
                                      ? "Signing in..."
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
                        // Phone login button
                        GestureDetector(
                          onTap: () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PhoneLoginView(),
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
                    // Signup link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
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
                                builder: (context) => PhoneSignUpView(),
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
                            "Sign Up",
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
