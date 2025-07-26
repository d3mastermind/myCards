import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mycards/features/auth/presentation/email_login/email_login_vm.dart';
import 'package:mycards/features/auth/presentation/forgot_password/forgot_password_view.dart';
import 'package:mycards/features/auth/presentation/phone_login/phone_login_view.dart';
import 'package:mycards/features/auth/presentation/phone_signup/phone_signup_view.dart';
import 'package:mycards/main.dart';

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
    // Listen to state changes and navigate on success
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.listen<EmailLoginState>(emailLoginVMProvider, (previous, next) {
        if (next.isSuccess) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const MyApp()),
            (route) => false,
          );
        }
      });
    });
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      ref.read(emailLoginVMProvider.notifier).login(email, password);
    }
  }

  void _handleGoogleSignIn() {
    ref.read(emailLoginVMProvider.notifier).signInWithGoogle();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(emailLoginVMProvider);

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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: SizedBox(
                        height: 50,
                        child: Image.asset("assets/images/logo.png"),
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Center(
                      child: Text(
                        "LOG IN",
                        style:
                            Theme.of(context).textTheme.displaySmall!.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 40, 0, 0),
                      child: SizedBox(
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
                            TextButton(
                              onPressed: () {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ForgotPasswordView(),
                                  ),
                                  (route) => false,
                                );
                              },
                              child: Text(
                                " Forgot Password?",
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium!
                                    .copyWith(color: Colors.deepOrange),
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
                            onPressed: state.isLoading ? null : _handleLogin,
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
                                    style: Theme.of(context)
                                        .textTheme
                                        .displaySmall,
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
                              : _handleGoogleSignIn,
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
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
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
                                builder: (context) => PhoneLoginView(),
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
                                  "Log in With Phone Number",
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
                          "Don't Have an account?",
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
                                    color: Colors.deepOrange,
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
