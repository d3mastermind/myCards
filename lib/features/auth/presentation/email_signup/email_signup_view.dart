import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
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
          SnackBar(content: Text(next.errorMessage)),
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
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // SizedBox(
                    //   height: 50,
                    // ),
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
                                fillColor: Colors.grey.withAlpha(50),
                                suffixIcon: Icon(Icons.email_outlined),
                                //labelText: "Email",
                                hintText: "example@gmail.com",
                                border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
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
                                fillColor: Colors.grey.withAlpha(50),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    obscureText
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                  ),
                                  onPressed: () {
                                    log("eye pressed");
                                    setState(() {
                                      obscureText = !obscureText;
                                    });
                                  },
                                ),
                                labelText: "Password",
                                border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
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
                              obscureText: obscureText,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.grey.withAlpha(50),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    obscureText2
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                  ),
                                  onPressed: () {
                                    log("eye pressed");
                                    setState(() {
                                      obscureText2 = !obscureText2;
                                    });
                                  },
                                ),
                                labelText: "Confirm Password",
                                border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.circular(20),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 250,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: state.isLoading ? null : _handleSignUp,
                            style: ButtonStyle(
                              backgroundColor:
                                  WidgetStatePropertyAll(Colors.deepOrange),
                              shape: WidgetStatePropertyAll(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                            child: state.isLoading
                                ? SizedBox(
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
                                        .displaySmall!
                                        .copyWith(color: Colors.white),
                                  ),
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Center(
                      child: SizedBox(
                        height: 20,
                        child: Stack(
                          children: [
                            Align(
                              child: Divider(),
                            ),
                            Align(
                              alignment: Alignment.center,
                              child: Container(
                                alignment: Alignment.center,
                                width: 100,
                                height: 20,
                                color: Colors.white,
                                child: Text(
                                  "OR",
                                  style: TextStyle(
                                    fontSize: 20,
                                    backgroundColor: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Column(
                      children: [
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
                              spacing: 10,
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
                                    height: 40,
                                  ),
                                Text(
                                  state.isGoogleLoading
                                      ? "Signing in..."
                                      : "Sign Up With Google",
                                  style: Theme.of(context).textTheme.bodyLarge,
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
                                builder: (context) => PhoneSignUpView(),
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
                              spacing: 10,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  "assets/icon/phone.png",
                                  height: 40,
                                ),
                                Text(
                                  "Sign Up With Phone Number",
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Already Have and account?",
                          style: Theme.of(context).textTheme.titleLarge,
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
                            child: Text(
                              "Log In",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge!
                                  .copyWith(
                                    color: Color.fromARGB(255, 255, 215, 0),
                                  ),
                            ))
                      ],
                    )
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
