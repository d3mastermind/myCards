import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:loading_indicator/loading_indicator.dart';
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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 50,
                    child: Image.asset("assets/images/logo.png"),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Text(
                    "SIGN UP",
                    style: Theme.of(context).textTheme.displaySmall!.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 40, 0, 0),
                    child: SizedBox(
                      //height: 200,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            //height: 50,
                            decoration: BoxDecoration(
                                color: Colors.grey.withAlpha(60),
                                borderRadius: BorderRadius.circular(20)),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: InternationalPhoneNumberInput(
                                initialValue: initialPhoneNumber,
                                inputDecoration: InputDecoration(
                                  contentPadding:
                                      EdgeInsets.fromLTRB(0, 0, 0, 15),
                                  hintText: "Phone number",
                                  border: InputBorder.none,
                                ),
                                selectorConfig: const SelectorConfig(
                                  selectorType: PhoneInputSelectorType
                                      .BOTTOM_SHEET, // Dropdown or bottom sheet
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
                          SizedBox(
                            height: 20,
                          ),
                          Container(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed:
                                  state.isLoading ? null : _handlePhoneSignUp,
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Color.fromARGB(255, 255, 215, 0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: state.isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: LoadingIndicator(
                                        indicatorType:
                                            Indicator.lineSpinFadeLoader,
                                        colors: [
                                          Colors.red,
                                          Colors.orange,
                                          Colors.redAccent,
                                          Colors.orangeAccent
                                        ],
                                        //backgroundColor: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      "Sign Up",
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge!
                                          .copyWith(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 1,
                                  color: Colors.grey.withAlpha(100),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  "OR",
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium!
                                      .copyWith(
                                        color: Colors.grey,
                                      ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  height: 1,
                                  color: Colors.grey.withAlpha(100),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          GestureDetector(
                            onTap: state.isGoogleLoading
                                ? null
                                : _handleGoogleSignUp,
                            child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: Colors.grey.withAlpha(60)),
                              height: 50,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(width: 10),
                                  if (state.isGoogleLoading)
                                    const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularLoadingWidget(),
                                    )
                                  else
                                    Image.asset(
                                      "assets/icon/google.png",
                                      height: 40,
                                    ),
                                  SizedBox(width: 10),
                                  Text(
                                    state.isGoogleLoading
                                        ? "Signing in..."
                                        : "Sign Up With Google",
                                    style:
                                        Theme.of(context).textTheme.bodyLarge,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
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
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: Colors.grey.withAlpha(60)),
                              height: 50,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(width: 10),
                                  Image.asset(
                                    "assets/icon/email.png",
                                    height: 40,
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    "Sign Up With Email",
                                    style:
                                        Theme.of(context).textTheme.bodyLarge,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            "Already have an account?",
                            style: Theme.of(context).textTheme.titleMedium,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(width: 4),
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
                            child: Text(
                              "Log In",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .copyWith(
                                    color: Color.fromARGB(255, 255, 215, 0),
                                    fontWeight: FontWeight.bold,
                                  ),
                            ))
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
