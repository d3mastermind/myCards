import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:mycards/features/auth/presentation/phone_signup/phone_signup_vm.dart';
import 'package:mycards/features/auth/presentation/email_signup/email_signup_view.dart';
import 'package:mycards/features/auth/presentation/phone_login/phone_login_view.dart';
import 'package:mycards/features/auth/presentation/verify_otp/otp_verification_view.dart';
import 'dart:developer' as developer;
import 'package:mycards/core/utils/logger.dart';
import 'package:mycards/widgets/loading_indicators/circular_loading_widget.dart';
import 'package:mycards/screens/bottom_navbar_controller.dart';

class PhoneSignUpView extends ConsumerStatefulWidget {
  const PhoneSignUpView({super.key});

  @override
  ConsumerState<PhoneSignUpView> createState() => _PhoneSignUpViewState();
}

class _PhoneSignUpViewState extends ConsumerState<PhoneSignUpView> {
  final _formKey = GlobalKey<FormState>();
  String phoneNumber = "";
  PhoneNumber initialPhoneNumber = PhoneNumber(isoCode: 'US');

  @override
  void initState() {
    super.initState();
  }

  void _handlePhoneSignUp() {
    AppLogger.log('PhoneSignUpView: User initiated phone signup',
        tag: 'PhoneSignUpView');
    if (_formKey.currentState!.validate()) {
      AppLogger.log(
          'PhoneSignUpView: Form validation passed, proceeding with signup',
          tag: 'PhoneSignUpView');
      ref
          .read(phoneSignUpVMProvider.notifier)
          .signUpWithPhone(phoneNumber, context);
    } else {
      AppLogger.logWarning('PhoneSignUpView: Form validation failed',
          tag: 'PhoneSignUpView');
    }
  }

  void _handleGoogleSignUp() {
    ref.read(phoneSignUpVMProvider.notifier).signUpWithGoogle(context);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(phoneSignUpVMProvider);

    // Listen to state changes in build method
    ref.listen<PhoneSignUpState>(phoneSignUpVMProvider, (previous, next) {
      if (next.isSuccess &&
          next.verificationId != null &&
          next.phoneNumber != null) {
        AppLogger.logSuccess(
            'PhoneSignUpView: Navigating to OTP verification screen',
            tag: 'PhoneSignUpView');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OtpVerificationScreen(
              firebaseOtp: next.verificationId!,
              phoneNumber: next.phoneNumber!,
            ),
          ),
        );
        // Clear success state after navigation
        ref.read(phoneSignUpVMProvider.notifier).clearSuccess();
      } else if (next.isGoogleSuccess) {
        AppLogger.logSuccess(
            'PhoneSignUpView: Google signup successful, navigating to home',
            tag: 'PhoneSignUpView');
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const ScreenController()),
          (route) => false,
        );
        ref.read(phoneSignUpVMProvider.notifier).clearSuccess();
      }
    });

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFF8F9FA),
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
                    const SizedBox(height: 32),
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
                      "Sign up with your phone number",
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                    const SizedBox(height: 40),
                    // Phone input in a card
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
                          Text(
                            "Phone Number",
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium!
                                .copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF1A1A1A),
                                ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8F9FA),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.grey[300]!,
                                width: 1,
                              ),
                            ),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: InternationalPhoneNumberInput(
                                initialValue: initialPhoneNumber,
                                inputDecoration: const InputDecoration(
                                  contentPadding:
                                      EdgeInsets.symmetric(vertical: 16),
                                  hintText: "Enter your phone number",
                                  border: InputBorder.none,
                                ),
                                selectorConfig: const SelectorConfig(
                                  selectorType:
                                      PhoneInputSelectorType.BOTTOM_SHEET,
                                  setSelectorButtonAsPrefixIcon: true,
                                  leadingPadding: 8,
                                ),
                                onInputChanged: (PhoneNumber number) {
                                  setState(() {
                                    phoneNumber = number.phoneNumber!;
                                  });
                                  developer.log(phoneNumber);
                                },
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
                        onPressed: state.isLoading ? null : _handlePhoneSignUp,
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
                    // Social signup buttons
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
                        // Email signup button
                        GestureDetector(
                          onTap: () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EmailSignUpView(),
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
                                  "assets/icon/email.png",
                                  height: 24,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  "Continue with Email",
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
