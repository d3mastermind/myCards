import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:mycards/features/auth/presentation/email_login/email_login_view.dart';
import 'package:mycards/features/auth/presentation/phone_signup/phone_signup_view.dart';
import 'package:mycards/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mycards/features/auth/presentation/phone_login/phone_login_vm.dart';

class PhoneLoginView extends ConsumerStatefulWidget {
  const PhoneLoginView({super.key});

  @override
  ConsumerState<PhoneLoginView> createState() => _PhoneLoginViewState();
}

class _PhoneLoginViewState extends ConsumerState<PhoneLoginView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool obscureText = true;
  bool obscureText2 = true;
  String password = "";
  String confirmPassword = "";
  String phoneNumber = "";
  PhoneNumber initialPhoneNumber = PhoneNumber(isoCode: 'US');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.listen<PhoneLoginState>(phoneLoginVMProvider, (previous, next) {
        if (next.isSuccess) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const MyApp(),
            ),
          );
        }
      });
    });
  }

  void _handlePhoneLogin() {
    if (_formKey.currentState!.validate()) {
      ref
          .read(phoneLoginVMProvider.notifier)
          .loginWithPhone(phoneNumber, context);
    }
  }

  void _handleGoogleLogin() {
    ref.read(phoneLoginVMProvider.notifier).signInWithGoogle(context);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(phoneLoginVMProvider);
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
                    "LOG IN",
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
                                  log(phoneNumber);
                                },
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 20,
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
                          onPressed: state.isLoading ? null : _handlePhoneLogin,
                          style: ButtonStyle(
                            backgroundColor: WidgetStatePropertyAll(
                              const Color.fromARGB(255, 255, 215, 0),
                            ),
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
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  "Log In",
                                  style:
                                      Theme.of(context).textTheme.displaySmall,
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
                  GestureDetector(
                    onTap: state.isGoogleLoading ? null : _handleGoogleLogin,
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
                                child:
                                    CircularProgressIndicator(strokeWidth: 2))
                          else
                            Image.asset(
                              "assets/icon/google.png",
                              height: 40,
                            ),
                          Text(
                            state.isGoogleLoading
                                ? "Signing in..."
                                : "Log in With Google",
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
                          builder: (context) => EmailLoginView(),
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
                            "assets/icon/email.png",
                            height: 40,
                          ),
                          Text(
                            "Log In With Email",
                            style: Theme.of(context).textTheme.bodyLarge,
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
                      Text(
                        "Dont have an account?",
                        style: Theme.of(context).textTheme.titleLarge,
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
                          child: Text(
                            "Sign Up",
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
    );
  }
}
